class_name StatModifier
extends Resource

# Structure: { "Stat_Code": [ "Display Name", Min_Value, Max_Value ] }
@export var stat_database: Dictionary = {
	"atk": ["Bonus Attack", 5, 15],
	"hp": ["Bonus Max HP", 50, 200],
	"def": ["Bonus Defense", 2, 8],
	"crit_c": ["Crit Chance", 1, 5],
	"crit_d": ["Crit Damage", 10, 30],
	"speed": ["Bonus Speed", 10, 30]
}
