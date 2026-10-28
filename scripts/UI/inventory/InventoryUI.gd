extends Control

# 1. Định nghĩa các đường dẫn Node và Scene
const ITEM_SLOT_UI_SCENE = preload("res://Scene/itemSlotUI.tscn") 
@onready var item_grid: GridContainer = $ScrollContainer/ItemGrid

# Đường dẫn lưu file dữ liệu JSON thực tế trên thiết bị
const SAVE_FILE_PATH = "user://save_game.json"

# Biến lưu trữ Instance dữ liệu RAM hòm đồ
var inventory_data: InventoryData

func _ready() -> void:
	# Khởi tạo đối tượng quản lý bộ nhớ RAM hòm đồ
	inventory_data = InventoryData.new()
	inventory_data.initialize_inventory()
	
	# Đăng ký UI lắng nghe tín hiệu phát ra từ RAM dữ liệu
	inventory_data.inventory_updated.connect(update_ui)
	
	# Gọi hàm nạp dữ liệu thực tế từ file JSON lên
	load_inventory_from_file()
func load_inventory_from_file() -> void:

	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	
	if parse_result == OK:
		var data_dict = json.get_data()
		
		if data_dict.has("inventory"):
			var inventory_content = data_dict["inventory"]
			inventory_data.from_dict(inventory_content)
		
		# 🌟 ĐÂY CHÍNH LÀ DÒNG QUAN TRỌNG: Ép UI phải vẽ lại dựa trên RAM vừa nạp
		update_ui(inventory_data) 
		
		inventory_data.debug_print_inventory_contents()
	else:
		print("❌ Lỗi parse cấu trúc file JSON: ", json.get_error_message())



# 4. Hàm vẽ tự động 30 ô đồ lên giao diện mỗi khi dữ liệu thay đổi
func update_ui(inv_data: InventoryData) -> void:
	# Dọn dẹp sạch các node giao diện cũ
	for child in item_grid.get_children():
		child.queue_free()
		
	# Duyệt qua mảng slots trong RAM để ánh xạ lên lưới giao diện
	for i in range(inv_data.slots.size()):
		var slot_instance = ITEM_SLOT_UI_SCENE.instantiate() as ItemSlotUI
		item_grid.add_child(slot_instance)
		
		var inv_item: InventoryItem = inv_data.slots[i]
		var final_ui_data = {}
		
		# Kiểm tra nếu ô bộ nhớ đang chứa vật phẩm trang bị hợp lệ
		if inv_item != null and inv_item.item_data != null:
			var equipment: ItemEquipment = inv_item.item_data
			
			# Kiểm tra xem file .tres được load lên thông qua ITEM_DATABASE đã có ảnh hay chưa
			if equipment.texture:
				final_ui_data = {
					"icon_path": equipment.texture, # Đẩy thẳng đối tượng kết cấu ảnh Texture2D sang UI
					"quantity": inv_item.quantity
				}
		
		# Đồng bộ dữ liệu xuống node ItemSlotUI cụ thể
		slot_instance.update_slot(i, final_ui_data)
		
		# Đăng ký sự kiện bấm ô đồ
		slot_instance.pressed.connect(_on_item_slot_pressed.bind(slot_instance))

# 5. Xử lý logic tương tác khi click chuột
func _on_item_slot_pressed(slot_ui: ItemSlotUI) -> void:
	print("Bấm vào ô số: ", slot_ui.slot_index)
