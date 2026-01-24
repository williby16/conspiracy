extends Node2D

var toDo : Array; # [object, action]
###
"""
Actions:
	Connect
	Move
	Draw Yarn
Thing on top gets priority! (notepad allways on top)
"""

#yarn connection
var currConnection : Node2D = null;
var toCon : Node2D = null;
var disconnect : Node2D = null;


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# decides if actions can be taken.
	toDoLogic(delta);
	
	if (disconnect != null):
		currConnection = null;
		#toCon = null;
		disconnect = null;

# utility

# log an object to be handled.
func logAction(anObj : Node2D, action : String) -> void:
	if [anObj, action] not in toDo:
		toDo.append([anObj, action]);

func log_disconnect(toDis : Node2D) -> void:
	disconnect = toDis;

func wannaConnect(thisObj : Node2D) -> void:
	currConnection = thisObj;
	
		
func canConnect() -> bool:
	if (currConnection != null):
		return true;
	else:
		return false;

# main func
func toDoLogic(delta : float) -> void:
	
	if (toDo.size() > 1):
		# get the one on top, that has priority, then let handle_logic handle the rest!
		# handle ignores and note pages:
		var ignoreSpotted = false;
		var toDoSub = [];
		for i in toDo:
			if "ignore" in i[0].get_groups():
				ignoreSpotted = true;
				toDoSub.append([i[0].get_parent().get_parent(), i[0].get_parent(), i[1], true]) # [listobj, note_taker, action, <ingorobj>]
			if "NotePage" in i[0].get_groups():
				toDoSub.append([i[0].get_parent(), i[0], i[1], false]); # # [listobj, note_taker, action, <ingorobj>]
		if (toDoSub.size() >= 1):
			# cancel all photo actions
			for i in toDo:
				if ("Photo" in i[0].get_groups()):
					stop_logic(i)
			var noteParent = toDoSub[0][0][0].get_parent();
			var curr;
			var prev = noteParent.get_children().find(toDoSub[0][0][0], 0);
			for i in toDoSub:
				pass
		
		# just photos
		for i in toDo:
			pass # just photos logic now
			
	
	elif (toDo.size() == 1):
		handle_logic(toDo[0]);
	
	# makes the connection if thats the output of the thing
	if (toCon != null && currConnection != null) && (toCon != currConnection):
		get_parent().logic_connect(currConnection, toCon);
		toCon = null;
		currConnection = null;


func stop_logic(handle : Array) -> void: # stops whatever it thinks is happening from happening (brute force stop everything)
	pass;

func handle_logic(handle : Array) -> void: # takes an arraythat is stored in toDo
	match handle[1]: # for connecting, each one should check if theres another log in there for the priority that wants to connect
		"drag":
			pass;
		"connect":
			pass;
		"draw":
			pass;
