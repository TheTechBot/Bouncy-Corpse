extends Node

#this is an autoload so every script can use it (Project Settings > Globals)

var score = 0
var deaths = 0
var bounces = 0
var checkpoint_position = Vector2.ZERO
var has_checkpoint = false
var level_complete = false
var bodies = []

var message_text = ""
var message_time = 0.0


func add_point():
	score += 1


func add_body(body):
	bodies.append(body)
	#too many bodies = lag so delete the oldest one
	if bodies.size() > 12:
		var oldest = bodies[0]
		bodies.remove_at(0)
		if is_instance_valid(oldest):
			oldest.queue_free()


func show_message(text, seconds):
	message_text = text
	message_time = seconds


func _process(delta):
	if message_time > 0:
		message_time -= delta

	#only in a level (the menu and the end screen dont have a Player)
	var in_level = get_tree().current_scene != null and get_tree().current_scene.has_node("Player")

	#R = restart the level
	if Input.is_action_just_pressed("restart") and in_level:
		restart()

	#ESC = back to menu
	if Input.is_action_just_pressed("ui_cancel") and in_level:
		go_to_menu()


#clears everything from the level we were in
func reset_level():
	has_checkpoint = false
	level_complete = false
	bodies.clear()
	message_time = 0
	Engine.time_scale = 1.0 #just in case we left while dying (slow motion)


#called by the start button
func new_game():
	score = 0
	deaths = 0
	bounces = 0
	reset_level()


func restart():
	reset_level()
	get_tree().reload_current_scene()


func go_to_level(path):
	reset_level()
	get_tree().change_scene_to_file(path)


func go_to_menu():
	reset_level()
	get_tree().change_scene_to_file("res://Scense/menu.tscn")
