extends Control

# Điền chính xác tên Action trong Input Map của bạn tại bảng Inspector (bên phải)
@export var action_left: String = "move_left"
@export var action_right: String = "move_right"
@export var action_up: String = "move_up"
@export var action_down: String = "move_down"

@onready var base: TextureRect = $base
@onready var tip: TextureRect = $base/tip

var max_distance: float = 50.0 # Bán kính giới hạn của cần gạt
var dragging: bool = false
var joystick_vector: Vector2 = Vector2.ZERO

func _ready() -> void:
	# Tự động tính toán tâm dựa trên kích thước ảnh của Base và Tip
	tip.position = (base.size / 2) - (tip.size / 2)
	max_distance = base.size.x / 2

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		# Khi ngón tay chạm vào vùng giới hạn của Joystick
		if event.pressed and get_global_rect().has_point(event.position):
			dragging = true
		# Khi buông ngón tay ra
		elif not event.pressed and dragging:
			dragging = false
			reset_joystick()
			
	elif event is InputEventScreenDrag and dragging:
		# Tính toán vị trí ngón tay so với tâm vòng tròn lớn (Base)
		var center: Vector2 = base.global_position + (base.size / 2)
		var vector: Vector2 = event.position - center
		
		# Nếu kéo quá xa, giới hạn nút gạt (Tip) chỉ nằm trong vòng tròn Base
		if vector.length() > max_distance:
			vector = vector.normalized() * max_distance
			
		tip.global_position = center + vector - (tip.size / 2)
		
		# Trả về tỉ lệ Vector từ -1 đến 1 để truyền vào Input Map
		joystick_vector = vector / max_distance
		update_input_map()

func update_input_map() -> void:
	# Giả lập lực đẩy Joystick thành lực nhấn phím trong Input Map
	# Xử lý trục ngang X (Trái / Phải)
	if joystick_vector.x < 0:
		Input.action_press(action_left, abs(joystick_vector.x))
		Input.action_release(action_right)
	elif joystick_vector.x > 0:
		Input.action_press(action_right, joystick_vector.x)
		Input.action_release(action_left)
	else:
		Input.action_release(action_left)
		Input.action_release(action_right)
		
	# Xử lý trục dọc Y (Lên / Xuống)
	if joystick_vector.y < 0:
		Input.action_press(action_up, abs(joystick_vector.y))
		Input.action_release(action_down)
	elif joystick_vector.y > 0:
		Input.action_press(action_down, joystick_vector.y)
		Input.action_release(action_up)
	else:
		Input.action_release(action_up)
		Input.action_release(action_down)

func reset_joystick() -> void:
	# Đưa nút gạt nhỏ (Tip) về chính giữa
	tip.position = (base.size / 2) - (tip.size / 2)
	joystick_vector = Vector2.ZERO
	# Giải phóng hoàn toàn các phím (Thả phím ra)
	Input.action_release(action_left)
	Input.action_release(action_right)
	Input.action_release(action_up)
	Input.action_release(action_down)
