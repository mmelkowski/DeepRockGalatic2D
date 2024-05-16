extends Node2D

const SPEED = 60

var direction = 1
@onready var ray_cast_right = $RayCast_right
@onready var ray_cast_left = $RayCast_left
@onready var animated_sprite = $AnimatedSprite2D

var is_alive = true

var hp_max = 100
var hp = hp_max: set = _set_health, get = _get_health
var base_damage = 40
var received_damage : float

# signal to use die function
signal has_died


func _ready():
	add_to_group("enemy")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if ray_cast_right.is_colliding():
		direction = -1
		animated_sprite.flip_h = true

	elif ray_cast_left.is_colliding():
		direction = 1
		animated_sprite.flip_h = false

	position.x += direction * SPEED * delta


func _on_hurtbox_area_entered(hitbox):
	# add check for in group of projectile
	received_damage = hitbox.get_parent().base_damage
	self.hp -= received_damage
	#print(hitbox.get_parent().name + " hitbox touched " + name + "hurtbox and deal " + str(received_damage))


func _set_health(value):
	if value != hp:
		hp = clamp(value,0 ,hp_max)
		if hp <= 0:
			has_died.emit()


func _get_health():
	return hp


func _on_has_died():
	die()


func die():
	queue_free()
