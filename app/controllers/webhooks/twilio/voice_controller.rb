class Webhooks::Twilio::VoiceController < Webhooks::Twilio::TwilioWebhooksController

  # set on phone number
  def incoming
    sim_sid = get_sim_sid(params[:To])
    response = Twilio::TwiML::VoiceResponse.new
    response.dial do |d|
      d.sim sim_sid
    end

    render xml: response.to_xml
  end

  # Set on the SIM
  def outgoing
    from_phone = parse_sim_sid(params[:From])
    response = Twilio::TwiML::VoiceResponse.new
    response.dial(caller_id: from_phone) do |d|
      d.number params[:To]
    end

    render xml: response.to_xml
  end
end