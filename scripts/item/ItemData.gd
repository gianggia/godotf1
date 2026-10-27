class_name ItemData
extends Resource

@export var item_name: String = ""
@export var texture: Texture2D
@export_multiline var description: String = ""

# ĐÂY LÀ DÒNG THÊM MỚI: Quản lý độ hiếm của vật phẩm
@export var rarity: Resource 
