extends Control

# 1. Định nghĩa các đường dẫn Node và Scene
const ITEM_SLOT_UI_SCENE = preload("res://Scene/itemSlotUI.tscn") 
@onready var item_grid: GridContainer = $ScrollContainer/ItemGrid
@onready var detail_popup = $ItemDetails

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
	# 🛠️ MẸO SỬA LỖI NHANH: Nếu muốn ép hệ thống xóa file cũ lỗi để tạo lại file mới, 
	# bạn có thể tạm thời bỏ comment dòng dưới đây, chạy game 1 lần, rồi comment lại:
	# DirAccess.remove_absolute(SAVE_FILE_PATH)

	# 1. Kiểm tra nếu file chưa tồn tại thì tạo file mới
	if not FileAccess.file_exists(SAVE_FILE_PATH):
		print("📂 File save chưa tồn tại. Đang tạo file mới tại: ", SAVE_FILE_PATH)
		var new_file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
		if new_file:
			# Khởi tạo toàn bộ dữ liệu là một Dictionary trống rỗng {}
			# Điều này giúp hàm inventory_data.from_dict() nhận được chính xác 1 Dictionary
			var default_data = {}
			new_file.store_line(JSON.stringify(default_data))
			new_file.close()
		else:
			print("❌ Lỗi nghiêm trọng: Không thể tạo file mới tại hệ thống!")
			return

	# 2. Tiến hành mở file để đọc dữ liệu
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	if file == null:
		print("❌ Lỗi: Không thể mở file để đọc dù file đã tồn tại!")
		return
		
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	
	if parse_result == OK:
		var data_dict = json.get_data()
		
		# 3. KIỂM TRA ĐỊNH DẠNG ĐẦU VÀO: Ép kiểu dữ liệu phải là Dictionary trước khi truyền
		if data_dict is Dictionary:
			# Truyền thẳng toàn bộ data_dict vào hàm from_dict của bạn
			inventory_data.from_dict(data_dict)
		else:
			print("❌ Lỗi: Cấu trúc file JSON đọc được không phải là Dictionary (Đang là Array hoặc kiểu khác)!")
			return
		
		# 🌟 Ép UI phải vẽ lại dựa trên RAM vừa nạp
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


# 5. Xử lý logic tương tác khi click chuột / chạm màn hình
func _on_item_slot_pressed(slot_ui: ItemSlotUI) -> void:
	var index = slot_ui.slot_index
	var inv_item: InventoryItem = inventory_data.slots[index]
	
	if inv_item != null and inv_item.item_data != null:
		# ❌ DÒNG CŨ BỊ LỖI: detail_popup.display_item(equipment)
		
		#  DÒNG MỚI ĐÃ SỬA: Truyền thẳng inv_item (chứa cả item_data lẫn bonus_stats) sang popup
		detail_popup.display_item(inv_item)
	else:
		# Nếu bấm vào ô trống thì ẩn popup đi
		detail_popup.hide()


# Hàm nhận vào dữ liệu vật phẩm và số lượng để đưa lên UI thông tin
func show_item_details(equipment: ItemEquipment, quantity: int) -> void:
	print("--- THÔNG TIN VẬT PHẨM ---")
	print("Tên: ", equipment.item_name)
	print("Số lượng: ", quantity)
	
	# GIẢ SỬ: Bạn có một cụm UI tên là $DetailPanel ở trong Scene này
	# Bạn có thể bật nó lên và gán chữ cho các Label của nó như sau:
	#
	# $DetailPanel.show()
	# $DetailPanel/NameLabel.text = equipment.item_name
	# $DetailPanel/DescriptionLabel.text = equipment.description
	
	# Nếu là Vũ khí thì in thêm chỉ số Sát thương (Ví dụ thuộc tính là attack_power)
	if equipment.has_method("get_damage") or "attack_power" in equipment:
		print("Sát thương: ", equipment.attack_power)
		
	# Nếu là Giáp thì in thêm chỉ số Phòng thủ (Ví dụ thuộc tính là defense)
	if "defense" in equipment:
		print("Phòng thủ: ", equipment.defense)

# Hàm ẩn bảng thông tin khi cần
func hide_item_details() -> void:
	# $DetailPanel.hide()
	pass
