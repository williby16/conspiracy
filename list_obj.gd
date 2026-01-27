extends Node2D

# var id : type;
var photo1 : Node2D;
var photo2 : Node2D;
var clickable : bool = false;
var able : bool = true;
var canCreate : bool = true;

var currNotes : String = "";

var myPage : Node2D;

var currEditable = true;

# load
const page = preload("res://things/note_taker.tscn")

func _process(delta: float) -> void:
	if (clickable && Input.is_action_just_released("left_click") && able && canCreate):
		open_notes(currEditable);

func open_notes(editable) -> void:
	#get_parent().toggle_ignore_children(); # I dontwant to use this anymore
	canCreate = false;
	var thisPage = page.instantiate();
	thisPage.get_children()[1].editable = editable;
	thisPage.top_level = true; # this will make it so it wont move with the parent, but now its position is global
	add_child(thisPage)
	thisPage.set_notes_text(currNotes); 
	thisPage.position = Vector2(400, 400); # TODO Hardcoded BAD
	myPage = thisPage;
	
func log_notes(thisPage: String) -> void:
	currNotes = thisPage;

func notify_removal() -> void:
	canCreate = true;


func toggle_ignore():
	if able:
		able = false;
	else:
		able = true;
		

func set_photos(x: Node2D, y: Node2D) -> void:
	photo1 = x;
	photo2 = y;

func set_connection_text(name : String) -> void:
	$ConnectionName.append_text(name);

func _on_up_button_pressed() -> void:
	if (able):
		get_parent().move_up(self);


func _on_down_button_pressed() -> void:
	if (able):
		get_parent().move_down(self);


func _on_delete_pressed() -> void:
	if (able):
		log_notes(currNotes);
		#get_parent().log_notes(photo1, photo2, currNotes);
		get_parent().get_parent().removeConnection(photo1, photo2);


func _on_open_notes_mouse_entered() -> void:
	clickable = true;


func _on_open_notes_mouse_exited() -> void:
	clickable = false;
