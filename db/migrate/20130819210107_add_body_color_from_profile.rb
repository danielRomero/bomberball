class AddBodyColorFromProfile < ActiveRecord::Migration
  def change
    add_column :profiles, :body_color, :string
  end
end
