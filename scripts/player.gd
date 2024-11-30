extends Node2D

@export var snake_part_scene: PackedScene

var snake_timer
var accepting_input = true
var extending_phase_1 = false
var extending_phase_2 = false
var moving_from = PI
var moving_to = 0
var snake_parts = []
var pos = position

func round_radians(rad):
	while(rad >= 2 * PI):
		rad -= 2 * PI
	return rad
	
func update_position(direction):
	# Update postion
	if direction == 0: # Right
		pos.x += 64
	elif direction == PI/2: # Down
		pos.y += 64
	elif direction == PI: # Left
		pos.x -= 64
	elif direction == 3*PI/2: # Up
		pos.y -= 64

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#snake_timer = snake_part_scene.instantiate()
	#snake_timer.position = Vector2(-1000, -1000)
	#snake_timer.IS_TIMER = true
	#snake_timer.cycle_finished.connect(_on_snake_timer_cycle_finished)
	#add_child(snake_timer)
	$Timer.start()

	for i in 5:
		var snake_part = snake_part_scene.instantiate()
		var part_position = pos
		part_position.x -= i * 64
		snake_part.position = part_position
		snake_parts.append(snake_part)
		add_child(snake_part)
	
	snake_parts[0].set_animation("head_in_straight")
	snake_parts[1].set_animation("head_out_straight")
	snake_parts[-1].set_animation("tail_out_straight")
	snake_parts[-2].set_animation("tail_in_straight")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if accepting_input:
		var user_input = moving_from
		if Input.is_action_just_pressed("move_right"):
			user_input = 0
		elif Input.is_action_just_pressed("move_down"):
			user_input = PI/2
		elif Input.is_action_just_pressed("move_left"):
			user_input = PI
		elif Input.is_action_just_pressed("move_up"):
			user_input = 3*PI/2


			
		if user_input == moving_from:
			pass
		else:
			moving_to = user_input
			accepting_input = false
	
func _on_snake_timer_cycle_finished():
	cycle()

func _on_timer_timeout() -> void:
	cycle()


func _on_grow():
	extending_phase_1 = true
	
func _on_die():
	snake_timer.stop()
	for part in snake_parts:
		part.stop()
	
func cycle():
	
	if accepting_input:
		moving_to = round_radians(moving_from + PI)
	
	update_position(moving_to)
	
	# Add new snake part to front
	var snake_part = snake_part_scene.instantiate()
	snake_part.grow.connect(_on_grow)
	snake_part.die.connect(_on_die)
	snake_part.position = pos
	snake_parts.push_front(snake_part)
	add_child(snake_part)
	
	# Remove old snake part
	if not extending_phase_2:
		var old_snake_part = snake_parts.pop_back()
		old_snake_part.queue_free()
	else:
		extending_phase_2 = false
	
	snake_parts[0].set_direction(moving_from, moving_to)
	snake_parts[1].set_direction(moving_from, moving_to)
	var back_direction = snake_parts[-2].get_direction()
	snake_parts[-1].set_direction(back_direction.x, back_direction.y)
	
	snake_parts[0].set_state("head_in")
	snake_parts[1].set_state("head_out")
	snake_parts[2].set_state("body")
	snake_parts[-1].set_state("tail_out")
	snake_parts[-2].set_state("tail_in")
	
	if extending_phase_1:
		snake_parts[-2].set_state("body")
	
	for part in snake_parts:
		part.set_sprite_frame_and_progress(0, 0)
		part.play()
		
	$Timer.start()
	#snake_timer.set_sprite_frame_and_progress(0, 0)
	#snake_timer.play()
	
	if extending_phase_1:
		snake_parts[-1].stop()
		extending_phase_1 = false
		extending_phase_2 = true
	
	moving_from = round_radians(moving_to + PI)
	accepting_input = true
