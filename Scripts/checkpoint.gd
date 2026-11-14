extends Area2D

var touched = false


func _on_body_entered(body):
	if body.name == "Player" and touched == false:
		touched = true
		$AnimatedSprite2D.play("up")
		GameManager.checkpoint_position = global_position + Vector2(-5, -2)
		GameManager.show_message("CHECKPOINT!", 1.5)
