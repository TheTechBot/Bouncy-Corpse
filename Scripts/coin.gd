extends Area2D

const SFX_COIN := preload("res://Assets/sounds/coin.wav")
var taken := false


func _on_body_entered(body: Node2D) -> void:
	if taken or not body.has_method("die"):
		return
	taken = true
	GameManager.add_point()
	GameManager.play_sfx(SFX_COIN, randf_range(0.95, 1.1), -4.0)
	var t := create_tween()
	t.tween_property(self, "position:y", position.y - 10.0, 0.2)
	t.parallel().tween_property(self, "modulate:a", 0.0, 0.2)
	t.tween_callback(queue_free)
