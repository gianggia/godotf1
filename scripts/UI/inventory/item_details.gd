# file: itemDetailPopup.gd
extends Control

#@onready var name_label: Label = $NameLabel
@onready var desc_label: Label = $DescLabel
# @onready var icon_rect: TextureRect = $VBoxContainer/IconRect # Nếu có ảnh

func _ready() -> void:
	hide() # Mặc định mới vào game thì ẩn popup này đi

# Hàm để nhận dữ liệu từ ngoài truyền vào và hiển thị lên
func display_item(inv_item: Variant) -> void:
	if inv_item == null:
		hide()
		return
		
	var equipment: ItemEquipment = null
	if "item_data" in inv_item:
		equipment = inv_item.item_data
		
	if equipment == null:
		print("❌ Lỗi: Không tìm thấy dữ liệu ItemEquipment tĩnh!")
		return

	# --- ĐỌC DỮ LIỆU ĐỘ HIẾM VÀ ĐỔI MÀU CHỮ ---
	var rarity_text = "Common"
	var text_color = Color.WHITE # Màu mặc định là Trắng nếu không tìm thấy file cấu hình
	
	if equipment.rarity != null:
		# Lấy thông tin trực tiếp từ Object tài nguyên .tres đã nạp trong RAM ở hàm from_dict
		if "rarity_name" in equipment.rarity:
			rarity_text = equipment.rarity.resource_name if equipment.rarity.resource_name != "" else equipment.rarity.rarity_name
		
		# 🌟 LẤY MÀU SẮC ĐÃ CẤU HÌNH TỪ FILE TRES
		if "rarity_color" in equipment.rarity:
			text_color = equipment.rarity.rarity_color
	elif "rarity_name" in inv_item:
		rarity_text = inv_item.rarity_name
		
	# Gán văn bản hiển thị tên
	#name_label.text = "[" + str(rarity_text) + "] " + str(equipment.item_name)
	
	# 🌟 ÉP MÀU CHỮ CỦA LABEL THAY ĐỔI THEO FILE .TRES
	#name_label.add_theme_color_override("font_color", text_color)
	desc_label.add_theme_color_override("font_color",text_color)
	# --- CÁC ĐOẠN ĐỌC SỐ LƯỢNG / BONUS_STATS GIỮ NGUYÊN ---
	var qty = 1
	if "quantity" in inv_item: qty = inv_item.quantity

	var stats_text = equipment.description if equipment.description else "Vật phẩm trang bị."
	stats_text += "\nSố lượng: " + str(qty)
	
	if "base_attack" in equipment and equipment.base_attack > 0:
		stats_text += "\nSát thương gốc: " + str(equipment.base_attack)
	if "base_defense" in equipment and equipment.base_defense > 0:
		stats_text += "\nPhòng thủ gốc: " + str(equipment.base_defense)

	var raw_bonus_stats = inv_item.bonus_stats if "bonus_stats" in inv_item else (equipment.bonus_stats if "bonus_stats" in equipment else null)

	if raw_bonus_stats is Dictionary and not raw_bonus_stats.is_empty():
		stats_text += "\n\n--- THUỘC TÍNH NGẪU NHIÊN ---"
		for stat_name in raw_bonus_stats.keys():
			var stat_value = raw_bonus_stats[stat_name]
			stats_text += "\n+ " + str(stat_name) + ": " + str(stat_value)
	desc_label.label_settings.font_color=text_color
	desc_label.text = stats_text
	show()
