class Webhooks::WebhooksController < ApplicationController
  include WebhooksHelper

  rescue_from Webhooks::NotFound, with: :record_not_found
  rescue_from Webhooks::Forbidden, with: :forbidden

  protected
  def record_not_found(e)
    render json: { error: "Not found" }, status: 404
  end

  def forbidden(e)
    render json: { error: "Action forbidden." }, status: 403
  end
end