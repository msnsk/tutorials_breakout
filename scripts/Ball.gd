extends RigidBody2D


const MAX_SPEED = 300.0
export (float) var first_speed = 120.0 # Updated @ P11 # Updated @ P14
export (float) var speed_up = 1.0 # Updated @ P14
var direction: Vector2
var velocity: Vector2
onready var ball_speed = first_speed # Updated @ P11 # Updated @ P14
onready var paddle = get_node("../Paddle")
onready var launch_sound = $LaunchSound


func _ready():
	direction = Vector2(1, -1).normalized()
	velocity = direction * ball_speed


func _process(_delta):
	if mode == 3:
		position.x = paddle.position.x
		if Input.is_action_just_pressed("launch_ball"):
			mode = 2
			apply_impulse(Vector2.ZERO, velocity)
			launch_sound.play()


func _on_Ball_body_entered(body):
	ball_speed += speed_up
	direction = linear_velocity.normalized()
	velocity = direction * min(ball_speed, MAX_SPEED)
	
	if body.is_in_group("Bricks"):
		var collide_sound # Added @ P14
		var animation = body.get_node("AnimationPlayer") # Moved @ P14
		match body.brick_hardness: # Modified @ P14
			body.Hardness.METAL:
				collide_sound = body.get_node("MetalCollideSound")
				collide_sound.play()
				animation.play("metal_collided")
			body.Hardness.HARD:
				collide_sound = body.get_node("HardCollideSound")
				collide_sound.play()
				animation.play("hard_collided")
				body.brick_hardness = body.Hardness.NORMAL
			body.Hardness.NORMAL:
				collide_sound = body.get_node("CollideSound")
				collide_sound.play()
				animation.play("collided")
				yield(animation, "animation_finished")
				body.queue_free()
	
	elif body.get_name() == "Paddle":
		var collide_sound = body.get_node("CollideSound")
		collide_sound.play()
		var animation = body.get_node("AnimationPlayer")
		if animation.is_playing():
			animation.stop()
		animation.play("hit")
		direction = (position - body.position).normalized()
		velocity = direction * min(ball_speed, MAX_SPEED)
	elif body.get_name() == "Wall": # 追加
		var collide_sound = body.get_node("CollideSound")
		collide_sound.play()
	
	linear_velocity = velocity


func _on_VisibilityNotifier2D_screen_exited():
	queue_free()

