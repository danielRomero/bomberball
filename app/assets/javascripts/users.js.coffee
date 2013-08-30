# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
window.user_profile_costomize_bomb = (canvas, bomb_color, explosion_color, width, height) ->
	canvas.clearCanvas()
	x = 20
	y = 20
	canvas.drawEllipse(
	  fillStyle: bomb_color,
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

#user_profile_costomize_bombardier = (canvas, head_color, body_color, limbs_color, eyes_color) ->