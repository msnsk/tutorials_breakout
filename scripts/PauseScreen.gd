extends Control


onready var sound = $PauseKeySound


func _ready():
	hide()

func _input(event):
	if event.is_action_released("Pause"):
		sound.play()
#		yield(sound, "finished")
		visible = not visible
		get_tree().paused = not get_tree().paused
	elif event.is_action_released("Quit") and visible:
		sound.play()
		yield(sound, "finished")
		get_tree().paused = false
		get_tree().change_scene("res://scene/GameStartView.tscn")
