extends AnimatedSprite2D

@onready var timer = $Timer



func _ready():
	# init life timer
	timer.start()


func _on_timer_timeout():
	queue_free()
