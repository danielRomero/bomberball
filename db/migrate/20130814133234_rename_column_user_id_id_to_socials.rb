class RenameColumnUserIdIdToSocials < ActiveRecord::Migration
  def change
  	rename_column :socials, :user_id_id, :user_id
  end
end
