# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
window.game = {
  players : null
  grid : null
  canvas : null
  block_height : 0
  block_width : 0
  new_grid_elems : []

  bombs : []

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

  window.game.block_width = window.game.canvas_width / 9
  window.game.block_height = window.game.canvas_height / 7

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
  #drawing game grid
  #
  #console.log window.game.grid
  if (window.game.grid != null)
    window.game.draw_grid(canvas)
  
window.game.draw_grid = (canvas) ->
  #recorro el array para saber que dibujar
  x = 0
  y = 0

  iterator = -1
  i = 0
  for row in window.game.grid
    iterator++
    for elem in window.game.grid[iterator]
      # el elemento viene así => type:id ahora solo necesito el type
      switch elem.block_type
        when 'brick'
          window.game.draw_brick(canvas, x, y)
        when 'block'
          window.game.draw_block(canvas, x, y)
        when 'has_bomb'
          window.game.draw_has_bomb(canvas, x, y)
        when 'empty'
          window.game.draw_empty(canvas, x, y)
  
        when 'has_player'
          for player in window.game.players
            if(player['user_id'] == elem.user_id)
              window.game.draw_player(canvas, x, y, player['head_color'])
          
      window.game.draw_number(canvas, x, y, i)
      i++
      x += window.game.block_width
    x = 0
    y += window.game.block_height
window.game.draw_number = (canvas ,x, y, i)->
  canvas.drawText
    #fillStyle: "#9cf"
    layer:true
    strokeStyle: "#25a"
    strokeWidth: 2
    fromCenter:false
    x: x+40
    y: y+20
    fontSize: 16
    fontFamily: "Verdana, sans-serif"
    text: i
window.game.draw_brick = (canvas ,x,y) ->
  canvas.drawRect
    strokeStyle: "#AEB8BA"
    strokeWidth: 1
    fillStyle: "#FFA42D"
    fromCenter: false
    x: x
    y: y
    width: window.game.block_width
    height: window.game.block_height

window.game.draw_empty = (canvas ,x,y) ->
  canvas.drawRect
    strokeStyle: "#AEB8BA"
    strokeWidth: 1
    fillStyle: "#FFFFFF"
    fromCenter: false
    x: x
    y: y
    width: window.game.block_width
    height: window.game.block_height

window.game.draw_has_bomb = (canvas ,x,y) ->
  canvas.drawRect
    strokeStyle: "#AEB8BA"
    strokeWidth: 1
    fillStyle: "#0612FE"
    fromCenter: false
    x: x
    y: y
    width: window.game.block_width
    height: window.game.block_height

window.game.draw_block = (canvas ,x,y) ->
  canvas.drawRect
    strokeStyle: "#AEB8BA"
    strokeWidth: 1
    fillStyle: "#000000"
    fromCenter: false
    x: x
    y: y
    width: window.game.block_width
    height: window.game.block_height

window.game.draw_player = (canvas, x, y, head_color, eyes_colo, body_color, limbs_color) ->
  canvas.drawRect
    strokeStyle: head_color
    strokeWidth: 1
    fillStyle: head_color
    fromCenter: false
    x: x
    y: y
    width: window.game.block_width
    height: window.game.block_height

window.game.update = () ->
  # if (window.game.key_pressed != null)
  #   # solo muevo si pulsa tecla
  #   # guardo en temporal las coordenadas nuevas
  #   x =  window.game.player_1[0][0]
  #   y = window.game.player_1[0][1]
  #   movement_size = 20
  #   switch window.game.key_pressed
  #     when 8
  #       #backspace 8
  #       console.log 'bomba!'
  #     when 37
  #       #left 37
  #       x -= movement_size
  #     when 38
  #       #up 38
  #       y -= movement_size
  #     when 39
  #       #right 39
  #       x += movement_size
  #     when 40
  #       #down 40
  #       y += movement_size
  #   # miro las colisiones
  #   if (!window.game.collisions(x,y))
  #     # si no hay colisiones actualizo las posiciones
  #     window.game.player_1[0][1] = y
  #     window.game.player_1[0][0] = x

  # Sincronizo el grid con el server
  window.conn.update_grid(window.game.new_grid_elems)

window.game.collisions = (player_x, player_y) ->
  collision = false
  #jugador con bordes de pantalla
  if ((player_x <= 0) or (player_x + window.game.players_width >= window.game.canvas_width) or (player_y <= 0) or (player_y + window.game.players_height >= window.game.canvas_height))
    collision = true
  #jugador con bloques
  return collision