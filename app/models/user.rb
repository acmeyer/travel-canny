class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_one :shipping_address, as: :addressable, dependent: :destroy, class_name: 'Address'
  has_many :sims, dependent: :destroy
  has_many :shipments, through: :sims
  has_many :trips, dependent: :destroy
  has_one :stripe_customer, as: :billable, dependent: :destroy, class_name: 'StripeCustomer'
  has_many :auth_tokens
  has_one :data_plan, dependent: :destroy
  has_many :data_usage_records, dependent: :destroy

  before_validation :strip_name

  after_create :make_billable, :create_sim, :create_shipment, :add_data_plan, :add_to_marketing_email_list
  # needed because sidekiq could receive before the record finishes being added to the DB
  after_commit :send_welcome_email, on: :create

  after_save :expire_tokens, if: Proc.new { |user| user.saved_change_to_encrypted_password? }
  after_save :update_stripe_shipping_address, if: Proc.new { |user| !user.shipping_address.blank? && user.shipping_address.changed?}

  before_destroy :remove_from_email_lists

  include PgSearch
  pg_search_scope :search_users, :against => [:first_name, :last_name, :email]

  accepts_nested_attributes_for :shipping_address, allow_destroy: true
  accepts_nested_attributes_for :stripe_customer

  def name
    self.first_name + ' ' + self.last_name unless self.first_name.blank?
  end

  def admin?
    self.admin
  end

  def send_data_warning_sms_notification
    if has_payment_source
      notification_message = I18n.t('sms.notification.data_warning_message_top_up', amount_remaining: self.data_plan.amount_remaining_mb.round)
    else
      notification_message = I18n.t('sms.notification.data_warning_message_add_payment', amount_remaining: self.data_plan.amount_remaining_mb.round, add_payment_url: self.add_payment_url)
    end

    SendNotificationSmsWorker.perform_async(self.id, self.primary_sim.id, notification_message, 'data_warning')
  end

  def send_data_limit_exceeded_sms_notification
    if has_payment_source
      notification_message = I18n.t('sms.notification.data_limit_exceeded_message_top_up')
    else
      notification_message = I18n.t('sms.notification.data_limit_exceeded_message_add_payment', add_payment_url: self.add_payment_url)
    end

    SendNotificationSmsWorker.perform_async(self.id, self.primary_sim.id, notification_message, 'data_limit_exceeded')
  end

  def disable_data
    self.primary_sim.disable_data!
  end

  def enable_data
    self.primary_sim.reenable_data!
  end

  def primary_sim
    self.sims.order(:created_at).last
  end

  def add_payment_url
    payment_url_token = generate_add_payment_token
    return "#{Rails.env.development? ? 'http' : 'https'}://#{ENV['DOMAIN_NAME']}/pay/#{payment_url_token}"
  end

  def update_stripe_shipping_address(shipping_address)
    begin
      stripe_customer = Stripe::Customer.retrieve(self.stripe_customer.stripe_id)
      stripe_customer.address.name = self.name
      stripe_customer.address.line1 = shipping_address[:street_1]
      stripe_customer.address.line2 = shipping_address[:street_2] unless shipping_address[:street_2].blank?
      stripe_customer.address.city = shipping_address[:city]
      stripe_customer.address.state = shipping_address[:state] unless shipping_address[:state].blank?
      stripe_customer.address.postal_code = shipping_address[:postal_code]
      stripe_customer.address.country = shipping_address[:country] unless shipping_address[:country].blank?
      stripe_customer.address.save
    rescue => e
      STDERR.puts("Failed to add stripe shipping address to customer: #{e}")
    end
  end

  def add_payment_source(stripe_token, billing_address)
    begin
      stripe_customer = Stripe::Customer.retrieve(self.stripe_customer.stripe_id)
      stripe_card = stripe_customer.sources.create(source: stripe_token)
      self.stripe_customer.default_source = stripe_card.id
      self.stripe_customer.save!
      card = stripe_customer.sources.retrieve(stripe_card.id)
      card.name = self.name
      card.address_line1 = billing_address[:street_1]
      card.address_line2 = billing_address[:street_2] unless billing_address[:street_2].blank?
      card.address_city = billing_address[:city]
      card.address_state = billing_address[:state] unless billing_address[:state].blank?
      card.address_zip = billing_address[:postal_code]
      card.address_country = billing_address[:country] unless billing_address[:country].blank?
      card.save
    rescue => e
      STDERR.puts("Failed to add stripe payment source: #{e}")
    end
  end

  def add_trip(countries)
    begin
      country_ids = []
      countries.each do |country_name|
        country = Country.find_by_name(country_name)
        country_ids << country.id if !country.blank?
      end
      self.trips.create!(country_ids: country_ids) if !country_ids.blank?
    rescue => e
      STDERR.puts("Failed to add user trip: #{e}, countries: #{countries}")
    end
  end

  def reset_data_notifications
    self.last_data_warning_message_sent = nil
    self.last_data_exceeded_message_sent = nil
    self.save
  end

  private
  def has_payment_source
    return !self.stripe_customer.default_source.blank?
  end

  def create_sim
    self.sims.create!(name: self.name)
  end

  def generate_add_payment_token
    begin
      self.add_payment_token = Devise.friendly_token(8)
    end while User.exists?(add_payment_token: add_payment_token)
    self.add_payment_token_expires = DateTime.now + 6.hours
    self.save!
    self.reload
    return self.add_payment_token
  end

  def create_shipment
    sim = self.sims.last
    if !sim.blank?
      shipment = sim.create_shipment!(status: 'processing')
      shipment.reload
      if !self.shipping_address.blank?
        shipment.create_address(
          street_1: self.shipping_address.street_1,
          street_2: self.shipping_address.street_2,
          city: self.shipping_address.city,
          state: self.shipping_address.state,
          country: self.shipping_address.country,
          postal_code: self.shipping_address.postal_code,
        )
      end
    end
  end

  def add_data_plan
    begin
      self.create_data_plan!
    rescue Exception
      STDERR.puts("Error while creating data plan: #{$!}")
    end
  end

  def send_welcome_email
    UserMailer.welcome_email(self.id).deliver_later
  end

  def add_to_marketing_email_list
    begin
      mailchimp = Gibbon::Request.new
      mailchimp.lists(ENV['MAILCHIMP_MARKETING_LIST_ID']).members.create(
        body: {
          email_address: self.email,
          merge_fields: {FNAME: self.first_name, LNAME: self.last_name},
          status: "subscribed"
        }
      )
    rescue Exception
      STDERR.puts("Error while adding user to Mailchimp marketing list: #{$!}")
    end
  end

  def remove_from_email_lists
    begin
      mailchimp = Gibbon::Request.new
      mailchimp.lists(ENV['MAILCHIMP_MARKETING_LIST_ID']).members(Digest::MD5.hexdigest(self.email)).update(body: { status: "unsubscribed" })
    rescue Exception
      STDERR.puts("Error while adding user to Mailchimp marketing list: #{$!}")
    end
  end

  def make_billable
    begin
      result = Stripe::Customer.create(
        description: self.name,
        email: self.email,
        shipping: {
          name: self.name,
          address: {
            line1: self.shipping_address.try(:street_1),
            line2: self.shipping_address.try(:street_2),
            city: self.shipping_address.try(:city),
            state: self.shipping_address.try(:state),
            postal_code: self.shipping_address.try(:postal_code),
            country: self.shipping_address.try(:country),
          }
        }
      )

      self.build_stripe_customer do |cust|
        cust.stripe_id = result.id
        cust.save
      end
    rescue Exception
      STDERR.puts("Error while creating a new customer at Stripe: #{$!}")
    end
  end

  def strip_name
    self.first_name.strip! if first_name?
    self.last_name.strip! if last_name?
    true
  end

  def expire_tokens
    self.auth_tokens.update_all(expires_at: DateTime.now)
  end
end
