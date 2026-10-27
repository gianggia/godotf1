extends Button
class_name ItemSlotUI

var slot_index: int = -1

# Hàm cập nhật giao diện ô đồ an toàn
func update_slot(index: int, item_data: Dictionary) -> void:
	slot_index = index
	
	# Lấy trực tiếp các Node con tại thời điểm chạy hàm để tránh lỗi null bất đồng bộ
	var icon_node = get_node_or_null("Icon") as TextureRect
	var label_node = get_node_or_null("QuantityLabel") as Label
	
	# Nếu các Node giao diện bên trong chưa kịp tạo xong, bỏ qua để tránh sập game
	if not icon_node or not label_node:
		return
		
	# TRƯỜNG HỢP 1: Ô trống dữ liệu
	if item_data.is_empty():
		icon_node.texture = null
		label_node.text = ""
		return
		
	# TRƯỜNG HỢP 2: Có vật phẩm -> Kiểm tra đường dẫn và nạp ảnh
	var path = item_data.get("icon_path", "")
	if path != "" and ResourceLoader.exists(path):
		icon_node.texture = load(path)
	else:
		icon_node.texture = null
		
	# Cập nhật số lượng hiển thị
	var quantity = item_data.get("quantity", 1)
	if quantity > 1:
		label_node.text = str(quantity)
	else:
		label_node.text = ""

# Hàm bật/tắt viền sáng khi người chơi chạm chọn ô này
func set_highlight(is_selected: bool) -> void:
	var border_node = get_node_or_null("BorderHighlight") as ReferenceRect
	if border_node:
		border_node.visible = is_selected
