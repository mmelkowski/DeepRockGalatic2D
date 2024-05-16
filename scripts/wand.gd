extends Area2D

var damage = 30

func _physics_process(_delta):
	look_at(get_global_mouse_position())
