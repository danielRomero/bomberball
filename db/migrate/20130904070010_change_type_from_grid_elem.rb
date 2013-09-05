class ChangeTypeFromGridElem < ActiveRecord::Migration
  def change
  	rename_column :grid_elems, :type, :block_type
  end
end
