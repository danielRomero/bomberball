class Player < ActiveRecord::Base
	belongs_to :games
	has_many :users
end
