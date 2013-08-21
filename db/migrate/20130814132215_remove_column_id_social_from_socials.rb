class RemoveColumnIdSocialFromSocials < ActiveRecord::Migration
  def change
  	remove_column :socials, :id_social
  end
end
