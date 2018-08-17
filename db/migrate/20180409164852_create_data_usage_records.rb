class CreateDataUsageRecords < ActiveRecord::Migration[5.1]
  def up
    create_table :data_usage_records do |t|
      t.belongs_to :user, index: true
      t.string :units, default: "bytes"
      t.datetime :start
      t.datetime :end
      t.bigint :total_usage

      t.timestamps
    end

    add_column :users, :last_data_usage_record_request, :datetime

    User.all.each do |u|
      # For each user sim, get the hourly usage records from Twilio
      # from the time they were created until now, update their data plan usage accordingly
      twilio_client = Twilio::REST::Client.new
      # Don't fetch sims unless they have a sid
      u.sims.where.not(sid: nil).each do |sim|
        # Get all records from user creation until now since we have nothing at the moment
        usage = twilio_client.wireless.sims(sim.sid).usage_records.list(
          start: u.created_at.iso8601(),
          granularity: 'hourly'
        )
        # Create our own usage records for the user for each Twilio usage record
        usage.each do |ur|
          u.data_usage_records.create!(start: ur.period['start'], end: ur.period['end'], total_usage: ur.data['total'], units: ur.data['units'])
          unless ur.data['units'] == 'bytes'
            puts "Twilio usage record not in bytes! Units in: #{ur.data['units']}"
          end
        end
      end

      # Update the user's last_data_usage_record_request
      u.update!(last_data_usage_record_request: DateTime.now)

      # Update user's plan based on usage records
      u.data_plan.update!(total_amount_used: u.data_usage_records.sum(:total_usage))
    end
  end

  def down
    drop_table :data_usage_records
    remove_column :users, :last_data_usage_record_request
  end
end
