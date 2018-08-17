class UserJson
  def initialize(user, format = :full)
    @user = user
    @format = (format || :full).to_s.to_sym
  end

  def call(options=nil)
    return to_json(@user, options) unless @user.respond_to?(:each)
    @user.map { |user| to_json(user, options) }
  end

  private

  def to_json(user, options)
    return nil unless user
    Rails.cache.fetch("json/v1.0/#{@format}/#{user.cache_key}") do
      case @format
      when :short
        short_json(user, options)
      else
        full_json(user, options)
      end
    end
  end

  def short_json(user, options)
    {
      id: user.id,
      name: user.name,
      email: user.email,
    }
  end

  def full_json(user, options)
    return nil if user.nil?
    {
      id: user.id,
      first_name: user.first_name,
      last_name: user.last_name,
      email: user.email,
      apiToken: user.auth_tokens.last.try(:token),
    }
  end
end
