extends Control


onready var pause_screen = get_node("../PauseScreen")

func _ready():
	show()
	pause_screen.pause_mode = 1
	get_tree().paused = true

func _input(_event):
	if Input.is_action_just_pressed("ui_accept"):
		yield(get_tree().create_timer(0.1), "timeout")
		hide()
		pause_screen.pause_mode = 2
		get_tree().paused = false
		pause_mode = 1
