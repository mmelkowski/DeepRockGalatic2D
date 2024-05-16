extends CharacterBody2D


# Signal for bullet spawning
signal weapon_shot(projectile_scene, location, angle, zdex, base_damage)

# signal for healthbar update
signal hp_changed(new_hp)
signal has_died

# Physics const
const SPEED = 130.0
const JUMP_VELOCITY = -300.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# On ready var for location, hp, etc...
@onready var animated_sprite = $AnimatedSprite2D
@onready var hitbox_feet = $hitbox/CollisionShape2D
@onready var hurtbox = $hurtbox/CollisionShape2D

@export var hp_max = 100
@export var hp = hp_max: set = _set_health, get = _get_health

@onready var main = owner
@onready var projectile_scene = preload("res://scenes/projectile.tscn")


"""
FUNCTION
"""

func _ready():
	add_to_group("Player")


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	if Input.is_action_just_pressed("left_click"):
		#animated_sprite.play("death")
		shoot()
		
	# Get the input direction and handle the movement/deceleration.
	var direction = Input.get_axis("move_left", "move_right")

	# Flip the sprite
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true

	# Play animations
	if is_on_floor():
		hitbox_feet.disabled = true
		if direction == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("run")
	else:
		animated_sprite.play("jump")
		hitbox_feet.disabled = false

	# Aply movement
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

"""
Health setget
"""

func _set_health(value):
	if value != hp:
		hp = clamp(value,0 ,hp_max)
		hp_changed.emit(hp)
		if hp == 0:
			has_died.emit()


func _get_health():
	return hp

func _on_hurtbox_area_entered(hitbox):
	var base_damage = hitbox.get_parent().base_damage
	self.hp -= base_damage
	print(hitbox.get_parent().name + " hitbox touched " + name + "hurtbox and deal " + str(base_damage))


"""
Shoot/damage
"""

func shoot():
	# TO DO: Change the global_position for the muzzle of the weapon
	var weapon_damage = 30
	weapon_shot.emit(
		projectile_scene, 
		global_position,
		global_position.angle_to_point(get_global_mouse_position()),
		z_index,
		weapon_damage
		)


func die():
	get_tree().reload_current_scene()


func _on_has_died():
	die()
