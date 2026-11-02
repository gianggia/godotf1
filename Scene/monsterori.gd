extends CharacterBody2D

const SPEED = 20.0 # Quái chạy chậm hơn Player một chút

var max_hp = 3
var current_hp = max_hp

var player_to_chase: CharacterBody2D = null
var is_dead: bool = false # 🌟 BƯỚC 1: Thêm biến kiểm tra trạng thái chết

func _physics_process(_delta: float) -> void:
	if is_dead: return # 🌟 BƯỚC 2: Nếu đã chết thì DỪNG TOÀN BỘ vật lý và hoạt ảnh di chuyển
	
	if player_to_chase:
		var direction = (player_to_chase.global_position - global_position).normalized()
		velocity = direction * SPEED
		$AnimatedSprite2D.play("walk") # (Nếu có hoạt ảnh di chuyển)
	else:
		velocity = Vector2.ZERO
		$AnimatedSprite2D.play("idle") # (Nếu có hoạt ảnh đứng yên)
		
	move_and_slide()

# --- LOGIC PHÁT HIỆN NGƯỜI CHƠI ---
# Click chuột phải vào DetectionArea -> Node -> Signals -> Kết nối body_entered và body_exited
func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.name == "Char": # Hoặc check bằng class/Group
		player_to_chase = body

func _on_detection_area_body_exited(body: Node2D) -> void:
	if body == player_to_chase:
		player_to_chase = null

# --- LOGIC NHẬN SÁT THƯƠNG ---
# Click chuột phải vào Hurtbox (Area2D của quái) -> Kết nối tín hiệu area_entered
func _on_hurtbox_area_entered(area: Area2D) -> void:
	print("hit!")
	# Kiểm tra xem area chạm vào có phải là Hitbox rìu của Player không
	if area.name == "HitBox": 
		take_damage(1)

func take_damage(amount: int) -> void:
	current_hp -= amount
	print("Quái bị chém! Máu còn: ", current_hp)
	
	# Hiệu ứng chớp đỏ khi bị đau (tùy chọn)
	var tween = create_tween()
	tween.tween_property($Sprite2D, "modulate", Color.RED, 0.1)
	tween.tween_property($Sprite2D, "modulate", Color.WHITE, 0.1)
	
	if current_hp <= 0:
		die()

func die() -> void:
	if is_dead: return # Tránh hàm chạy trùng lặp nhiều lần
	is_dead = true # 🌟 BƯỚC 3: Bật cờ tử trận lên!
	
	print("Quái vật đã chết!")
	player_to_chase = null
	velocity = Vector2.ZERO # Ép đứng yên tại chỗ
	
	# Tắt va chạm để tránh bị chém thêm bồi
	if has_node("Hurtbox"):
		$Hurtbox.set_deferred("monitoring", false)
		$Hurtbox.set_deferred("monitorable", false)
		
	# Bắt đầu play hoạt ảnh die chuẩn chỉnh
	if has_node("AnimatedSprite2D"):
		$AnimatedSprite2D.play("die")
		print("Đang phát hoạt ảnh die...")
		await $AnimatedSprite2D.animation_finished # Chờ diễn xong nét diễn cuối
		
	queue_free() # Diễn xong rồi mới chính thức biến mất


func _on_hurt_box_area_entered(area: Area2D) -> void:
	print("hit!") # Dòng này sẽ in ra màn hình Output để báo hiệu thành công
	if area.name == "HitBox": 
		take_damage(1)
	
