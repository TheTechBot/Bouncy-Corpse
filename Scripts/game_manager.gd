extends Node
## Global game state. Registered as the "GameManager" autoload.

signal score_changed(score: int)
signal deaths_changed(deaths: int)
signal message(text: String, seconds: float)

const MAX_CORPSES := 12  # oldest body disappears when you pass this

var score := 0
var deaths := 0
var bounces := 0
var checkpoint_position := Vector2.ZERO
var has_checkpoint := false
var level_complete := false
var corpses: Array[Node] = []


func reset() -> void:
	score = 0
	deaths = 0
	bounces = 0
	has_checkpoint = false
	level_complete = false
	corpses.clear()
	score_changed.emit(score)
	deaths_changed.emit(deaths)


func add_point() -> void:
	score += 1
	score_changed.emit(score)


func add_death() -> void:
	deaths += 1
	deaths_changed.emit(deaths)


func set_checkpoint(pos: Vector2) -> void:
	checkpoint_position = pos
	has_checkpoint = true


func register_corpse(corpse: Node) -> void:
	corpses.append(corpse)
	while corpses.size() > MAX_CORPSES:
		var old = corpses.pop_front()
		if is_instance_valid(old):
			old.vanish()


func show_message(text: String, seconds := 2.5) -> void:
	message.emit(text, seconds)


func play_sfx(stream: AudioStream, pitch := 1.0, volume_db := 0.0) -> void:
	if stream == null:
		return
	var p := AudioStreamPlayer.new()
	p.stream = stream
	p.pitch_scale = pitch
	p.volume_db = volume_db
	add_child(p)
	p.finished.connect(p.queue_free)
	p.play()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("restart"):
		reset()
		get_tree().reload_current_scene()
