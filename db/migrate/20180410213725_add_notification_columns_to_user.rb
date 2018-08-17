class AddNotificationColumnsToUser < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :last_data_warning_message_sent, :datetime
    add_column :users, :last_data_exceeded_message_sent, :datetime
  end
end
