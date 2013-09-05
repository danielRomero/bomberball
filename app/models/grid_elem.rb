class GridElem < ActiveRecord::Base
	belongs_to :game
	# => block_type can be: empty, has_bomb, has_player, brick, block
	def get_type
		return self.block_type+':'+self.id.to_s
	end
end
