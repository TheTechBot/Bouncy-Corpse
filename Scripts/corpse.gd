extends CharacterBody2D
## A dead body left behind. It falls, lands, stacks on other bodies,
## and acts as a trampoline for the living player.

var flip := false

@onready var sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	add_to_group("corpse")
	sprite.flip_h = flip
	sprite.modulate = Color(0.55, 0.6, 0.7)


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
		velocity.y = min(velocity.y, 420.0)
	else:
		velocity.y = 0.0
	velocity.x = 0.0
	move_and_slide()


func squish() -> void:
	var t := create_tween()
	sprite.scale = Vector2(1.3, 0.6)
	t.tween_property(sprite, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)


func vanish() -> void:
	remove_from_group("corpse")
	var t := create_tween()
	t.tween_property(self, "modulate:a", 0.0, 0.4)
	t.tween_callback(queue_free)
