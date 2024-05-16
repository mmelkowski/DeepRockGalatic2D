extends Node

var level = preload("res://scenes/game.tscn")
const MAIN_MENU = preload("res://scenes/screens/main_menu.tscn")
var MAIN_MENU_instance : CanvasLayer
const PAUSE_MENU = preload("res://scenes/screens/pause_menu.tscn")
var PAUSE_MENU_instance : CanvasLayer


func start_game():
	if get_tree().paused:
		get_tree().paused = false
	
	transition_to_scene(level.resource_path)


func exit_game():
	get_tree().quit()


func transition_to_scene(scene_path):
	await get_tree().create_timer(0.3).timeout
	get_tree().change_scene_to_file(scene_path)


func pause_game():
	get_tree().paused = true
	PAUSE_MENU_instance = PAUSE_MENU.instantiate()
	get_tree().get_root().add_child(PAUSE_MENU_instance)


func continue_game():
	get_tree().paused = false


func main_menu():
	MAIN_MENU_instance = MAIN_MENU.instantiate()
	get_tree().get_root().add_child(MAIN_MENU_instance)
