class LandingController < ApplicationController
  
  def index
  	# => filtro, si soy usuario registrado mando al controlador de usuarios, si no renderizo landing
  	if (current_user)
  		redirect_to user_path(current_user.id)
  	end
  end

  def about_me
  end
end
