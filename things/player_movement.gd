extends CharacterBody3D

# How fast the player moves in meters per second.
@export var speed = 1.0
#@onready var spd = speed;
# The downward acceleration when in the air, in meters per second squared.
@export var fall_acceleration = 75

const chat_screen = preload("res://things/chat_screen.tscn")

# get the camera
# ts probably not the best lmao
@onready var cameraPivot = get_child(0)
@onready var camera = cameraPivot.get_child(0)
@onready var trueCamera = camera.get_child(0)
@onready var camView = trueCamera.get_child(1) # should be CameraFocus

@onready var sprite = $Sprite3D # change sprite name here

@export var logic : Node2D;
var inLogic : bool = false;
var talking : bool = false ;
var justTalked : bool = false ; 
var talkingTo = null;

# will change when we change directions so that movement will always be the arrow keys
var facingX = 1;
var facingZ = 1;
var moveSpeed = 1;

var target_velocity = Vector3.ZERO
var targetRotation = 0;
var rotateDir : int;
var rotationSpeed = 10;

var inConvo = false;

# variables for poloroid mode
@onready var prevCamPos = camera.position;
@onready var prevCamRot = camera.rotation;
@onready var targetPosition = camera.position;

var currViewing : Area3D = null;

var SENSITIVITY = 0.0025

func _ready():
	camView.enabled = false; # IMPORTANT, WHAT ALLOWS FOR PICTURES
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED) #debug
	camView.enabled = true; # test debug

func create_chat(person):
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	var thisConvo = chat_screen.instantiate()
	thisConvo.set_person(person)
	thisConvo.player = self;
	get_tree().root.get_child(0).add_child(thisConvo) # child of node3D

func can_move():
	return (not(inLogic or talking))

func _process(_delta): # _ tells the linter I dont mean to use it
	if Input.is_action_just_pressed("esc"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	# polling, maybe move stuff like this to _Input()?
	if Input.is_action_just_pressed("space"):
		if not inLogic: # need thesse two seprate for the else statement....
			if not talking:
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
				logic.activate();
				inLogic = true;
		else:
			if not logic.is_focused():
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
				logic.deactivate();
				inLogic = false;
	# polaroid logic
	if can_move():
		# put up and down camera!
		if Input.is_action_just_pressed("ui_up"):
			camView.enabled = true;
		elif Input.is_action_just_pressed("ui_down"):
			camView.enabled = false;
		# picture and chat logic
		if camView.is_colliding() and "obj" in camView.get_collider().get_groups():
			if currViewing != camView.get_collider():
				currViewing = camView.get_collider();
			# highlight currViewing TODO
			if "npc" in currViewing.get_groups():
				#print("Press E to talk.")
				if Input.is_action_just_pressed("E"):
					talking = true;
					justTalked = true;
					create_chat(currViewing);
			if Input.is_action_just_pressed("left_click"):
				var img = get_viewport().get_texture().get_image();
				img = resize_image(img)
				#img.save_png("user://NAME") # works without saving the image... but Ill need to save it at some point?
				#img = Image.load_from_file("user://NAME")
				logic.add_pic(camView.get_collider(), img);
				#img.save_png("usr://name");
		elif currViewing != null:
			# unhighlight currViewing TODO
			currViewing = null;

	# stop talking
	if talking and not justTalked and Input.is_action_just_pressed("E") and not inConvo: # dont stop talking IF in a special convo type
		inConvo = true;
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		talking = false;
		justTalked = false;
		talkingTo = null;
	# clean up var # bad way to do this lol # but it works!
	justTalked = false;
	
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and can_move():
		camera.rotate_y(-event.relative.x * SENSITIVITY)
		trueCamera.rotate_x(-event.relative.y * SENSITIVITY)
		trueCamera.rotation.x = clamp(trueCamera.rotation.x, deg_to_rad(-40), deg_to_rad(60))
		rotation.y = camera.rotation.y

func move(delta, spd, dirMod):
	var direction = Vector3.ZERO
	
	# player movement inputs
	if Input.is_action_pressed("D"):
		direction.x += (moveSpeed)
	if Input.is_action_pressed("A"):
		direction.x -= (moveSpeed)
	if Input.is_action_pressed("S"):
		direction.z += (moveSpeed)
	if Input.is_action_pressed("W"):
		direction.z -= (moveSpeed)

	if direction != Vector3.ZERO:
		direction = direction.normalized()

	# Ground Velocity
	target_velocity.x = direction.x * spd
	target_velocity.z = direction.z * spd
	# rotate to match camera
	if not dirMod: # main camera mode
		target_velocity = target_velocity.rotated(Vector3.UP, cameraPivot.rotation.y)
	else: #first person camera mode
		target_velocity = target_velocity.rotated(Vector3.UP, camera.global_rotation.y)
	
	# Vertical Velocity -- LIKELY UNUSED
	if not is_on_floor(): # If in the air, fall towards the floor. Literally gravity
		target_velocity.y = target_velocity.y - (fall_acceleration * delta)

	# Moving the Character
	velocity = target_velocity
	move_and_slide()

func resize_image(img):
	# resize a viewport image to fit within the poloroid!
	# FIRST, make it a square
	var w = img.data["width"]
	var h = img.data['height']

	var diff = w-h
	w-=diff

	img = img.get_region(Rect2i(diff/2, 0, w, h))

	img.resize(125, 125)

	return img


func _physics_process(delta):
	if can_move():
		# poloroid logic
		#targetPosition = global_position # unused now since we lerp to global_position
		#camera.global_position = camera.global_position.lerp(global_position, rotationSpeed * delta) 
		move(delta, speed, true)
			# camera follow mouse
			# maybe make it so your still able to move, just slower
			# raycast logic
		
		# finish rotating either way
		#cameraPivot.rotation.y = lerp_angle(cameraPivot.rotation.y, targetRotation, rotationSpeed * delta)
		
