class RenameColumnFromLocation < ActiveRecord::Migration
  def change
  	rename_column :locations, :user_id_id, :user_id
  end
end
