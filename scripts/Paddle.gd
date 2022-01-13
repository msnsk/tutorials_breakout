extends KinematicBody2D


export (int) var speed = 300 # Updated @ P14
onready var animation = $AnimationPlayer


func _physics_process(_delta):
	var direction = Vector2.ZERO
	if Input.is_action_pressed("move_right"):
		direction.x = 1
	if Input.is_action_pressed("move_left"):
		direction.x = -1
	var velocity = speed * direction
	velocity = move_and_slide(velocity)


func _on_AnimationTimer_timeout():
	animation.play("blink")
