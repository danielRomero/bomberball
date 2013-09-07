class CreatePlayers < ActiveRecord::Migration
  def change
    create_table :players do |t|
    	t.references :games
    	t.references :users
      t.timestamps
    end
  end
end
