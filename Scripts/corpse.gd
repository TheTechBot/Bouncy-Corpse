extends CharacterBody2D

#this is the dead body. it falls down and stays there.
#the player bounces on it (look at bounce() in player.gd)


func _ready():
	add_to_group("corpse")
	$Sprite2D.modulate = Color(0.6, 0.6, 0.7) #grey so it looks dead


func _physics_process(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta
	velocity.x = 0
	move_and_slide()
