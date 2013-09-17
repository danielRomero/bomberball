class GamesController  < ApplicationController 
	before_filter :login_required

	def new
		@user = current_user
		@game = nil
		@host = request.host_with_port
		# => mirar si el user tiene ya una partida, si es así, utilizar esa partida
		# => si no tiene partida crear una para ese user
		# => si no hay partidas con menos de 4 jugadores, crear una partida con ese user
		if(@user.player)
			# si el user tiene player, está en un juego
			@game = Game.find(@user.player.game_id)
		else
			# si no se le busca un juego disponible
			Game.all.each do |g|
				@game = g if(g.players.count<4)
			end
			#si no se ha encontado juego, se crea
			if(@game.blank?)
				@game = Game.create(:user_id => @user.id)
			end
			# se crea un player en ese juego para ese jugador
			@game.players.create(:user_id => @user.id)
		end
	end

	def delete
		# Sería destroy pero si hay vista previa es delete
		# Cuándo abandona un jugador el juego?
	end

end
