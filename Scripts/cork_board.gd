extends Node2D

const PHOTO = preload("res://things/Photo.tscn");
const YARN = preload("res://things/Yarn.tscn");

var evidence : Array = [];
var photoIDs : Array = [];

var alrCon : Array;

func activate():
	show();
func deactivate():
	hide();

func get_evidence_and_connections():
	return [photoIDs, alrCon]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in evidence:
		addPhoto(i);

func is_focused():
	for notes_manager in get_children():
		if notes_manager.name == "Notes_Manager":
			for listobj in notes_manager.get_children():
				for note_taker in listobj.get_children():
					if note_taker.name == "NoteTaker":
						for textedit in note_taker.get_children():
							if textedit.name == "TextEdit":
								return textedit.has_focus();
	return false

# logic.add_pic(camView.get_collider(), img);
func add_pic(obj, img):
	var myPhoto = PHOTO.instantiate();
	var nameID = obj.get_groups()[-1]
	if nameID in photoIDs: # only 1 photo of an object
		return
	# make sure photos not already in use?
	# set photo image
	#format img here?
	myPhoto.update_image(img);

	# build photo
	myPhoto.nameID = nameID;
	myPhoto.update_name();
	photoIDs.append(nameID);
	myPhoto.global_position = Vector2(0,0);
	$PhotosManager.add_child(myPhoto);

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	#debug
	if Input.is_action_just_pressed("left"):
		print(photoIDs)
		print(evidence)
		print(alrCon)
	update_lines();

func logic_connect(photo1 : Node2D, photo2 : Node2D) -> void:
	for i in alrCon:
		if photo1 in i && photo2 in i:
			return;
	#set up the lines
	var thisYarn = YARN.instantiate();
	$YarnHolder.add_child(thisYarn);
	#points are pre-added now
	#thisYarn.get_child(0).add_point(Vector2(0,0), 0);
	#thisYarn.get_child(0).add_point(Vector2(0,0), 1);
	thisYarn.PhotoLog(photo1, photo2);
	alrCon.append([photo1, photo2, thisYarn.get_child(0), thisYarn]);
	$Notes_Manager.update_connections()

func update_lines() -> void:
	for con in alrCon: # 0 is photo 1 1 is photo 2 and 2 is the yarn
		con[2].set_point_position(0, con[0].position-Vector2(0,90));
		con[2].set_point_position(1, con[1].position-Vector2(0,90));

func removeConnection(photo1 : Node2D, photo2 : Node2D) -> void:
	var count = 0;
	for i in alrCon:
		if photo1 in i && photo2 in i:
			i[3].queue_free(); # gets rid of the 'yarn' object
			alrCon.remove_at(count);
			$Notes_Manager.update_connections()
		count += 1;
			
func getConnections() -> Array:
	return alrCon;

var nullPhotos = 0;
func _on_spawn_picture_pressed() -> void:
	nullPhotos += 1;
	addPhoto("NULL" + str(nullPhotos));
	
func addPhoto(nameID : String) -> void: # update this for image useage (this will reload photos eventually)
	var myPhoto = PHOTO.instantiate();
	myPhoto.nameID = nameID;
	photoIDs.append(nameID);
	myPhoto.global_position = Vector2(0,0);
	$PhotosManager.add_child(myPhoto);
