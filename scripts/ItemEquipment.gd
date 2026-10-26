class_name ItemEquipment
extends ItemData

@export_group("Base Stats")
@export var base_attack: int = 10
@export var base_defense: int = 0

# English Bonus Stats Dictionary: { "Display Name": Rolled_Value }
var bonus_stats: Dictionary = {} 

# Function to get full name with random stats in English
func get_display_name() -> String:
	var final_name = item_name
	if not bonus_stats.is_empty():
		final_name += " ("
		for key in bonus_stats:
			final_name += "+" + str(bonus_stats[key]) + " " + str(key) + ", "
		final_name = final_name.rstrip(", ") + ")"
	return final_name
