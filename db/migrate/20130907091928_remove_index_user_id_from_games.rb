class RemoveIndexUserIdFromGames < ActiveRecord::Migration
  def change
    remove_index :games, :user_id
  end
end
