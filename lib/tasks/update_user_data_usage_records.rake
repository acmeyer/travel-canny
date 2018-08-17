desc "Update user data usage records from Twilio"
task :update_user_data_usage_records => [:environment] do |t|
  User.all.each do |u|
    FetchDataUsageRecordsWorker.perform_async(u.id)
  end
end