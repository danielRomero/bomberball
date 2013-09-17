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

	