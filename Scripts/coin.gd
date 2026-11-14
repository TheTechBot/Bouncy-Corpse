extends Area2D

var taken = false


func _on_body_entered(body):
	if body.name == "Player" and taken == false:
		taken = true
		GameManager.add_point()
		$AnimatedSprite2D.visible = false
		$CoinSound.play()
		await $CoinSound.finished
		queue_free()
