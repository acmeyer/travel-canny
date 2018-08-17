class AuthToken < ApplicationRecord
  belongs_to :user, touch: true
  before_create :generate_unique_token

  scope :not_expired, -> { where("expires_at > '#{DateTime.now.to_formatted_s(:db)}'") }

  def self.generate_new_token(user_id, ip_address, user_agent)
    user = User.find_by_id user_id
    raise "AuthToken: User id #{user_id} was not found" unless user
    auth_token = AuthToken.new
    auth_token.user_id = user.id
    auth_token.expires_at = DateTime.now + 2.months # expires if not used for a couple months
    auth_token.last_used_at = DateTime.now
    auth_token.ip_address = ip_address
    auth_token.user_agent = user_agent
    auth_token.save!
    auth_token
  end

  def update_last_used(ip_address, user_agent)
    self.expires_at = DateTime.now + 2.months
    self.last_used_at = DateTime.now
    self.ip_address = ip_address
    self.user_agent = user_agent
    self.save!
  end

  def expired?
    self.expires_at < DateTime.now
  end

  private
  def generate_unique_token
    begin
      self.token = Devise.friendly_token(75)
    end while AuthToken.exists?(token: token)
  end
end
