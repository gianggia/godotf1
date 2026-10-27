class_name CharacterStats
extends Resource

@export_group("Base Stats")
@export var max_hp: int = 100
@export var attack: int = 10
@export var defense: int = 5
@export var speed: float = 200.0
@export var crit: float =0.0
@export var critDamage: float = 200.0


# Biến động để tính toán trong trận đấu (Không cần hiện trên Inspector)
var current_hp: int = 100

# Hàm khởi tạo lại máu khi bắt đầu game hoặc đổi màn
func initialize() -> void:
	current_hp = max_hp
