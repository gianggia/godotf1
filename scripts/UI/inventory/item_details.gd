# file: itemDetailPopup.gd
extends Control

@onready var name_label: Label = $NameLabel
@onready var desc_label: Label = $DescLabel
# @onready var icon_rect: TextureRect = $VBoxContainer/IconRect # Nếu có ảnh

func _ready() -> void:
	hide() # Mặc định mới vào game thì ẩn popup này đi

# Hàm để nhận dữ liệu từ ngoài truyền vào và hiển thị lên
func display_item(equipment: ItemEquipment) -> void:
	name_label.text = equipment.item_name
	desc_label.text = equipment.description if equipment.description else "Không có mô tả."
	
	# Nếu có thuộc tính sát thương/giáp thì cộng chuỗi vào mô tả
	if "attack_power" in equipment:
		desc_label.text += "\nSát thương: " + str(equipment.attack_power)
	if "defense" in equipment:
		desc_label.text += "\nPhòng thủ: " + str(equipment.defense)
		
	show() # Bật popup lên
