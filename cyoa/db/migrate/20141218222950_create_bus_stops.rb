class CreateBusStops < ActiveRecord::Migration
  def change
    create_table :bus_stops do |t|
      t.integer :public_id
      t.string :name
      t.float :lat
      t.float :lng
      t.string :direction
      t.integer :sequence_order
      t.boolean :waypoint
      t.float :feet_from_start
      t.integer :bus_route_id

      t.timestamps
    end
    add_index :bus_stops, :public_id
    add_index :bus_stops, :bus_route_id
    add_index :bus_stops, :waypoint
  end
end
