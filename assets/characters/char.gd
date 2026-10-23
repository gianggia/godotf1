extends CharacterBody2D

const SPEED = 300.0

# --- ĐƯỜNG DẪN ĐẾN CÁC NODE CON ---
@onready var anim = $AnimatedSprite2D/Anim/AnimationPlayer
@onready var sprite = $AnimatedSprite2D/Anim/charSprite
@onready var weapon_sprite = $AnimatedSprite2D/Anim/WeaponSprite # Thêm đường dẫn tới WeaponSprite

# Biến lưu hướng nhìn cuối cùng của nhân vật (Mặc định ban đầu nhìn xuống dưới)
var last_direction = "Down"

func _ready() -> void:
	# Mặc định lúc vào game sẽ ẩn vũ khí đi, khi nào bấm tấn công mới hiện
	weapon_sprite.visible = false

func _physics_process(delta: float) -> void:
	# 1. Lấy hướng di chuyển dạng Vector2 từ hệ thống Input Map
	var input_direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	# 2. Xử lý di chuyển và tốc độ (Thêm vùng chết deadzone 0.2 để mượt mà hơn khi dùng cần gạt)
	if input_direction.length() > 0.2:
		# Nhân với SPEED để di chuyển. Nếu dùng joystick gạt nhẹ, nhân vật sẽ đi chậm, gạt mạnh sẽ chạy full tốc độ.
		velocity = input_direction * SPEED
		
		# 3. Phân tích hướng để bật walk animation VÀ cập nhật lại last_direction
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
				
	else:
		# Nếu không gạt joystick / bấm nút, dừng nhân vật lại mượt mà
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.y = move_toward(velocity.y, 0, SPEED)
		
		# 4. Kích hoạt trạng thái đứng yên (Idle) dựa vào hướng nhìn cuối cùng đã lưu
		if last_direction == "Right":
			anim.play("idleRight")
		elif last_direction == "Left":
			anim.play("idleLeft")
		elif last_direction == "Up":
			anim.play("idleUp")
		elif last_direction == "Down":
			anim.play("idle")
		else:
			anim.play("idle") 

	# --- XỬ LÝ SỰ KIỆN TẤN CÔNG (THÊM MỚI) ---
	# Kiểm tra nếu người chơi bấm nút atkBtn
	if Input.is_action_just_pressed("atk"):
		# Hiện vũ khí lên
		weapon_sprite.visible = true
		anim.play("attack")
		# Phát hoạt ảnh attack tương ứng với hướng nhìn cuối cùng
		#if last_direction == "Right":
			#anim.play("attack")
		#elif last_direction == "Left":
			#anim.play("attack")
		#elif last_direction == "Up":
			#anim.play("attack")
		#else:
			#anim.play("attack")

	# 5. Áp dụng chuyển động thực tế vào Godot
	move_and_slide()
