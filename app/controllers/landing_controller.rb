class LandingController < ApplicationController
  
  def index
  	logger.debug 'PARAMS DE ROOT -----------------'
  	logger.debug params.inspect
  	logger.debug '-----------------------'
  	if (current_user)
  		redirect_to user_path(current_user.id)
  	end
  end
end
