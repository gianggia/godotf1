class_name StatModifier
extends Resource

enum StatType { ATTACK, DEFENSE, MAX_HP, CRIT_CHANCE, CRIT_DAMAGE }

@export var stat_type: StatType
@export var stat_name: String = ""
@export var min_value: int = 1
@export var max_value: int = 10
