extends Area2D

#the trophy at the end

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
		GameManager.show_message("YOU BOUNCED BACK!", 4)
		$WinSound.play()
		$AnimatedSprite2D.visible = false
