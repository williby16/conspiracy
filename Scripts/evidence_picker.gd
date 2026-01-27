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

func build_screen():
	# use singles and doubles to put together the screen
	# TODO implement photos
	# TODO implement scrooling

	# singles

	# doubles

	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
