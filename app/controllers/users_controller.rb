class UsersController < ApplicationController
	
	before_filter :login_required, :only => [:show,:user_sign_out,:update]
	def entrar
		user = User.last
		sign_in(user)
		redirect_to root_path
		
	end
	def update
		@user = current_user
		#miro si el id del usuario que quiere modificar es el suyo
		if (params['id'].to_i == @user.id)
			if @user.update_attributes!(user_params)
				@socials = @user.socials
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

	def show
		@user = current_user
		@socials = current_user.socials
	end

	def user_sign_out
		sign_out()
		redirect_to root_path
	end

	def login_beperk
		# con beperk no tenemos location, podemos pero paso de pedirlo, me da pereza
		require 'oauth2'
		url_endpoint = 'http://apibeta.beperk.com'
		client = OAuth2::Client.new(ENV['BEPERK_CLIENT_ID'], ENV['BEPERK_CLIENT_SECRET'], {:site => url_endpoint, :authorize_url => "/oauth2/authenticate", :token_url => "/oauth2/token"})
		callbackUrl = ENV['DOMINIO']+'/users/login_beperk'
		# => "https://example.org/oauth/authorization?response_type=code&client_id=client_id&redirect_uri=http://localhost:8080/oauth2/callback"
		unless(params[:code].nil?)
			token = client.auth_code.get_token(params[:code], :redirect_uri => callbackUrl)
			# AQUI DEBERÍAMOS TENER AL USUARIO
			response = token.get(url_endpoint+'/users/'+token.params['user_id'].to_s, :params => { 'client_id' => ENV['BEPERK_CLIENT_ID'],'client_secret'=> ENV['BEPERK_CLIENT_SECRET']})
			#logger.debug 'RESPUESTA' + response.parsed['response']['status'].to_s
			response =  JSON.parse(response.body)
			response = response['response']['content']['user']
			
			

			if((user = User.where(:email => response['email'])) and !user.blank?)
				# => ya registrado
				social_signed = false
				for social in user.socials
					if((social.social_id == response['id']) and (social.name == 'beperk'))
						# YA REGISTRADO CON ESTA RED SOCIAL
						social_signed = true
						break
					end
				end
				if (!social_signed)
					social = user.socials.create(:social_id => response['id'], :sn_type => 'beperk', :name => response['name'],:avatar_url => response['avatar_cmedium'],:social_link=>'url_endpoint'+response['id'])
					# REGISTRADO!
				else
					# => ya tiene esta red social
					# REGISTRADO!
					redirect_to root_path
				end
			else
				# => es un usuario nuevo
				begin

					user = User.create(:email => response['email'],:name => response['name'],:avatar_url => response['avatar_cmedium'])
					
					profile = Profile.create(:user_id=>user.id)

					social = user.socials.create(:social_id => response['id'], :sn_type => 'beperk', :name => response['name'],:avatar_url => response['avatar_cmedium'],:social_link=>'url_endpoint'+response['id'])

					#Usuario registrado con exito
					# REGISTRADO!
					redirect_to root_path

				rescue Exception => e
					logger.debug 'Error en el login de usuario'+e.backtrace.inspect
					redirect_to root_path
				end
			end

		else
			redirect_to client.auth_code.authorize_url(:redirect_uri => callbackUrl)
		end
	end

	def login_facebook
		require 'rest_client'
		# DOCS => https://developers.facebook.com/docs/facebook-login/login-flow-for-web-no-jssdk/
		callbackUrl = ENV['DOMINIO']+'/users/login_facebook'
		# permisos que pedimos al usuario separados por coma => https://developers.facebook.com/docs/reference/login/
		scope = 'email'
		if(!params[:code].nil?)			
			# => pido Access token (en la documentacion pone por get)
			url = 'https://graph.facebook.com/oauth/access_token?client_id='+ENV['FACEBOOK_CLIENT_ID']+'&redirect_uri='+callbackUrl+'&client_secret='+ENV['FACEBOOK_CLIENT_SECRET']+'&code='+params[:code]
			response = RestClient.get url
			# => FB me devuelve un string, lo paso a hash
			response = CGI.parse(response)
			# saco algo así {"access_token"=>["CYUEGUiTZA1kUkvr6AH02dBrHkTIikgNGsWgAECIZD"], "expires"=>["5174572"]}
			# => verifico el access token
			url = 'https://graph.facebook.com/me?access_token='+response['access_token'].first
			
			response = RestClient.get url
			response = JSON.parse(response)
			
			if((user = User.where(:email => response['email'])) and !user.blank?)
				# => ya registrado
				social_signed = false
				for social in user.socials
					if((social.social_id == response['id']) and (social.name == 'facebook'))
						# YA REGISTRADO CON ESTA RED SOCIAL
						social_signed = true
						break
					end
				end
				if (!social_signed)
					social = user.socials.create(:social_id => response['id'], :sn_type => 'facebook', :name => response['first_name'],:avatar_url => avatar_url,:social_link=>response['link'])
					location = user.locations.create(:location => response['location']['name'])
					# REGISTRADO!
				else
					# => ya tiene esta red social
					# REGISTRADO!
					redirect_to root_path
				end
			else
				# => es un usuario nuevo
				#FB no devuelve el avatar así que lo pido a parte
				begin
					get_avatar_url='https://graph.facebook.com/'+response['id']+'?fields=picture.type(large)'
					avatar_url=RestClient.get get_avatar_url
					avatar_url=JSON.parse(avatar_url)['picture']['data']['url']

					user = User.create(:email => response['email'],:name => response['first_name'],:avatar_url => avatar_url)
					
					profile = Profile.create(:user_id => user.id)
					
					social = user.socials.create(:social_id => response['id'], :sn_type => 'facebook', :name => response['first_name'],:avatar_url => avatar_url,:social_link=>response['link'])
					
					location = user.locations.create(:location => response['location']['name'])
					# REGISTRADO!
					redirect_to root_path
				rescue Exception => e
					logger.debug 'Error en el login de usuario'+e.backtrace.inspect
					redirect_to root_path
				end

			end

		elsif (params[:error])
			redirect_to root_path

		else
			# => primera vez que entro, voy a pedir el code
			url = 'https://www.facebook.com/dialog/oauth?client_id='+ ENV['FACEBOOK_CLIENT_ID'] + '&scope='+scope+'&redirect_uri='+callbackUrl+'&app_id='+ENV['FACEBOOK_CLIENT_ID']
			redirect_to url
		end
	end

	def login_twitter
		if((!params[:twitter_email].nil?) and (!params[:twitter_email].first.blank?))
			session[:twitter_email] = params[:twitter_email].first
		end
		if (!session[:twitter_email].blank?)
			# ya tengo el email, puedo empezar o continuar con el proceso de oauth
			@consumer = OAuth::Consumer.new( ENV['TWITTER_CONSUMER_KEY'], ENV['TWITTER_CONSUMER_SECRET'], {
      :site               => "https://api.twitter.com",
      :scheme             => :header,
      :http_method        => :post,
      :request_token_path => "/oauth/request_token",
      :access_token_path  => "/oauth/access_token",
      :authorize_path     => "/oauth/authenticate"
	    })
	    callbackUrl = ENV['DOMINIO']+'/users/login_twitter'
	    unless(params["oauth_token"].nil?)
	    	request_token = session[:request_token]
	    	access_token = request_token.get_access_token(:oauth_verifier => params[:oauth_verifier])
	      tw_user_request = access_token.get('https://api.twitter.com/1.1/account/verify_credentials.json')
	      tw_user = JSON.parse(tw_user_request.body).to_hash
	      # TW nos devuelve una imagen pequeña, quitando "_normal" de la url obtenemos la original (ojo, NO es una chapuza, así lo pone en la doc de tw)
	      tw_user['profile_image_url'].slice! '_normal'
	      social_link = 'https://twitter.com/'+tw_user['screen_name'].to_s

	      # AQUI TENEMOS AL USUARIO
	      if((user = User.where(:email => session[:twitter_email]).first) and !user.blank?)
	      	
					# => ya registrado pero no sé con que red social
					social_signed = false
					for social in user.socials
						if(social.sn_type == 'twitter')
							# YA REGISTRADO CON ESTA RED SOCIAL
							social_signed = true
							break
						end
					end
					if (!social_signed)
						# está registrado con otra red social, le asignamos esta también
						social = user.socials.create(:social_id => tw_user['id_str'], :sn_type => 'twitter', :name => tw_user['name'], :avatar_url => tw_user['profile_image_url'],:social_link => social_link)
						location = user.locations.create(:location => tw_user['location'])
					end
					sign_in(user)
				else
					# => es un usuario nuevo
					begin
						user = User.create(:email => session[:twitter_email],:name => tw_user['name'],:avatar_url => tw_user['profile_image_url'])

						profile = Profile.create(:user_id=>user.id)

						social = user.socials.create(:social_id => tw_user['id_str'], :sn_type => 'twitter', :name => tw_user['name'], :avatar_url => tw_user['profile_image_url'],:social_link => social_link)

						location = user.locations.create(:location => tw_user['location'])

						#Usuario registrado con exito
						# REGISTRADO!
						sign_in(user)
					rescue Exception => e
						logger.debug 'ERROR QUE TE CAGAS'+e.message

						logger.debug 'Error en el login de usuario'+e.backtrace.inspect
						redirect_to root_path
					end
				end
				redirect_to user_path(user.id)
	    else
	    	request_token = @consumer.get_request_token(:oauth_callback => callbackUrl)
	    	session[:request_token] = request_token
	      redirect_to request_token.authorize_url(:oauth_callback => callbackUrl)
	    end
		else
			#no tengo email, redirijo a home
			redirect_to root_path
		end
		
	end

	def login_google
		#con google no tenemos location
    client = OAuth2::Client.new(ENV['GOOGLE_CLIENT_ID'], ENV['GOOGLE_CLIENT_SECRET'], {:site => 'https://accounts.google.com', :authorize_url => "/o/oauth2/auth", :token_url => "/o/oauth2/token"})

    callbackUrl = ENV['DOMINIO']+'/users/login_google'

    unless(params[:code].nil?)
      token = client.auth_code.get_token(params[:code], :redirect_uri => callbackUrl, :token_method => :post)
      # raise "#{token.token} #{token.refresh_token}".inspect
      
      response = token.get('https://www.googleapis.com/oauth2/v1/userinfo?alt=json', :params => { 'query_foo' => 'bar' })
      response = response.parsed
      # AQUI TENEMOS AL USUARIO
      if((user = User.where(:email => response['email']).first) and !user.blank?)
				# => ya registrado con alguna red social
				social_signed = false
				for social in user.socials
					if(social.sn_type == 'google')
						# YA REGISTRADO CON ESTA RED SOCIAL
						social_signed = true
						break
					end
				end
				if (!social_signed)
					social = user.socials.create(:social_id => response['id'], :sn_type => 'google', :name => response['given_name'],:avatar_url => response['picture'],:social_link=>response['link'])
					# REGISTRADO!
				end
				sign_in(user)

			else
				# => es un usuario nuevo
				begin

					user = User.create(:email => response['email'],:name => response['given_name'],:avatar_url => response['picture'])
					# lOGUEA AL USUARIO
					
					
					# DEVUELVE AL USUARIO
					
					#raise current_user.inspect
					profile = Profile.create(:user_id=>user.id)

					social = user.socials.create(:social_id => response['id'], :sn_type => 'google', :name => response['given_name'],:avatar_url => response['picture'],:social_link=>response['link'])
					#Usuario registrado con exito
					# REGISTRADO!
					sign_in(user)
				rescue Exception => e
					logger.debug 'Error en el login de usuario'+e.backtrace.inspect
				end
			end
			redirect_to user_path(user.id)
    else
      if !params[:denied]
        redirect_to firstUrl =  client.auth_code.authorize_url(:redirect_uri => callbackUrl, :scope => 'https://www.googleapis.com/auth/userinfo.profile https://www.googleapis.com/auth/userinfo.email', :access_type => "offline", :approval_prompt => 'force')
        
      else
        redirect_to root_path
      end
    end
	end
	private
		def user_params
			params.require(:user).permit(:avatar_url, :name)
		end
end

