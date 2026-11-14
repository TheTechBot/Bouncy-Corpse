extends CanvasLayer


func _process(delta):
	$Top/Coins.text = "Coins: " + str(GameManager.score)
	$Top/Deaths.text = "Bodies: " + str(GameManager.deaths)

	#the big text in the middle (riddles, checkpoint, win)
	if GameManager.message_time > 0:
		$Message.text = GameManager.message_text
		$Message.visible = true
	else:
		$Message.visible = false
