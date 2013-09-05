# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
window.conn = {
	dispatcher : null
}
window.conn.failure = (response) ->
	console.log 'failure: ' + response.message

window.conn.success = (response)->
	console.log 'success: ' + response.message

window.conn.init_game_connection = (uri) ->
  window.conn.dispatcher = new WebSocketRails('localhost:3000/websocket')

  window.conn.dispatcher.trigger('update_movement', {user_name: 'esto es un parametro', msg_body: 'mensaje para update movement'}, window.conn.success, window.conn.failure)
	
  # estos eventos son llamados desde el servidor
  window.conn.dispatcher.bind 'movement_updated', (msg_data) ->
 		console.log 'successfully created: '+ msg_data.some_values_to_response

 	window.conn.dispatcher.bind 'player_connected', (msg_data) ->
 		console.log 'Evento de crear juagador: '+ msg_data.some_values_to_response

 	window.conn.dispatcher.bind 'player_disconnected', (msg_data) ->
 		console.log 'El jugador '+msg_data.name+' ha abandonado la partida'

 	window.conn.dispatcher.bind 'sync_grid', (msg_data) ->
 		window.game.grid = msg_data.grid

window.conn.create_player = (msg) ->
	console.log 'metodo de crear jugador'
	window.conn.dispatcher.trigger('player_connected', {user_name: 'esto es un parametro', msg_body: msg}, window.conn.success, window.conn.failure)

window.conn.player_leave_page = (user_id) ->
	window.conn.dispatcher.trigger('player_disconnected', {user_id: user_id})

window.conn.sync_grid = (grid) ->
	window.conn.dispatcher.trigger('sync_grid',{grid: grid})
	