extends Node2D

### NOTE THis code is a mess, BUT it works, and I think most of the bugs are ironed out, so, use this for now, if this game is ever serious though, this won't work...

var toDo : Array; # drag
var toDo2 : Array; # yarn

#yarn connection
var currConnection : Node2D = null;
var toDo3 : Array;
var toCon : Node2D = null;
var disconnect : Node2D = null;


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# so basically, if its bigger than one, the first in the list is allowed to move, then the rest are not
	# IF theres only one, make sure it's allowed to move
	toDoLogic1(delta);
	
	# do the same thing for yarn:
	toDoLogic2(delta);
	
	# hehe connections code :D
	toDoLogic3(delta); # trust the process
	
	if (disconnect != null):
		currConnection = null;
		#toCon = null;
		disconnect = null;

# log an object to be handled.
func logD(anObj : Node2D) -> void:
	if !(anObj in toDo):
		toDo.append(anObj);

func log_disconnect(toDis : Node2D) -> void:
	disconnect = toDis;

func wannaConnect(thisObj : Node2D) -> void:
	currConnection = thisObj;

func logYarn(anyObj : Node2D) -> void:
	if !(anyObj in toDo2):
		toDo2.append(anyObj);

func YarnConnect(anotherObj : Node2D) -> void:
	if !(anotherObj in toDo3):
		toDo3.append(anotherObj);
		
func canConnect() -> bool:
	if (currConnection != null):
		return true;
	else:
		return false;

# can move logic
# TODO BIG NOTE :: MAKE ALL TODO LOGICS DO THE TOP LAYER NOT THE FIRST IN LIST NOTE !!! TODO # should be good lol
func toDoLogic1(delta : float) -> void:
	var toDoSub = [];
	var toDoSubSub = [];
	if toDo.size() > 1:
		#NOTE
		# THis is kinda slow, but the cleaning up the mose with the ogMouse in Photo.gd made it look WAY better
		# basically all this is doing is picking the child closest to the top in the tree thats also in todo, and that is the child allowed to drag
		# same will be done for yarn
		# NOTETAKERS ON TOP!!!!!!!! YEYYAYAYAHHHH /j
		# but fr this handles the notetakers first, then the photos if there are no notetakers present
		var spotted_ignore = false;
		for i in toDo:
			if ("ignore" in i.get_groups()):
				spotted_ignore = true; # if this gets set to true, we need to ignore all photos, and then handle note taker logic, allowing top note takers to move
		if (spotted_ignore):
			#ignorance logic
			for i in toDo:
				if ("Photo" in i.get_groups()):
					i.stop_moving(); # stop & remove all photographs
				elif ("ignore" in i.get_groups()):
					toDoSubSub.append([i.get_parent().get_parent(), i.get_parent(), true]); # [listobj, note_taker, <ingorobj>]
				else:
					toDoSubSub.append([i.get_parent(), i, false]); # [listobj, note_taker, <ingorobj>]
			for i in toDoSubSub:
				var noteParent = toDoSubSub[0][0].get_parent();
				var curr;
				var prev = noteParent.get_children().find(toDoSubSub[0][0], 0);
				for x in toDoSubSub:
					curr = noteParent.get_children().find(x[0], 0);
					if (curr < prev):
						prev = curr;
				for x in toDoSubSub:
					if (x[0] == noteParent.get_children()[curr]):
						if not x[2]:
							x[1].can_move();
					elif (not x[2]):
						x[1].stop_moving();
			
			toDo.clear();
			return;
			
		for i in toDo:
			if ("NotePage" in i.get_groups()):
				toDoSub.append([i.get_parent(), i]); # [listobj, note_taker]
		if toDoSub.size() >= 1: # for all the things wanting to move, grab the one closest to the top of the family tree, let that one move, KILL THE REST!!!
			var noteParent = toDoSub[0][0].get_parent(); # I mean it is an oject
			var curr;
			var prev = noteParent.get_children().find(toDoSub[0][0], 0);
			for i in toDoSub:
				curr = noteParent.get_children().find(i[0], 0);
				if (curr < prev):
					prev = curr;
			# find top item in toDoSub (This works for now tho)
			for i in toDoSub:
				if i[0] == noteParent.get_children()[curr]:
					toDo.pop_at(toDo.find(i[1])).can_move(); # MAYBE HANDLE TYPING HERE TOO (draging something over a text box doesn't work)
					break;
			for i in toDo:
				i.stop_moving();
			toDo.clear();
			return;
			
			
		# this is essentially the same thing as above, just not ONLY photos
		var curr; # for all the things wanting to move, grab the one closest to the top of the family tree, let that one move
		var prev = get_children().find(toDo[0],0);
		for i in toDo: # array.find(name,0)
			curr = get_children().find(i, 0);
			if (curr < prev):
				prev = curr;
		toDo.pop_at(toDo.find(get_children()[curr])).can_move();
		# this and after was original code:
		#toDo.pop_front().can_move();
		for i in toDo:
			i.stop_moving();
	elif toDo.size() == 1:
		if ("ignore" not in toDo[0].get_groups()):
			toDo.pop_front().can_move();
	# clean up just in case
	toDo.clear();

# this code is obsolete as toDo3 now covers it. #TODO UPDATE THIS ONE # not obsolete??? still do what it should...
func toDoLogic2(delta : float) -> void:
	var toDo2Sub = [];
	var spotted_over = false;
	for i in toDo2:
		if ("NotePage" in i.get_groups() || "ignore" in i.get_groups()):
			toDo2.clear();
			break;
		if ("PhotoOver" in i.get_groups()):
			toDo2[toDo2.find(i,0)] = i.get_parent(); # set it as the photo, if its not on top it wont be used, if it is on top it will be cleared!
			spotted_over = true;
			toDo2Sub.append([i.get_parent(), true]) # photo, <isMoving>
		else:
			toDo2Sub.append([i, false]);
	
	if (spotted_over && toDo2Sub.size() > 1): # this will determen if the one trying to move is the highest, if it is, it gets priotirty, if it isn't, it stays where it is. (i.e. not priority)
		var curr;
		var prev = get_children().find(toDo2Sub[0][0],0);
		for i in toDo2Sub:
			curr = get_children().find(i[0], 0);
			if ( curr < prev ):
				prev = curr;
		var check = toDo2Sub[toDo2Sub.find(get_children()[curr])];
		if (check[1]):
			print("ohpoop")
		
	if toDo2.size() > 1:
		#toDo2.pop_front().can_draw();
		var curr;
		var prev = get_children().find(toDo2[0],0);
		for i in toDo2: # array.find(name,0)
			curr = get_children().find(i, 0);
			if (curr < prev):
				prev = curr;
		toDo2.pop_at(toDo2.find(get_children()[curr])).can_draw();
		for i in toDo2:
			i.stop_draw();
	elif toDo2.size() == 1 && "PhotoOver" not in toDo2[0].get_groups(): #ignore if its just moving lol
		toDo2.pop_front().can_draw();
	toDo2.clear();

# connections
func toDoLogic3(delta : float) -> void:
	for i in toDo3:
		if ("NotePage" in i.get_groups() || "ignore" in i.get_groups()):
			toDo3.clear();
			currConnection = null; # stop it from connecting if moving note page
			break;
	if (toDo3.size() > 1):
		#toCon = toDo3.pop_front();
		var curr;
		var prev = get_children().find(toDo3[0],0);
		for i in toDo3: # array.find(name,0)
			curr = get_children().find(i, 0);
			if (curr < prev):
				prev = curr;
		toCon = toDo3.pop_at(toDo3.find(get_children()[curr]));
	elif (toDo3.size() == 1):
		toCon = toDo3[0];
	toDo3.clear();
		
	# alr here
	if (toCon != null && currConnection != null) && (toCon != currConnection):
		get_parent().logic_connect(currConnection, toCon);
		toCon = null;
		currConnection = null;
