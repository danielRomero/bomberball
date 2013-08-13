class User < ActiveRecord::Base
	has_many :socials, :dependent => :destroy
	validates :name, :presence     => true 
	validates :email #, :presence     => true en twitter no hay email
end
