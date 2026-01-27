extends Node2D

var id : String;

var conversation = null

var currTxt : int = 0;

var personObj = null;

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
func _process(delta: float) -> void:
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
	# fetch curr loigc evidence
	# prompt argue menu
	# display argue text??? or handle that within argue menue?
	pass

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("Q"):
		argue()
	if Input.is_action_just_pressed("E"):
		queue_free();
	if Input.is_action_just_pressed("left"):
		_on_left_pressed();
	if Input.is_action_just_pressed("right"):
		_on_right_pressed();
