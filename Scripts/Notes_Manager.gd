extends Sprite2D

const LIST_OBJ = preload("res://things/ListObj.tscn");


var connections : Array;
var connectionsAndList : Array;
var redraw = false;
var button_height = 120;
var scroll_factor : int = 0; # scroll factor
var max_scroll : int = 0; #(7*button_height);
var min_scroll : int = 0;
var scrollable : bool = true;
var canScroll : bool = true;

var notes : Array = []; # later store this in a txt file # but this will be used to remember text

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# if move up move down or delete, run logic and set redraw to true
	canScroll = can_scroll()
	if redraw:
		draw_list();
	# scrolling logic
	if (len(connectionsAndList) >= 1 and scrollable and canScroll):
		min_scroll = -len(connectionsAndList)*button_height + button_height # make it so you can only go so high the lowest one is at the top (+ button_height so the first one doesnt count;
		scroll(delta);
	elif (scroll_factor != 0): # reset the scroll!
		scroll_factor = 0

func can_scroll() -> bool:
	# basically, right now the script is attached to the sprite of the page, so, use dimensions of self!
	if ((get_global_mouse_position().x > (global_position.x-(texture.get_width()*scale.x/2)) and get_global_mouse_position().x < (global_position.x+(texture.get_width()*scale.x/2))) and (get_global_mouse_position().y > (global_position.y-(texture.get_height()*scale.y/2)) and get_global_mouse_position().y < (global_position.y+(texture.get_height()*scale.y/2)))):
		return true;
	else:
		return false;

func scroll(delta) -> void:
	if Input.is_action_just_released("scroll_up"):
		scroll_factor -= button_height
		redraw = true
	elif Input.is_action_just_released("scroll_down"):
		scroll_factor += button_height
		redraw = true
		
	if (max_scroll < scroll_factor):
		scroll_factor = max_scroll
	elif (min_scroll > scroll_factor):
		scroll_factor = min_scroll
	#print(scroll_factor)

func update_connections() -> void:
	var toRemove = [];
	var possibleConnections = get_parent().getConnections();
	# all this section does is gets whats in the connections from the corkboard, and then add them under the current conenctions, while removing any missing.
	for i in possibleConnections: # this is done so we have our own seperate order of connections here, and we're not editing the original list
		if (i not in connections): 
			connections.append(i);
	for i in connections: # same thing need to clear out ones that are actually not used
		if (i not in possibleConnections):
			toRemove.append(i);
	for i in toRemove: # this is seperate to not mess up the loop
		# IF the thing being removed has a list connection (it will), delete the list connection object
		for x in connectionsAndList:
			if i in x:
				# removes it from the list, then deletes the object
				var temp = x[1];
				log_notes(x[0][0], x[0][1], x[1].currNotes); # this will log and save the notes
				connectionsAndList.erase(x);
				temp.queue_free();
		connections.erase(i);
	possibleConnections = [] # clear it out
	
	redraw = true;

func move_up(toMove : Node2D) -> void:
	# checks to see if the one pressed up on is at the top, if its not, move it up one and the one above it down one.
	if (len(connectionsAndList) > 1 and connectionsAndList[0][1] != toMove):
		var index = 0;
		# find the index in the list
		for i in connectionsAndList:
			if i[1] == toMove:
				break;
			index += 1;
		# create temp variables to save the positions
		var thisObj = connectionsAndList[index];
		var prevObj = connectionsAndList[index-1];
		# switch the positions
		connectionsAndList[index] = prevObj;
		connectionsAndList[index-1] = thisObj;
		# redraw the list
		redraw = true;
	
func move_down(toMove : Node2D) -> void:
	# same as move_up but down
	if (len(connectionsAndList) > 1 and connectionsAndList[-1][1] != toMove):
		var index = 0;
		# find the index in the list
		for i in connectionsAndList:
			if i[1] == toMove:
				break;
			index += 1;
		# create temp variables to save the positions
		var thisObj = connectionsAndList[index];
		var prevObj = connectionsAndList[index+1];
		# switch the positions
		connectionsAndList[index] = prevObj;
		connectionsAndList[index+1] = thisObj;
		# redraw the list
		redraw = true;
	
func log_notes(photo1 : Node2D, photo2 : Node2D, note :String) -> void: # NOTE TODO NOTE TODO MAKE THIS STORED IN A TEXT FILE LATER NOTE TODO TODO NOTE
	notes.append([[photo1, photo2], note]); # make like an update notes that reads the text file to rebuild this notes list!
	
func draw_list() -> void:
	# So BASICALLY, for each thing in connections, if it doesn't already have a listing, create one for it! then log that it has one
	for x in connections:
		var create = true;
		for y in connectionsAndList:
			if x in y:
				create = false;
		if create:
			var thisListing = LIST_OBJ.instantiate();
			thisListing.position -= texture.get_size()/2
			thisListing.set_connection_text("[color=black]"+ x[0].nameID + " -> " + x[1].nameID +"[/color]")
			connectionsAndList.append([x, thisListing]); # THIS IS WHERE CONNECTIONSANDLIST IS MADE
			thisListing.set_photos(x[0],x[1]);
			for i in notes:
				if (x[0] in i[0] && x[1] in i[0]):
					thisListing.currNotes = i[1];
			add_child(thisListing)
	# set position
	var currAdjuster = 0;
	for thisObj in connectionsAndList: 
		thisObj[1].position = Vector2(0,scroll_factor) - texture.get_size()/2 + Vector2(0, button_height*currAdjuster); # button_height its double the height of the delete button TODO
		currAdjuster += 1;
		
	redraw = false;

# what this is doing, is it gets the children of notesmanager, which are list_objs, and then it gets their childrens, and if that child is a note page, it checks if that note page is draggable
# if that notepage is draggable, then that means the mouse is LIKELY over it! So yarn cannot be removed!
func is_hover() -> bool:
	for x in get_children(): # list obj
		for y in x.get_children(): # list obj childrens
			if "NotePage" in y.get_groups():
				if y.draggable || y.ignore: # if it can move, or if the mouse is in the main body
					return true;
	return false;

# for each child, toggle if it can be interacted with!
# Not used anymore.......
func toggle_ignore_children() -> void: # do this for EVERYTHING
	var children = get_children();
	for child in children:
		child.toggle_ignore();
	if (scrollable):
		scrollable = false;
	else:
		scrollable = true;
