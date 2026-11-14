extends Area2D

#untick this in the inspector if u dont want a body (we use that for the water)
@export var leaves_body = true


func _on_body_entered(body):
	if body.has_method("die"):
		body.die(leaves_body)
