extends CanvasLayer


func _on_play_button_pressed():
	MissionSelectionHandler.start_game()
	queue_free()


func _on_option_button_pressed():
	print("No options yet =S")


func _on_exit_button_pressed():
	MissionSelectionHandler.exit_game()
