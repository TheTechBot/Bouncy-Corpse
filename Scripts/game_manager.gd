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

	#R = restart
	if Input.is_action_just_pressed("restart"):
		restart()


func restart():
	score = 0
	deaths = 0
	bounces = 0
	has_checkpoint = false
	level_complete = false
	bodies.clear()
	message_time = 0
	get_tree().reload_current_scene()
