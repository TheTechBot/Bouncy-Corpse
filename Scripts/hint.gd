extends Area2D
## Invisible zone that shows a tip once when the player walks in.

@export_multiline var text := ""
@export var seconds := 4.0
var shown := false


func _on_body_entered(body: Node2D) -> void:
	if shown or not body.has_method("die"):
		return
	shown = true
	GameManager.show_message(text, seconds)
