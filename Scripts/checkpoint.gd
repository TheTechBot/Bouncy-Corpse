extends Area2D
## Touch the flag -> you respawn here after dying.

const SFX := preload("res://Assets/sounds/power_up.wav")
var active := false

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D


func _on_body_entered(body: Node2D) -> void:
	if active or not body.has_method("die"):
		return
	active = true
	sprite.play("up")
	GameManager.set_checkpoint(global_position + Vector2(-5, -2))
	GameManager.play_sfx(SFX, 1.0, -6.0)
	GameManager.show_message("CHECKPOINT!", 1.5)
