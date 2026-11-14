extends Area2D
## The fruit at the end of the level.

const SFX := preload("res://Assets/sounds/power_up.wav")
var done := false


func _process(_delta: float) -> void:
	position.y += sin(Time.get_ticks_msec() / 250.0) * 0.08


func _on_body_entered(body: Node2D) -> void:
	if done or not body.has_method("die"):
		return
	done = true
	GameManager.level_complete = true
	GameManager.play_sfx(SFX, 0.8)
	GameManager.show_message("YOU BOUNCED BACK!", 4.0)
	var t := create_tween()
	t.tween_property(self, "scale", Vector2(2, 2), 0.3)
	t.tween_property(self, "modulate:a", 0.0, 0.3)
