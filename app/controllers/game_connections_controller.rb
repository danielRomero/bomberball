class GameConnectionsController < WebsocketRails::BaseController
	
	def player_connected
		logger.debug 'PLAYER CONNECTED'
		logger.debug message.inspect
		# envia mensaje al cliente al evento definido con el nombre que se indica con un has de parámetros
		send_message :player_connected, {some_values_to_response: 'vale, lo he creado'}
	end

	def player_disconnected
		logger.debug 'PLAYER DIS-CONNECTED'+message.inspect
		logger.debug 'PLAYER DIS-CONNECTED => '+message['user_id'].to_s
		user = User.where(:id => message['user_id'].to_s)
	end

	def update_movement
		# The `message` method contains the data received
    logger.debug message.inspect
    if message
      send_message :movement_updated, {some_values_to_response: 'values'}
    else
      send_message :create_fail, task, :namespace => :tasks
    end
	end

	def update_grid
		iterator = 0
		grid = []
		for row in message['grid']
			row_new = []
			for elem_new in message['grid'][iterator]
				elem_old = GridElem.find(elem_new.split(':').last.to_i)
				# si ha cambiado el elemento del grid, actualizo la bd, si no se queda como está
				if (elem_old.block_type != elem_new.split(':').first)
					elem_new = elem_old.update_attributes(:block_type => elem_new.split(':').first)
					row_new << elem_new.get_type
				else
					row_new << elem_new
				end
			end
			iterator += 1
			grid << row_new
		end
		send_message :sync_grid, {grid: grid}
	end

end
