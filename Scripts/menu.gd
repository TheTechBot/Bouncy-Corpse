extends Control


func _ready():
	$Center/Box/Start.grab_focus() #so u can press enter too


func _on_start_pressed():
	GameManager.new_game()
	get_tree().change_scene_to_file("res://Scense/game.tscn")


func _on_quit_pressed():
	get_tree().quit()
