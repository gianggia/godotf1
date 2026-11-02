class_name TouchButton
extends Control
## Nút cảm ứng tròn cho HUD.
## Xử lý theo từng ngón tay (index) bằng _input, nên bấm nhiều nút + cần gạt cùng lúc vẫn ổn
## (Button thường của Godot chỉ nhận 1 ngón). Vị trí và kích thước do BaseHUD (base_hud.gd) tính.

signal pressed
signal released

## Tên action trong Input Map sẽ được nhấn/nhả theo nút (để trống = chỉ phát signal).
@export var action: StringName = &""
## Hình biểu tượng (để trống thì vẽ chữ "text").
@export var icon: Texture2D:
	set(value):
		icon = value
		queue_redraw()
@export var text: String = "":
	set(value):
		text = value
		queue_redraw()
## Vẽ khung tròn kiểu RPG. Tắt đi nếu ảnh icon đã là nút hoàn chỉnh.
@export var frame: bool = true:
	set(value):
		frame = value
		queue_redraw()
@export var accent: Color = Color(0.78, 0.6, 0.25):
	set(value):
		accent = value
		queue_redraw()
## > 0: mỗi lần bấm tự chạy hồi chiêu chừng đó giây (nút bị khóa và hiện hình quạt tối).
@export_range(0.0, 60.0, 0.1) var cooldown_time: float = 0.0
## Trượt ngón ra khỏi nút thì tự nhả.
@export var release_on_leave: bool = true

var is_down := false
var _touch_index := -1
var _cooldown_total := 0.0
var _cooldown_left := 0.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_process(false) # chỉ bật khi đang hồi chiêu
	resized.connect(queue_redraw)
	visibility_changed.connect(_on_visibility_changed)
	_on_visibility_changed()


func _on_visibility_changed() -> void:
	var active := is_visible_in_tree()
	set_process_input(active) # ẩn thì không nhận chạm
	if not active:
		_release()


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			if _touch_index == -1 and _hit(event.position):
				_touch_index = event.index
				get_viewport().set_input_as_handled()
				if _cooldown_left <= 0.0:
					_press()
		elif event.index == _touch_index:
			get_viewport().set_input_as_handled()
			_release()
	elif event is InputEventScreenDrag and event.index == _touch_index:
		get_viewport().set_input_as_handled()
		if release_on_leave and is_down and not _hit(event.position):
			_release()


# Vùng chạm hơi rộng hơn hình vẽ 15% cho dễ bấm
func _hit(pos: Vector2) -> bool:
	var radius := minf(size.x, size.y) * 0.5 * 1.15
	return pos.distance_to(get_global_rect().get_center()) <= radius


func _use_action() -> bool:
	return action != &"" and InputMap.has_action(action)


func _press() -> void:
	is_down = true
	if _use_action():
		Input.action_press(action)
	pressed.emit()
	if cooldown_time > 0.0:
		start_cooldown(cooldown_time)
	queue_redraw()


func _release() -> void:
	_touch_index = -1
	if not is_down:
		return
	is_down = false
	if _use_action():
		Input.action_release(action)
	released.emit()
	queue_redraw()


# Tương thích với TouchScreenButton cũ
func is_pressed() -> bool:
	return is_down


func is_ready() -> bool:
	return _cooldown_left <= 0.0


func start_cooldown(seconds: float) -> void:
	_cooldown_total = maxf(seconds, 0.01)
	_cooldown_left = seconds
	set_process(true)
	queue_redraw()


func _process(delta: float) -> void:
	_cooldown_left = maxf(_cooldown_left - delta, 0.0)
	if _cooldown_left <= 0.0:
		set_process(false)
	queue_redraw()


func _draw() -> void:
	var c := size * 0.5
	var r := minf(size.x, size.y) * 0.5
	if is_down:
		r *= 0.92 # hiệu ứng nhấn xuống
	var on_cooldown := _cooldown_left > 0.0

	if frame:
		var bg := Color(0.3, 0.22, 0.1, 0.95) if is_down else Color(0.09, 0.07, 0.11, 0.85)
		draw_circle(c, r, bg)
		draw_arc(c, r - 1.5, 0.0, TAU, 48, accent, 3.0, true)

	var tint := Color(1, 1, 1, 0.45) if on_cooldown else Color.WHITE
	if icon != null:
		var side := r * 1.2 if frame else r * 2.0
		draw_texture_rect(icon, Rect2(c - Vector2(side, side) * 0.5, Vector2(side, side)), false, tint)
	elif text != "":
		var font_size := int(r * 0.7)
		var font := ThemeDB.fallback_font
		draw_string(font, Vector2(0.0, c.y + font_size * 0.35), text,
			HORIZONTAL_ALIGNMENT_CENTER, size.x, font_size, accent.lightened(0.3))

	if on_cooldown:
		# Hình quạt tối: vẽ bằng cung dày, nhỏ dần theo thời gian còn lại
		var frac := _cooldown_left / _cooldown_total
		draw_arc(c, r * 0.5, -PI * 0.5, -PI * 0.5 + TAU * frac, 32, Color(0, 0, 0, 0.55), r, true)


func _on_pressed() -> void:
	pass # Replace with function body.


func _on_loot_btn_pressed() -> void:
	pass # Replace with function body.
