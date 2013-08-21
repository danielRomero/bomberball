class AddDefaultAvatarUrlToSocialAndUser < ActiveRecord::Migration
  def change
  	change_column_default(:socials, :avatar_url, 'default_avatar.svg')
    change_column_default(:users, :avatar_url, 'default_avatar.svg')
  end
end
