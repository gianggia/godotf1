# File: ItemEquipment.gd (hoặc ItemBase.gd nơi bạn định nghĩa cấu trúc vật phẩm)
class_name ItemEquipment
extends ItemData

@export var item_id: String = ""             # Dùng để tra cứu khi Save/Load JSON
			 # <--- THÊM DÒNG NÀY ĐỂ SỬA LỖI INVALID ASSIGNMENT


# Thêm loại trang bị để phân biệt khi đúc đồ và mặc đồ
@export_enum("Weapon", "Armor", "Boots") var equipment_type: String = "Weapon"

@export var base_attack: float = 0.0
@export var base_defense: float = 0.0
@export var bonus_stats: Dictionary = {}



## Function to get full name with random stats in English
#func get_display_name() -> String:
	#var final_name = item_name
	#if not bonus_stats.is_empty():
		#final_name += " ("
		#for key in bonus_stats:
			#final_name += "+" + str(bonus_stats[key]) + " " + str(key) + ", "
		#final_name = final_name.rstrip(", ") + ")"
	#return final_name
