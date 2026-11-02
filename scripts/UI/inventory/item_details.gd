extends PanelContainer
## Bảng chi tiết vật phẩm dạng "bottom sheet" cho điện thoại dọc.
## Đặt tại: res://scripts/UI/inventory/item_details.gd

const COLOR_LABEL := Color(0.88, 0.83, 0.72)
const COLOR_VALUE := Color(1.0, 0.86, 0.45)
const COLOR_BONUS := Color(0.55, 0.95, 0.55)
const MARGIN := 8.0

# Tên hiển thị cho các thuộc tính ngẫu nhiên (key trong JSON -> chữ hiển thị).
# Key nào không có trong bảng sẽ tự đổi "crit_chance" thành "Crit chance".
const STAT_NAMES := {
	"attack": "Sát thương",
	"defense": "Phòng thủ",
	"hp": "Máu",
	"health": "Máu",
	"mana": "Mana",
	"speed": "Tốc độ",
	"crit_chance": "Tỉ lệ chí mạng",
}

@onready var icon_frame: PanelContainer = %IconFrame
@onready var icon_rect: TextureRect = %IconRect
@onready var name_label: Label = %NameLabel
@onready var rarity_label: Label = %RarityLabel
@onready var desc_label: Label = %DescLabel
@onready var stats_list: VBoxContainer = %StatsList
@onready var bonus_header: Label = %BonusHeader
@onready var bonus_list: VBoxContainer = %BonusList
@onready var close_button: Button = %CloseButton


func _ready() -> void:
	close_button.pressed.connect(hide)
	hide() # Mặc định mới vào game thì ẩn popup này đi
	_dock_to_bottom()
	# ItemDetails mặc định là node đầu tiên của InventoryUI nên bị lưới đồ vẽ đè.
	# Đưa xuống cuối danh sách con để luôn nằm trên cùng.
	var p := get_parent()
	if p:
		p.move_child.call_deferred(self, -1)


# Dán bảng vào đáy vùng cha, rộng hết bề ngang; chiều cao tự nở lên theo nội dung
func _dock_to_bottom() -> void:
	anchor_left = 0.0
	anchor_right = 1.0
	anchor_top = 1.0
	anchor_bottom = 1.0
	grow_horizontal = Control.GROW_DIRECTION_BOTH
	grow_vertical = Control.GROW_DIRECTION_BEGIN
	offset_left = MARGIN
	offset_right = -MARGIN
	offset_bottom = -MARGIN
	offset_top = -MARGIN # thu về chiều cao 0, container tự nở lên theo nội dung


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

	# --- ĐỘ HIẾM + MÀU ---
	var rarity_text = "Common"
	var rarity_color := Color.WHITE

	if equipment.rarity != null:
		if "rarity_name" in equipment.rarity:
			rarity_text = equipment.rarity.resource_name if equipment.rarity.resource_name != "" else equipment.rarity.rarity_name
		if "rarity_color" in equipment.rarity:
			rarity_color = equipment.rarity.rarity_color
	elif "rarity_name" in inv_item:
		rarity_text = inv_item.rarity_name

	# --- TÊN + ĐỘ HIẾM ---
	name_label.text = str(equipment.item_name)
	name_label.add_theme_color_override("font_color", rarity_color)
	rarity_label.text = str(rarity_text)
	rarity_label.add_theme_color_override("font_color", rarity_color)

	# Viền bảng và khung icon đổi theo độ hiếm
	_tint_border(self, rarity_color)
	_tint_border(icon_frame, rarity_color)

	# --- ICON ---
	var tex: Texture2D = null
	for prop in ["icon", "texture"]:
		if prop in equipment and equipment.get(prop) is Texture2D:
			tex = equipment.get(prop)
			break
	icon_rect.texture = tex
	icon_frame.visible = tex != null

	# --- MÔ TẢ ---
	desc_label.text = str(equipment.description) if equipment.description else "Vật phẩm trang bị."

	# --- CHỈ SỐ GỐC + SỐ LƯỢNG ---
	_clear(stats_list)
	_clear(bonus_list)

	if "base_attack" in equipment and equipment.base_attack > 0:
		_add_row(stats_list, "Sát thương gốc", str(equipment.base_attack), COLOR_VALUE)
	if "base_defense" in equipment and equipment.base_defense > 0:
		_add_row(stats_list, "Phòng thủ gốc", str(equipment.base_defense), COLOR_VALUE)

	var qty = 1
	if "quantity" in inv_item:
		qty = inv_item.quantity
	_add_row(stats_list, "Số lượng", "x" + str(qty), COLOR_VALUE)

	# --- THUỘC TÍNH NGẪU NHIÊN ---
	var raw_bonus_stats = inv_item.bonus_stats if "bonus_stats" in inv_item else (equipment.bonus_stats if "bonus_stats" in equipment else null)

	var has_bonus: bool = raw_bonus_stats is Dictionary and not raw_bonus_stats.is_empty()
	bonus_header.visible = has_bonus
	if has_bonus:
		for stat_name in raw_bonus_stats.keys():
			_add_row(bonus_list, _pretty_stat_name(str(stat_name)), "+" + str(raw_bonus_stats[stat_name]), COLOR_BONUS)

	# --- HIỆN BẢNG ---
	_dock_to_bottom()
	show()
	reset_size.call_deferred()
	await get_tree().process_frame
	reset_size()


func _pretty_stat_name(key: String) -> String:
	if STAT_NAMES.has(key):
		return STAT_NAMES[key]
	return key.replace("_", " ").capitalize()


func _tint_border(ctrl: Control, color: Color) -> void:
	var box := ctrl.get_theme_stylebox("panel") as StyleBoxFlat
	if box == null:
		return
	box = box.duplicate()
	box.border_color = color
	ctrl.add_theme_stylebox_override("panel", box)


func _clear(list: Control) -> void:
	for child in list.get_children():
		list.remove_child(child)
		child.queue_free()


# Thêm một dòng "Tên ........ Giá trị"
func _add_row(list: Control, stat_name: String, value: String, value_color: Color) -> void:
	var row := HBoxContainer.new()
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var left := Label.new()
	left.text = stat_name
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left.add_theme_color_override("font_color", COLOR_LABEL)
	left.add_theme_font_size_override("font_size", 15)

	var right := Label.new()
	right.text = value
	right.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	right.add_theme_color_override("font_color", value_color)
	right.add_theme_font_size_override("font_size", 15)

	row.add_child(left)
	row.add_child(right)
	list.add_child(row)
