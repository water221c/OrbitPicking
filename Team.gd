extends Label

signal FreeQueue(size: int)

func _on_button_pressed():
	FreeQueue.emit(size.y)
	queue_free()

