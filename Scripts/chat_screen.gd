extends Node2D

const argue_menu = preload("res://things/evidence_picker.tscn")

var id : String;

var conversation = null

var currTxt : int = 0;

var personObj = null;

var arguing = false;

func set_person(person):
	personObj = person;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	conversation = load_conversation(personObj)
	load_text(conversation["text"][currTxt])

func load_text(txt : String):
	$Talking.clear()
	$Talking.add_text(txt)
	$reminder.clear()
	$reminder.add_text("E - Close | Q - Argue | " + str(currTxt+1) + " / " + str(conversation["text"].size()))

func load_conversation(ID):
	print(ID.get_groups())
	return {
	"text": ["Hey newbie", "Erhm learn how to play buddy", "end of conversation."],
	"argue": [{"tag->tag": "null"}, {"tag->tag": "null"}, {"tag->tag": "null"}]
}

func set_id(ID : String):
	id = ID;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_right_pressed() -> void:
	if currTxt+1 == conversation["text"].size():
		return
	currTxt += 1
	load_text(conversation["text"][currTxt])

func _on_left_pressed() -> void:
	if currTxt == 0:
		return
	currTxt -= 1
	load_text(conversation["text"][currTxt])

func argue():
	arguing = true;
	var logic = get_parent().get_child(1); # SHOULD be logic world # maybe run this within
	var this_menu = argue_menu.instantiate();
	this_menu.logic = logic;
	add_child(this_menu);

func resolve_argue(results):
	stop_argue()

func stop_argue():
	arguing = false;

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("E"): # maybe?
		queue_free();
	if not arguing:
		if Input.is_action_just_pressed("Q"):
			argue()
		if Input.is_action_just_pressed("left"):
			_on_left_pressed();
		if Input.is_action_just_pressed("right"):
			_on_right_pressed();
	elif arguing and Input.is_action_just_pressed("Q"):
		stop_argue();
