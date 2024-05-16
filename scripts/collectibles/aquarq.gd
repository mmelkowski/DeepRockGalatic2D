extends Area2D

@onready var animation_player = $AnimationPlayer

# Get the gravity from the project settings to be synced with RigidBody nodes.

var award_amount : int = 1

# FIXME make a body so the collectible can fall
"""
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	velocity.y += gravity * delta
	move_and_slide()
"""


func _on_body_entered(_body):
	CollectibleManager.give_pickup_award("aquarq", award_amount)
	animation_player.play("pickup")

