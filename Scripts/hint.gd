extends Area2D

#invisible box. when the player walks in it shows the riddle text

@export_multiline var text = ""
@export var seconds = 6.0
var shown = false


func _on_body_entered(body):
	if body.name == "Player" and shown == false:
		shown = true
		GameManager.show_message(text, seconds)
