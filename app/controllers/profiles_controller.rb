class ProfilesController < ApplicationController

	before_filter :login_required

	def update
		@user = current_user
		if (params['id'].to_i == @user.profile.id)
			if @user.profile.update_attributes(profile_params)
				respond_to do |format|
	        format.js { render }
	        format.html { render :nothing => true}
	      end
			else
				logger.debug 'error'
			end
		else
			logger.debug 'error 401'
		end
	end

	private
	def profile_params
		params.require(:profile).permit(:bomb_color, :eyes_color, :body_color, :head_color, :limbs_color)
	end
end
