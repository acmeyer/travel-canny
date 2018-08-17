class FetchDataUsageRecordsWorker
  include Sidekiq::Worker

  def perform(user_id)
    u = User.find(user_id)
    # For each user sim, get the hourly usage records from Twilio
    # from the time they were last fetched until now, update their data plan usage accordingly
    twilio_client = Twilio::REST::Client.new
    # Don't fetch sims unless they have a sid
    u.sims.where.not(sid: nil).each do |sim|
      # Get all records from the most recent record on
      last_record = u.data_usage_records.order(:updated_at).last
      start = last_record.blank? ? DateTime.now - 1.day : u.created_at
      usage = twilio_client.wireless.sims(sim.sid).usage_records.list(
        start: start.iso8601(),
        granularity: 'hourly'
      )
      # Create our own usage records for the user for each Twilio usage record, or update existing ones
      usage.each do |ur|
        data_record = u.data_usage_records.find_or_create_by!(
          start: ur.period['start'], 
          end: ur.period['end']
        )
        data_record.update!(
          total_usage: ur.data['total'], 
          units: ur.data['units']
        )
        unless ur.data['units'] == 'bytes'
          puts "Twilio usage record not in bytes! Units in: #{ur.data['units']}"
        end
      end
    end

    # Update user's plan based on usage records
    u.data_plan.update!(total_amount_used: u.data_usage_records.sum(:total_usage))
  end
end
