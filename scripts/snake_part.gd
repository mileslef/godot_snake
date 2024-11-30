extends Area2D

var snake_animiation = "body_straight"
var moving_from = PI
var moving_to = 0
var state = "head_in"
@export var IS_TIMER = false
var DEBUG = false


signal cycle_finished
signal grow
signal die

func round_radians(rad):
	while(rad >= 2 * PI):
		rad -= 2 * PI
	while(rad < -PI):
		rad += 2 * PI
	return rad

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimatedSprite2D.set_animation(snake_animiation)
	$AnimatedSprite2D.play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	# Update animation label
	var new_label = ""
	new_label = str(new_label, $AnimatedSprite2D.get_animation(), "\n")
	new_label = str(new_label, $AnimatedSprite2D.get_frame(), "\n")
	new_label = str(new_label, "from: ", snappedf(moving_from, 0.01), "\n")
	new_label = str(new_label, "to:   ", snappedf(moving_to, 0.01), "\n")
	new_label = str(new_label, "turn: ", snappedf(round_radians(moving_from - moving_to), 0.01))
	$AnimationLabel.set_text(new_label)
	
func set_animation(animation):
	$AnimatedSprite2D.set_animation(animation)
	
func set_state(s):
	state = s
	var new_animation = state
	var turn = moving_from - moving_to
	
	while(turn >= PI):
		turn -= 2 * PI
	while(turn < -PI):
		turn += 2 * PI
	if snappedf(abs(turn), 0.01) == 3.14:
		new_animation = str(new_animation, "_straight")
	else:
		new_animation = str(new_animation, "_turn")
		$AnimatedSprite2D.set_flip_v(turn < 0)
			
	rotation = round_radians((moving_from + PI))
	set_animation(new_animation)

func _on_animated_sprite_2d_animation_finished() -> void:
	if IS_TIMER:
		cycle_finished.emit()
		
func set_sprite_frame_and_progress(f, p):
	$AnimatedSprite2D.set_frame_and_progress(f, p)
	
func set_direction(f=moving_from, t=moving_to):
	moving_from = f
	moving_to = t
	
func get_direction():
	return(Vector2(moving_from, moving_to))
	
func play():
	$AnimatedSprite2D.play()
	
func stop():
	$AnimatedSprite2D.stop()
	
func get_identity():
	if state == "tail_out" or state == "head_in":
		return "don't worry about it"
	else:
		return "snake_part"

func _on_area_entered(area: Area2D) -> void:
	if area.get_identity() == "snake_part":
		die.emit()
	elif area.get_identity() == "apple":
		grow.emit()
