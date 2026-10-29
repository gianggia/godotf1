extends CharacterBody2D

const SPEED = 300.0

# --- ĐƯỜNG DẪN ĐẾN CÁC NODE CON ---
@onready var animation_tree = $AnimatedSprite2D/Anim/AnimationTree
@onready var state_machine = animation_tree["parameters/playback"]
@onready var weapon_sprite = $AnimatedSprite2D/Anim/WeaponSprite 

var last_input_direction = Vector2.DOWN # Lưu hướng nhìn cuối cùng dạng Vector2
var is_attacking = false

# --- THAM SỐ THỜI GIAN ĐÒN ĐÁNH ---
var attack_timer = 0.0 
const ATTACK_DURATION = 0.3 

func _ready() -> void:
	weapon_sprite.visible = false
	animation_tree.active = true 
	
	# Kết nối nút bấm cảm ứng trên Mobile (Giữ nguyên)
	$"../BaseHUDCanvasLayer/MobileControls/BtnAtk".pressed.connect(_on_touch_screen_button_pressed)

func _physics_process(delta: float) -> void:
	# --- THÊM MỚI: KIỂM TRA PHÍM J TRÊN BÀN PHÍM ---
	# Nếu ấn phím J, tự động kích hoạt hàm chém y hệt như bấm nút cảm ứng
	if Input.is_action_just_pressed("atk"):
		_trigger_attack_logic()

	# Lấy dữ liệu di chuyển từ hệ thống Input Map
	var input_direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	# --- XỬ LÝ ĐẾM THỜI GIAN KẾT THÚC ĐÒN ĐÁNH ---
	if is_attacking:
		attack_timer -= delta
		if attack_timer <= 0:
			is_attacking = false
			weapon_sprite.visible = false

	# --- XỬ LÝ DI CHUYỂN VÀ CẬP NHẬT HƯỚNG ---
	if not is_attacking:
		if input_direction.length() > 0.2:
			velocity = input_direction * SPEED
			last_input_direction = input_direction.normalized()
			
			animation_tree.set("parameters/walk/blend_position", input_direction)
			state_machine.travel("walk")
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.y = move_toward(velocity.y, 0, SPEED)
			
			animation_tree.set("parameters/idle/blend_position", last_input_direction)
			state_machine.travel("idle")
			
		move_and_slide()
	else:
		# --- XỬ LÝ VỪA ĐI VỪA CHÉM ---
		if input_direction.length() > 0.2:
			velocity = input_direction * SPEED
		else:
			velocity = Vector2.ZERO
		move_and_slide()

# --- HÀM KÍCH HOẠT KHI BẤM TouchScreenButton ---
func _on_touch_screen_button_pressed() -> void:
	_trigger_attack_logic()

# --- THÊM MỚI: TÁCH RIÊNG LOGIC CHÉM ĐỂ DÙNG CHUNG CHO CẢ PHÍM J VÀ NÚT CẢM ỨNG ---
func _trigger_attack_logic() -> void:
	if is_attacking: 
		return # Đang chém nửa chừng thì chặn không cho spam
		
	is_attacking = true
	weapon_sprite.visible = true
	attack_timer = ATTACK_DURATION 
	
	animation_tree.set("parameters/attack/blend_position", last_input_direction)
	state_machine.travel("attack")
