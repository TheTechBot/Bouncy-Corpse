extends Control


func _ready():
	$Back.grab_focus()
	#go back to the menu by itself after a few seconds
	await get_tree().create_timer(8).timeout
	GameManager.go_to_menu()


func _on_back_pressed():
	GameManager.go_to_menu()
