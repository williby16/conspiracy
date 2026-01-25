extends CharacterBody3D

# How fast the player moves in meters per second.
@export var speed = 1.0
# The downward acceleration when in the air, in meters per second squared.
@export var fall_acceleration = 75

# get the camera
# ts probably not the best lmao
@export var cameraPivot : Node3D
@onready var camera = cameraPivot.get_child(0)
@onready var trueCamera = camera.get_child(0)
@onready var camView = trueCamera.get_child(1) # should be CameraFocus

@onready var sprite = $Sprite3D # change sprite name here

@export var logic : Node2D;
var inLogic : bool = false;

# will change when we change directions so that movement will always be the arrow keys
var facingX = 1;
var facingZ = 1;
var moveSpeed = 1;

var target_velocity = Vector3.ZERO
var targetRotation = 0;
var rotateDir : int;
var rotationSpeed = 10;

# variables for poloroid mode
var looking = false;
var justLooked = false;
var stopLooking = false;
@onready var prevCamPos = camera.position;
@onready var prevCamRot = camera.rotation;
@onready var targetPosition = camera.position;

var currViewing : Area3D = null;

var SENSITIVITY = 0.0025

func _ready():
	camView.enabled = false;

func _process(_delta): # _ tells the linter I dont mean to use it
	if Input.is_action_just_pressed("space"):
		if not inLogic:
			if looking:
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			logic.activate();
			inLogic = true;
		else:
			if not logic.is_focused():
				if looking:
					Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
				logic.deactivate();
				inLogic = false;
	if not inLogic:
		# user input to rotation degrees
		if Input.is_action_just_pressed("ui_right") and not looking:
			targetRotation += deg_to_rad(90)
		elif Input.is_action_just_pressed("ui_left") and not looking:
				targetRotation -= deg_to_rad(90);
		# THIS FIX DOES NOT WORK TODO TECHNICALLY PRONE TO INTERGER OVERFLOWS!!!!!
		#if targetRotation == deg_to_rad(360) or targetRotation == deg_to_rad(-360):
		#	rotateDir = targetRotation/deg_to_rad(360); # should be either 1 or -1 # idk if Ill use this yet!
		#	targetRotation = 0;
		
		if Input.is_action_just_pressed("ui_up") and not looking:
			looking = true;
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			justLooked = true;
			camView.enabled = true;
		elif Input.is_action_just_pressed("ui_down") and looking:
			sprite.show()
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			looking = false;
			stopLooking = true;
			camView.enabled = false;
			#justLooked = true;

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and looking and not inLogic:
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
	if not inLogic:
		# poloroid logic
		if looking:
			if justLooked:
				sprite.hide()
				targetPosition = global_position # unused now since we lerp to global_position
				justLooked = false
				#camera.rotation = Vector3.ZERO # idk if I like this effect
			camera.global_position = camera.global_position.lerp(global_position, rotationSpeed * delta) 
			move(delta, speed/3, looking)
			# camera follow mouse
			# maybe make it so your still able to move, just slower
			# raycast logic
			if camView.is_colliding() and "obj" in camView.get_collider().get_groups():
				if currViewing != camView.get_collider():
					currViewing = camView.get_collider();
				# highlight currViewing TODO
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
		
		# finish rotating either way
		cameraPivot.rotation.y = lerp_angle(cameraPivot.rotation.y, targetRotation, rotationSpeed * delta)
		
		if not looking and not stopLooking:
			# make sure to fix camera transform
			camera.position = camera.position.lerp(prevCamPos, rotationSpeed * delta)
			# still fix these just in case.
			camera.rotation = prevCamRot # lerp y and (z or x) prolly
			trueCamera.rotation = Vector3.ZERO # don't actually rotate this camera
			# camera and player rotation
			rotation.y = lerp_angle(rotation.y, targetRotation, rotationSpeed * delta)
			move(delta, speed, looking)
			
		elif stopLooking:
			stopLooking = false
			var currRot = camera.global_rotation.y;
			# lets to operations in degrees...
			currRot = rad_to_deg(currRot);
			# make sure the pivot is pointed in the last direction the player was looking locked into a certain angle
			if (currRot <= 45) and (currRot >= -45): # <= because lets favor 0 
				currRot = 0;
			elif (currRot > 45) and (currRot < 135): # 90
				currRot = 90
			elif (currRot < -45) and (currRot > -135): # -90
				currRot = -90
			elif (currRot >= 135) or (currRot <= -135): # <= because lets favor 180/-180
				currRot = 180 # 180 and -180 should be equal!
			# back to radians
			cameraPivot.rotation.y = deg_to_rad(currRot);
			# need to lock this in to degrees...
			targetRotation = cameraPivot.rotation.y # added benifit of resetting the rotation # lets do operations in degrees...
			camera.global_position = global_position # fix the camera since its position was displaced when we changed the pivot rotation!
		
