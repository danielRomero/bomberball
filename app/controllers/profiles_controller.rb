class ProfilesController < ApplicationController

	def update
		@user = current_user
		if @user.profile.update_attributes(profile_params)
			logger.debug 'funciona ok'
			respond_to do |format|
        format.js { render }
        format.html { render :nothing => true}
      end
		else
			logger.debug 'error'
		end
	end

	private
	def profile_params
		params.require(:profile).permit(:bomb_color, :eyes_color, :body_color, :head_color, :limbs_color)
	end
end
