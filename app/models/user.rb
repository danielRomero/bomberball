class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
	has_many :socials,:dependent => :destroy
	has_many :locations, :dependent => :destroy
	has_one :profile, :dependent => :destroy
	validates :name, :presence     => true
	validates :email, :presence     => true #en twitter no hay email pero se pide

end
