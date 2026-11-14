extends CanvasLayer

@onready var coins: Label = $Top/Coins
@onready var deaths: Label = $Top/Deaths
@onready var msg: Label = $Message
var msg_tween: Tween


func _ready() -> void:
	GameManager.score_changed.connect(func(s): coins.text = "Coins: %d" % s)
	GameManager.deaths_changed.connect(func(d): deaths.text = "Bodies: %d" % d)
	GameManager.message.connect(_on_message)
	coins.text = "Coins: %d" % GameManager.score
	deaths.text = "Bodies: %d" % GameManager.deaths
	msg.modulate.a = 0.0


func _on_message(text: String, seconds: float) -> void:
	msg.text = text
	if msg_tween:
		msg_tween.kill()
	msg_tween = create_tween()
	msg.modulate.a = 1.0
	msg.scale = Vector2(1.3, 1.3)
	msg_tween.tween_property(msg, "scale", Vector2.ONE, 0.2)
	if seconds < 900.0:
		msg_tween.tween_interval(seconds)
		msg_tween.tween_property(msg, "modulate:a", 0.0, 0.4)
