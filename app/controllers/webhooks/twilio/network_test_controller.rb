class Webhooks::Twilio::NetworkTestController < Webhooks::Twilio::TwilioWebhooksController
  def incoming_sms
    @sim = Sim.find_by_phone_number(params[:From])
    # If the sim isn't in our db or isn't a test sim just ignore the message
    if @sim && @sim.test_sim?
      # Keep track of messages sent between numbers to avoid wasting resources
      session[:message_count] ||= 0
      message_count = session[:message_count]

      if message_count < 3
        user_message = params[:Body].downcase
        if user_message == ENV['NETWORK_TEST_SURVEY_INPUT']
          test_response = "Thanks for testing out our SIM! In the survey, input the code: #{ENV['NETWORK_TEST_SURVEY_CODE']}"
        else
          test_response = "Sorry, the message you sent didn't match what's in the survey. Please try again, #{2 - message_count} attempts remaining."
        end
        response = Twilio::TwiML::MessagingResponse.new
        response.message(from: params[:To], to: params[:From], body: test_response)
        session[:message_count] += 1
        render xml: response.to_xml
      end
      # Possibly add a response when the checks fail
      # else
      #   test_response = "Sorry, this phone number isn't recognized as one of our SIMs or is no longer active for testing."
    end

  end
end