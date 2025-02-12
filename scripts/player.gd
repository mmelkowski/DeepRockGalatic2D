extends CharacterBody2D


# Signal for bullet spawning
signal weapon_shot(projectile_scene, location, angle, zdex, base_damage)

# signal for healthbar update
signal hp_changed(new_hp)
signal has_died
signal to_pause

#export (pas sur si nécéssaire)

# Physics const
const SPEED = 130.0
const JUMP_VELOCITY = -300.0
const POGO_JUMP_VELOCITY = -350.0
const POGO_BOUNCE_VELOCITY = -250.0
const CLIMB_SPEED = 70.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

#@onready var main = owner

# On ready var for node location
@onready var animated_sprite = $AnimatedSprite2D
@onready var hitbox_feet = $hitbox/CollisionShape2D
@onready var hurtbox = $hurtbox/CollisionShape2D
@onready var mining_pickaxe = $mining_pickaxe
@onready var ladder_check = $ladderCheck


# Player Health var
var hp_max = 100
var hp = hp_max: set = _set_health, get = _get_health
var knockback_vector = Vector2(500, 0)
var motion = Vector2()

# Player damages
var base_damage = 0
var damage_received : float
@onready var hurtbox_timer = $hurtboxTimer

# WATER_GUN
@onready var water_gun = $water_gun
@onready var projectile_scene = preload("res://scenes/projectile.tscn")
@onready var end_of_water_gun = $water_gun/EndOfWeapon
@onready var water_gun_animation_player = $water_gun/AnimationPlayer
@onready var water_gun_sprite = $water_gun/Sprite2D
@onready var water_gun_cooldown = $water_gun/cooldown

# POGO
@onready var pogo_sprite = $pogo_stick/Sprite2D
static var jumb_buffered: bool

# VACUUM
@onready var vacuum = $vacuum
@onready var end_of_vacuum = $vacuum/EndOfWeapon
@onready var vacuum_sprite = $vacuum/Sprite2D
@onready var vacuum_animation_player = $vacuum/AnimationPlayer
@onready var vacuum_cooldown = $vacuum/cooldown
var vacuum_array = []

# Weapon var
@onready var weapon_equiped = water_gun
@onready var end_of_weapon = end_of_water_gun
@onready var weapon_animation_player = water_gun_animation_player
@onready var weapon_equiped_sprite = water_gun_sprite
@onready var weapon_equiped_cooldown = water_gun_cooldown
var weapon_equiped_left_click_action = "shoot"

# Mining var
@onready var mining_pick_marker = $mining_pickaxe/mining_pick_marker
@onready var mining_timer = $mining_pickaxe/miningTimer
@onready var mining_pick_animation_player = $mining_pickaxe/AnimationPlayer

@onready var tilemap_to_mine = get_node("/root/Game/TileMap")
var mining_start_pos : Vector2i
@onready var mining_animation_scene = preload("res://scenes/mining_animation.tscn")
var mining_animation : Object

# platform
var platform_layer = 6

# Create const for each state (here MOVE = 0, CLIMB = 1)
enum {
	MOVE,
	CLIMB,
	POGO,
}
# initialise state in MOVE
var state = MOVE

"""
FUNCTION
"""

func _ready():
	add_to_group("Player")
	
	# set correct weapon display
	switch_visibility("weapon")
	vacuum.visible = false


func _physics_process(delta):
	# Reset collision with platform
	set_collision_mask_value(platform_layer, true)
	
	# show pause menu
	if Input.is_action_just_pressed("escape_key"):
		to_pause.emit()

	# Flip the sprite to follow mouse
	if get_global_mouse_position().x > global_position.x:
		animated_sprite.flip_h = false
		weapon_equiped_sprite.flip_v = false
	elif get_global_mouse_position().x < global_position.x:
		animated_sprite.flip_h = true
		weapon_equiped_sprite.flip_v = true

	# weapon management
	if Input.is_action_just_pressed("weapon_1"):
		state = MOVE
		move_state(delta)
		switch_weapon("water_gun")
		switch_visibility("weapon")
	elif Input.is_action_just_pressed("weapon_2"):
		state = MOVE
		move_state(delta)
		switch_weapon("vacuum")
		switch_visibility("weapon")
	elif Input.is_action_just_pressed("weapon_3"):
		state = POGO
		pogo_state(delta)
	elif Input.is_action_just_pressed("weapon_4"):
		pass

	# shoot with weapon
	if Input.is_action_pressed("left_click"):
		if state == POGO:
			state = MOVE

		if weapon_equiped.visible != true:
			switch_visibility("weapon")

		if weapon_equiped_left_click_action == "shoot":
			shoot()
		elif weapon_equiped_left_click_action == "vacuum":
			if Input.is_action_pressed("left_control"):
				vacuum_release_action()
			else:
				vacuum_suck_action()

	# Mining
	if Input.is_action_pressed("right_click"):
		switch_visibility("mining_pickaxe")
		if state == POGO:
			state = MOVE
		mine()
	if mining_timer.time_left > 0:
		mine()

	match state:
		MOVE:
			pogo_sprite.visible = false
			move_state(delta)
		CLIMB:
			pogo_sprite.visible = false
			climb_state(delta)
		POGO:
			pogo_state(delta)


"""
State
"""

func move_state(delta):
	if is_on_ladder() and Input.is_action_pressed("move_up"):
		state = CLIMB

	# Add the gravity
	if not is_on_floor():
		velocity.y += gravity * delta
		if Input.is_action_pressed("move_down"):
			# Remove collision with platform
			set_collision_mask_value(platform_layer, false)

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		if Input.is_action_pressed("move_down"):
			# Remove collision with platform
			set_collision_mask_value(platform_layer, false)
		else:
			velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	var direction = Input.get_axis("move_left", "move_right")

	# Play animations
	if is_on_floor():
		hitbox_feet.disabled = true
		if direction == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("run")
	else:
		# TODO squash jump animation
		animated_sprite.play("jump")
		hitbox_feet.disabled = false

	# Aply movement
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	move_and_slide()


func climb_state(_delta):
	if not is_on_ladder():
		state = MOVE
	# Get the input direction and handle the movement/deceleration.
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	# Aply movement
	#print("direction: ", direction)
	if direction:
		velocity = direction * CLIMB_SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, CLIMB_SPEED)
		velocity.y = move_toward(velocity.y, 0, CLIMB_SPEED)
		# Play animations
		# FIXME animation don't transition from previous animation to climb anim
		if direction == Vector2(0,0):
			# need climbing stance
			animated_sprite.play("climb_idle")
		else:
			# animation is not continu
			animated_sprite.play("climb_move")
			
	move_and_slide()


func pogo_state(delta):
	switch_visibility("pogo")
	if is_on_ladder() and Input.is_action_pressed("move_up"):
		state = CLIMB

	# Handle jump.
	if Input.is_action_pressed("jump"):
		jumb_buffered = true

	# Add the gravity
	if not is_on_floor():
		velocity.y += gravity * delta
		if Input.is_action_pressed("move_down"):
			# Remove collision with platform
			set_collision_mask_value(platform_layer, false)
	else:
		if jumb_buffered:
			velocity.y = POGO_JUMP_VELOCITY
			jumb_buffered = false
		else:
			velocity.y = POGO_BOUNCE_VELOCITY

		
	if Input.is_action_pressed("move_down"):
		# Remove collision with platform
		set_collision_mask_value(platform_layer, false)

	# Get the input direction and handle the movement/deceleration.
	var direction = Input.get_axis("move_left", "move_right")

	# Play animations
	if is_on_floor():
		animated_sprite.play("idle")
	else:
		animated_sprite.play("jump")

	# Apply movement
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


"""
MOVE ladder
"""

func is_on_ladder():
	if not ladder_check.is_colliding():
		return false
	else:
		return true

"""
hurtbox
"""

func _on_hurtbox_area_entered(hitbox_enemy):
	if hurtbox_timer.time_left > 0:
		return null
	else:
		hurtbox_timer.start()
	# Knockback
	knockback(hitbox_enemy.global_position)
	# Health update
	damage_received = hitbox_enemy.get_parent().base_damage
	self.hp -= damage_received
	#print(hitbox_enemy.get_parent().name + " hitbox touched " + name + "hurtbox and deal " + str(base_damage))


func knockback(hit_pos):
	# FIXME play animation hit
	animated_sprite.play("hit")
	# knockback from hit
	var knockback_vector_on_hurt = knockback_vector.rotated(global_position.angle_to_point(hit_pos))
	velocity.y = knockback_vector_on_hurt.y - 250
	velocity.x = knockback_vector_on_hurt.x
	#print("knockback_vector_on_hurt: ", knockback_vector_on_hurt)
	move_and_slide()


func _on_hurtbox_timer_timeout():
	hurtbox_timer.stop()

"""
Shoot/damage
"""

func shoot():
	if weapon_equiped_cooldown.time_left == 0:
		weapon_equiped_cooldown.start()
		weapon_shot.emit(
			projectile_scene, 
			end_of_weapon.global_position,
			end_of_weapon.global_position.angle_to_point(get_global_mouse_position()),
			z_index,
			weapon_equiped.damage
			)
		# Play weapon shot animation
		weapon_animation_player.play("shooting")

func _on_cooldown_timeout():
	weapon_equiped_cooldown.stop()

func mine():
	"""
	# Maybe try to just use math to get mining location instead of permanent marker
	var angle = global_position.angle_to_point(get_global_mouse_position())
	var mining_dist = Vector2(20, 0)
	var mining_point = global_position + mining_dist
	#mining_point = mining_point.rotated(angle)
	"""
	# Play mining pickaxe animation
	mining_pick_animation_player.play("mining")
	if not Input.is_action_pressed("right_click"):
		mining_timer.stop()
		mining_animation.queue_free()
		return null

	# Condition to stop animation if selected square change
	elif mining_timer.time_left > 0 and tilemap_to_mine.local_to_map(mining_pick_marker.global_position) != mining_start_pos:
		mining_timer.stop()
		mining_animation.queue_free()
		return null

	# So destruction happen after 1sec of mining
	elif mining_timer.time_left == 0:
		mining_timer.start()
		mining_start_pos = tilemap_to_mine.local_to_map(mining_pick_marker.global_position)

		# if tile is empty --> stop
		if tilemap_to_mine.get_cell_source_id(1, mining_start_pos) == -1:
			mining_timer.stop()
			if mining_animation != null:
				mining_animation.queue_free()
			return null

		mining_animation = mining_animation_scene.instantiate()

		# tile coord to global coord
		mining_animation.global_position.x = (mining_start_pos.x * 16) + 8
		mining_animation.global_position.y = (mining_start_pos.y * 16) + 8

		# set node to be on the top node to avoid moving with player
		mining_animation.top_level = true

		# spawn animation on tile
		add_child(mining_animation)


func _on_mining_timer_timeout():
	mining_timer.stop()	
	if (mining_start_pos == tilemap_to_mine.local_to_map(mining_pick_marker.global_position)
		and Input.is_action_pressed("right_click")):
		tilemap_to_mine.set_cell(1, tilemap_to_mine.local_to_map(mining_pick_marker.global_position))


# TODO Vacuum function
func vacuum_suck_action():
	var tile_to_get = tilemap_to_mine.local_to_map(get_global_mouse_position())
	var block_type = tilemap_to_mine.get_cell_atlas_coords(1, tile_to_get)
	if block_type != Vector2i(-1, -1) and vacuum_array.size() < 5:
		vacuum_array.append(block_type)
		tilemap_to_mine.set_cell(1, tile_to_get)
		# Update progress bar
		WeaponManager.vacuum_update(vacuum_array.size())
		weapon_animation_player.play("shooting")


func vacuum_release_action():
	var tile_to_set = tilemap_to_mine.local_to_map(get_global_mouse_position())
	var block_type = tilemap_to_mine.get_cell_atlas_coords(1, tile_to_set)
	if block_type == Vector2i(-1, -1) and vacuum_array.size() > 0:
		var block_type_to_set = vacuum_array.pop_back()
		# FIXME Somehow the block value is correct but nothing appear
		tilemap_to_mine.set_cell(1, tile_to_set, 0, block_type_to_set)
		# Update progress bar
		WeaponManager.vacuum_update(vacuum_array.size())
		weapon_animation_player.play("shooting")


func die():
	get_tree().reload_current_scene()

func _on_has_died():
	die()


func switch_visibility(tool: String):
	match tool:
		"weapon":
			print("switching to weapon equiped ", weapon_equiped)
			mining_pickaxe.visible = false
			weapon_equiped.visible = true
			pogo_sprite.visible = false
		"mining_pickaxe":
			mining_pickaxe.visible = true
			weapon_equiped.visible = false
			pogo_sprite.visible = false
		"pogo":
			mining_pickaxe.visible = false
			weapon_equiped.visible = false
			pogo_sprite.visible = true


func switch_weapon(weapon: String):
	match weapon:
		"water_gun":
			weapon_equiped.visible = false
			weapon_equiped = water_gun
			end_of_weapon = end_of_water_gun
			weapon_animation_player = water_gun_animation_player
			weapon_equiped_sprite = water_gun_sprite
			weapon_equiped_cooldown = water_gun_cooldown
			weapon_equiped_left_click_action = "shoot"

		"vacuum":
			weapon_equiped.visible = false
			weapon_equiped = vacuum
			end_of_weapon = end_of_vacuum
			weapon_animation_player = vacuum_animation_player
			weapon_equiped_sprite = vacuum_sprite
			weapon_equiped_cooldown = vacuum_cooldown
			weapon_equiped_left_click_action = "vacuum"
