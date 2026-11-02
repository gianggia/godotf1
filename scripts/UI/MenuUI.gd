extends CanvasLayer

# Đường dẫn tới các nút bấm chuyển Tab
@onready var button_inventory: Button = $MainPanel/TabBarContainer/ButtonInventory
@onready var button_character: Button = $MainPanel/TabBarContainer/ButtonCharacter

# Nút đóng menu và tiêu đề
@onready var button_close: Button = $MainPanel/CloseButton
@onready var title_label: Label = $MainPanel/TitleLabel

# Đường dẫn tới các Tab nội dung bên trong ContentContainer
@onready var inventory_ui: Control = $MainPanel/ContentContainer/InventoryUI
@onready var character_ui: Control = $MainPanel/ContentContainer/CharacterUI

# Biến cờ để kiểm tra xem đã nạp dữ liệu từ JSON lần nào chưa
var is_first_load: bool = true

func _ready() -> void:
	# Mặc định ẩn toàn bộ Menu khi mới vào game
	visible = false

	# Kết nối sự kiện nhấn nút của các Tab
	button_inventory.pressed.connect(_on_inventory_tab_pressed)
	button_character.pressed.connect(_on_character_tab_pressed)
	button_close.pressed.connect(toggle_menu)

	# Nối với nút Menu trên HUD (đợi 1 khung hình để HUD kịp khởi tạo xong)
	_connect_hud.call_deferred()


# Tìm HUD qua group "hud_controls" và nghe signal menu_requested (phát khi bấm BtnMenu)
func _connect_hud() -> void:
	for hud in get_tree().get_nodes_in_group("hud_controls"):
		if hud.has_signal("menu_requested") and not hud.menu_requested.is_connected(toggle_menu):
			hud.menu_requested.connect(toggle_menu)
			print("✅ MenuUI đã nối với nút Menu của HUD")

## Hàm công tắc: chỉ đóng/mở khung MenuUI, không tự bật InventoryUI
func toggle_menu() -> void:
	visible = !visible
	# Menu mở thì ẩn cụm điều khiển HUD (cần gạt, nút đánh...), đóng lại thì hiện lại
	get_tree().call_group("hud_controls", "set_enabled", not visible)

	# Khi Menu được mở lên, giữ cho vùng nội dung trống trải
	if visible:
		inventory_ui.visible = false
		character_ui.visible = false
		# Mở lại nút Tab (tránh kẹt nút bị khóa từ lần mở trước)
		button_inventory.disabled = false
		button_character.disabled = false
		title_label.text = "MENU"

## Hàm trung tâm quản lý việc ẩn/hiện chính xác các Tab
func show_tab(tab_name: String) -> void:
	# Bước 1: Ẩn tất cả các Tab nội dung để reset giao diện
	inventory_ui.visible = false
	character_ui.visible = false

	# Bước 2: Bật lại tương tác cho TẤT CẢ các nút bấm
	button_inventory.disabled = false
	button_character.disabled = false

	# Bước 3: Kích hoạt chính xác Tab được chọn và khóa nút bấm của Tab đó lại
	# (nút bị khóa sẽ hiện kiểu "đang chọn" sáng vàng)
	match tab_name:
		"inventory":
			inventory_ui.visible = true
			button_inventory.disabled = true
			title_label.text = "TÚI ĐỒ"

			if is_first_load:
				inventory_ui.load_inventory_from_file()
				is_first_load = false
			else:
				if inventory_ui.has_method("update_ui"):
					inventory_ui.update_ui(inventory_ui.inventory_data)

		"character":
			character_ui.visible = true
			button_character.disabled = true
			title_label.text = "NHÂN VẬT"

			if character_ui.has_method("update_stats"):
				character_ui.update_stats()


# Các hàm phản hồi khi người chơi chạm vào nút chuyển Tab
func _on_inventory_tab_pressed() -> void:
	show_tab("inventory")

func _on_character_tab_pressed() -> void:
	show_tab("character")
