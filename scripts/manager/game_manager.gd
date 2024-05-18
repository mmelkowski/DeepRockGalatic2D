extends Node

# TODO See if it is usefull
var player = null

@onready var projectile_container = $"../ProjectileContainer"
@onready var healthbar = $"../gameScreen/MarginContainer/VBoxContainer/Control/healthbar"
@onready var camera_2d = $"../Player/Camera2D"
@onready var killzone = $"../Killzone"

const PAUSE_MENU = preload("res://scenes/screens/pause_menu.tscn")
var PAUSE_MENU_instance : CanvasLayer

# Quantity to hp value var
var red_sugar_amount_to_hp: int = 40
var health_pickup_amount_to_hp: int = 50


func _ready():
	player = get_tree().get_first_node_in_group("player")
	#assert(player != null)
	# on player signal "weapon_shot" use func "_on_player_weapon_shot"
	player.weapon_shot.connect(_on_player_weapon_shot)
	
	# connect signal for health pickup
	CollectibleManager.on_health_collectible_award_received.connect(on_health_collectible_award_received)

	# set camera limit to killzone
	camera_2d.limit_bottom = killzone.position.y


func _on_player_weapon_shot(projectile_scene, location, angle, zdex, base_damage):
	var projectile = projectile_scene.instantiate()
	# dir is rotated by 90 deg (1.5708 rad)
	projectile.dir = angle + 1.5708
	# spawn pos is offset by 8 pixel to shoot from player
	projectile.spawnPos = location #+ Vector2(0,-8)
	projectile.spawnRot = angle
	projectile.zdex = zdex - 1
	projectile.base_damage = base_damage
	projectile_container.add_child.call_deferred(projectile)


# to update helthbar
func _on_player_hp_changed(new_hp):
	healthbar.value = new_hp


func _on_player_to_pause():
	print("game manager player pressed pause")
	MissionSelectionHandler.pause_game()


func on_health_collectible_award_received(type: String, amount: int):
	match type:
		"red_sugar":
			player.hp += amount * red_sugar_amount_to_hp
		"health_pickup":
			player.hp += amount * health_pickup_amount_to_hp

