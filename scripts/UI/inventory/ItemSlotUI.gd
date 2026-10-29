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
		
	# TRƯỜNG HỢP 2: Có vật phẩm -> Lấy thẳng Object ảnh đã nạp sẵn
	var texture_object = item_data.get("icon_path", null)
	
	# Kiểm tra nếu dữ liệu truyền xuống đúng là một Object hình ảnh (Texture2D)
	if texture_object is Texture2D:
		icon_node.texture = texture_object
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


func _ready() -> void:
	# TỰ GẮN SỰ KIỆN: Ép chính nó lắng nghe sự kiện bấm của chính nó
	self.pressed.connect(_on_self_pressed)

# Hàm này sẽ chạy NGAY LẬP TỨC khi phần cứng nhận được cú click vào ô này
func _on_self_pressed() -> void:
	print("=> [CHẮC CHẮN] Ô đồ số ", slot_index, " đã chạy vào hàm bấm thành công!")
func _pressed() -> void:
	print("=> [VẬT LÝ] Ô đồ số ", slot_index, " vừa được bấm trực tiếp từ phần cứng!")


func _on_pressed() -> void:
	print("=> on-press [VẬT LÝ] Ô đồ số ", slot_index, " vừa được bấm trực tiếp từ phần cứng!")
