extends CharacterBody2D


const SPEED = 130.0
const JUMP_VELOCITY = -300.0
const BOUNCE_VELOCITY = -470.0 #when u land on a dead body
const BIG_BOUNCE_VELOCITY = -540.0 #if u hold jump when u land on a body

var dead_body = preload("res://Scense/corpse.tscn")
var is_dead = false
var can_die = true

@onready var animated_sprite = $AnimatedSprite2D
@onready var jump_sound = $JumpSound
@onready var hurt_sound = $HurtSound
@onready var bounce_sound = $BounceSound


func _ready():
	#the start of the level is the first checkpoint
	if GameManager.has_checkpoint == false:
		GameManager.checkpoint_position = global_position
		GameManager.has_checkpoint = true


func _physics_process(delta: float) -> void:
	if is_dead:
		return

	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		#fall a bit faster (feels better)
		if velocity.y > 0:
			velocity += get_gravity() * delta * 0.4

	# Handle jump.
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		jump_sound.play()

	#get directions = 1,0,-1
	var direction := Input.get_axis("move_left", "move_right")
	#flip the sprite
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true
	#play animations
	if is_on_floor():
		if direction == 0:
			animated_sprite.play("Idle")
		else:
			animated_sprite.play("run")
	else:
		animated_sprite.play("jump")
	#apply movment
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

	#did we land on top of a dead body?
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var thing = collision.get_collider()
		if thing.is_in_group("corpse") and collision.get_normal().y < -0.7:
			bounce()


func bounce():
	if Input.is_action_pressed("Jump"):
		velocity.y = BIG_BOUNCE_VELOCITY
	else:
		velocity.y = BOUNCE_VELOCITY
	bounce_sound.play()
	GameManager.bounces += 1


#spikes, slime and water call this
func die(leave_body):
	if is_dead or can_die == false or GameManager.level_complete:
		return
	print("You died!")
	is_dead = true
	GameManager.deaths += 1
	hurt_sound.play()

	#leave a dead body where we died
	if leave_body:
		var body = dead_body.instantiate()
		body.global_position = global_position
		get_parent().add_child.call_deferred(body)
		GameManager.add_body(body)

	animated_sprite.visible = false
	$CollisionShape2D.set_deferred("disabled", true)
	Engine.time_scale = 0.5
	await get_tree().create_timer(0.35).timeout
	Engine.time_scale = 1.0
	respawn()


func respawn():
	global_position = GameManager.checkpoint_position
	velocity = Vector2.ZERO
	animated_sprite.visible = true
	$CollisionShape2D.set_deferred("disabled", false)
	$Camera2D.reset_smoothing()
	is_dead = false
	#cant die for a tiny bit after respawn (we had a bug where u died 2 times)
	can_die = false
	await get_tree().create_timer(0.3).timeout
	can_die = true
