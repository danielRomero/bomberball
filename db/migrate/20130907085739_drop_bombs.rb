class DropBombs < ActiveRecord::Migration
  def change
  	drop_table :bombs
  	drop_table :grid_elems
  	drop_table :players
  end
end
