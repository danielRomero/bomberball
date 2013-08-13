class UsersController < ApplicationController

	

	def login_beperk
		logger.debug 'ENTRA LOGIN'
		logger.debug params.inspect
		require 'oauth2'
		client = OAuth2::Client.new(ENV['BEPERK_CLIENT_ID'], ENV['BEPERK_CLIENT_SECRET'], {:site => 'http://api.beperk.com', :authorize_url => "/oauth2/authenticate", :token_url => "/oauth2/token"})
		callbackUrl = ENV['DOMINIO']+'/users/login_beperk'
		# => "https://example.org/oauth/authorization?response_type=code&client_id=client_id&redirect_uri=http://localhost:8080/oauth2/callback"
		unless(params[:code].nil?)
			logger.debug 'PIDO TOKEN'
			token = client.auth_code.get_token(params[:code], :redirect_uri => callbackUrl)
			logger.debug token.token
			logger.debug token.params
			logger.debug token.params['response']['status']
			logger.debug token.params['user_id']
			logger.debug 'PIDO usuario'
			
			# AQUI DEBERÍAMOS TENER AL USUARIO
			response = token.get('http://api.beperk.com/users/1', :params => { 'client_id' => ENV['BEPERK_CLIENT_ID'],'client_secret'=> ENV['BEPERK_CLIENT_SECRET']})
			logger.debug 'RESPUESTA' + response.parsed['response']['status'].to_s
		else
			logger.debug 'PIDO CODIGO'
			redirect_to client.auth_code.authorize_url(:redirect_uri => callbackUrl)
		end
	end

	def login_facebook
		require 'rest_client'
		# DOCS => https://developers.facebook.com/docs/facebook-login/login-flow-for-web-no-jssdk/
		callbackUrl = ENV['DOMINIO']+'/users/login_facebook'
		# permisos que pedimos al usuario separados por coma => https://developers.facebook.com/docs/reference/login/
		scope = 'email'
		logger.debug params.inspect
		if(!params[:code].nil?)			
			# => pido Access token (en la documentacion pone por get)
			url = 'https://graph.facebook.com/oauth/access_token?client_id='+ENV['FACEBOOK_CLIENT_ID']+'&redirect_uri='+callbackUrl+'&client_secret='+ENV['FACEBOOK_CLIENT_SECRET']+'&code='+params[:code]
			response = RestClient.get url
			# => FB me devuelve un string, lo paso a hash
			response = CGI.parse(response)
			logger.debug response.inspect
			# saco algo así {"access_token"=>["CYUEGUiTZA1kUkvr6AH02dBrHkTIikgNGsWgAECIZD"], "expires"=>["5174572"]}
			# => verifico el access token
			url = 'https://graph.facebook.com/me?access_token='+response['access_token'].first
			
			response = RestClient.get url
			# AQUI TENEMOS AL USUARIO
			logger.debug response.inspect
		elsif (params[:error])
			redirect_to root_path

		else
			# => primera vez que entro, voy a pedir el code
			url = 'https://www.facebook.com/dialog/oauth?client_id='+ ENV['FACEBOOK_CLIENT_ID'] + '&scope='+scope+'&redirect_uri='+callbackUrl+'&app_id='+ENV['FACEBOOK_CLIENT_ID']
			redirect_to url
		end
	end

	def login_twitter
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

      # AQUI TENEMOS AL USUARIO
      logger.debug tw_user

    else
    	request_token = @consumer.get_request_token(:oauth_callback => callbackUrl)
    	session[:request_token] = request_token
      redirect_to request_token.authorize_url(:oauth_callback => callbackUrl)
    end
	end

	def login_google
    client = OAuth2::Client.new(ENV['GOOGLE_CLIENT_ID'], ENV['GOOGLE_CLIENT_SECRET'], {:site => 'https://accounts.google.com', :authorize_url => "/o/oauth2/auth", :token_url => "/o/oauth2/token"})

    callbackUrl = ENV['DOMINIO']+'/users/login_google'

    unless(params[:code].nil?)
      token = client.auth_code.get_token(params[:code], :redirect_uri => callbackUrl, :token_method => :post)
      # raise "#{token.token} #{token.refresh_token}".inspect
      raise token.inspect
      response = token.get('https://www.googleapis.com/oauth2/v1/userinfo?alt=json', :params => { 'query_foo' => 'bar' })
      # AQUI TENEMOS AL USUARIO
      logger.debug response.parsed.inspect
    else
      if !params[:denied]
        redirect_to firstUrl =  client.auth_code.authorize_url(:redirect_uri => callbackUrl, :scope => 'https://www.googleapis.com/auth/userinfo.profile https://www.googleapis.com/auth/userinfo.email', :access_type => "offline", :approval_prompt => 'force')
        # => "https://accounts.google.com/o/oauth2/auth?response_type=code&client_id=564443062753.apps.googleusercontent.com&redirect_uri=http%3A%2F%2Fbeperk.com%3A4000&scope=https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fplus.me&access_type=offline&approval_prompt=force
      else
        redirect_to root_path
      end
    end
	end
end

