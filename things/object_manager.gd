extends Node3D

@export var player : CharacterBody3D;
@onready var camera = player.get_child(0).get_child(0).get_child(0); # should be camera

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var cam = camera.global_position;
	for child in get_children():
		if "2Dobj" in child.get_groups():
			child.look_at(cam)
		elif "npc" in child.get_groups():
			# if npc but not 2d Look at the camera but don't tilt!
			child.look_at(Vector3(cam.x, 0, cam.z));
