extends CanvasLayer

# Đường dẫn tới các nút bấm chuyển Tab
@onready var button_inventory: Button = $MainPanel/TabBarContainer/ButtonInventory
@onready var button_character: Button = $MainPanel/TabBarContainer/ButtonCharacter

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

## Hàm Công tắc để HUD hoặc Hệ thống gọi từ ngoài vào nhằm Đóng/Mở Menu
## Hàm công tắc: BÂY GIỜ CHỈ LÀM ĐÚNG 1 NHIỆM VỤ ĐÓNG/MỞ
## Hàm công tắc: Chỉ đóng/mở Khung MenuUI, không tự ý bật InventoryUI nữa
func toggle_menu() -> void:
	visible = !visible
	
	# Khi Menu được mở lên, giữ cho vùng nội dung trống trải
	if visible:
		inventory_ui.visible = false
		character_ui.visible = false



## Hàm trung tâm quản lý việc ẩn/hiện chính xác các Tab
func show_tab(tab_name: String) -> void:
	# Bước 1: Ẩn tất cả các Tab nội dung để reset giao diện
	inventory_ui.visible = false
	character_ui.visible = false
	
	# Bước 2: Bật lại tương tác cho TẤT CẢ các nút bấm
	button_inventory.disabled = false
	button_character.disabled = false
	
	# Bước 3: Kích hoạt chính xác Tab được chọn và khóa nút bấm của Tab đó lại
	match tab_name:
		"inventory":
			inventory_ui.visible = true
			button_inventory.disabled = true # Khóa không cho bấm trùng
			
			if is_first_load:
				inventory_ui.load_inventory_from_file()
				is_first_load = false
			else:
				if inventory_ui.has_method("update_ui"):
					# SỬA TẠI ĐÂY: Truyền thẳng biến dữ liệu RAM của hòm đồ vào hàm.
					# (Bạn hãy thay thế 'inventory_data' bằng tên chính xác của biến chứa RAM hòm đồ
					# nằm trong file InventoryUI.gd của bạn nhé, ví dụ: inventory_ui.inventory_data)
					inventory_ui.update_ui(inventory_ui.inventory_data)
				
		"character":
			character_ui.visible = true
			button_character.disabled = true # Khóa không cho bấm trùng
			
			if character_ui.has_method("update_stats"):
				character_ui.update_stats()


# Các hàm phản hồi khi người chơi click chuột vào nút chuyển Tab
func _on_inventory_tab_pressed() -> void:
	show_tab("inventory")

func _on_character_tab_pressed() -> void:
	show_tab("character")
