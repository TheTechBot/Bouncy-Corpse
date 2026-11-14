extends Control

var time = 0.0


func _ready():
	$Buttons/Start.grab_focus() #so u can also press enter


func _process(delta):
	#make the frog bounce on the dead frog :)
	time += delta
	$Frog.position.y = 372 - abs(sin(time * 3)) * 60


func _on_start_pressed():
	GameManager.new_game()
	get_tree().change_scene_to_file("res://Scense/game.tscn")


func _on_quit_pressed():
	get_tree().quit()
