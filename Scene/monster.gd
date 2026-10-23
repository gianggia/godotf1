extends CharacterBody2D

const SPEED = 100.0 # Quái chạy chậm hơn Player một chút
var max_hp = 3
var current_hp = max_hp

var player_to_chase: CharacterBody2D = null

func _physics_process(_delta: float) -> void:
	# Nếu phát hiện thấy người chơi thì đuổi theo
	if player_to_chase:
		var direction = (player_to_chase.global_position - global_position).normalized()
		velocity = direction * SPEED
	else:
		# Nếu không có người chơi thì đứng yên (hoặc bạn có thể viết thêm logic đi tuần)
		velocity = Vector2.ZERO
		
	move_and_slide()

# --- LOGIC PHÁT HIỆN NGƯỜI CHƠI ---
# Click chuột phải vào DetectionArea -> Node -> Signals -> Kết nối body_entered và body_exited
func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.name == "Player": # Hoặc check bằng class/Group
		player_to_chase = body

func _on_detection_area_body_exited(body: Node2D) -> void:
	if body == player_to_chase:
		player_to_chase = null

# --- LOGIC NHẬN SÁT THƯƠNG ---
# Click chuột phải vào Hurtbox (Area2D của quái) -> Kết nối tín hiệu area_entered
func _on_hurtbox_area_entered(area: Area2D) -> void:
	# Kiểm tra xem area chạm vào có phải là Hitbox rìu của Player không
	if area.name == "Hitbox": 
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
	print("Quái vật đã chết!")
	queue_free() # Xóa quái vật khỏi game
