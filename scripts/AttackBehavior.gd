class_name AttackBehavior
extends Resource

@export var attack_range: float = 50.0   # Tầm đánh (Kiếm ngắn, Cung dài)
@export var attack_speed: float = 1.0   # Tốc độ ra đòn (Kiếm nhanh, Búa chậm)

# Các thông số nâng cao dành riêng cho từng loại (để mặc định, loại nào cần thì điền)
@export_group("Ranged Weapon")
@export var projectile_speed: float = 0.0 # Tốc độ bay của tên (Chỉ dùng cho Cung)
@export var ammo_scene: PackedScene       # File thực thể mũi tên/đạn để bắn ra

@export_group("Heavy Weapon")
@export var splash_radius: float = 0.0    # Bán kính sát thương lan (Chỉ dùng cho Búa)
