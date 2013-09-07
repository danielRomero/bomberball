class GameConnectionsController < WebsocketRails::BaseController
	
	def player_disconnected
		logger.debug 'Player disconneted!!!'
		# aquí hay que quitar el player del grid del controller_store
		# sin embargo del connection_store se elimina automáticamente el player
	end

	def player_connected		
		logger.debug 'Player conneted!!!'
		connection_store[:user_id] = message['user_id']

	end

	def update_grid
		logger.debug 'MENSAJE => '+message.inspect
		logger.debug '************* USER LIST **************'+connection_store.collect_all(:user_id).inspect
		# si es el primer usuario conectado creo el grid y le digo que estamos esperando a más usuarios
		controller_store[:grid]
		# si solo hay un usuario y no se ha creado antes el grid, lo creo
		if((connection_store.collect_all(:user_id).count <= 1) and (controller_store[:grid].blank?))
			grid = create_grid
		else
			# si hay más de un usuario paso a actualizar el grid
			grid = grid_comparison(message['grid'], controller_store[:grid])
		end
		# actualizo el store del grid
		controller_store[:grid] = grid 
		WebsocketRails[message['game_id']].trigger(:update_grid, {grid: grid})
	end

	def create_grid
		grid = []
		# CREO GRID
		# array que contiene todas las filas las cuales contienen sus columnas
		for i in 0..6
			row = []
			for j in 0..8
				if(((i % 2) != 0) and ((j % 2) != 0))
					row << {:block_type => 'block', :time => 0}
				elsif (j==0 or j==1 or j==7 or j == 8) and (i==0 or i==1 or i==5 or i==6)
					if ((i == 0) and (j == 0))
						row << {:block_type => 'has_player', :time => 0}
					else
						row << {:block_type => 'empty', :time => 0}
					end

				else
					row << {:block_type => 'brick', :time => 0}
				end
			end
			grid << row
		end
		logger.debug ' ===================  EL GRID ======================'
		#logger.debug grid
		return grid
	end

	def grid_comparison(new_grid, old_grid)
		return controller_store[:grid]
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
