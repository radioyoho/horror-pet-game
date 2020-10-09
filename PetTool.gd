extends Button

const GnomeTools = preload("res://tools/GnomeTools.tres")

enum {
	GRAB,
	PET
}

func _on_PetTool_pressed():
	#if button is pressed we set that tool as the tool it uses
#	print("You pressed the pet tool!")
	GnomeTools.Tool = PET
