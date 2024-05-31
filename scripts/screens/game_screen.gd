extends CanvasLayer

@onready var coin_count_label = $MarginContainer/VBoxContainer/HBoxContainer/coin_count_label
@onready var aquarq_count_label = $MarginContainer/VBoxContainer/HBoxContainer/aquarq_count_label
@onready var vacuum_progress_bar = $MarginContainer/VBoxContainer/vacuum_control/TextureProgressBar


func _ready():
	CollectibleManager.on_collectible_award_received.connect(on_collectible_award_received)
	WeaponManager.on_vacuum_update.connect(on_vacuum_update)


func on_collectible_award_received(award_type : String, total_award : int):
	match award_type:
		"coin":
			coin_count_label.text = str(total_award)

		"aquarq":
			aquarq_count_label.text = str(total_award)


func on_vacuum_update(amount: int):
	# use ax+b to slide the value to fit with the bar where a is 0.84 and b 0.47
	vacuum_progress_bar.value = (amount * 0.84) + 0.47
