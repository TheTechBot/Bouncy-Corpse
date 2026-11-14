extends Area2D
## Anything that kills the player: slimes, spikes, and the bottom of the world.

## Leave a dead body behind? (false for falling off the map)
@export var leaves_corpse := true


func _on_body_entered(body: Node2D) -> void:
	if body.has_method("die"):
		body.die(leaves_corpse)


func _on_timer_timeout() -> void:
	pass  # kept so old scene connections still work
