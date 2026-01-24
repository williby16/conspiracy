extends Node3D

@export var camera : Camera3D;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	for child in get_children():
		if "2Dobj" in child.get_groups():
			child.look_at(camera.global_position)
