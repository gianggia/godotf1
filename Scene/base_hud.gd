extends CanvasLayer
## HUD điều khiển cảm ứng: tự bố trí theo màn hình DỌC hoặc NGANG, có tính vùng tai thỏ.
##
## Thêm nút kỹ năng mới: nhân bản node "Skill1" trong MobileControls, đặt tên mới,
## thêm tên đó vào SECONDARY bên dưới, bật Visible. Vị trí tự xếp thành cung quanh nút đánh.
## Nếu bật/tắt Visible của nút lúc đang chơi (mở khóa kỹ năng), gọi refresh_layout().

enum HudOrientation { AUTO, PORTRAIT, LANDSCAPE }

signal button_pressed(button_name: StringName)
signal menu_requested

@export var orientation: HudOrientation = HudOrientation.AUTO
## Cạnh ngắn của màn hình thiết kế (px). Dọc 720x1280 thì để 720.
@export var design_short_side: float = 720.0
@export var min_scale: float = 0.8
@export var max_scale: float = 1.6
@export var use_safe_area: bool = true

# Các nút phụ, xếp theo thứ tự trên cung quanh nút đánh (nút đang ẩn sẽ bị bỏ qua)
const SECONDARY: Array[StringName] = [&"lootBtn", &"Skill1", &"Skill2", &"Skill3", &"Skill4", &"Skill5"]
const ARC_ANGLES: Array[float] = [195.0, 232.0, 268.0] # độ: 180 = bên trái, 270 = phía trên
const SLOTS_PER_RING := 3

@onready var controls: Control = $MobileControls
@onready var joystick: Control = $MobileControls/Joystick
@onready var btn_atk: Control = $MobileControls/BtnAtk
@onready var btn_menu: Control = $MobileControls/BtnMenu


func _ready() -> void:
	add_to_group("hud_controls")
	get_viewport().size_changed.connect(refresh_layout)
	for child in controls.get_children():
		if child.has_signal("pressed") and child is Control:
			child.pressed.connect(_on_button_pressed.bind(child.name))
	refresh_layout()


# Menu mở thì ẩn cả cụm điều khiển (MenuUI gọi qua group "hud_controls")
func set_enabled(enabled: bool) -> void:
	controls.visible = enabled


func _on_button_pressed(button_name: StringName) -> void:
	button_pressed.emit(button_name)
	if button_name == &"BtnMenu":
		menu_requested.emit()
		


func refresh_layout() -> void:
	var vp := get_viewport().get_visible_rect().size
	var landscape := vp.x > vp.y
	if orientation == HudOrientation.PORTRAIT:
		landscape = false
	elif orientation == HudOrientation.LANDSCAPE:
		landscape = true

	var s := clampf(minf(vp.x, vp.y) / design_short_side, min_scale, max_scale)
	var safe := _safe_margins(vp) # x=trái, y=trên, z=phải, w=dưới

	# --- Cần gạt: vùng nửa trái, phần dưới màn hình ---
	joystick.anchor_left = 0.0
	joystick.anchor_right = 0.4 if landscape else 0.5
	joystick.anchor_top = 0.3 if landscape else 0.5
	joystick.anchor_bottom = 1.0
	joystick.offset_left = safe.x
	joystick.offset_top = 0.0
	joystick.offset_right = 0.0
	joystick.offset_bottom = -safe.w
	joystick.call("relayout", (150.0 if landscape else 170.0) * s)

	# --- Nút đánh chính: góc dưới phải, nằm trong tầm ngón cái ---
	var main_size := (110.0 if landscape else 120.0) * s
	var margin := (Vector2(40.0, 36.0) if landscape else Vector2(28.0, 110.0)) * s
	margin += Vector2(safe.z, safe.w)
	var main_center := Vector2(-(margin.x + main_size * 0.5), -(margin.y + main_size * 0.5))
	_place_center(btn_atk, Vector2.ONE, main_center, Vector2.ONE * main_size)

	# --- Nút phụ: xếp thành cung quanh nút đánh, đầy 3 nút thì sang vòng ngoài ---
	var small := 78.0 * s
	var idx := 0
	for button_name in SECONDARY:
		var b := controls.get_node_or_null(NodePath(button_name)) as Control
		if b == null or not b.visible:
			continue
		var ring := floori(float(idx) / SLOTS_PER_RING)
		var slot := idx % SLOTS_PER_RING
		var angle := deg_to_rad(ARC_ANGLES[slot])
		var radius := main_size * 0.5 + small * 0.5 + 34.0 * s + ring * (small + 14.0 * s)
		_place_center(b, Vector2.ONE, main_center + Vector2(cos(angle), sin(angle)) * radius, Vector2.ONE * small)
		idx += 1

	# --- Nút menu: góc trên phải ---
	var menu_size := 64.0 * s
	var m := Vector2(16.0, 16.0) * s + Vector2(safe.z, safe.y)
	_place_center(btn_menu, Vector2(1.0, 0.0),
		Vector2(-(m.x + menu_size * 0.5), m.y + menu_size * 0.5), Vector2.ONE * menu_size)


# Đặt control quanh tâm "center" tính từ điểm neo "anchor" (anchor là 0 hoặc 1)
func _place_center(n: Control, anchor: Vector2, center: Vector2, sz: Vector2) -> void:
	n.anchor_left = anchor.x
	n.anchor_right = anchor.x
	n.anchor_top = anchor.y
	n.anchor_bottom = anchor.y
	n.offset_left = center.x - sz.x * 0.5
	n.offset_right = center.x + sz.x * 0.5
	n.offset_top = center.y - sz.y * 0.5
	n.offset_bottom = center.y + sz.y * 0.5


# Lề an toàn (tai thỏ, thanh điều hướng) đổi sang toạ độ viewport. Máy tính để bàn: bằng 0.
func _safe_margins(vp: Vector2) -> Vector4:
	if not use_safe_area or not OS.has_feature("mobile"):
		return Vector4.ZERO
	var win := Vector2(DisplayServer.window_get_size())
	var safe := DisplayServer.get_display_safe_area()
	if win.x <= 0.0 or win.y <= 0.0 or safe.size == Vector2i.ZERO:
		return Vector4.ZERO
	var k := Vector2(vp.x / win.x, vp.y / win.y)
	return Vector4(
		maxf(safe.position.x * k.x, 0.0),
		maxf(safe.position.y * k.y, 0.0),
		maxf((win.x - safe.end.x) * k.x, 0.0),
		maxf((win.y - safe.end.y) * k.y, 0.0))


func _on_btn_menu_pressed() -> void:
	pass # Replace with function body.
