extends Control


const SCORE_FILE_PATH = "user://score_record.save" # Added @ P13

onready var high_score = $VBox/ResultsContainer/HighScore # Added @ P13
onready var last_score = $VBox/ResultsContainer/LastScore # Added @ P13
onready var high_level = $VBox/ResultsContainer/HighLevel # Added @ P13
onready var last_level = $VBox/ResultsContainer/LastLevel # Added @ P13
onready var sound = $KeySound


func _ready(): # Added @ P13
	load_data()
	

func _input(event):
	if event is InputEventKey:
		#print("Input at Game Over: ", event.as_text()) # Removed @ P14
		if event.is_action_released("Quit"):
			sound.play()
			yield(sound, "finished")
			get_tree().quit()
		elif event.is_action_released("ui_accept"):
			sound.play()
			yield(sound, "finished")
			get_tree().change_scene("res://scene/GameStartView.tscn")


func load_data(): # Added @ P13
	var file = File.new()
	if file.file_exists(SCORE_FILE_PATH):
		file.open(SCORE_FILE_PATH, File.READ)
		var data = parse_json(file.get_line())
		print("loading... data[\"last_score\"]: ", data["last_level"], data["high_level"])
		if data != null:
			high_score.text = "High Score: " + str(data["high_score"])
			last_score.text = "Last Score: " + str(data["last_score"])
			high_level.text = "High Level: " + str(data["high_level"])
			last_level.text = "Last Level: " + str(data["last_level"])
		file.close()
