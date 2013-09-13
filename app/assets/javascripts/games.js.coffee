# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
window.game = {
  user_id : null
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
window.game.set_user_id = (user_id) ->
  window.game.user_id = user_id
window.game.canvas_set_size_pc = (canvas) ->
  canvas.attr('width',Math.floor(canvas.parent().width()))
  canvas.attr('height',Math.floor(canvas.parent().width()/2))
  
  window.game.canvas_height = Math.floor((canvas.parent().width()/2))
  window.game.canvas_width = Math.floor(canvas.parent().width())

  window.game.block_width = Math.floor(window.game.canvas_width / 9)
  window.game.block_height = Math.floor(window.game.canvas_height / 7)

  
window.game.canvas_set_size_touch = (canvas) ->
  # si NO estamos en modo lanscape mostramos una alerta y ocultamos el canvas
  width = 0
  height = 0
  if window.innerHeight > window.innerWidth
    canvas.hide()
    $('#turn_device_to_landscape_alert').show()
    # el alto pasa a ser el ancho y viceversa para calcular el tamaño del canvas
    height = window.innerWidth
    width = window.innerHeight
  else
    # obtengo el alto y ancho para calcular el tamaño del canvas
    height = window.innerHeight
    width = window.innerWidth
  # ya tengo el tamaño del dispositivo, calculo tamaños
  canvas.attr('width',Math.floor(width))
  canvas.attr('height',Math.floor(width/2))
  
  window.game.canvas_height = Math.floor((width/2))
  window.game.canvas_width = Math.floor(width)

  window.game.block_width = Math.floor(window.game.canvas_width / 9)
  window.game.block_height = Math.floor(window.game.canvas_height / 7)
  # dejo el header o barra de navegacion fija arriba y hago scroll despacio hasta el canvas
  $('nav').removeClass('navbar-fixed-top')
  $("html, body").animate
    scrollTop: canvas.position().top
  , "slow"

window.game.listener_change_device_orientation = (canvas) ->
  # Cuando cambia la orientación, si está en modo landscape mostramos el canvas, si no una alerta
  window.addEventListener "orientationchange", (->
    if window.innerHeight > window.innerWidth
      canvas.hide()
      $('#turn_device_to_landscape_alert').show()
    else
      canvas.show()
      $('#turn_device_to_landscape_alert').hide()
  ), false

window.game.keyboard_control = () ->
  $(document).keydown (event) ->
    event = window.event or event
    if(((event.keyCode == 68) or (event.keyCode == 87) or (event.keyCode == 83) or (event.keyCode == 65) or (event.keyCode == 37) or (event.keyCode == 38) or (event.keyCode == 39) or (event.keyCode == 40)) and (window.game.key_pressed == null)) 
      window.game.key_pressed = event.keyCode
      event.preventDefault()
      event.stopPropagation()

  $(document).keyup (event) ->
  	window.game.key_pressed = null

window.game.draw = (canvas) ->
  canvas.clearCanvas()
  if (window.game.grid != null)
    window.game.draw_grid(canvas, window.game.grid, window.game.players)
  
window.game.draw_grid = (canvas, grid, players) ->
  #recorro el array para saber que dibujar
  x = 0
  y = 0

  iterator = -1
  i = 0
  for row in grid
    iterator++
    for elem in grid[iterator]
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
          window.game.draw_player(canvas, x, y, elem.head_color)
        else
          window.game.draw_empty(canvas, x, y)
          
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
  canvas.drawEllipse
    strokeStyle: "#AEB8BA"
    strokeWidth: 1
    fillStyle: "#0612FE"
    fromCenter: false
    x: x
    y: y
    width: window.game.block_width/2
    height: window.game.block_height/2

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
  if (window.game.key_pressed != null and window.game.grid != null)
    # solo muevo si pulsa tecla
    x = 0
    y = 0
    switch window.game.key_pressed
      when 37
        # left 37
        x = -1
      when 38
        # up 38
        y = -1
      when 39
        # right 39
        x = +1
      when 40
        # down 40
        y = +1
      when 65
        # a 65
        window.game.place_bomb([0,-1], window.game.grid)
      when 87
        # w 87
        window.game.place_bomb([-1,0], window.game.grid)

      when 83
        # s 83
        window.game.place_bomb([+1,0], window.game.grid)

      when 68
        # d 68
        window.game.place_bomb([0,+1], window.game.grid)


    #obtengo la posición previa al movimiento
    old_position = window.game.player_actual_position(window.game.grid)
    new_position = [old_position[0]+y, old_position[1]+x]
    #compruebo que se puda mover
    switch window.game.player_mov_collision(new_position[0], new_position[1], window.game.grid)
      when 'ok'
        # mando la nueva posicion y borro la anterior
        window.game.new_grid_elems.push(new_position[0]+':'+new_position[1]+':'+'has_player'+':'+0+':'+window.game.user_id)
        window.game.new_grid_elems.push(old_position[0]+':'+old_position[1]+':'+'empty'+':'+0)
      when 'die'
        console.log 'USER DIE'
    window.conn.update_grid(window.game.new_grid_elems)
    window.game.new_grid_elems = []
window.game.player_actual_position = (grid) ->
  i = -1
  for row in grid
    i++
    j = 0
    for elem in row
      if((elem.block_type == 'has_player') and (elem.user_id == window.game.user_id))
        return [i,j]
      j++

# poner una bomba
window.game.place_bomb = (bomb_position, grid) ->
  actual_position = window.game.player_actual_position(grid)
  future_position = [actual_position[0]+bomb_position[0], actual_position[1]+bomb_position[1]]
  if ((future_position[0] >= 0) and (future_position[0] <= 6) and (future_position[1] >= 0) and (future_position[1] <= 8))
    # solo surge efecto si está vacío el lugar donde colocar la bomba
    if(grid[future_position[0]][future_position[1]].block_type == 'empty')
      window.conn.update_grid([future_position[0]+':'+future_position[1]+':'+'has_bomb'+':'+3+':'+window.game.user_id])
      console.log 'bomb_placed'

# estudiando los casos de colisiones
window.game.player_mov_collision = (i, j, grid) ->
  back = 'ok'
  # si se sale del mapa
  if((j < 0) or (j > 8) or (i < 0) or (i > 6))
    back = 'collision'
  else if(grid[i][j].block_type != 'empty')
    if grid[i][j].block_type == 'explosion'
      # si choca con una explosion muere
      back = 'die'
    else
      # si choca contra un block o brick u otro player, colisiona
      back = 'collision'
  return back

window.game.disconnect_player = () ->
  old_position = window.game.player_actual_position(window.game.grid)
  window.conn.update_grid([old_position[0]+':'+old_position[1]+':'+'empty'+':'+0])
  
