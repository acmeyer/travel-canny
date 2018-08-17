module ApiHelper
  def verify_client_key
    # TODO: verify request has a client key header that matches the server's accepted client key
    key = request.headers['Client-Api-Key']
    raise Api::V1::Unauthorized unless Devise.secure_compare(ENV['CLIENT_API_KEY'], key)
  end

  def unauthorized(e)
    render json: { error: "Unauthorized" }, status: 401
  end

  def not_found
    render json: { error: "Not Found" }, status: 404
  end
end