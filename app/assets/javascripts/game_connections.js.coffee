# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
window.conn = {
	dispatcher : null
	channel_name : ''
	channel : null
}

window.conn.init_connection = (game_id, user_id, host) ->
	#host => 'localhost:3000/websocket'
	window.conn.dispatcher = new WebSocketRails(host+'/websocket')
	window.conn.channel_name = game_id
	#subscribe this client to a channel with name GAME_ID
	window.conn.channel = window.conn.dispatcher.subscribe(window.conn.channel_name)
	window.conn.connect_player(user_id)

	# --- this events are called from server controller
	window.conn.channel.bind 'update_grid', (msg) ->
		console.log 'grid updated'
		window.game.grid = msg.grid
		window.game.players = msg.players

	window.conn.channel.bind 'player_win', (msg)  ->
		window.game.player_win()

window.conn.update_grid = (new_grid_elems) ->
	window.conn.dispatcher.trigger('update_grid', {new_values: new_grid_elems, game_id: window.conn.channel_name})

window.conn.connect_player = (user_id) ->
	window.conn.dispatcher.trigger('connect_player', {user_id: user_id, game_id: window.conn.channel_name})

window.conn.disconnect_player = (user_id) ->
	window.conn.dispatcher.trigger('disconnect_player', {user_id: user_id, game_id: window.conn.channel_name})
	#window.conn.dispatcher.unsubscribe(window.conn.channel_name)

# ----------------------------------------- OLD -------------------------------------
#window.conn.failure = (response) ->
#	console.log 'failure: ' + response.message

#window.conn.success = (response)->
#	console.log 'success: ' + response.message

#window.conn.init_game_connection = (uri) ->
#  window.conn.dispatcher = new WebSocketRails('localhost:3000/websocket')

#  window.conn.dispatcher.trigger('update_movement', {user_name: 'esto es un parametro', msg_body: 'mensaje para update movement'}, window.conn.success, window.conn.failure)
	
# estos eventos son llamados desde el servidor
#  window.conn.dispatcher.bind 'movement_updated', (msg_data) ->
# 		console.log 'successfully created: '+ msg_data.some_values_to_response
#
# 	window.conn.dispatcher.bind 'player_connected', (msg_data) ->
# 		console.log 'Evento de crear juagador: '+ msg_data.some_values_to_response

# 	window.conn.dispatcher.bind 'player_disconnected', (msg_data) ->
# 		console.log 'El jugador '+msg_data.name+' ha abandonado la partida'

# 	window.conn.dispatcher.bind 'sync_grid', (msg_data) ->
# 		window.game.grid = msg_data.grid

#window.conn.create_player = (msg) ->
#	console.log 'metodo de crear jugador'
#	window.conn.dispatcher.trigger('player_connected', {user_id: msg, game_id: window.game.game_id}, window.conn.success, window.conn.failure)

#window.conn.player_leave_page = (user_id) ->
#	window.conn.dispatcher.trigger('player_disconnected', {user_id: user_id})

#window.conn.sync_grid = (grid) ->
#	window.conn.dispatcher.trigger('sync_grid',{grid: grid})


	
window.conn.pruebas = (user_id) ->
	dispatcher = new WebSocketRails('localhost:3000/websocket')
	#subscribe this client to a channel with name GAME_ID
	channel = dispatcher.subscribe('game_id')
	
	dispatcher.trigger('new_user', {user_id: user_id}, window.conn.success, window.conn.failure)
	
	channel.bind 'new_user', (msg) ->
		$('#pruebas_1').append(msg.user_id)
		$('#pruebas_2').append(msg.list_users[0])
		#alert typeof msg.list_users
		console.log msg.list_users

	