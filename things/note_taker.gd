extends Node2D

# drag vars
const SPEED = 30;
var draggable = false;
var dragging = false;
var makeUpDrag = false;
var prevMouse : Vector2;
var ogMouse : Vector2;
var fsCanMove = false; # for sure can move
var myText;
var ignore : bool = false;
var ignoring = false;

#@onready var movement_manager : Node2D = get_parent().get_parent().get_parent().get_child(2); # should be a PhotosManager node...
# ^ change this to get it through root?
@onready var movement_manager : Node2D = get_tree().root.get_child(0).get_child(1).get_child(2); # should be photosmanager

func set_notes_text(text: String) -> void:
	$TextEdit.text = text;

func _on_button_pressed() -> void:
	get_parent().log_notes($TextEdit.get_text());
	get_parent().notify_removal();
	self.queue_free();



#drag
func _process(delta: float) -> void:
	myText = $TextEdit.text;
	drag_logic(delta);
	if (Input.is_action_just_pressed("left_click") && ignore) || ignoring:
		ignoring = true;
		movement_manager.logD($Ingorer);
		movement_manager.logYarn($Ingorer); # could be a possible fix, but its still buggy
		movement_manager.YarnConnect(self);
	if (Input.is_action_just_released("left_click")):
		ignoring = false;

#""" # idk y ts aint workin bru pmo # DO NOT CHANGE SCALE OMMMLLL
# same drag code from photo
func drag_logic(delta: float) -> void:
	if (draggable && Input.is_action_just_pressed("left_click")) || dragging:
		# alert that THIS ONE is moving, and if any others are it will be stopped
		if (Input.is_action_just_pressed("left_click")):
			ogMouse = get_local_mouse_position(); # this will make it so the pictures dont center themselves on the mouse CLEANS UP ALOOOTTT
		movement_manager.logD(self);
		movement_manager.logYarn(self); # could be a possible fix, but its still buggy
		movement_manager.YarnConnect(self);
		dragging = true;
		#to be safe
		if (fsCanMove):
			# this will make it so the one moved will clip to the top
			move_to_top(); # do need logic to make sure the notpad is ALWAYS on top
			makeUpDrag = false; # this fixed a problem lol idk y
			global_position = global_position.lerp(((get_global_mouse_position()-ogMouse)), SPEED*delta);
	
	# if you let go of the mouse, it will stop following, but if its not caught up with the mouse yet, it will
	if dragging && Input.is_action_just_released("left_click"):
		dragging = false;
		fsCanMove = false;
		if global_position != get_global_mouse_position():
			prevMouse = get_global_mouse_position()-ogMouse;
			makeUpDrag = true;
	
	# catches up with where the mouse was if it didnt.
	if makeUpDrag:
		if global_position != prevMouse:
			global_position = global_position.lerp(prevMouse, SPEED*delta);
		else:
			makeUpDrag = false;

# general
func move_to_top() -> void:
	var ogParent = get_parent();
	var ogParentParent = ogParent.get_parent();
	get_parent().get_parent().remove_child(ogParent);
	ogParentParent.add_child(ogParent);




func stop_moving() -> void:
	draggable = false;
	dragging = false;
	makeUpDrag = false;
	fsCanMove = false;

func can_move() -> void:
	fsCanMove = true;
#"""

func _on_area_2d_mouse_entered() -> void:
	draggable = true;


func _on_area_2d_mouse_exited() -> void:
	if !dragging:
		draggable = false;
		fsCanMove = false;


func _on_ingorer_mouse_entered() -> void:
	ignore = true;


func _on_ingorer_mouse_exited() -> void:
	ignore = false;
