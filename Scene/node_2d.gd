extends Node

@export var base_weapon_test: ItemEquipment
@export var base_armor_test: ItemEquipment

@onready var loot_gen_node= $LootGenerator # Nhớ check lại đường dẫn Node này trên Scene
@onready var menu_ui: CanvasLayer = $BaseHUDCanvasLayer
#@onready var inventory_button: Button = $BaseHUDCanvasLayer/MobileControls/BtnMenu

func _ready() -> void:
	await get_tree().process_frame
	print("\n==================================================")
	print("🎮 HỆ THỐNG KIỂM THỬ HÒM ĐỒ ĐÃ SẴN SÀNG:")
	print(" 👉 Bấm phím [ G ] để ĐÚC ĐỒ & TỰ ĐỘNG SAVE")
	print(" 👉 Bấm phím [ L ] để TẢI FILE SAVE (LOAD) & KIỂM TRA ĐỒ")
	print("==================================================\n")

func _unhandled_input(event: InputEvent) -> void:
	# 1. BẤM PHÍM G ĐỂ TẠO ĐỒ & LƯU
	if Input.is_key_label_pressed(KEY_G):
		print("\n--- 🎲 ĐANG ĐÚC VÀ THÊM VẬT PHẨM MỚI ---")
		
		if base_weapon_test and loot_gen_node:
			var dropped_weapon = loot_gen_node.generate_equipment(base_weapon_test)
			InventoryManager.add_to_player_inventory(dropped_weapon)
		
		if base_armor_test and loot_gen_node:
			var dropped_armor = loot_gen_node.generate_equipment(base_armor_test)
			InventoryManager.add_to_player_inventory(dropped_armor)

	# 2. BẤM PHÍM L ĐỂ LOAD FILE VÀ IN RA KIỂM TRA
	if Input.is_key_label_pressed(KEY_L):
		print("\n--- 📂 ĐANG ĐỌC FILE SAVE VÀ DỰNG LẠI HÒM ĐỒ ---")
		SaveManager.load_game()
		
		# Gọi hàm debug quét sạch hòm đồ trong RAM
		if InventoryManager.player_inventory:
			InventoryManager.player_inventory.debug_print_inventory_contents()
