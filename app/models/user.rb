class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :rememberable, :trackable
         
	has_many :socials,:dependent => :destroy
	has_many :locations, :dependent => :destroy
	has_one :profile, :dependent => :destroy

end
