class StripeCustomer < ApplicationRecord
  belongs_to :billable, polymorphic: true, touch: true

  before_destroy :remove_stripe

  def card_expiration_date
    begin
      sc = Stripe::Customer.retrieve self.stripe_id
      return false unless self.default_source
      card = sc.sources.retrieve self.default_source
      Date.strptime(card.exp_month.to_s + '/' + card.exp_year.to_s, "%m/%Y") + 1.month
    rescue
      nil
    end
  end

  def card_expired
    begin
      sc = Stripe::Customer.retrieve self.stripe_id
      return false unless self.default_source
      card = sc.sources.retrieve self.default_source
      expiring = Date.strptime(card.exp_month.to_s + '/' + card.exp_year.to_s, "%m/%Y") + 1.month
      return expiring < Time.now
    rescue
      #Nothing
    end
  end

  def card_expiring_soon
    begin
      sc = Stripe::Customer.retrieve self.stripe_id
      return false unless self.default_source
      card = sc.sources.retrieve self.default_source
      expiring = Date.strptime(card.exp_month.to_s + '/' + card.exp_year.to_s, "%m/%Y") + 1.month
      return expiring < 30.days.from_now
    rescue
      #Nothing
    end
  end

  def remove_stripe
    begin
      sc = Stripe::Customer.retrieve self.stripe_id
      sc.delete
    rescue Stripe::InvalidRequestError, Stripe::AuthenticationError => _e
      # Nothing
    end
  end
end
