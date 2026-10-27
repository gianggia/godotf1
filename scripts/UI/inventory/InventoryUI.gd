extends Control

# 1. Đường dẫn tới file ô đồ đơn lẻ mà bạn đã làm ở Bước trước
# Bạn hãy kiểm tra xem tên file trong thư mục của bạn có đúng là "ItemSlotUI.tscn" không nhé
const ITEM_SLOT_UI_SCENE = preload("res://Scene/itemSlotUI.tscn") 

# 2. Kết nối tới lưới GridContainer trên giao diện
@onready var item_grid: GridContainer = $ScrollContainer/ItemGrid

func _ready() -> void:
	# Khi hòm đồ vừa mở lên, chạy hàm vẽ các ô đồ ngay
	render_inventory()

# 3. Hàm tạo ô đồ tự động
func render_inventory() -> void:
	# Xóa các ô cũ trong lưới nếu có (để tránh bị trùng lặp dữ liệu)
	for child in item_grid.get_children():
		child.queue_free()
		
	# Quy định số lượng ô đồ bạn muốn có trong hòm (Ví dụ: game của bạn có 20 ô)
	var total_slots = 30
	
	# Vòng lặp để tự động tạo ra 20 ô đồ xếp vào lưới
	for i in range(total_slots):
		# Nhân bản một ô đồ từ file thiết kế thô (ItemSlotUI.tscn)
		var slot_instance = ITEM_SLOT_UI_SCENE.instantiate() as ItemSlotUI
		
		# Thêm ô đồ này vào làm con của lưới GridContainer
		item_grid.add_child(slot_instance)
		
		# Giả lập nạp dữ liệu trống cho ô đồ (Lát nữa chúng ta sẽ đổ vật phẩm thật sau)
		var empty_data = {}
		slot_instance.update_slot(i, empty_data)
		
		# Lắng nghe sự kiện khi người chơi bấm vào ô này
		slot_instance.pressed.connect(_on_item_slot_pressed.bind(slot_instance))

# 4. Hàm xử lý khi người chơi chạm vào một ô bất kỳ
func _on_item_slot_pressed(slot_ui: ItemSlotUI) -> void:
	print("Bạn vừa bấm vào ô đồ số: ", slot_ui.slot_index)
	# Lát nữa chúng ta sẽ viết code bật viền sáng và hiện bảng chi tiết ở đây
