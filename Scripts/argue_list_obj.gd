extends Node2D


var notes : String = "null";
const page = preload("res://things/note_taker.tscn")
@onready var movement_manager : Node2D = get_tree().root.get_child(0).get_child(1).get_child(2); # should be photosmanager
var canCreate = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if notes == "null":
		notes = "Fatal Error"

func set_text(txt : String):
	$txt.clear();
	$txt.add_text(txt);

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# spawn notes
func _on_button_pressed():
	if canCreate:
		canCreate = false;
		var thisPage = page.instantiate();
		thisPage.get_children()[1].editable = false;
		thisPage.top_level = true; # this will make it so it wont move with the parent, but now its position is global
		add_child(thisPage)
		thisPage.set_notes_text(notes); 
		thisPage.position = Vector2(400, 400);

func notify_removal() -> void:
	canCreate = true;

func log_notes(catch) -> void: # catch cleanup from other usage!
	return


# need a funciton to tell when the mouse is within the box

# need a function that when the mouse is in the box and it clicks, it tells the parent it was clicked 
# (and probly gives it its tags)