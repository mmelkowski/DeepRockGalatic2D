extends CanvasLayer

const MAIN_MENU = preload("res://scenes/screens/main_menu.tscn")


func _process(_delta):
	# to use escape as a way to go back to the game
	if Input.is_action_just_pressed("escape_key") and get_tree().paused:
		print("pause menu escape")
		MissionSelectionHandler.continue_game()
		queue_free()


func _on_continue_button_pressed():
	MissionSelectionHandler.continue_game()
	queue_free()


func _on_main_menu_button_pressed():
	MissionSelectionHandler.main_menu()
	queue_free()


func _on_exit_game_button_pressed():
	MissionSelectionHandler.exit_game()
