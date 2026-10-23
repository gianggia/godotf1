extends CharacterBody2D

const SPEED = 300.0

# --- ĐƯỜNG DẪN ĐẾN CÁC NODE CON ---
@onready var anim = $AnimatedSprite2D/Anim/AnimationPlayer
@onready var sprite = $AnimatedSprite2D/Anim/charSprite
@onready var weapon_sprite = $AnimatedSprite2D/Anim/WeaponSprite 

# Các trạng thái của nhân vật
enum State { IDLE, WALK, ATTACK }
var current_state = State.IDLE

var last_direction = "Down"

func _ready() -> void:
	weapon_sprite.visible = false
	# Kết nối tín hiệu khi animation chạy xong hoàn toàn
	anim.animation_finished.connect(_on_animation_finished)

func _physics_process(delta: float) -> void:
	# Lấy dữ liệu Input di chuyển
	var input_direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")

	# --- 1. XỬ LÝ CHUYỂN ĐỔI TRẠNG THÁI (CHỈ XỬ LÝ DI CHUYỂN) ---
	if current_state != State.ATTACK:
		if input_direction.length() > 0.2:
			current_state = State.WALK
		else:
			current_state = State.IDLE

	# --- 2. THỰC THI LOGIC THEO TRẠNG THÁI ---
	match current_state:
		State.IDLE:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.y = move_toward(velocity.y, 0, SPEED)
			
			if last_direction == "Right": anim.play("idleRight")
			elif last_direction == "Left": anim.play("idleLeft")
			elif last_direction == "Up": anim.play("idleUp")
			else: anim.play("idleDown")
			
			move_and_slide()

		State.WALK:
			velocity = input_direction * SPEED
			
			if abs(input_direction.x) > abs(input_direction.y):
				if input_direction.x > 0:
					anim.play("walkRight")
					last_direction = "Right"
				else:
					anim.play("walkLeft")
					last_direction = "Left"
			else:
				if input_direction.y > 0:
					anim.play("walkDown")
					last_direction = "Down"
				else:
					anim.play("walkUp")
					last_direction = "Up"
					
			move_and_slide()

		State.ATTACK:
			# Đứng yên khi chém và chỉ cho phép animation chạy, không làm gì khác
			velocity = Vector2.ZERO
			move_and_slide()

# --- 3. HÀM CHỈ KÍCH HOẠT ĐÚNG 1 LẦN KHI BẤM TouchScreenButton ---
func _on_touch_screen_button_pressed() -> void:
	# Nếu đang combo hoặc đang attack thì không cho bấm liên tục
	if current_state == State.ATTACK:
		return
		
	# Kích hoạt trạng thái tấn công
	current_state = State.ATTACK
	weapon_sprite.visible = true
	
	# Phát hoạt ảnh tương ứng theo hướng nhìn
	if last_direction == "Right":
		anim.play("attackRight")
	elif last_direction == "Left":
		anim.play("attackLeft")
	elif last_direction == "Up":
		anim.play("attackUp")
	else:
		anim.play("attackDown")

# --- 4. XỬ LÝ KHI ANIMATION KẾT THÚC ---
func _on_animation_finished(anim_name: String) -> void:
	if current_state == State.ATTACK:
		weapon_sprite.visible = false  # Ẩn vũ khí
		current_state = State.IDLE     # Trả về đứng yên
