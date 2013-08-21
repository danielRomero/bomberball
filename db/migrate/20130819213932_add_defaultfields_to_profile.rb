class AddDefaultfieldsToProfile < ActiveRecord::Migration
  def change
    change_column_default(:profiles, :body_color, '#0004FF')
    change_column_default(:profiles, :head_color, '#FA0909')
    change_column_default(:profiles, :eyes_color, '#1AFF00')
    change_column_default(:profiles, :limbs_color, '#000000')
    change_column_default(:profiles, :explosion_color, '#FA0909')
    change_column_default(:profiles, :bomb_color, '#000000')
  end
end
