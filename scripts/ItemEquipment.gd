class_name ItemEquipment
extends ItemData

enum Slot { WEAPON, ARMOR, HELMET, RING, BOOT }
# Định nghĩa các loại vũ khí cụ thể
enum WeaponType { NONE, SWORD, BOW, HAMMER }

@export var slot_type: Slot = Slot.WEAPON
@export var weapon_type: WeaponType = WeaponType.NONE
@export var attack_power: int = 10

# Nạp cấu hình đòn đánh riêng vào đây
@export var attack_behavior: AttackBehavior
