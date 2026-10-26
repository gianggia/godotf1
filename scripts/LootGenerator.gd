class_name LootGenerator
extends Node

# Danh sách tất cả các dòng ẩn có thể xuất hiện trong game (Kéo thả các file mod_.tres vào đây)
@export var all_modifiers: Array[StatModifier] = []

func generate_weapon(base_weapon_res: ItemEquipment, rarity_res: ItemRarity) -> ItemEquipment:
	# BẮT BUỘC: Nhân bản (Duplicate) file gốc để tránh việc sửa một cây kiếm làm tất cả cây kiếm khác bị sửa theo
	var new_weapon = base_weapon_res.duplicate()
	new_weapon.rarity = rarity_res
	
	# Xác định số lượng dòng ẩn dựa trên Độ hiếm (Ví dụ: Đồ trắng 0 dòng, Đồ cam 3 dòng)
	var num_of_affixes = 0
	match rarity_res.rarity_name:
		"normal": num_of_affixes = 0
		"rage": num_of_affixes = 1
		"epic": num_of_affixes = 2
		"legend": num_of_affixes = 3

	# Tiến hành găm dòng ngẫu nhiên vào món đồ
	var available_mods = all_modifiers.duplicate()
	for i in range(num_of_affixes):
		if available_mods.size() == 0: break
		
		# Chọn ngẫu nhiên 1 loại dòng (ví dụ: dòng Công)
		var random_mod = available_mods.pick_random()
		available_mods.erase(random_mod) # Xóa để không bị trùng dòng
		
		# Lăn xúc xắc lấy chỉ số ngẫu nhiên trong khoảng (Range) cho phép
		var rolled_value = randi_range(random_mod.min_value, random_mod.max_value)
		
		# Lưu vào túi chỉ số của món đồ
		new_weapon.bonus_stats[random_mod.stat_name] = rolled_value
		
	return new_weapon
