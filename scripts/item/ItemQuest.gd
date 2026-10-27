class_name ItemQuest
extends ItemData

@export var quest_id: String = ""     # Mã nhiệm vụ để check xem người chơi đang làm nhiệm vụ nào
@export var is_destroyable: bool = false # Khóa lại không cho người chơi lỡ tay xóa mất đồ nhiệm vụ
