class AddAvatarUrlandNameFromSocial < ActiveRecord::Migration
  def change
    add_column :socials, :avatar_url, :string
    add_column :socials, :name, :string
  end
end
