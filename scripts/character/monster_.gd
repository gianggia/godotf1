extends CharacterBody2D
## Quái vật Skeleton (rig cutout từ Sprite2D, animation nằm trong AnimationPlayer).
## Animation: idle_ / walk_ / attack_ + (up, down, left, right) và die.
## Để gây sát thương, node người chơi cần thuộc group "player" và có hàm take_damage(amount).

signal died(monster: CharacterBody2D)

enum State { IDLE, CHASE, ATTACK, DEAD }

@export var max_hp: int = 30
@export var move_speed: float = 45.0
@export var detect_range: float = 160.0
@export var attack_range: float = 28.0
@export var attack_damage: int = 5
@export var attack_cooldown: float = 1.2
@export var target_group: StringName = &"player"

@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var visual: Node2D = $Visual
@onready var body_shape: CollisionShape2D = $CollisionShape2D
@onready var attack_area: Area2D = $AttackArea
@onready var attack_shape: CollisionShape2D = $AttackArea/CollisionShape2D

var hp: int
var state: State = State.IDLE
var facing: StringName = &"down"
var target: Node2D = null
var _cooldown_left: float = 0.0


func _ready() -> void:
	hp = max_hp
	add_to_group("monsters")
	anim.animation_finished.connect(_on_animation_finished)
	_play("idle")


func _physics_process(delta: float) -> void:
	if state == State.DEAD:
		return

	_cooldown_left = maxf(_cooldown_left - delta, 0.0)
	if target == null or not is_instance_valid(target):
		target = get_tree().current_scene.find_child("Char",true,false) as Node2D

	match state:
		State.IDLE:
			_state_idle()
		State.CHASE:
			_state_chase()
		State.ATTACK:
			velocity = Vector2.ZERO

	move_and_slide()


# ---------------- Trạng thái ----------------
func _state_idle() -> void:
	velocity = Vector2.ZERO
	if target != null and global_position.distance_to(target.global_position) <= detect_range:
		state = State.CHASE


func _state_chase() -> void:
	if target == null:
		state = State.IDLE
		_play("idle")
		return

	var to_target := target.global_position - global_position
	var dist := to_target.length()

	if dist > detect_range * 1.5:
		velocity = Vector2.ZERO
		state = State.IDLE
		_play("idle")
		return

	_face_towards(to_target)

	if dist <= attack_range:
		velocity = Vector2.ZERO
		if _cooldown_left <= 0.0:
			_start_attack()
		else:
			_play("idle")
	else:
		velocity = to_target / dist * move_speed
		_play("walk")


func _start_attack() -> void:
	state = State.ATTACK
	_cooldown_left = attack_cooldown
	attack_shape.position = _anim_dir * 18.0 + Vector2(0, -12)
	_play("attack")


# Được gọi từ track "method" trong animation attack_* đúng khung hình chém
func _on_hit_frame() -> void:
	if state != State.ATTACK:
		return
	for body in attack_area.get_overlapping_bodies():
		if body.is_in_group(target_group) and body.has_method("take_damage"):
			body.take_damage(attack_damage)


func _on_animation_finished(anim_name: StringName) -> void:
	if state == State.DEAD:
		if anim_name == &"die":
			died.emit(self)
			queue_free()
	elif state == State.ATTACK and String(anim_name).begins_with("attack"):
		state = State.CHASE


# ---------------- Sát thương / chết ----------------
func take_damage(amount: int) -> void:
	if state == State.DEAD:
		return
	hp -= amount
	visual.modulate = Color(1.0, 0.45, 0.45)
	create_tween().tween_property(visual, "modulate", Color.WHITE, 0.15)
	if hp <= 0:
		die()


func die() -> void:
	if state == State.DEAD:
		return
	state = State.DEAD
	velocity = Vector2.ZERO
	body_shape.set_deferred("disabled", true)
	attack_area.set_deferred("monitoring", false)
	anim.play("die")

var _anim_dir:Vector2=Vector2.DOWN
# ---------------- Hướng + animation ----------------
func _face_towards(dir: Vector2) -> void:
	# Có độ trễ nhỏ để tránh nhấp nháy khi đi chéo
	_anim_dir=dir.normalized()
	if absf(dir.x)>4.0:
		facing= &"right" if dir.x>0.0 else &"left"
	
	## EDit claude only facing laeft and right
	
	#var facing_horizontal := facing == &"left" or facing == &"right"
	#var go_horizontal: bool
	#if facing_horizontal:
		#go_horizontal = absf(dir.y) <= absf(dir.x) * 1.25
	#else:
		#go_horizontal = absf(dir.x) > absf(dir.y) * 1.25
	#if go_horizontal:
		#facing = &"right" if dir.x > 0.0 else &"left"
	#else:
		#facing = &"down" if dir.y > 0.0 else &"up"


func _facing_vector() -> Vector2:
	match String(facing):
		"up":
			return Vector2.UP
		"left":
			return Vector2.LEFT
		"right":
			return Vector2.RIGHT
		_:
			return Vector2.DOWN


func _play(base_name: String) -> void:
	var anim_name := "%s_%s" % [base_name, facing]
	if anim.current_animation != anim_name:
		anim.play(anim_name)
