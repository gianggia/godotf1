extends Node
# File: LootGenerator.gd

# Drag and drop 'global_stat_db.tres' here in Inspector
@export var stat_db: StatModifier

func generate_weapon(base_weapon_res: ItemEquipment, rarity_res: ItemRarity) -> ItemEquipment:
	# 1. Duplicate the base item to create a unique instance in RAM
	var new_weapon: ItemEquipment = base_weapon_res.duplicate()
	new_weapon.rarity = rarity_res
	new_weapon.bonus_stats = {} 
	
	if stat_db == null or stat_db.stat_database.is_empty():
		return new_weapon
		
	# 2. Determine number of affixes based on English Rarity Name
	var num_of_affixes: int = 0
	match rarity_res.rarity_name:
		"Common": num_of_affixes = 0
		"Rare": num_of_affixes = 1
		"Epic": num_of_affixes = 2
		"Legendary": num_of_affixes = 3

	# 3. Get all stat codes available
	var available_keys: Array = stat_db.stat_database.keys()
	
	# 4. Roll random stats loop
	for i in range(num_of_affixes):
		if available_keys.is_empty(): break
		
		var random_key = available_keys.pick_random()
		available_keys.erase(random_key) 
		
		# Lấy mảng dữ liệu [Tên_Hiển_Thị, Min, Max] từ Dictionary
		var stat_info: Array = stat_db.stat_database[random_key]
		
		# SỬA LẠI ĐOẠN NÀY: Chỉ định rõ vị trí index trong mảng, [1], [2]
		var display_name: String = stat_info[0]
		var min_val: int = stat_info[1]
		var max_val: int = stat_info[2]
		
		# Lăn xúc xắc giá trị ngẫu nhiên
		var rolled_value: int = randi_range(min_val, max_val)
	
		new_weapon.bonus_stats[display_name] = rolled_value
		
	return new_weapon
