extends Control

onready var sound = $KeySound

func _input(event):
	if event is InputEventKey and event.is_pressed():
		sound.play()
		yield(sound, "finished")
		get_tree().change_scene("res://scene/Game.tscn")
