extends Node3D

@export var myTexture : Texture2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print(myTexture)
	for child in get_children():
		var mat = StandardMaterial3D.new()
		mat.albedo_texture = myTexture
		child.get_child(1).material = mat
