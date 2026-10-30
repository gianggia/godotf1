extends Node

# File sẽ được lưu tại thư mục dữ liệu ứng dụng của từng HĐH (Đảm bảo quyền ghi file)
const SAVE_FILE_PATH = "user://save_game.json"

# Key bảo mật dùng để mã hóa file nếu bạn không muốn người chơi mở notepad lên sửa trực tiếp
const SECRET_KEY = "MySuperSecretRPGKey123"

func _ready() -> void:
	# Chờ 1 khung hình ngắn để đảm bảo tất cả các Autoload khác đã nạp xong vào RAM
	await get_tree().process_frame
	load_game() 

# Ví dụ cấu trúc chuẩn mà hàm save_game() của bạn CẦN tạo ra:
func save_game() -> void:
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	if file:
		# Lấy dữ liệu hòm đồ hiện tại trong RAM chuyển thành Dictionary
		var inventory_dict = {}
		if InventoryManager.player_inventory:
			# Bạn cần có một hàm to_dict() trong InventoryData.gd để chuyển RAM -> Dict
			inventory_dict = InventoryManager.player_inventory.to_dict() 
		else:
			# Định dạng trống chuẩn dự phòng nếu RAM chưa có gì
			inventory_dict = {
				"max_slots": 30,
				"active_items": {}
			}
			
		var master_data = {
			"inventory": inventory_dict
		}
		
		file.store_line(JSON.stringify(master_data))
		file.close()
		print("💾 Hệ thống: Đã lưu dữ liệu game thành công!")


# Hàm thực hiện Tải game
# Hàm thực hiện Tải game
# Hàm thực hiện Tải game
func load_game() -> void:
	# 🌟 TỰ ĐỘNG TẠO FILE NẾU CHƯA CÓ
	if not FileAccess.file_exists(SAVE_FILE_PATH):
		print("⚠️ Hệ thống: Không tìm thấy file save cũ. Tiến hành lấy dữ liệu đồ ban đầu để tạo file save...")
		
		# KHẮC PHỤC: Trước khi gọi save_game(), ta phải kiểm tra xem RAM đã có dữ liệu mẫu chưa
		if InventoryManager.player_inventory:
			# Gọi hàm lưu dữ liệu hiện tại của RAM xuống file thành công
			save_game() 
			print("✅ Hệ thống: Khởi tạo file save đầu tiên dựa trên đồ mặc định thành công!")
		else:
			print("❌ Hệ thống: Không thể khởi tạo file do player_inventory trống!")
		return
		
	# Tiến hành mở file để đọc dữ liệu
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var error = json.parse(json_string)
		
		if error == OK:
			var master_data = json.get_data()
			
			if master_data is Dictionary and master_data.has("inventory"):
				var inventory_content = master_data["inventory"]
				
				# Nếu file bị lỗi định dạng rỗng/Array do lần chạy trước, bỏ qua ko nạp để giữ lại đồ mặc định
				if not (inventory_content is Dictionary) or inventory_content.is_empty():
					print("⚠️ Hệ thống: File JSON trống hoặc sai định dạng. Giữ nguyên đồ khởi tạo trong RAM.")
					return
				
				if InventoryManager.player_inventory:
					InventoryManager.player_inventory.from_dict(inventory_content)
					InventoryManager.player_inventory.inventory_updated.emit(InventoryManager.player_inventory)
					print("📂 Hệ thống: Đã tải dữ liệu Hòm đồ thành công từ file JSON tổng!")
		else:
			print("❌ Hệ thống: File save bị hỏng hoặc lỗi parse JSON!")
