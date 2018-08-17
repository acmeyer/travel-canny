class DropDatesFromTrips < ActiveRecord::Migration[5.1]
  def change
    remove_column :trips, :start_date, :datetime
    remove_column :trips, :end_date, :datetime
  end
end
