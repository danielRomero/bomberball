class RenameReferencesFromGames < ActiveRecord::Migration
  def change
  	rename_column :players, :users_id, :user_id
  	rename_column :players, :games_id, :game_id
  end
end
