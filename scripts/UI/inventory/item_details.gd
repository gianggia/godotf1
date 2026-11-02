extends Control

#@onready var name_label: Label = $NameLabel
@onready var desc_label: Label = $DescLabel

@onready var icon_frame: Control = $IconFrame


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

	# --- ĐỌC DỮ LIỆU ĐỘ HIẾM VÀ ĐỔI MÀU ---
	var rarity_text = "Common"
	var rarity_color := Color.WHITE

	if equipment.rarity != null:
		if "rarity_name" in equipment.rarity:
			rarity_text = equipment.rarity.resource_name if equipment.rarity.resource_name != "" else equipment.rarity.rarity_name
		if "rarity_color" in equipment.rarity:
			rarity_color = equipment.rarity.rarity_color
	elif "rarity_name" in inv_item:
		rarity_text = inv_item.rarity_name

	# Tên + màu độ hiếm (chỉ tên và viền đổi màu, phần mô tả giữ màu giấy da)
	desc_label.text = "[" + str(rarity_text) + "] " + str(equipment.item_name)
	desc_label.add_theme_color_override("font_color", rarity_color)

	# Viền popup đổi theo độ hiếm
	var box := get_theme_stylebox("panel").duplicate() as StyleBoxFlat
	if box:
		box.border_color = rarity_color
		add_theme_stylebox_override("panel", box)

	# Icon: thử vài tên property phổ biến, ẩn khung nếu không có
	var tex: Texture2D = null
	for prop in ["icon", "texture"]:
		if prop in equipment and equipment.get(prop) is Texture2D:
			tex = equipment.get(prop)
			break
	
	icon_frame.visible = tex != null

	# --- SỐ LƯỢNG / CHỈ SỐ ---
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

	desc_label.text = stats_text
	show()
	# Thu/giãn panel cho vừa nội dung mới
	reset_size.call_deferred()
