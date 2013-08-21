class AddSocialIdToSocials < ActiveRecord::Migration
  def change
    add_column :socials, :social_id, :string
  end
end
