# File: ItemRarity.gd
class_name ItemRarity
extends Resource

@export var rarity_name: String = ""
@export var rarity_color: Color = Color.WHITE
@export var drop_chance: float = 0.0
@export var stat_multiplier: float = 1.0 # Hệ số nhân chỉ số (Ví dụ: Common = 1.0, Legendary = 2.5)
