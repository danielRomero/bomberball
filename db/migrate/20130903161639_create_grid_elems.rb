class CreateGridElems < ActiveRecord::Migration
  def change
    create_table :grid_elems do |t|
    	t.string :type
    	t.integer :x
    	t.integer :y
    	t.references :game
      t.timestamps
    end
  end
end
