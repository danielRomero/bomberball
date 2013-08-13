class CreateSocials < ActiveRecord::Migration
  def change
    create_table :socials do |t|

      t.timestamps
    end
  end
end
