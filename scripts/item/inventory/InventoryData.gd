# File: res://database/InventoryData.gd
class_name InventoryData
extends Resource

signal inventory_updated(inventory_data: InventoryData)

@export var max_slots: int = 30
@export var slots: Array[InventoryItem] = []

# Hàm khởi tạo kích thước mảng hòm đồ trống
func initialize_inventory() -> void:
	slots.clear()
	slots.resize(max_slots)

# ==================== HÀM ADD_ITEM (SỬA LỖI CHÍNH) ====================

# ==================== CÁC HÀM TIỆN ÍCH KHÁC (BỔ SUNG) ====================

# Hàm xóa/vứt vật phẩm khỏi dữ liệu
func remove_item(index: int) -> void:
	if index >= 0 and index < slots.size():
		slots[index] = null
		inventory_updated.emit(self)

# Tráo đổi vị trí giữa 2 ô (Phục vụ tính năng kéo thả Drag & Drop sau này)
func swap_slots(index_a: int, index_b: int) -> void:
	var temp = slots[index_a]
	slots[index_a] = slots[index_b]
	slots[index_b] = temp
	inventory_updated.emit(self)

# ==================== CHUYỂN ĐỔI SANG DICTIONARY ĐỂ SAVE ====================
# File: res://database/InventoryData.gd

# Bản đồ tra cứu nhanh: map giữa item_id và đường dẫn file .tres gốc trong dự án của bạn
# Hãy điền tất cả các file mẫu trang bị của bạn vào danh sách này
const ITEM_DATABASE: Dictionary = {
	"sword_base": "res://TresourcesEquipments/swordtest.tres", # Sửa lại đường dẫn thực tế file của bạn
	"armor_base": "res://TresourcesEquipments/armor.tres"  # Sửa lại đường dẫn thực tế file của bạn
}
# --- BỔ SUNG THÊM BẢNG TRA CỨU ĐỘ HIẾM TẠI ĐÂY ---
const RARITY_DATABASE: Dictionary = {
	"Common": "res://TresourcesEquipments/rarity_common.tres",       # Sửa lại đường dẫn thực tế 
	"Rare": "res://TresourcesEquipments/rarity_rare.tres", 
	"Epic" : "res://TresourcesEquipments/rarity_epic.tres",          # tới các file rarity.tres 
	"Legendary": "res://TresourcesEquipments/rarity_legendary.tres"  # của bạn trong dự án
}

# ==================== HÀM THÊM ĐỒ CHỐNG TRÙNG VÀ GHI ĐÈ ====================
func add_item(new_equipment: ItemEquipment) -> bool:
	if not new_equipment: 
		return false
	
	# Duyệt qua mảng để tìm ô trống thực sự trong bộ nhớ ổn định
	for i in range(slots.size()):
		if slots[i] == null:
			var new_inv_item = InventoryItem.new()
			new_inv_item.item_data = new_equipment
			new_inv_item.quantity = 1
			
			slots[i] = new_inv_item
			print("➕ Đã nhét thành công vào [Ô số %d]" % i)
			
			inventory_updated.emit(self)
			return true
			
	print("❌ Hòm đồ đã đầy!")
	return false

# ==================== TO_DICT: CHỈ LƯU Ô CÓ ĐỒ CÓ CHỈ SỐ INDEX ====================
func to_dict() -> Dictionary:
	var active_items: Dictionary = {}
	
	for i in range(slots.size()):
		if slots[i] != null:
			var equipment = slots[i].item_data
			
			# Lấy tên độ hiếm an toàn (nếu có)
			var rarity_str: String = "Common" # Mặc định nếu lỗi
			if equipment.rarity:
				rarity_str = equipment.rarity.rarity_name
			
			active_items[str(i)] = {
				"item_id": equipment.item_id,
				"rarity_name": rarity_str, # <--- GHI ĐỘ HIẾM VÀO FILE JSON
				"bonus_stats": equipment.bonus_stats,
				"quantity": slots[i].quantity
			}
			
	return {
		"max_slots": max_slots,
		"active_items": active_items
	}


# ==================== FROM_DICT: DỰNG LẠI KHUNG 30 Ô VÀ ĐẮP ĐỒ VÀO VỊ TRÍ CŨ ====================
func from_dict(data: Dictionary) -> void:
	self.max_slots = data.get("max_slots", 30)
	self.slots.clear()
	self.slots.resize(max_slots)
	
	var active_items = data.get("active_items", {})
	
	for slot_index_str in active_items:
		var slot_index = int(slot_index_str)
		if slot_index >= max_slots: continue
			
		var item_raw = active_items[slot_index_str]
		var id = item_raw.get("item_id", "")
		var r_name = item_raw.get("rarity_name", "Common") # Lấy tên độ hiếm từ file JSON
		
		if ITEM_DATABASE.has(id):
			var path = ITEM_DATABASE[id]
			if ResourceLoader.exists(path):
				var base_equipment = ResourceLoader.load(path).duplicate() as ItemEquipment
				base_equipment.item_id = id
				base_equipment.bonus_stats = item_raw.get("bonus_stats", {})
				
				# --- PHỤC HỒI OBJECT RARITY TỪ FILE GỐC ---
				if RARITY_DATABASE.has(r_name):
					var rarity_path = RARITY_DATABASE[r_name]
					if ResourceLoader.exists(rarity_path):
						base_equipment.rarity = ResourceLoader.load(rarity_path) as ItemRarity
				
				var inv_item = InventoryItem.new()
				inv_item.item_data = base_equipment
				inv_item.quantity = item_raw.get("quantity", 1)
				
				slots[slot_index] = inv_item

# Thêm hàm này vào InventoryData.gd hoặc file Test của bạn
func debug_print_inventory_contents() -> void:
	print("\n🔍 ===== 📦 TRẠNG THÁI HÒM ĐỒ TRONG RAM (Tối đa: %d ô) =====" % max_slots)
	
	var total_items_found: int = 0
	
	for i in range(slots.size()):
		if slots[i] == null:
			continue
			
		total_items_found += 1
		var equipment: ItemEquipment = slots[i].item_data
		var rarity_name: String = "Không xác định"
		
		if equipment.rarity:
			rarity_name = equipment.rarity.rarity_name
			
		print("👉 [Ô số %d]: %s (Độ hiếm: %s) - Số lượng: %d" % [
			i, 
			equipment.item_id.to_upper(), 
			rarity_name, 
			slots[i].quantity
		])
		
		if equipment.bonus_stats.size() > 0:
			var stat_strings: Array = []
			for stat_name in equipment.bonus_stats:
				var stat_value = equipment.bonus_stats[stat_name]
				if stat_name in ["crit_c", "crit_d"]:
					stat_strings.append("%s: +%d%%" % [stat_name.to_upper(), stat_value])
				else:
					stat_strings.append("%s: +%d" % [stat_name.to_upper(), stat_value])
			print("   ↳ Chỉ số ẩn: [ %s ]" % ", ".join(stat_strings))
		else:
			print("   ↳ Chỉ số ẩn: (Không có dòng ẩn)")
			
	if total_items_found == 0:
		print("📭 Hòm đồ trống rỗng! (Tất cả %d ô đều là null)" % max_slots)
		
	print("==============================================================\n")
