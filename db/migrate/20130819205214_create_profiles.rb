class CreateProfiles < ActiveRecord::Migration
  def change
    create_table :profiles do |t|

      t.timestamps
      t.belongs_to :user
      t.string :head_color
      t.string :limbs_color
      t.string :eyes_color
      t.string :bomb_color
      t.string :explosion_color
    end
  end
end
