extends CanvasLayer

@onready var coin_count_label = $MarginContainer/VBoxContainer/HBoxContainer/coin_count_label
@onready var aquarq_count_label = $MarginContainer/VBoxContainer/HBoxContainer/aquarq_count_label


func _ready():
	CollectibleManager.on_collectible_award_received.connect(on_collectible_award_received)


func on_collectible_award_received(award_type : String, total_award : int):
	match award_type:
		"coin":
			coin_count_label.text = str(total_award)

		"aquarq":
			aquarq_count_label.text = str(total_award)

"""
func on_coin_award_received(total_award : int):
	coin_count_label.text = str(total_award)
"""
