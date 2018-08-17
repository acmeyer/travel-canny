class CreateTrips < ActiveRecord::Migration[5.1]
  def change
    create_table :trips do |t|
      t.datetime :start_date
      t.datetime :end_date
      t.belongs_to :user, index: true

      t.timestamps
    end
  end
end
