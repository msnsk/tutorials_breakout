extends Area2D

signal item_collided(item)

enum Powerup {
	SLOW,
	EXPAND,
	MULTIPLE,
	LASER,
	LIFE,
}

var chosen_item = null

onready var sprite = $AnimatedSprite
onready var slow_1 = preload("res://sprites/Slow1.png")
onready var slow_2 = preload("res://sprites/Slow2.png")
onready var slow_3 = preload("res://sprites/Slow3.png")
onready var slow_frames = [slow_1, slow_2, slow_3]
onready var expand_1 = preload("res://sprites/Expand1.png")
onready var expand_2 = preload("res://sprites/Expand2.png")
onready var expand_3 = preload("res://sprites/Expand3.png")
onready var expand_frames = [expand_1, expand_2, expand_3]
onready var multiple_1 = preload("res://sprites/Multiple1.png")
onready var multiple_2 = preload("res://sprites/Multiple2.png")
onready var multiple_frames = [multiple_1, multiple_2]
onready var laser_1 = preload("res://sprites/Laser1.png")
onready var laser_2 = preload("res://sprites/Laser2.png")
onready var laser_3 = preload("res://sprites/Laser3.png")
onready var laser_frames = [laser_1, laser_2, laser_3]
onready var life_1 = preload("res://sprites/Heart1.png")
onready var life_2 = preload("res://sprites/Heart2.png")
onready var life_3 = preload("res://sprites/Heart3.png")
onready var life_frames = [life_1, life_2, life_3]

func _ready():
	randomize()
	add_sprite_frames()
	
func add_sprite_frames():
	var random_num = randf()
	var item_list = []
	
	if random_num <= 0.3:
		item_list += slow_frames
		chosen_item = Powerup.SLOW
	elif random_num <= 0.55:
		item_list += expand_frames
		chosen_item = Powerup.EXPAND
	elif random_num <= 0.75:
		item_list += multiple_frames
		chosen_item = Powerup.MULTIPLE
	elif random_num <= 0.9:
		item_list += laser_frames
		chosen_item = Powerup.LASER
	else:
		item_list += life_frames
		chosen_item = Powerup.LIFE
		
	for item in item_list:
		# add to the head
		sprite.frames.add_frame("drop", item, 0)


func _physics_process(_delta):
	position.y += 0.75


func _on_Powerup_body_entered(_body):
	emit_signal("item_collided", chosen_item)
	queue_free()

	
