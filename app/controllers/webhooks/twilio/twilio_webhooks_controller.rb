class Webhooks::Twilio::TwilioWebhooksController < Webhooks::WebhooksController
  skip_before_action  :verify_authenticity_token
  
  protected
  def get_sim_sid(phone)
    sim = Sim.where(phone_number: phone).first
    raise Webhooks::NotFound unless !sim.blank?
    return sim.sid
  end

  def parse_sim_sid(sid)
    parsed_sid = sid.split(':')[1]
    sim = Sim.where(sid: parsed_sid).first
    raise Webhooks::NotFound unless !sim.blank?
    return sim.phone_number
  end
end