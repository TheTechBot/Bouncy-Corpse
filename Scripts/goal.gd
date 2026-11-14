extends Area2D

#the trophy at the end

#where to go after this trophy (change it in the inspector)
@export var next_scene = "res://Scense/level2.tscn"

var start_y = 0.0
var time = 0.0


func _ready():
	start_y = position.y


func _process(delta):
	#float up and down
	time += delta
	position.y = start_y + sin(time * 4) * 2


func _on_body_entered(body):
	if body.name == "Player" and GameManager.level_complete == false:
		GameManager.level_complete = true
		GameManager.show_message("YOU BOUNCED BACK!", 2)
		$WinSound.play()
		$AnimatedSprite2D.visible = false
		#super bounce up into the next level!
		body.velocity.y = -700
		await get_tree().create_timer(1.5).timeout
		GameManager.go_to_level(next_scene)
