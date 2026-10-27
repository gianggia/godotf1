# File: LootGenerator.gd
extends Node

# Drag and drop 'global_stat_db.tres' here in Inspector
@export var stat_db: StatModifier
@export var rarities: Array[ItemRarity] = []

func _get_random_rarity() -> ItemRarity:
	if rarities.is_empty(): return null
	var total_weight: float = 0.0
	for rarity in rarities:
		if rarity != null: total_weight += rarity.drop_chance
		
	var rolled_weight: float = randf_range(0.0, total_weight)
	var current_weight_sum: float = 0.0
	
	for rarity in rarities:
		if rarity == null: continue
		current_weight_sum += rarity.drop_chance
		if rolled_weight <= current_weight_sum: return rarity
	return rarities[0]

# Giữ nguyên tên hàm cũ để Godot không bị lỗi cache tìm hàm
func generate_equipment(base_item_res: ItemEquipment) -> ItemEquipment:
	var rarity_res: ItemRarity = _get_random_rarity()
	if rarity_res == null: return null
		
	# 1. Nhân bản khuôn đồ gốc trong RAM
	var new_item: ItemEquipment = base_item_res.duplicate()
	new_item.rarity = rarity_res
	new_item.bonus_stats = {} 
	
	# Kiểm tra database tổng và kiểm tra xem loại đồ này có được định nghĩa dòng ẩn không
	if stat_db == null or not stat_db.stat_database.has(new_item.equipment_type):
		return new_item
		
	# 2. Quyết định số lượng dòng ẩn dựa trên độ hiếm
	var num_of_affixes: int = 0
	match rarity_res.rarity_name:
		"Common": num_of_affixes = 1
		"Rare": num_of_affixes = randi_range(1, 2)
		"Epic": num_of_affixes = randi_range(2, 3)
		"Legendary": num_of_affixes = 4

	# LẤY ĐÚNG DANH SÁCH MÃ CHỈ SỐ CỦA LOẠI ĐỒ ĐÓ (Ví dụ: "Weapon", "Armor", "Boots")
	var type_pool: Dictionary = stat_db.stat_database[new_item.equipment_type]
	var available_keys: Array = type_pool.keys()
	
	# 3. Vòng lặp roll stats ngẫu nhiên không trùng dòng
	for i in range(num_of_affixes):
		if available_keys.is_empty(): break
		
		var random_key = available_keys.pick_random()
		available_keys.erase(random_key) 
		
		# Lấy mảng dữ liệu [Tên_Hiển_Thị, Min, Max] từ Pool của loại đồ đó
		var stat_info: Array = type_pool[random_key]
		var display_name: String = stat_info[0]
		
		# Tính toán khoảng Dynamic dựa trên hệ số độ hiếm
		var dynamic_min: float = float(stat_info[1]) * rarity_res.stat_multiplier
		var dynamic_max: float = float(stat_info[2]) * rarity_res.stat_multiplier
		
		# Lăn xúc xắc và ép về số nguyên cứng
		var rolled_float_value: float = randf_range(dynamic_min, dynamic_max)
		var final_int_value: int = roundi(rolled_float_value)
	
		new_item.bonus_stats[display_name] = final_int_value
		
	return new_item
