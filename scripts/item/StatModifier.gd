# File: StatModifier.gd
class_name StatModifier
extends Resource

# Cấu trúc Dictionary phân cấp theo Loại Đồ -> Mã Chỉ Số -> [Tên, Min, Max]
@export var stat_database: Dictionary = {
	"Weapon": {
		"atk": ["Attack", 10, 20],
		"crit_c": ["Crit Chance", 1, 5],
		"crit_d": ["Crit Damage", 10, 25]
	},
	"Armor": {
		"hp": ["Max HP", 50, 100],
		"def": ["Defense", 5, 15]
	},
	"Boots": {
		"speed": ["Bonus Speed", 5, 10],
		"hp": ["Max HP", 30, 60]
	}
}
