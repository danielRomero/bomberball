class AddUserIdAndLocationFromLocation < ActiveRecord::Migration
  def change
    add_reference :locations, :user_id, index: true
    add_column :locations, :location, :string
  end
end
