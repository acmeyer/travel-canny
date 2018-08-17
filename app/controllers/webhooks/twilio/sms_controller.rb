class Webhooks::Twilio::SmsController < Webhooks::Twilio::TwilioWebhooksController

  def incoming
    sim_sid = get_sim_sid(params[:To])
    response = Twilio::TwiML::MessagingResponse.new
    response.message(from: params[:From], to: "sim:#{sim_sid}", body: params[:Body])

    render xml: response.to_xml
  end

  def outgoing
    from_phone = parse_sim_sid(params[:From])
    response = Twilio::TwiML::MessagingResponse.new
    response.message(from: from_phone, to: params[:To], body: params[:Body])

    render xml: response.to_xml
  end

  def notification_response
    sim = Sim.find_by_phone_number(params[:From])
    if sim
      @user = sim.user
      response = params[:Body].downcase
      if response == 'add'
        if @user.data_plan.add_500_mbs_and_charge
          message = I18n.t('messages.successfully_added_data')
        else
          message = I18n.t('errors.failed_to_add_data')
        end
      else
        message = I18n.t('sms.notification.response_not_recognized')
      end

      # TODO: better handling so that user gets message right away (in case of reactivation)
      # Send message via worker for better handling
      SendNotificationSmsWorker.perform_async(@user.id, sim.id, message, 'notification_response')
    end
  end
end