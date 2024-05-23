extends Node



"""
static var total_coin_amount : int
static var total_aquarq_amount : int

signal on_collectible_award_received
signal on_health_collectible_award_received

# FIXME reinit the variables so they are clear

func give_pickup_award(award_type : String, collectible_award : int):
	match award_type:
		"coin":
			total_coin_amount += collectible_award
			# signal to update coin amount
			on_collectible_award_received.emit("coin", total_coin_amount)

		"aquarq":
			total_aquarq_amount += collectible_award
			on_collectible_award_received.emit("aquarq", total_aquarq_amount)

		"red_sugar":
			on_health_collectible_award_received.emit("red_sugar", collectible_award)
"""
