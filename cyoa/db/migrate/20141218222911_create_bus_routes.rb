class CreateBusRoutes < ActiveRecord::Migration
  def change
    create_table :bus_routes do |t|
      t.integer :public_id
      t.string :name
      t.string :color
      t.string :directions

      t.timestamps
    end
    add_index :bus_routes, :public_id
  end
end
