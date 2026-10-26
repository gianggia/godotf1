class_name ItemRarity
extends Resource

@export var rarity_name: String = ""      # Tên bậc: Thường, Hiếm, Sử Thi, Huyền Thoại...
@export var text_color: Color = Color.WHITE # Màu chữ hiển thị khi nhặt được đồ
@export var drop_chance: float = 1.0       # Tỷ lệ rơi đồ (Ví dụ: Đồ trắng 0.7, Đồ đỏ 0.01)
