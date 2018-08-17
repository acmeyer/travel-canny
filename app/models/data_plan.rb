class DataPlan < ApplicationRecord
  belongs_to :user, touch: true

  enum status: [ :enabled, :disabled ]

  after_save :send_user_notifications, :disable_sim

  def total_amount_mb
    (self.total_amount / 1000000.0).round(3)
  end

  def total_amount_used_mb
    (self.total_amount_used / 1000000.0).round(3)
  end

  def warning_amount_mb
    (self.warning_amount / 1000000.0).round(3)
  end

  def amount_remaining
    self.total_amount - self.total_amount_used
  end

  def amount_remaining_mb
    (self.amount_remaining / 1000000.0).round(3)
  end 

  def add_500_mbs_and_charge
    customer = Stripe::Customer.retrieve(self.user.stripe_customer.stripe_id)
    Stripe::Charge.create(
      :amount => 1000,
      :currency => "usd",
      :customer => customer.id,
      :description => "Add data charge for #{self.user.email}"
    )
    self.total_amount += 500000000
    # reactivate if disabled
    self.status = 'enabled' if self.status == 'disabled'
    if self.save
      self.user.reset_data_notifications
      return true
    else
      return false
    end
  end

  private
  def send_user_notifications
    unless self.user.beta_user
      if self.saved_change_to_total_amount_used?
        # send user a SMS notification if the amount remaining is less than the warning amount
        if (self.amount_remaining > 0) && (self.amount_remaining <= self.warning_amount)
          self.user.send_data_warning_sms_notification if self.user.last_data_warning_message_sent.blank?
        # send user a SMS notification telling them they have exceeded their plan's total amount and disable the plan
        elsif self.amount_remaining < 0
          self.status = 'disabled'
          self.save
          self.user.send_data_limit_exceeded_sms_notification if self.user.last_data_exceeded_message_sent.blank?
        end
      end
    end
  end

  def disable_sim
    if self.saved_change_to_status? 
      if self.status == 'disabled'
        self.user.disable_data
      elsif self.status == 'enabled'
        self.user.enable_data
      end
    end
  end
end
