class Game < ActiveRecord::Base
	has_many :players,:dependent => :destroy
	has_many :bombs,:dependent => :destroy
	has_many :grid_elems,:dependent => :destroy
	attr_reader(:grid)
	attr_writer(:grid)
end
