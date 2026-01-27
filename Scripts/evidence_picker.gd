extends Node2D

#const LIST_OBJ = preload("res://things/ListObj.tscn");
#const page = preload("res://things/note_taker.tscn")
#@onready var movement_manager : Node2D = get_tree().root.get_child(0).get_child(1).get_child(2); # should be photosmanager

const LIST_OBJ = preload("res://things/argue_list_obj.tscn");

var logic = null;
var singles = null;
var cons = null;
var doubles = null;
var triples = null;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var thisSet = logic.get_evidence_and_connections()
	singles = thisSet[0]
	cons = thisSet[1]
	var thisSet2 = build_cons_strings()
	doubles = thisSet2[0]
	triples = thisSet2[1]
	build_screen()

func build_cons_strings():
	var myDoubles = []
	# doubles
	# COPY LIST OBJ, delete the buttons and make the text edit un editable
	#for connection in cons:
	#	var thisCon = connection[0].get_photo_name() + " -> " + connection[1].get_photo_name()
	#	myDoubles.append(thisCon)
	for listObj in logic.get_children()[1].get_children():
		#var thisList = LIST_OBJ.instantiate();
		#set position
		#for i in range(0, 3):
			#thisList.get_child(i).queue_free()
		#thisList.set_connection_text(listObj.get_children()[-1].get_parsed_text())
		var thisCon = listObj.get_children()[-1].get_parsed_text() # connection text
		var thisNotes = listObj.currNotes # get notes
		#thisList.currEditable = false;
		#add_child(thisList)
		myDoubles.append([thisCon, thisNotes])
	# triples
	# implement later - idk if I even will do triples!
	
	return [myDoubles, null]

# make this look more pretty lol
# TODO Add scrolling capabillity
func build_screen():
	# use singles and doubles to put together the screen
	# TODO implement photos
	# TODO implement scrooling

	# singles
	var currPos = Vector2(0, 77)
	for single in singles:
		print(single)
		var thisSingle = LIST_OBJ.instantiate(); # size 77 y
		thisSingle.myID = single;
		thisSingle.set_text(single);
		thisSingle.position = currPos;
		currPos.y += 77;
		# FIGURE TS OUT::::
		thisSingle.get_child(0).queue_free()
		add_child(thisSingle);
		# instantiate and give it single as an ID
	# doubles
	currPos = Vector2(300, 77)
	for doubleSet in doubles:
		var double = doubleSet[0]
		var tsNote = doubleSet[1]
		print(double)
		var thisDouble = LIST_OBJ.instantiate(); # size 77 y
		thisDouble.myID = double;
		thisDouble.set_text(double);
		thisDouble.notes = tsNote;
		thisDouble.position = currPos;
		currPos.y += 77;
		add_child(thisDouble);
		# instantiate and give it double as an ID and tsNote as notes

	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
