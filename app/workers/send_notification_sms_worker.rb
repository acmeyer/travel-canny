class SendNotificationSmsWorker
  include Sidekiq::Worker

  def perform(user_id, sim_id, message, message_type)
    user = User.find(user_id)
    sim = Sim.find(sim_id)
    client = Twilio::REST::Client.new

    # fetch sim first to get it's status check the sim's status, 
    # if it is updating or scheduled to be updated, 
    # wait until complete before sending the message, 
    # otherwise it will fail to send
    begin
      twilio_sim = client.wireless.sims(sim.sid).fetch
    end while twilio_sim.status == 'updating' || twilio_sim.status == 'scheduled'

    message = client.messages.create({
      from: ENV['TWILIO_NOTIFICATION_PHONE_NUMBER'],
      to: sim.phone_number,
      body: message
    })

    puts "Finished sending SMS notification message: #{message} to: #{sim.phone_number}"

    if message_type == 'data_warning'
      user.update!(last_data_warning_message_sent: DateTime.now)
    elsif message_type == 'data_limit_exceeded'
      user.update!(last_data_exceeded_message_sent: DateTime.now)
    end
  end
end
