extends Node2D # Hoặc Node tùy theo Node gốc của Map bạn

# 1. Khai báo các ô kéo thả tài nguyên mẫu ở Inspector
@export var base_weapon_test: ItemEquipment # Ô kéo file sword.tres
@export var rarity_test: Resource          # Ô kéo file rarity_legendary.tres (hoặc bậc khác)

# 2. Gọi Node LootGenerator đã gắn ở Bước 1
@onready var loot_gen_node = $LootGenerator

func _ready() -> void:
	# Chờ 1 khung hình để đảm bảo mọi thứ đã nạp xong
	await get_tree().process_frame
	
	print("--- BẮT ĐẦU KIỂM TRA HỆ THỐNG ĐÚC ĐỒ ---")
	
	# Kiểm tra nếu bạn quên chưa kéo thả file mẫu trên Inspector
	if base_weapon_test == null or rarity_test == null:
		print("Lỗi: Bạn chưa kéo thả file sword.tres hoặc file Rarity vào Inspector của Map!")
		return
		
	# 3. Tiến hành gọi hàm đúc đồ ngẫu nhiên từ khuôn gốc
	var crafted_item: ItemEquipment = loot_gen_node.generate_weapon(base_weapon_test, rarity_test)
	
	# 4. In kết quả kiểm tra ra cửa sổ Output của Godot
	print("Tên vật phẩm đúc ra: ", crafted_item.get_display_name())
	print("Độ hiếm thực tế: ", crafted_item.rarity.rarity_name)
	print("Bảng chỉ số ẩn dính kèm (bonus_stats): ", crafted_item.bonus_stats)
	print("---------------------------------------")
