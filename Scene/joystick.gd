extends Control
## Cần gạt ảo, hỗ trợ đa chạm.
## Node này là VÙNG CẢM ỨNG (do base_hud.gd căn theo màn hình). Chế độ "floating":
## cần gạt xuất hiện ngay chỗ ngón tay chạm trong vùng; thả tay thì trở về vị trí chờ (mờ).

signal vector_changed(vector: Vector2)

# Điền chính xác tên Action trong Input Map của bạn
@export var action_left: String = "move_left"
@export var action_right: String = "move_right"
@export var action_up: String = "move_up"
@export var action_down: String = "move_down"

## true: cần gạt hiện tại chỗ chạm. false: cố định ở vị trí chờ.
@export var floating: bool = true
@export var base_diameter: float = 160.0
## Tỉ lệ kích thước nút gạt nhỏ so với vòng lớn
@export_range(0.2, 1.0) var tip_ratio: float = 0.5
## Vùng chết ở giữa, tránh trôi nhẹ
@export_range(0.0, 0.5) var deadzone: float = 0.15
## Độ mờ khi chờ (chỉ ở chế độ floating)
@export_range(0.0, 1.0) var idle_alpha: float = 0.35

@onready var base: TextureRect = $base
@onready var tip: TextureRect = $base/tip

var vector: Vector2 = Vector2.ZERO # -1..1 sau khi bỏ vùng chết
var _touch_index: int = -1
var _radius: float = 80.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(relayout)
	visibility_changed.connect(_on_visibility_changed)
	relayout()
	_on_visibility_changed()


func get_vector() -> Vector2:
	return vector


# Gọi lại khi đổi kích thước vùng hoặc đường kính vòng
func relayout(diameter: float = -1.0) -> void:
	if diameter > 0.0:
		base_diameter = diameter
	base.size = Vector2.ONE * base_diameter
	tip.size = base.size * tip_ratio
	_radius = base_diameter * 0.5
	_reset_visual()


func _on_visibility_changed() -> void:
	var active := is_visible_in_tree()
	set_process_input(active) # ẩn thì không nhận chạm
	if not active and _touch_index != -1:
		_end()


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			if _touch_index == -1 and get_global_rect().has_point(event.position):
				var local: Vector2 = event.position - global_position
				# Chế độ cố định: chỉ nhận khi chạm gần vòng cần gạt
				if not floating and local.distance_to(_base_center()) > _radius * 1.4:
					return
				_touch_index = event.index
				get_viewport().set_input_as_handled()
				if floating:
					_set_base_center(_clamp_center(local))
				base.modulate.a = 1.0
				_drag(local)
		elif event.index == _touch_index:
			get_viewport().set_input_as_handled()
			_end()
	elif event is InputEventScreenDrag and event.index == _touch_index:
		get_viewport().set_input_as_handled()
		_drag(event.position - global_position)


func _drag(local: Vector2) -> void:
	var offset := (local - _base_center()).limit_length(_radius)
	tip.position = (base.size - tip.size) * 0.5 + offset

	var raw := offset / _radius
	var length := raw.length()
	if length < deadzone:
		vector = Vector2.ZERO
	else:
		vector = raw.normalized() * ((length - deadzone) / (1.0 - deadzone))

	_apply_actions()
	vector_changed.emit(vector)


func _apply_actions() -> void:
	# Giả lập lực đẩy cần gạt thành lực nhấn phím trong Input Map
	_set_action(action_left, maxf(-vector.x, 0.0))
	_set_action(action_right, maxf(vector.x, 0.0))
	_set_action(action_up, maxf(-vector.y, 0.0))
	_set_action(action_down, maxf(vector.y, 0.0))


func _set_action(action: String, strength: float) -> void:
	if not InputMap.has_action(action):
		return
	if strength > 0.0:
		Input.action_press(action, strength)
	else:
		Input.action_release(action)


func _end() -> void:
	_touch_index = -1
	vector = Vector2.ZERO
	_apply_actions() # thả hết các phím
	vector_changed.emit(vector)
	_reset_visual()


func _reset_visual() -> void:
	_set_base_center(_default_center())
	base.modulate.a = idle_alpha if floating else 1.0


# ---- tiện ích vị trí (toạ độ cục bộ của vùng cảm ứng) ----
func _default_center() -> Vector2:
	return Vector2(
		clampf(size.x * 0.5, _radius, maxf(_radius, size.x - _radius)),
		maxf(_radius, size.y - _radius - 40.0))


func _base_center() -> Vector2:
	return base.position + base.size * 0.5


func _set_base_center(center: Vector2) -> void:
	base.position = center - base.size * 0.5
	tip.position = (base.size - tip.size) * 0.5


func _clamp_center(local: Vector2) -> Vector2:
	return Vector2(
		clampf(local.x, _radius, maxf(_radius, size.x - _radius)),
		clampf(local.y, _radius, maxf(_radius, size.y - _radius)))
