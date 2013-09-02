# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
window.game = {
  players_width : 50
  players_height : 50

  # los valores son coordenadas, el primero es el jugador y el segundo la bomba
  player_1 : [[10,10],[0,0]]
  player_2 : [[0,0],[0,0]]
  player_3 : [[0,0],[0,0]]
  player_4 : [[0,0],[0,0]]

  canvas_width : 0
  canvas_height: 0
	key_pressed : null
}

window.game.canvas_set_size = (canvas) ->
  canvas.attr('width',canvas.parent().width())
  canvas.attr('height',canvas.parent().width()/2)
  window.game.canvas_height = (canvas.parent().width()/2)
  window.game.canvas_width = canvas.parent().width()

window.game.keyboard_control = (canvas) ->
	$(document).keypress (event) ->
    if((event.keyCode == 8) or (event.keyCode == 37) or (event.keyCode == 38) or (event.keyCode == 39) or (event.keyCode == 40)) 
      window.game.key_pressed = event.keyCode
      event.preventDefault()
      event.stopPropagation()

  $(document).keyup (event) ->
  	window.game.key_pressed = null
  	console.log window.game.key_pressed

window.game.draw = (canvas) ->
  canvas.clearCanvas();
  # drawing player 1
  canvas.drawRect
    strokeStyle: "#000000"
    strokeWidth: 4
    fromCenter: false
    x: window.game.player_1[0][0]
    y: window.game.player_1[0][1]
    width: window.game.players_width
    height: window.game.players_height

window.game.update = (canvas) ->
  if (window.game.key_pressed != null)
    # solo muevo si pulsa tecla
    # guardo en temporal las coordenadas nuevas
    x =  window.game.player_1[0][0]
    y = window.game.player_1[0][1]
    switch window.game.key_pressed
      when 8
        #backspace 8
        console.log 'bomba!'
      when 37
        #left 37
        x -= 1 
      when 38
        #up 38
        y -= 1
      when 39
        #right 39
        x += 1
      when 40
        #down 40
        y += 1
    # miro las colisiones
    if (!window.game.collisions(x,y))
      # si no hay colisiones actualizo las posiciones
      window.game.player_1[0][1] = y
      window.game.player_1[0][0] = x

window.game.collisions = (player_x, player_y) ->
  collision = false
  #jugador con bordes de pantalla
  if ((player_x <= 0) or (player_x + window.game.players_width >= window.game.canvas_width) or (player_y <= 0) or (player_y + window.game.players_height >= window.game.canvas_height))
    collision = true
  #jugador con bloques
  return collision