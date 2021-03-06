# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
window.game = {
  end : true
  user_id : null
  players : null
  grid : null
  canvas : null
  block_height : 0
  block_width : 0
  new_grid_elems : []
  i_draw : 0
  i_update : 0


  canvas_width : 0
  canvas_height: 0

	key_pressed : null
}
window.game.set_user_id = (user_id) ->
  window.game.user_id = user_id

window.game.canvas_set_size_pc = (canvas) ->
  window.game.canvas = canvas
  canvas.attr('width',Math.floor(canvas.parent().width()))
  canvas.attr('height',Math.floor(canvas.parent().width()/2))
  
  window.game.canvas_height = Math.floor((canvas.parent().width()/2))
  window.game.canvas_width = Math.floor(canvas.parent().width())

  window.game.block_width = Math.floor(window.game.canvas_width / 9)
  window.game.block_height = Math.floor(window.game.canvas_height / 7)

  
window.game.canvas_set_size_touch = (canvas) ->
  $('#controls_description_pc').hide()
  window.game.canvas = canvas
  # si NO estamos en modo lanscape mostramos una alerta y ocultamos el canvas
  width = 0
  height = 0
  width = window.innerWidth
  canvas_width = parseInt(Math.round(width*0.60))
  # tamaño de los controles sobre la pantalla
  table_size = parseInt(Math.floor((width - canvas_width - 20)/3))
  $('.touch_controls').css('min-width', table_size)

  $('table').css('font-size', parseInt((table_size-12)/3))
  # ya tengo el tamaño del dispositivo, calculo tamaños
  canvas.attr('width',canvas_width-20)
  canvas.attr('height', parseInt(Math.floor(canvas_width/2)))
  
  window.game.canvas_width = parseInt(canvas_width - 20)
  window.game.canvas_height = parseInt(Math.floor((window.game.canvas_width /2)))

  window.game.block_width = parseInt(Math.floor(window.game.canvas_width / 9))
  window.game.block_height = parseInt(Math.floor(window.game.canvas_height / 7))
  # dejo el header o barra de navegacion fija arriba y hago scroll despacio hasta el canvas
  
  $("html, body").animate
    scrollTop: $('.game').position()
  , "slow"
  $('nav').removeClass('navbar-fixed-top')
  if window.innerHeight > window.innerWidth
    $('.game').hide()
    $('#turn_device_to_landscape_alert').show()

window.game.listener_change_device_orientation = () ->
  # Cuando cambia la orientación, si está en modo landscape mostramos el canvas, si no una alerta
  window.addEventListener "orientationchange", (->
    if window.innerHeight > window.innerWidth
      $('.game').hide()
      $('#turn_device_to_landscape_alert').show()
    else
      window.game.canvas_set_size_touch(window.game.canvas)
      $('.game').show()
      $('#turn_device_to_landscape_alert').hide()
  ), false
window.game.touch_controls = (controls) ->
  controls.show()
  # move player
  $('.icon-chevron-sign-up').click (e) ->
    window.game.key_pressed = 38
  $('.icon-chevron-sign-right').click (e) ->
    window.game.key_pressed = 39
  $('.icon-chevron-sign-down').click (e) ->
    window.game.key_pressed = 40
  $('.icon-chevron-sign-left').click (e) ->
    window.game.key_pressed = 37
  # place bomb  
  $('.icon-arrow-up').click (e) ->
    window.game.key_pressed = 87
  $('.icon-arrow-right').click (e) ->
    window.game.key_pressed = 68
  $('.icon-arrow-down').click (e) ->
    window.game.key_pressed = 83
  $('.icon-arrow-left').click (e) ->
    window.game.key_pressed = 65


window.game.keyboard_control = () ->
  $(document).keydown (event) ->
    event = window.event or event
    if(((event.keyCode == 68) or (event.keyCode == 87) or (event.keyCode == 83) or (event.keyCode == 65) or (event.keyCode == 37) or (event.keyCode == 38) or (event.keyCode == 39) or (event.keyCode == 40)) and (window.game.key_pressed == null)) 
      window.game.key_pressed = event.keyCode
      event.preventDefault()
      event.stopPropagation()

window.game.draw = (canvas) ->
  canvas.clearCanvas()
  b = new Date().getTime()
  frames = b-window.game.i_draw
  window.game.i_draw = b
  #$('#frames_draw').html('draw FPS: '+Math.round(1000/frames));
  if (window.game.grid != null)
    window.game.draw_grid(canvas, window.game.grid, window.game.players)
  
window.game.draw_grid = (canvas, grid, players) ->
  #recorro el array para saber que dibujar
  x = 0
  y = 0
  i = 0
  j = 0
  for row in grid
    for elem in grid[i]
      # el elemento viene así => type:id ahora solo necesito el type
      switch elem.block_type
        when 'brick'
          window.game.draw_brick(canvas, x, y)
        when 'block'
          window.game.draw_block(canvas, x, y)
        when 'has_bomb'
          if (new Date().getTime()/1000 - elem.time >= 3)
            # si ha transcurrido este tiempo la bomba explota
            window.game.bomb_explosion(i, j, grid)
          else
            window.game.draw_has_bomb(canvas, x, y, elem.bomb_color)
        when 'empty'
          window.game.draw_empty(canvas, x, y)
        when 'has_player'
          window.game.draw_player(canvas, x, y, elem.head_color, elem.eyes_color, elem.body_color, elem.limbs_color)
        when 'has_explosion'
          if (new Date().getTime()/1000 - elem.time >= 2)
            # la explosion permanece un tiempo
            window.conn.update_grid([i+':'+j+':'+'empty'+':'+0])
          else
            window.game.draw_explosion(canvas,x , y)
        else
          window.game.draw_empty(canvas, x, y)
      x += window.game.block_width
      j++
    i++
    j = 0
    x = 0
    y += window.game.block_height

window.game.bomb_explosion = (i, j, grid) ->
  for a in [0,1]
    for b in [-1,+1]
      if ((a == 0) and (((i+b) <= 6) and ((i+b) >= 0)))
        window.game.bomb_explosion_collision(grid[i+b][j], i+b, j)
      else if ((a == 1) and (((j+b) <= 8) and ((j+b) >= 0)))
        window.game.bomb_explosion_collision(grid[i][j+b], i, j+b)
  window.game.new_grid_elems.push(i+':'+j+':'+'has_explosion'+':'+new Date().getTime()/1000)
  window.conn.update_grid(window.game.new_grid_elems)
  console.log window.game.new_grid_elems
  window.game.new_grid_elems = []

window.game.bomb_explosion_collision = (elem, i, j) ->
  try
    console.log 'collision'
    if elem.block_type == 'brick' or elem.block_type == 'empty'
      window.game.new_grid_elems.push(i+':'+j+':'+'has_explosion'+':'+new Date().getTime()/1000)
    else if elem.block_type == 'has_player'
      
      window.game.new_grid_elems.push(i+':'+j+':'+'has_explosion'+':'+new Date().getTime()/1000)
      if elem.user_id == window.game.user_id
        window.game.player_lose()
  catch e
    console.log e
window.game.draw_explosion = (canvas,x , y) ->
  canvas.drawPolygon
    fillStyle: "#36c"
    x: x+(window.game.block_width/2)
    y: y+(window.game.block_height/2)
    radius: window.game.block_height/2 - 4
    sides: 15
    concavity: 0.6
    strokeStyle: "#f60"
    strokeWidth: 2

window.game.draw_number = (canvas ,x, y, i) ->
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

window.game.draw_has_bomb = (canvas, x, y, bomb_color) ->
  width = window.game.block_width*0.6
  height = window.game.block_height*0.6
  x += width*0.8
  y += height
  canvas.drawEllipse(
    fillStyle: bomb_color
    x: x
    y: y
    width: width
    height: height
  ).drawEllipse(
    fillStyle: "black"
    x: x
    y: (y - ((height / 2) + parseInt(height / 12)))
    width: parseInt(width / 6)
    height: parseInt(height / 6)
  ).drawBezier
    strokeStyle: "#000"
    strokeWidth: 5
    x1: x
    y1: y - ((height / 2) + parseInt(height / 12))
    cx1: x + (parseInt(width / 6))
    cy1: y - height
    cx2: x + (parseInt(width / 6) * 2)
    cy2: y - (parseInt(height / 6) * 4)
    x2: x + (parseInt(width / 6) * 3)
    y2: y - (parseInt(height / 6) * 6)

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

window.game.draw_player = (canvas, x, y, head_color, eyes_color, body_color, limbs_color) ->
  width = window.game.block_width*0.3
  height = window.game.block_height*0.3
  x += width*1.6
  y+= height*0.6
  canvas.drawEllipse(
    fillStyle: head_color
    x: x
    y: y
    width: width
    height: height
  ).drawEllipse(
    fillStyle: eyes_color
    x: (x - parseInt(width / 4))
    y: (y - parseInt(height / 6))
    width: parseInt(width * 0.2)
    height: parseInt(height * 0.3)
  ).drawEllipse(
    fillStyle: eyes_color
    x: (x + parseInt(width / 4))
    y: (y - parseInt(height / 6))
    width: parseInt(width * 0.2)
    height: parseInt(height * 0.3)
  ).drawEllipse(
    fillStyle: body_color
    x: x
    y: y + height + height / 2
    width: (width * 2)
    height: (height * 2)
  ).drawEllipse(
    fillStyle: limbs_color
    x: parseInt(x + width)
    y: parseInt((y + (height / 2.8) + height / 3))
    width: parseInt(width * 0.4)
    height: parseInt(height * 0.4)
  ).drawEllipse(
    fillStyle: limbs_color
    x: parseInt(x - width)
    y: parseInt((y + (height / 2.8) + height / 3))
    width: parseInt(width * 0.4)
    height: parseInt(height * 0.4)
  ).drawEllipse(
    fillStyle: limbs_color
    x: parseInt((x + width/1.2))
    y: parseInt(y + height / 1.8 + height * 1.9)
    width: parseInt(width * 0.4)
    height: parseInt(height * 0.4)
  ).drawEllipse
    fillStyle: limbs_color
    x: parseInt((x - width/1.2))
    y: parseInt(y + height / 1.8 + height * 1.9)
    width: parseInt(width * 0.4)
    height: parseInt(height * 0.4)

window.game.update = () ->
  b = new Date().getTime()
  frames = b-window.game.i_update
  window.game.i_update = b
  #$('#frames_update').html('update FPS: '+Math.round(1000/frames));


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
    window.game.key_pressed = null


    #obtengo la posición previa al movimiento
    old_position = window.game.player_actual_position(window.game.grid)
    new_position = [old_position[0]+y, old_position[1]+x]
    #compruebo que se pueda mover
    switch window.game.player_mov_collision(new_position[0], new_position[1], window.game.grid)
      when 'ok'
        # mando la nueva posicion y borro la anterior
        window.game.new_grid_elems.push(new_position[0]+':'+new_position[1]+':'+'has_player'+':'+0+':'+window.game.user_id)
        window.game.new_grid_elems.push(old_position[0]+':'+old_position[1]+':'+'empty'+':'+0)
      when 'die'
        console.log 'USER DIE'
        
        window.game.new_grid_elems.push([old_position[0]+':'+old_position[1]+':'+'empty'+':'+0])
        

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
    if grid[i][j].block_type == 'has_explosion'
      # si choca con una explosion muere
      back = 'die'
    else
      # si choca contra un block o brick u otro player, colisiona
      back = 'collision'
  return back

window.game.disconnect_player = () ->
  old_position = window.game.player_actual_position(window.game.grid)
  window.conn.update_grid([old_position[0]+':'+old_position[1]+':'+'empty'+':'+0])

window.game.player_lose = (gana) ->
  #window.game.connection
  #
  # window.conn.disconnect_player(window.game.user_id)
  
  if (window.game.end)
    window.game.end = false
    $('#trigger_finish_modal').click()
    if(gana != undefined)
      console.log gana
      location.href = '/games/end_game?gana=true'
    else
      location.href = '/games/end_game'