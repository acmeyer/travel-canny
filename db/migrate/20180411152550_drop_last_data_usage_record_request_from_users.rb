class DropLastDataUsageRecordRequestFromUsers < ActiveRecord::Migration[5.1]
  def change
    remove_column :users, :last_data_usage_record_request, :datetime
  end
end
