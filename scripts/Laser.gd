extends Area2D


export (float) var laser_speed = 500

onready var line = $Line2D
onready var sound = $ShootSound


func _ready():
	sound.play()


func _physics_process(delta):
	position += Vector2.UP * laser_speed * delta


func _on_body_entered(body):
	if body.is_in_group("Bricks"):
		body.queue_free()
		queue_free()


func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
	print("laser queue_free")
