class GameConnectionsController < WebsocketRails::BaseController
	
	def player_disconnected
		logger.debug 'Player disconneted!!!'
		
		grid_game_id = 'grid'+message['game_id'].to_s
		players_list_id = 'players'+message['game_id'].to_s
		

		
		logger.debug 'numero de jugadores: '+connection_store.collect_all(players_list_id).count.to_s
		# resto uno porque es el jugador que se desconecta
		
		if (connection_store.collect_all(players_list_id).count-1 <= 1)
			#GANO, soy el último judador
			if (game = Game.find(message['game_id']) and !game.blank?)
				game.destroy
			end

			if(connection_store.collect_all(players_list_id).count-1 == 1)
				player_win(message['game_id'])
			end
		else
			# Pierdo, me han matado
		end

	end
	
	def player_win(game_id)
		WebsocketRails[game_id].trigger(:player_win, {})
	end

	def player_lose

	end

	def player_connected
		grid_game_id = 'grid'+message['game_id'].to_s
		players_list_id = 'players'+message['game_id'].to_s

		if((user = User.find(message['user_id'])) and (!user.blank?))
			player = case connection_store.collect_all(players_list_id).count
				when 1
					if controller_store[grid_game_id].blank?
						create_grid(grid_game_id)
					end
					new_player(user,0,0,players_list_id)
					['0:0:has_player:0:'+user.id.to_s]
				when 2
					new_player(user,0,8,players_list_id)
					['0:8:has_player:0:'+user.id.to_s]
				when 3
					new_player(user,6,0,players_list_id)
					['6:0:has_player:0:'+user.id.to_s]
				when 4
					new_player(user,6,8,players_list_id)
					['6:8:has_player:0:'+user.id.to_s]
			end

			
			#grid_comparison(player,controller_store[grid_game_id],players_list_id)
			update_game(player, grid_game_id, players_list_id)
			WebsocketRails[message['game_id']].trigger(:update_grid, {grid: controller_store[grid_game_id], players: connection_store[players_list_id]})
		end
	end
	#receive game_id, array with new values
	# values => [[i:j:block_type:time:id]]
	def update_grid
		grid_game_id = 'grid'+message['game_id'].to_s
		players_list_id = 'players'+message['game_id'].to_s
		if (!message['new_values'].blank?)
			update_game(message['new_values'], grid_game_id, players_list_id)
		end
		WebsocketRails[message['game_id']].trigger(:update_grid, {grid: controller_store[grid_game_id], players: connection_store[players_list_id]})
	end

private
	def new_player(user, i, j,players_list_id)
		profile = user.profile
		#logger.debug {:user_id => user.id, :i => i, :j => j, :head_color => profile.head_color.to_s, :limbs_color => profile.limbs_color.to_s, :eyes_color => profile.eyes_color.to_s, :body_color => profile.body_color.to_s, :bomb_color => profile.bomb_color.to_s}.inspect
		connection_store[players_list_id] = {:block_type => 'has_player', :user_id => user.id, :head_color => profile.head_color, :limbs_color => profile.limbs_color, :eyes_color => profile.eyes_color, :body_color => profile.body_color, :bomb_color => profile.bomb_color}

		logger.debug connection_store.collect_all(players_list_id)
	end

	def create_grid(grid_game_id)
		grid = []
		# CREO GRID == mapa del juego
		# array que contiene todas las filas las cuales contienen sus columnas
		for i in 0..6
			row = []
			for j in 0..8
				if(((i % 2) != 0) and ((j % 2) != 0))
					row << {:block_type => 'block', :time => 0}
				elsif (j==0 or j==1 or j==7 or j == 8) and (i==0 or i==1 or i==5 or i==6)
					row << {:block_type => 'empty', :time => 0}
				else
					row << {:block_type => 'brick', :time => 0}
				end
			end
			grid << row
		end
		controller_store[grid_game_id] = grid
		return grid
	end

	# data => [[i:j:block_type:time:id]]
	def update_game(new_values, grid_game_id, players_list_id)
		for new_value in new_values
			data = new_value.split(':')
			controller_store[grid_game_id][data[0].to_i][data[1].to_i] = case data[2]
				when 'has_player'
					get_player(data[4].to_i,players_list_id)
				when 'empty'
					{:block_type => 'empty'}
				when 'block'
					{:block_type => 'block'}
				when 'brick'
					{:block_type => 'brick'}
				when 'has_bomb'
					get_bomb(data[4], players_list_id)
				when 'has_explosion'
					{:block_type => data[2], :time => data[3]}
			end
		end
	end

	def get_player(id, players_list_id)
		for player in connection_store.collect_all(players_list_id)
			if player['user_id'] == id
				return player
			end
		end
	end

	def get_bomb(user_id, players_list_id)
		player = get_player(user_id.to_i, players_list_id)
		return {:block_type => 'has_bomb', :time => Time.now.to_i, :user_id => user_id, :bomb_color => player['bomb_color']}
	end

	# ----------------------------------- OLD ------------------------
	# def new_user
	# 	logger.debug '************* NEW USER **************'+message['user_id'].to_s.inspect

	# 	connection_store[:user_id] = message['user_id']
	# 	logger.debug '************* USER LIST **************'+connection_store.collect_all(:user_id).inspect

	# 	WebsocketRails['game_id'].trigger(:new_user, {user_id: message['user_id'], list_users: connection_store.collect_all(:user_id)})
	# 	#broadcast_message :new_user, {user_id: message['user_id'], list_users: connection_store.collect_all(:user_id)}
	# end
	
	# def player_connected
	# 	logger.debug 'PLAYER CONNECTED'
	# 	logger.debug message.inspect
	# 	# envia mensaje al cliente al evento definido con el nombre que se indica con un has de parámetros
	# 	game = Game.find(message['game_id'])
	# 	player = game.players.create!(:user_id => message['user_id'])
	# 	game.grid_elems.first.update_attribute(:block_type, 'has_player')
	# 	send_message :player_connected, {some_values_to_response: 'vale, lo he creado'}
	# end

	# def player_disconnected
	# 	logger.debug 'PLAYER DIS-CONNECTED'+message.inspect
	# 	logger.debug 'PLAYER DIS-CONNECTED => '+message['user_id'].to_s
	# 	user = User.where(:id => message['user_id'].to_s)
	# end

	# def update_movement
	# 	# The `message` method contains the data received
 #    logger.debug message.inspect
 #    if message
 #      send_message :movement_updated, {some_values_to_response: 'values'}
 #    else
 #      send_message :create_fail, task, :namespace => :tasks
 #    end
	# end

	# def update_grid
	# 	iterator = 0
	# 	grid = []
	# 	for row in message['grid']
	# 		row_new = []
	# 		for elem_new in message['grid'][iterator]
	# 			elem_old = GridElem.find(elem_new.split(':').last.to_i)
	# 			# si ha cambiado el elemento del grid, actualizo la bd, si no se queda como está
	# 			if (elem_old.block_type != elem_new.split(':').first)
	# 				elem_new = elem_old.update_attributes(:block_type => elem_new.split(':').first)
	# 				row_new << elem_new.get_type
	# 			else
	# 				# si no ha cambiado, introduzco el de la bd, que siempre estará más actualizado
	# 				row_new << elem_old.get_type
	# 			end
	# 		end
	# 		iterator += 1
	# 		grid << row_new
	# 	end
	# 	send_message :sync_grid, {grid: grid}
	# end

end
