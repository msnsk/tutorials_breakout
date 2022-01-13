extends Node2D

const POINT = 10
const MAX_LIFE = 5 # Added @ P11
const SCORE_FILE_PATH = "user://score_record.save" # Added @ P13

export var drop_rate = 0.2
export var level_num: int = 1 # Modified @ P14
var high_level_num: int = 0 # Added @ P13
var score: int = 0
var high_score: int = 0 # Added @ P13
var bonus_rate = 1.0
var life = 3
var is_playing = true
var is_multiple_on = false # Added @ P11
var is_laser_on = false # Added @ P11
var expand_timer = Timer.new() # Added @ P14
var multiple_timer = Timer.new() # Added @ P14
var laser_timer = Timer.new() # Added @ P14

#onready var level = $Level1 # Removed @ P11
onready var next_screen = $NextScreen
onready var next_screen_level = $NextScreen/VBox/Level
onready var next_screen_score = $NextScreen/VBox/Score
onready var next_screen_life = $NextScreen/VBox/HBox/Life
onready var hud_level = $HUD/LeftBox/Level
onready var hud_high_level = $HUD/MidBox/HighLevel # Added @ P13
onready var hud_score = $HUD/LeftBox/Score
onready var hud_high_score = $HUD/MidBox/HighScore # Added @ P13
onready var hud_rightbox = $HUD/RightBox
onready var paddle = $Paddle
#onready var ball = $Ball # Removed @ P11
onready var pause_screen = $PauseScreen
onready var life_down_sound = $LifeDownSound
onready var slow_collide_sound = $SlowCollideSound
onready var expand_collide_sound = $ExpandCollideSound
onready var multiple_collide_sound = $MultipleCollideSound
onready var laser_collide_sound = $LaserCollideSound
onready var life_collide_sound = $LifeCollideSound
onready var play_bgm = $PlayBGM

onready var paddle_position = paddle.position
onready var paddle_scale = paddle.scale # Added @ P11
#onready var ball_position = ball.position # Removed @ P11
onready var ball = preload("res://scene/Ball.tscn") # Added @ P11
onready var laser = preload("res://scene/Laser.tscn") # Added @ P11
onready var powerup = preload("res://scene/Powerup.tscn") # Added @ P10
onready var level = null # Updated @ P11

func _ready():
	randomize() # Added @ P10
	add_new_level() # Added @ P11
	add_new_ball() # Added @ P11
	update_hud_life()
	load_data() # Added @ P13
	set_timer(expand_timer, "stop_expand") # Added @ P14
	set_timer(multiple_timer, "stop_multiple") # Added @ P14
	set_timer(laser_timer, "stop_laser") # Added @ P14
	#leave_one_brick(73) # For debug # Moved @ P11
	#ball.connect("tree_exited", self, "_on_Ball_tree_exited") # Removed @ P11
	#for brick in level.get_children(): # Removed @ P11
		#brick.connect("tree_exited", self, "_on_Brick_tree_exited", [brick.global_position]) # Updated @ P10


func _process(_delta): # Added @ P11
	if is_multiple_on and Input.is_action_just_pressed("launch_ball"):
		add_new_ball()
	if is_laser_on and Input.is_action_just_pressed("ui_up"):
		fire_laser()


# For debug
func leave_one_brick(brick_num: int):
	for child in level.get_children():
		if child.get_name() == "Brick" + str(brick_num):
			continue
		child.queue_free()


# Set Timer
func set_timer(timer_var, stop_func): # Added @ P14
	add_child(timer_var)
	timer_var.connect("timeout", self, stop_func)


# Method receiving Ball signal
func _on_Ball_tree_exited():
	print("_on_Ball_tree_exited() called")
	var no_ball = true # Added @ P11
	for child in get_children(): # Added @ P11
		if child.is_in_group("Balls"):
			print("found ball")
			no_ball = false
			break
	
	if no_ball: # Added and Edited @ P11
		if is_playing:
			life -= 1
			if life <= 0:
#				if high_score < score: # Added @ P13 # Removed @ P14
#					high_score = score
#				if high_level_num < level_num: # Added @ P13 # Removed @ P14
#					high_level_num = level_num
				save_data() # Added @ P13
				get_tree().change_scene("res://scene/GameOverView.tscn")
			else:
				update_hud_life()
				life_down_sound.play()
		else:
			is_playing = true
		# Clear powerup items
		for child in get_children(): # Added @ P10
			if child.is_in_group("PowerupItems"):
				child.queue_free()
		# Set Paddle and Balls as default
		is_multiple_on = false # Added @ P11
		is_laser_on = false # Added @ P11
		paddle.position = paddle_position
		paddle.scale = paddle_scale # Added @ P11
		add_new_ball() # Added @ P11
		#ball = load("res://scene/Ball.tscn").instance() # Removed @ P11
		#call_deferred("add_child", ball) # Removed @ P11
		#call_deferred("move_child", ball, 3) # Removed @ P11
		#ball.connect("tree_exited", self, "_on_Ball_tree_exited") # Removed @ P11


# Set life nodes shown and hidden as life variable
func update_hud_life():
	var count = 0
	for child in hud_rightbox.get_children():
		count += 1
		if count <= life:
			child.show()
		else:
			child.hide()


# Add a new ball
func add_new_ball(): # Added @ P11
	print("add_new_ball() called")
	var instance = ball.instance()
	instance.position = Vector2(paddle.position.x, paddle.position.y - 10) # Added @ P11
	call_deferred("add_child", instance)
	call_deferred("move_child", instance, 4)
	instance.connect("tree_exited", self, "_on_Ball_tree_exited")	
	#instance.mode = 3 # Removed @ P11


# Method receiving Brick signal
func _on_Brick_tree_exited(brick_position):
	# Update Score
	score += POINT * bonus_rate
	bonus_rate += 0.1
	hud_score.text = "Score: " + str(score)

	# Exit current Level node
	var no_brick = true # Added @ P14
	for child in level.get_children(): # Added @ P14
		if child.brick_hardness != child.Hardness.METAL:
			no_brick = false
			break
	#if level.get_child_count() <= 0: # Removed @ P14
	if no_brick: # Added @ P14
		set_next_level()
	else: # Added @ P11
		# Drop powerup item
		drop_powerup(brick_position) # Added @ P10


func drop_powerup(brick_position: Vector2): # Added @ P10
	if randf() <= drop_rate:
		var powerup_instance = powerup.instance()
		powerup_instance.position = brick_position
		call_deferred("add_child", powerup_instance)
		call_deferred("move_child", powerup_instance, 5) # Added @ P 11
		powerup_instance.connect("item_collided", self, "_on_Powerup_item_collided") 

# Action when powerup item collided
func _on_Powerup_item_collided(item): # Updated @ P11
	match item:
		0: # SLOW
			slow_balls()
		1: # EXPAND
			expand_paddle()
		2: # MULTIPLE
			enable_multiple_balls()
		3: # LASER
			enable_laser()
		4: # LIFE
			add_life()

# slow balls
func slow_balls(): # Added @ P11
	slow_collide_sound.play() # Added @ P12
	for child in get_children():
		if child.is_in_group("Balls"):
			child.ball_speed = child.first_speed


# Stretch paddle
func expand_paddle(): # Added @ P11
	expand_collide_sound.play() # Added @ P12
	if paddle.scale <= paddle_scale:
		paddle.scale.x *= 2
		#yield(get_tree().create_timer(3), "timeout") # Removed @ P14
		#paddle.scale = paddle_scale # Removed @ P14
		expand_timer.wait_time = 10
		expand_timer.start() # Added @ P14

func stop_expand(): # Added @ P14
	expand_timer.stop()
	paddle.scale = paddle_scale


# enable powerup Multiple
func enable_multiple_balls(): # Added @ P11
	multiple_collide_sound.play() # Added @ P12
	if not is_multiple_on:
		is_multiple_on = true
		#yield(get_tree().create_timer(3), "timeout") # Removed @ P14
		#is_multiple_on = false # Removed @ P14
		multiple_timer.wait_time = 3
		multiple_timer.start() # Added @ P14

func stop_multiple(): # Added @ P14
	multiple_timer.stop()
	is_multiple_on = false


# enable powerup Laser
func enable_laser(): # Added @ P11
	laser_collide_sound.play() # Added @ P12
	if not is_laser_on:
		is_laser_on = true
		#yield(get_tree().create_timer(3), "timeout") # Removed @ P14
		#is_laser_on = false # Removed @ P14
		laser_timer.wait_time = 3
		laser_timer.start() # Added @ P14

func stop_laser(): # Added @ P14
	laser_timer.stop()
	is_laser_on = false


# fire laser beam
func fire_laser():
	var instance = laser.instance()
	call_deferred("add_child", instance)
	call_deferred("move_child", instance, 6)
	instance.position.x = paddle.position.x
	instance.position.y = paddle.position.y - 16

# Add a life if less than 5
func add_life(): # Added @ P11
	life_collide_sound.play() # Added @ P12
	if life < MAX_LIFE:
		life += 1
		update_hud_life()

# set next level
func set_next_level():
	print("set_next_level() called")
	# Change status
	is_playing = false
	#is_multiple_on = false # Added @ P11 # Removed @ P14
	#is_laser_on = false # Added @ P11 # Removed @ P14
	stop_expand()
	stop_multiple()
	stop_laser()
	
	# Clear left objects
	level.queue_free()
	for child in get_children():
		if child.is_in_group("Balls") or child.is_in_group("Lasers"): # 追加
			child.queue_free()
	# Save data
	save_data() # Added @ P14
	# Increment level number
	level_num += 1
	# If no more level, game clear
	if ResourceLoader.exists("res://scene/Level" + str(level_num) + ".tscn"): # Added @ P14
		# Stop PauseScreen node
		pause_screen.pause_mode = 1
		# Show NextScreen node
		next_screen.pause_mode = 2
		next_screen_level.text = "Level: " + str(level_num)
		next_screen_score.text = "Score: " + str(score)
		next_screen_life.text = "x " + str(life)
		next_screen.show()
		# Set Level of HUD the next level
		hud_level.text = "Level: " + str(level_num)
		# Set Paddle and Ball the first position
		#paddle.position = paddle_position # Removed @ P11
		#paddle.scale = paddle_scale # Removed @ P11
		#ball.position = ball_position # Removed @ P11
		#ball.mode = 3 # Removed @ P11
		# Set next Level node
		add_new_level() # Added @ P11
		#level = load("res://scene/Level" + str(level_num) + ".tscn").instance() # Removed @ P11
		#add_child(level) # Removed @ P11
		#move_child(level, 5) # Removed @ P11
		#for child in level.get_children(): # Removed @ P11
			#child.connect("tree_exited", self, "_on_Brick_tree_exited") # Removed @ P11
		# Pause game until NextScreen is hidden
		get_tree().paused = true
	else:
		get_tree().change_scene("res://scene/GameClearView.tscn")
		print("no more level!")


# Add new level
func add_new_level(): # Added @ P11
	level = load("res://scene/Level" + str(level_num) + ".tscn").instance()
	add_child(level)
	move_child(level, 3) # Changed from 5 to 3 @ P11
	for child in level.get_children():
		if child.brick_hardness != child.Hardness.METAL: # Added @ P14
			child.connect("tree_exited", self, "_on_Brick_tree_exited", [child.global_position]) # Updated to add th 4th arg @ P11 


func _on_PauseScreen_visibility_changed():
	play_bgm.stream_paused = not play_bgm.stream_paused


# Save data
func save_data(): # Added @ P13
	print("saving... level_num: ", level_num)
	if high_score < score: # Added @ P14
		high_score = score
	if high_level_num < level_num: # Added @ P14
		high_level_num = level_num
		
	var data = {
	"last_level": level_num,
	"high_level": high_level_num,
	"last_score": score,
	"high_score": high_score,
	}
	
	print("data[\"last_level\"]: ", data["last_level"])
	var file = File.new()
	file.open(SCORE_FILE_PATH, File.WRITE)
	file.store_line(to_json(data))
	file.close()


# Load data
func load_data(): # Added @ P13
	var file = File.new()
	if file.file_exists(SCORE_FILE_PATH):
		file.open(SCORE_FILE_PATH, File.READ)
		var data = parse_json(file.get_line())
		if data != null:
			high_score = data["high_score"]
			high_level_num = data["high_level"]
		file.close()
	hud_high_score.text = "H Scr: " + str(high_score)
	hud_high_level.text = "H Lvl: " + str(high_level_num)
