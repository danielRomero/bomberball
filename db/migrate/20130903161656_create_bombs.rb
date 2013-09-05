class CreateBombs < ActiveRecord::Migration
  def change
    create_table :bombs do |t|
    	t.integer :x
    	t.integer :y
    	t.references :user
    	t.references :game
    	t.references :player
      t.timestamps
    end
  end
end
