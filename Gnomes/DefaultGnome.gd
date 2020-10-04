extends KinematicBody2D

#For state machine
enum states {WALKING, GRABBED}
var currState

#timers
var _timer: float = 0;
export var time_2_change: float = 2.0

#movement
var velocity: = Vector2.ZERO
var moving: bool = false
export var speed := 500.0
var _direction := Vector2.ZERO

#dragging
var drag_pos = Vector2()

onready var anim_player: AnimationPlayer = $AnimationPlayer
onready var anim_tree: AnimationTree = $AnimationTree
onready var anim_state = anim_tree.get("parameters/playback")

func _ready():
	currState = states.WALKING

func _physics_process(delta):
		
	if currState == states.WALKING:
		var direction := _choose_direction(delta)

		if (direction != Vector2.ZERO):
			anim_tree.set("parameters/Idle/blend_position", direction)
			anim_tree.set("parameters/Move/blend_position", direction)
			anim_state.travel("Move")
			velocity = velocity.move_toward(direction * speed, delta)
		else:
			velocity = velocity.move_toward(Vector2.ZERO, delta)
			anim_state.travel("Idle")
#		print(direction)
		move_and_slide(direction * speed * delta)
		
		
func _choose_direction(delta: float) -> Vector2:
	if (_timer <= 0 and moving): 						#the timer reaches 0
		#the direction is randomized
		_direction = Vector2(rand_range(-1.0, 1.0), rand_range(-1.0, 1.0))
		_direction.normalized()
		_timer = time_2_change
		moving = false
	elif (_timer <= 0 and not moving):
		_direction = Vector2.ZERO
		_timer = time_2_change
		moving = true
	_timer -= delta							#timer goes down
	return _direction
		

func _input_event(viewport, event, shape_idx):
	if event.is_action_pressed("ui_touch"):
		get_tree().set_input_as_handled()
		drag_pos = event.position
		currState = states.GRABBED
		anim_state.travel("grabbed")
	
func _input(event):

	####
	#Works globally so dragging works if
	#mouse cursor is outside of Collision Shape
	#Disables dragging if the user releases click
	####
	if currState == states.WALKING:
		return
	
	if event.is_action_released("ui_touch"):
		drag_pos = Vector2()
		currState = states.WALKING
	
	
	if currState == states.GRABBED and event is InputEventMouseMotion:
		position += event.position - drag_pos
		drag_pos = event.position
