extends CharacterBody2D

const SPEED = 300.0

# --- ĐƯỜNG DẪN ĐẾN CÁC NODE CON ---
@onready var animation_tree = $AnimatedSprite2D/Anim/AnimationTree
@onready var state_machine = animation_tree["parameters/playback"]
@onready var weapon_sprite = $AnimatedSprite2D/Anim/WeaponSprite 

var last_input_direction = Vector2.DOWN # Lưu hướng nhìn cuối cùng dạng Vector2
var is_attacking = false

func _ready() -> void:
	weapon_sprite.visible = false
	# Tự động bật Active cho AnimationTree
	animation_tree.active = true 
	
	# SỬA LẠI ĐÒNG NÀY: Điền đúng đường dẫn từ Node gốc của Scene (Node2D) đi xuống nút bấm
	$"../CanvasLayer/MobileControls/BtnAtk".pressed.connect(_on_touch_screen_button_pressed)

func _physics_process(delta: float) -> void:
	# 1. Lấy dữ liệu di chuyển từ hệ thống Input Map
	var input_direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	# --- XỬ LÝ DI CHUYỂN VÀ CẬP NHẬT HƯỚNG ---
	if not is_attacking:
		if input_direction.length() > 0.2:
			velocity = input_direction * SPEED
			last_input_direction = input_direction.normalized() # Cập nhật hướng nhìn liên tục khi đi
			
			# Đồng bộ hướng vào BlendSpace2D của Walk và chuyển trạng thái sang Walk
			animation_tree.set("parameters/walk/blend_position", input_direction)
			state_machine.travel("walk")
		else:
			# Dừng nhân vật lại mượt mà
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.y = move_toward(velocity.y, 0, SPEED)
			
			# Đồng bộ hướng vào BlendSpace2D của Idle và chuyển trạng thái sang Idle
			animation_tree.set("parameters/idle/blend_position", last_input_direction)
			state_machine.travel("idle")
			
		move_and_slide()
	else:
		# --- XỬ LÝ VỪA ĐI VỪA CHÉM ---
		# Nếu đang chém mà người chơi vẫn vuốt joystick đi, nhân vật vẫn di chuyển theo hướng đó
		if input_direction.length() > 0.2:
			velocity = input_direction * SPEED
		else:
			velocity = Vector2.ZERO
		move_and_slide()

# --- HÀM KÍCH HOẠT KHI BẤM TouchScreenButton ---
func _on_touch_screen_button_pressed() -> void:
	if is_attacking: 
		return # Đang chém nửa chừng thì chặn không cho spam nút bấm
		
	is_attacking = true
	weapon_sprite.visible = true
	
	# 1. Đồng bộ hướng đánh dựa trên hướng nhìn cuối cùng vào BlendSpace2D của Attack
	animation_tree.set("parameters/attack/blend_position", last_input_direction)
	
	# 2. Ra lệnh cho StateMachine nhảy sang trạng thái chém lập tức
	state_machine.travel("attack")
	
	# 3. Tạo một bộ hẹn giờ tự động ẩn vũ khí và mở khóa di chuyển khi kết thúc animation chém
	# (Bạn hãy chỉnh số 0.3 này thành độ dài chính xác của animation chém của bạn nhé, ví dụ 0.2s hoặc 0.4s)
	await get_tree().create_timer(0.3).timeout
	weapon_sprite.visible = false
	is_attacking = false
