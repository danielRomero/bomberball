class RenameColumnTypeFromSocial < ActiveRecord::Migration
  def change
  	rename_column :socials, :type, :sn_type
  end
end
