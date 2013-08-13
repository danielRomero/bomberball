class AddTypeToSocila < ActiveRecord::Migration
  def change
    add_column :socials, :type, :string
    add_column :socials, :id_social, :string
  end
end
