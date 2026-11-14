extends CharacterBody2D
## Player: tight platformer physics + the Bouncy Corpse mechanic.
## Die -> your body stays behind -> land on it to bounce back higher.

const SPEED := 130.0
const ACCEL := 900.0            # ground acceleration (px/s^2)
const AIR_ACCEL := 650.0        # control in the air
const FRICTION := 1100.0
const JUMP_VELOCITY := -300.0
const JUMP_CUT := 0.45          # release jump early = shorter jump
const FALL_GRAVITY_MULT := 1.4  # fall faster than you rise (feels snappy)
const MAX_FALL_SPEED := 420.0
const COYOTE_TIME := 0.10       # can still jump just after leaving a ledge
const JUMP_BUFFER := 0.12       # jump pressed just before landing still counts
const BOUNCE_VELOCITY := -470.0       # landing on a corpse
const BOUNCE_VELOCITY_HELD := -540.0  # ...while holding jump
const RESPAWN_DELAY := 0.7
const RESPAWN_GRACE := 0.3     # can't die again right after respawning

const CORPSE_SCENE := preload("res://Scense/corpse.tscn")
const SFX_JUMP := preload("res://Assets/sounds/jump.wav")
const SFX_HURT := preload("res://Assets/sounds/hurt.wav")
const SFX_BOUNCE := preload("res://Assets/sounds/tap.wav")
const SFX_RESPAWN := preload("res://Assets/sounds/power_up.wav")

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var shape: CollisionShape2D = $CollisionShape2D
@onready var camera: Camera2D = get_node_or_null("Camera2D")

var dead := false
var coyote := 0.0
var jump_buffer := 0.0
var was_on_floor := true
var grace := 0.0          # invulnerable time after respawn
var bounce_lock := 0.0    # ignore floor for a moment after a corpse bounce
var base_scale := Vector2.ONE
var spawn_position := Vector2.ZERO


func _ready() -> void:
	base_scale = sprite.scale
	spawn_position = global_position
	if not GameManager.has_checkpoint:
		GameManager.set_checkpoint(global_position)


func _physics_process(delta: float) -> void:
	if dead:
		return
	grace -= delta
	bounce_lock -= delta

	# --- gravity (heavier when falling) ---
	if not is_on_floor():
		var g := get_gravity()
		if velocity.y > 0.0:
			g *= FALL_GRAVITY_MULT
		velocity += g * delta
		velocity.y = min(velocity.y, MAX_FALL_SPEED)

	# --- coyote time + jump buffer ---
	if is_on_floor() and bounce_lock <= 0.0:
		coyote = COYOTE_TIME
	else:
		coyote -= delta
	jump_buffer -= delta
	if Input.is_action_just_pressed("Jump"):
		jump_buffer = JUMP_BUFFER

	if jump_buffer > 0.0 and coyote > 0.0:
		velocity.y = JUMP_VELOCITY
		jump_buffer = 0.0
		coyote = 0.0
		GameManager.play_sfx(SFX_JUMP, randf_range(0.95, 1.05), -4.0)
		squash(Vector2(0.8, 1.2))

	# variable jump height
	if Input.is_action_just_released("Jump") and velocity.y < 0.0:
		velocity.y *= JUMP_CUT

	# --- horizontal movement with acceleration ---
	var direction := Input.get_axis("move_left", "move_right")
	if direction != 0.0:
		var accel := ACCEL if is_on_floor() else AIR_ACCEL
		velocity.x = move_toward(velocity.x, direction * SPEED, accel * delta)
		sprite.flip_h = direction < 0.0
	else:
		velocity.x = move_toward(velocity.x, 0.0, FRICTION * delta)

	var fall_speed := velocity.y
	move_and_slide()

	# --- corpse bounce ---
	for i in get_slide_collision_count():
		var col := get_slide_collision(i)
		var other := col.get_collider()
		if other and other.is_in_group("corpse") and col.get_normal().y < -0.7:
			bounce_on(other)
			break

	# animations (Idle / run / jump from the Pixel Adventure frog)
	if is_on_floor():
		sprite.play("Idle" if absf(velocity.x) < 10.0 else "run")
	else:
		sprite.play("jump")

	# landing squash
	if is_on_floor() and not was_on_floor and fall_speed > 150.0:
		squash(Vector2(1.25, 0.8))
	was_on_floor = is_on_floor()


func bounce_on(corpse: Node) -> void:
	velocity.y = BOUNCE_VELOCITY_HELD if Input.is_action_pressed("Jump") else BOUNCE_VELOCITY
	coyote = 0.0
	jump_buffer = 0.0
	bounce_lock = 0.1
	GameManager.bounces += 1
	GameManager.play_sfx(SFX_BOUNCE, 0.8, 2.0)
	squash(Vector2(0.7, 1.35))
	if corpse.has_method("squish"):
		corpse.squish()


func squash(amount: Vector2) -> void:
	var t := create_tween()
	sprite.scale = base_scale * amount
	t.tween_property(sprite, "scale", base_scale, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


## Called by spikes, slimes and the fall zone.
func die(leave_corpse := true) -> void:
	if dead or grace > 0.0 or GameManager.level_complete:
		return
	dead = true
	velocity = Vector2.ZERO
	shape.set_deferred("disabled", true)
	GameManager.add_death()
	GameManager.play_sfx(SFX_HURT)
	spawn_puff(Color(1, 0.4, 0.4))
	shake_camera()

	if leave_corpse:
		var corpse := CORPSE_SCENE.instantiate()
		corpse.global_position = global_position
		corpse.flip = sprite.flip_h
		get_parent().add_child.call_deferred(corpse)
		GameManager.register_corpse(corpse)

	sprite.visible = false
	Engine.time_scale = 0.6
	await get_tree().create_timer(RESPAWN_DELAY, true, false, true).timeout
	Engine.time_scale = 1.0
	respawn()


func respawn() -> void:
	global_position = GameManager.checkpoint_position
	velocity = Vector2.ZERO
	shape.set_deferred("disabled", false)
	sprite.visible = true
	sprite.modulate = Color(3, 3, 3)
	var t := create_tween()
	t.tween_property(sprite, "modulate", Color.WHITE, 0.35)
	squash(Vector2(0.3, 1.6))
	spawn_puff(Color(0.7, 1, 0.7))
	GameManager.play_sfx(SFX_RESPAWN, 1.2, -6.0)
	if camera:
		camera.reset_smoothing()
	grace = RESPAWN_GRACE
	dead = false


func spawn_puff(color: Color) -> void:
	var p := CPUParticles2D.new()
	p.one_shot = true
	p.emitting = false
	p.amount = 14
	p.lifetime = 0.45
	p.explosiveness = 1.0
	p.direction = Vector2.UP
	p.spread = 180.0
	p.initial_velocity_min = 40.0
	p.initial_velocity_max = 90.0
	p.gravity = Vector2(0, 200)
	p.scale_amount_min = 1.5
	p.scale_amount_max = 2.5
	p.color = color
	p.global_position = global_position + Vector2(5, -4)
	get_parent().add_child(p)
	p.emitting = true
	p.finished.connect(p.queue_free)


func shake_camera() -> void:
	if camera == null:
		return
	var t := create_tween()
	for i in 6:
		t.tween_property(camera, "offset", Vector2(randf_range(-3, 3), randf_range(-3, 3)), 0.03)
	t.tween_property(camera, "offset", Vector2.ZERO, 0.03)
