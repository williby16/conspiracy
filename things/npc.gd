extends Sprite3D


@export var camera : Camera3D;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# LEGACY, npcs will be objects...

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	look_at(camera.global_position)
