class AddUserIdToSocials < ActiveRecord::Migration
  def change
    add_reference :socials, :user_id, index: true
  end
end
