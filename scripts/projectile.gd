extends CharacterBody2D

var SPEED = 15000
@onready var lifespan_timer = $lifespan_timer

var projectileLifeSpan = 2
var dir : float
var spawnPos : Vector2
var spawnRot : float
var zdex : int
var base_damage : float
var die_on_env_collision = true


func _ready():
	global_position = spawnPos
	global_rotation = spawnRot
	z_index = zdex
	# init life timer
	lifespan_timer.start(projectileLifeSpan)


func _physics_process(delta):
	# Remove projectile if it collide with wall
	if (is_on_wall() or is_on_floor() or is_on_ceiling()) and die_on_env_collision:
		die()
	velocity = Vector2(0,-SPEED * delta).rotated(dir)
	move_and_slide()


# Use to destroy projectile upon colliding with enemy
func _on_hitbox_area_entered(_area):
	die()


# Destroy projectile after time so the projectile can go outside the screen 
# and still kill enemy
func _on_lifespan_timer_timeout():
	die()


func die():
	queue_free()
