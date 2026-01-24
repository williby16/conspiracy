extends StaticBody3D

@export var threeD : bool;
@onready var camera = get_parent().get_camera();

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# LEGACY

# Called every frame. 'delta' is the elapsed time since the previous frame.

func observe():
	# highlight obj
	pass
