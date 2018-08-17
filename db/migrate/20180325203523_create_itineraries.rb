class CreateItineraries < ActiveRecord::Migration[5.1]
  def up
    create_table :itineraries do |t|
      t.belongs_to :trip, index: true
      t.belongs_to :country, index: true

      t.timestamps
    end
  end

  def down
    drop_table :itineraries, if_exists: true
  end
end
