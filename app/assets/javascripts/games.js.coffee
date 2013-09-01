# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
window.game = {
	key_pressed : false
}
window.game.canvas_set_size = (canvas) ->
	canvas.attr('width',canvas.parent().width());
	canvas.attr('height',canvas.parent().width()/2);

window.game.keyboard_control = (canvas) ->
	$(document).keypress (event) ->
    window.game.key_pressed = event.keyCode
    console.log window.game.key_pressed
  $(document).keyup (event) ->
  	window.game.key_pressed = false
  	console.log window.game.key_pressed
  	
window.game.start_game = (canvas) ->