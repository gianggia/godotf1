extends Node

var player_inventory: InventoryData

func _ready() -> void:
	# Luôn tạo một thực thể data trống trong RAM làm mặc định
	player_inventory = InventoryData.new()
	player_inventory.initialize_inventory()

func add_to_player_inventory(new_equipment: ItemEquipment) -> bool:
	# 1. Gọi dữ liệu hòm đồ thực hiện thêm vật phẩm
	var success = player_inventory.add_item(new_equipment)
	
	# 2. Nếu thêm thành công (hòm đồ chưa đầy), tự động lưu game luôn
	if success:
		SaveManager.save_game()
		
	return success
