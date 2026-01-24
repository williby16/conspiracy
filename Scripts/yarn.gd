extends Node2D

var first : Node2D;
var second : Node2D;

# points
var p1 : Vector2;
var p2 : Vector2;

#deleting
var deletable : bool = false;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	draw_yarn(delta);


func draw_yarn(delta : float) -> void:
	# make a hitbox cover the line
	p1 = $Draw.get_point_position(0);
	p2 = $Draw.get_point_position(1);
	$String.scale.x = (p1.distance_to(p2))/21; # magic number, but WORKS???? # i made the width .5 also a magic number :P # 20 is perfect, but 19 gives a little space if you wanted to tap right ont the connecion spot
	$String.position = Vector2((p1.x+p2.x)/2, (p1.y+p2.y)/2); # this is fine
	$String.rotation_degrees = rad_to_deg((p1-p2).angle()); # Thisworked somehow idk yippieee
	
	# make code that highlights the line when its being hovered over # TODO NOTE
	if (deletable):
		pass # change color then change back else
	
	if (deletable && Input.is_action_just_pressed("left_click")): # want to make this a double click
		if (fs_can_del()): # check if its under a note
			get_parent().get_parent().removeConnection(first, second); # 2 get parents cause now I put the yarn object as a child in the "yarnHolder" node

func PhotoLog(photo1 : Node2D, photo2 : Node2D) -> void:
	first = photo1;
	second = photo2;

func fs_can_del() -> bool:
	var notes = (get_parent().get_parent().get_child(1)); # SHOULD BE Notes_Manager
	return not notes.is_hover();

func _on_string_mouse_entered() -> void:
	deletable = true;


func _on_string_mouse_exited() -> void:
	deletable = false;
