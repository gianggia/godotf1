extends Node

# File sẽ được lưu tại thư mục dữ liệu ứng dụng của từng HĐH (Đảm bảo quyền ghi file)
# Windows: %APPDATA%\Godot\app_userdata\[Tên_Project]\
const SAVE_FILE_PATH = "user://save_game.json"

# Key bảo mật dùng để mã hóa file nếu bạn không muốn người chơi mở notepad lên sửa trực tiếp
const SECRET_KEY = "MySuperSecretRPGKey123"

func _ready() -> void:
	# Chờ 1 khung hình ngắn để đảm bảo tất cả các Autoload khác đã nạp xong vào RAM
	await get_tree().process_frame
	load_game() 
# Hàm thực hiện Lưu game
func save_game() -> void:
	# 1. Thu thập dữ liệu từ Hòm đồ thành Dictionary
	var save_data: Dictionary = {
		"inventory": InventoryManager.player_inventory.to_dict()
		# Bạn có thể thêm dữ liệu khác ở đây sau này: "player_level": 10, "gold": 500...
	}
	
	# 2. Chuyển Dictionary thành chuỗi String dạng JSON gọn gàng
	var json_string = JSON.stringify(save_data, "\t") # Dùng "\t" để xuống dòng đẹp đẽ khi debug
	
	# 3. Ghi file xuống ổ cứng (Mã hóa với mật khẩu để chống cheat)
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(json_string)
		file.close()
		print("💾 Hệ thống: Đã lưu dữ liệu Hòm đồ thành công!")
	else:
		print("❌ Hệ thống: Lỗi không thể ghi file save! Mã lỗi: ", FileAccess.get_open_error())

# Hàm thực hiện Tải game
func load_game() -> void:
	if not FileAccess.file_exists(SAVE_FILE_PATH):
		print("⚠️ Hệ thống: Không tìm thấy file save cũ. Giữ nguyên hòm đồ trống.")
		return
		
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var error = json.parse(json_string)
		
		if error == OK:
			var master_data = json.get_data()
			
			if master_data.has("inventory"):
				# QUAN TRỌNG: Gọi trực tiếp hàm from_dict của thực thể đang chạy toàn cục
				if InventoryManager.player_inventory:
					InventoryManager.player_inventory.from_dict(master_data["inventory"])
					# Phát tín hiệu báo cho hệ thống/UI biết dữ liệu đã cập nhật
					InventoryManager.player_inventory.inventory_updated.emit(InventoryManager.player_inventory)
					print("📂 Hệ thống: Đã tải dữ liệu Hòm đồ thành công từ JSON!")
				else:
					print("❌ Hệ thống: InventoryManager.player_inventory chưa được khởi tạo trong RAM!")
		else:
			print("❌ Hệ thống: File save bị hỏng hoặc lỗi parse JSON!")
