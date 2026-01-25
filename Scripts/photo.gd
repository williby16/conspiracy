extends Node2D

# Identifiers
var nameID : String; # should put a dictionary or something so that it displays the proper photo for nameID

# drag vars
const SPEED = 30;
var draggable = false;
var dragging = false;
var makeUpDrag = false;
var prevMouse : Vector2;
var ogMouse : Vector2;
var fsCanMove = false; # for sure can move

# yarn vars
var drawable = false;
var drawing = false;
var string_point = Vector2(0,0);
var canDraw = false;

# yarn connectors
var connectable = false;
var tempYarn : Node2D;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# so basically if the mouse is within the main portion of the photo, you can drag it, and it will move towards the mouse
	drag_logic(delta);
	# yarn code
	yarn_logic(delta);

func update_name():
	$objName.append_text("[color=black]"+ nameID +"[/color]")

func update_image(img: Image):
	var newTexture = ImageTexture.create_from_image(img)
	$image.texture = newTexture;

#drag
func drag_logic(delta: float) -> void:
	if (draggable && Input.is_action_just_pressed("left_click")) || dragging:
		# alert that THIS ONE is moving, and if any others are it will be stopped
		if (Input.is_action_just_pressed("left_click")):
			ogMouse = get_local_mouse_position(); # this will make it so the pictures dont center themselves on the mouse CLEANS UP ALOOOTTT
		get_parent().logD(self);
		# bad code, pass in a sprite with a special tag on it
		#get_parent().logYarn($Sprite2D);
		#get_parent().YarnConnect($Sprite2D);
		dragging = true;
		#to be safe
		if (fsCanMove):
			# this will make it so the one moved will clip to the top
			move_to_top();
			makeUpDrag = false; # this fixed a problem lol idk y
			global_position = global_position.lerp((get_global_mouse_position()-ogMouse), SPEED*delta);
	
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

func _on_area_2d_mouse_entered() -> void:
	draggable = true;

func _on_area_2d_mouse_exited() -> void:
	if !dragging:
		draggable = false;

func stop_moving() -> void:
	draggable = false;
	dragging = false;
	makeUpDrag = false;
	fsCanMove = false;

func can_move() -> void:
	fsCanMove = true;

func stop_draw() -> void:
	drawing = false;
	drawable = false;
	canDraw = false;
	tempYarn.queue_free();
	#$TempYarn.set_point_position(0, Vector2(0, -90));

func can_draw() -> void:
	canDraw = true;

#yarn
func yarn_logic(delta : float) -> void:
	if connectable && Input.is_action_just_pressed("left_click"):
		if (get_parent().canConnect()):
			get_parent().YarnConnect(self);
	
	if (Input.is_action_just_pressed("left_click")):
		if (!drawing && drawable):
			get_parent().logYarn(self);
			drawing = true;
			get_parent().wannaConnect(self);
			tempYarn = Line2D.new();
			tempYarn.add_point(Vector2(0,-90), 0); # this doesnt matter, will be changed in the same frame
			tempYarn.add_point(Vector2(0,-90), 1); # hardcoded ik ik but it'll come back later, this is just the top of the picture
			tempYarn.set_default_color(Color(255, 0, 0, 255));
			add_child(tempYarn);
		elif drawing: # THIS WAS THE FIX OMG T.T
			drawing = false;
			drawable = false;
			canDraw = false;
			get_parent().log_disconnect(self);
			if (tempYarn != null):
				tempYarn.queue_free();
			#$TempYarn.set_point_position(0, Vector2(0, -90));
	
	if drawing && canDraw:
		#tempYarn.position = position - Vector2(0, -90);
		move_to_top()
		tempYarn.set_point_position(0, get_global_mouse_position()-global_position);
		#$TempYarn.set_point_position(0, get_global_mouse_position()-global_position);

func tieYarn() -> void:
	pass

func _on_yarn_space_mouse_entered() -> void:
	if (!get_parent().canConnect()): # make it so if you touch the connect zone while connecting, instead of re logging a connection it will make  the connection with the og
		drawable = true;


func _on_yarn_space_mouse_exited() -> void:
	if !drawing:
		drawable = false;
		canDraw = false;


func _on_whole_picture_mouse_entered() -> void:
	connectable = true;


func _on_whole_picture_mouse_exited() -> void:
	connectable = false;

# general
func move_to_top() -> void:
	var ogParent = get_parent();
	get_parent().remove_child(self);
	ogParent.add_child(self);
