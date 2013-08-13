class Social < ActiveRecord::Base
	belongs_to :user
	validates :id_social, :presence     => true
	validates :password, :presence     => true
end
