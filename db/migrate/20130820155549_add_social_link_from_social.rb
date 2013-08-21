class AddSocialLinkFromSocial < ActiveRecord::Migration
  def change
    add_column :socials, :social_link, :string
  end
end
