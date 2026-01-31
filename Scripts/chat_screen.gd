extends Node2D

const argue_menu = preload("res://things/evidence_picker.tscn")

var id : String;

var conversation = null

var currTxt : int = 0;

var personObj = null;

var arguing = false;

var currConvo = []; # this will later be loaded from a save file (ex. abdeaa)
var currIndex = 0;

func set_person(person):
	personObj = person;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# idk why but it breaks if I dont return and set conversation
	conversation = load_conversation("a")

	if currConvo.size() == 0:
		# trigger first convo
		currConvo.append("a") # LOAD FROM FILE # save to file when queue freed
		# call this from first convo actuall
		load_text(conversation["text"][currTxt]) # IF FIRST TIME LOADING TEXT, LOAD THE FIRST ONE!!!

func load_text(txt : String):
	$Talking.clear()
	$Talking.add_text(txt)
	$reminder.clear()
	$reminder.add_text("E - Close | Q - Argue | " + str(currTxt+1) + " / " + str(conversation["text"].size()))
	$conversationNum.clear()
	$conversationNum.add_text(str(currIndex+1) + " / " + str(currConvo.size()))

func update_text():
	var updt = $Talking.get_parsed_text()
	load_text(updt)


func load_conversation(ID):
	#print(ID.get_groups())
	var file = FileAccess.open("res://things/dialouge_tree.json", FileAccess.READ)
	var content = file.get_as_text()
	var myJSON = JSON.parse_string(content)
	myJSON = myJSON[personObj.get_groups()[2]] # magic num should group for persons name
	if currConvo.size() != 0:
		currTxt = 0
		conversation = myJSON[ID]
		load_text(myJSON[ID]["text"][0])
	return myJSON[ID]
	#return {
	#"text": ["Hey newbie", "Erhm learn how to play buddy", "end of conversation."],
	#"argue": [{"tag->tag": "a"}, {"tag->tag": "b"}, {"tag->tag": "c"}] # letters are next conversation to load
#}# remember where you came from

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

func _on_down_pressed() -> void:
	if currIndex < currConvo.size()-1:
		currIndex += 1
		conversation = load_conversation(currConvo[currIndex])

func _on_up_pressed() -> void:
	if currIndex != 0:
		currIndex -= 1;
		conversation = load_conversation(currConvo[currIndex])


func argue():
	arguing = true;
	var logic = get_parent().get_child(1); # SHOULD be logic world # maybe run this within
	var this_menu = argue_menu.instantiate();
	this_menu.logic = logic;
	add_child(this_menu);

func resolve_argue(results):
	#print(results) # load in new conversation for results, then change group to proper npc group
	if conversation["argue"][currTxt]["key"] == results:
		currConvo.append(conversation["argue"][currTxt]["result"])
		# update text for convo number
		# display confirm text
	else:
		pass
		# play confused text
	update_text()
	stop_argue()

func stop_argue():
	get_children()[-1].queue_free();
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
		if Input.is_action_just_pressed("up"):
			_on_up_pressed();
		if Input.is_action_just_pressed("down"):
			_on_down_pressed();
	elif arguing and Input.is_action_just_pressed("Q"):
		stop_argue();
