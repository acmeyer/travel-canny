class Sim < ApplicationRecord
  belongs_to :user, touch: true
  has_one :shipment, dependent: :destroy

  phony_normalize :phone_number, default_country_code: 'US'
  validates_plausible_phone :phone_number

  enum status: [ :ready, :active, :disabled ]

  before_create :generate_uuid, :generate_activation_code 
  before_create :setup_twilio_sim, if: Proc.new { |sim| sim.sid.blank? && !Rails.env.development? }

  include PgSearch
  pg_search_scope :search_sims, :against => [:sid, :uuid, :name, :status, :phone_number]

  def self.twilio_incoming_voice_webhook_url
    return "#{Rails.env.development? ? 'http' : 'https'}://#{ENV['DOMAIN_NAME']}/webhooks/twilio/voice/incoming"
  end

  def self.twilio_outgoing_voice_webhook_url
    return "#{Rails.env.development? ? 'http' : 'https'}://#{ENV['DOMAIN_NAME']}/webhooks/twilio/voice/outgoing"
  end

  def self.twilio_incoming_sms_webhook_url
    return "#{Rails.env.development? ? 'http' : 'https'}://#{ENV['DOMAIN_NAME']}/webhooks/twilio/sms/incoming"
  end

  def self.twilio_outgoing_sms_webhook_url
    return "#{Rails.env.development? ? 'http' : 'https'}://#{ENV['DOMAIN_NAME']}/webhooks/twilio/sms/outgoing"
  end

  def active?
    self.status == 'active'
  end

  def ready?
    self.status == 'ready'
  end

  def disabled?
    self.status == 'disabled'
  end

  def test_sim?
    self.test_sim
  end

  # Method to activate a sim through Twilio
  def activate!
    twilio_client = Twilio::REST::Client.new
    twilio_sim = twilio_client.wireless.sims(self.sid).fetch
    twilio_sim.update(status: "active")
    self.status = "active"
    return self.save!
  end

  # Method to enabled data on a sim through Twilio
  def reenable_data!
    twilio_client = Twilio::REST::Client.new
    twilio_sim = twilio_client.wireless.sims(self.sid).fetch
    twilio_sim.update(rate_plan: ENV['TWILIO_SIM_RATE_PLAN_SID'])
    self.rate_plan_sid = ENV['TWILIO_SIM_RATE_PLAN_SID']
    return self.save!
  end

  # Method to disable data on a sim through Twilio
  def disable_data!
    twilio_client = Twilio::REST::Client.new
    twilio_sim = twilio_client.wireless.sims(self.sid).fetch
    twilio_sim.update(rate_plan: ENV['TWILIO_DISABLED_DATA_SIM_RATE_PLAN_SID'])
    self.rate_plan_sid = ENV['TWILIO_DISABLED_DATA_SIM_RATE_PLAN_SID']
    self.save!
  end

  private
  def generate_uuid
    begin
      self.uuid = SecureRandom.hex
    end while Sim.exists?(uuid: uuid)
  end

  def generate_activation_code
    begin
      self.activation_code = SecureRandom.hex(4)
    end while Sim.exists?(activation_code: activation_code)
  end

  def setup_twilio_sim
    twilio_client = Twilio::REST::Client.new
    # Grab a SIM from the available list from twilio
    twilio_sim = twilio_client.wireless.sims.list(status: 'new').first
    # Get the rate plan to use with sims
    if self.test_sim?
      rate_plan = twilio_client.wireless.rate_plans(ENV['TWILIO_TEST_SIM_RATE_PLAN_SID']).fetch
    else
      rate_plan = twilio_client.wireless.rate_plans(ENV['TWILIO_SIM_RATE_PLAN_SID']).fetch
    end
    # Add rate plan to sim
    twilio_sim.update(rate_plan: rate_plan.sid)
    # Grab a phone number for the SIM
    country_code = self.country_code || 'US'
    number = twilio_client.available_phone_numbers(country_code).local.list.first
    twilio_number = twilio_client.incoming_phone_numbers.create(phone_number: number.phone_number)
    # Add incoming voice and sms handling urls
    twilio_number.update(voice_url: Sim::twilio_incoming_voice_webhook_url, sms_url: Sim::twilio_incoming_sms_webhook_url)
    # Add sim webhooks
    twilio_sim.update(voice_url: Sim::twilio_outgoing_voice_webhook_url, voice_method: "POST", sms_url: Sim::twilio_outgoing_sms_webhook_url, sms_method: "POST")
    # Update sim status to ready and add friendly name if it was provied
    twilio_sim.update(status: "ready", friendly_name: self.name)
    # Set model attributes
    self.sid = twilio_sim.sid
    self.phone_number = twilio_number.phone_number
    self.rate_plan_sid = rate_plan.sid
    self.iccid = twilio_sim.iccid
    self.status = "ready"
    # Update twilio sim to use our sim's uuid for db matching
    twilio_sim.update(unique_name: self.uuid)
  end
end
