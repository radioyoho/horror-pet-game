extends KinematicBody2D

const GnomeTools = preload("res://tools/GnomeTools.tres")

#enum for state machine
enum {
	IDLE,
	PICK_DIR,
	MOVE,
	INTER
}

enum{
	GRAB,
	PET
}

#Initial value of statemachine
var state = IDLE

#movement
export var speed := 1000.0
var direction := Vector2.ZERO
var velocity := Vector2.ZERO

# Position where we are going to store the touch position
var drag_pos = Vector2()

onready var anim_player: AnimationPlayer = $AnimationPlayer
onready var anim_tree: AnimationTree = $AnimationTree
onready var anim_state = anim_tree.get("parameters/playback")

func _ready():
	#Resets de seed for RNG
	randomize()
	
	#The cat decides it starts IDLE
	state = IDLE
	
	#The cat decides it looks to the front at the start
	anim_tree.set("parameters/Idle/blend_position", Vector2.DOWN)
	
	#Assign this gnome to the handler
	GnomeTools.Gnome = self
func _exit_tree():
	#Deallocate this gnome if tree exits, I'm not sure what that means
	GnomeTools.Gnome = null

func _physics_process(delta):
	#SUPER STATE MACHINE
	match state:
		IDLE:
			velocity = Vector2.ZERO
			idle_state()
			
		PICK_DIR:
			pick_dir_state()
			state = MOVE
		MOVE:
			move_state(delta)
		INTER:
			#Here we see what tool they are using
			inter_state()
				
	velocity = move_and_slide(velocity)
#	print(velocity)
	
func inter_state():
	match GnomeTools.Tool:
		GRAB:
			velocity = Vector2.ZERO
		PET:
			velocity = Vector2.ZERO
		
		
	
func pick_dir_state():
	#select direction where it's going to move
	direction = choose([Vector2.RIGHT, Vector2.UP, Vector2.DOWN, Vector2.LEFT])
	
	#Set animation positions
	anim_tree.set("parameters/Idle/blend_position", direction)
	anim_tree.set("parameters/Move/blend_position", direction)

	direction = direction.normalized()
	
func move_state(delta):	
	#Travel to moving animation state
	anim_state.travel("Move")
	
	#Move its position
	velocity = direction * speed * delta

func idle_state():
	#If the cat decides it doesn't move, the animation changes to idle
	anim_state.travel("Idle")

func _input_event(viewport, event, shape_idx):
	if event.is_action_pressed("ui_touch"):
		get_tree().set_input_as_handled()
		drag_pos = event.position
		state = INTER
		anim_state.travel("grabbed")
		print("Grabin'")
	
func _input(event):

	####
	#Works globally so dragging works if
	#mouse cursor is outside of Collision Shape
	#Disables dragging if the user releases click
	####
	if state == MOVE:
		return
	
	if event.is_action_released("ui_touch"):
		drag_pos = Vector2()
		state = IDLE
	
	
	if state == INTER and event is InputEventMouseMotion and GnomeTools.Tool == PET:
		position += event.position - drag_pos
		drag_pos = event.position

func choose(array):
	array.shuffle()
	return array.front()


func _on_Timer_timeout():
	$Timer.wait_time = choose([0.5, 1, 1.5])
	state = choose([IDLE, PICK_DIR])
