extends Area2D

@onready var animation_player = $AnimationPlayer

var award_amount : int = 1

func _on_body_entered(_body):
	animation_player.play("pickup")
	CollectibleManager.give_pickup_award("coin", award_amount)
