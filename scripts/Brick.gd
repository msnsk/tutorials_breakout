tool
extends StaticBody2D

enum Hardness{
	NORMAL,
	HARD,
	METAL,
} # Added @ P14

export (Hardness) var brick_hardness = Hardness.NORMAL setget set_color # Added @ P14
#export (Color) var brick_color = Color(1, 1, 1, 1) setget set_color # Removed @ P14

onready var sprite = $Sprite

func _ready():
	set_color(brick_hardness) # Modified @ P14
	modulate = Color(1, 1, 1, 1)
	sprite.scale = Vector2(1, 1)
	

func set_color(hardness): # Modified @ P14
	brick_hardness = hardness
	var brick_color: Color
	match hardness:
		Hardness.METAL:
			brick_color = Color.darkgray
		Hardness.HARD:
			brick_color = Color.firebrick
		Hardness.NORMAL:
			brick_color = Color.white
	if is_inside_tree():
		sprite.set_modulate(brick_color)
