class GamesController  < ApplicationController 
	before_filter :login_required
	def pruebas
		
	end
	
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
		
		# # => si hay partidas con menos de 4 jugadores, me uno
		# if(!@game.blank?)
		# 	logger.debug 'GAME NOT BLANK => '+@game.inspect
		# 	# inserto al usuario como jugador de la partida en la posición del grid correspondiente
		# 	logger.debug 'PLAYERS COUNT -> '+@game.players.count.to_s
		# 	logger.debug @game.grid_elems.inspect
		# 	# => LEO GRID
		# 	@game.grid = []
		# 	for i in 0..6
		# 		# meto cada fila en un array consiguiendo un array de filas que cada una contiene un array de columnas
		# 		elems = []
		# 		for elem in @game.grid_elems.offset(i*9).limit(9)
		# 			elems << elem.get_type
		# 		end
		# 		@game.grid << elems
		# 	end
		# 	@game.players.create(:user_id => @user.id, :x=> 10, :y => 10)
		# 	logger.debug @game.grid_elems.inspect
		# # => si no hay partidas de menos de 4 jugadores creo una
		# else
		# 	logger.debug 'CREAMOS GAME, GRID Y PLAYER'
		# 	@game = Game.create
		# 	@game.grid = []
		# 	# CREO GRID
		# 	# array que contiene todas las filas las cuales contienen sus columnas
		# 	for i in 0..6
		# 		row = []
		# 		for j in 0..8
		# 			if(((i % 2) != 0) and ((j % 2) != 0))
		# 				row << @game.grid_elems.create(:block_type => 'block').get_type
		# 			elsif (j==0 or j==1 or j==7 or j == 8) and (i==0 or i==1 or i==5 or i==6)
		# 				row << @game.grid_elems.create(:block_type => 'empty').get_type
		# 			else
		# 				row << @game.grid_elems.create(:block_type => 'brick').get_type
		# 			end
		# 		end
		# 		@game.grid << row
		# 	end
		# 	# => asignamos al usuario actual
		# 	@game.players.create(:user_id => @user.id, :x=> 10, :y => 10)
		# end
		# #@uri = 'localhost:3000/websocket'
		# @uri = request.host+':'+request.port.to_s+'/websocket'
	end

	def delete
		# Sería destroy pero si hay vista previa es delete
		# Cuándo abandona un jugador el juego?
	end

end
