extends Node2D

var radius = 0
var width = 0
var note_width = 0
var process = 0.0
var frame_radius	
@export var speed = 1.0
var processed = false
var begin_time
@export var manual = false
@export var temporary = false

signal pressed


func to_json(time: float) -> Dictionary:
	return {
		"y": Globals.note_type_info[Globals.NoteTypes.CRITICAL]['code'],
		't': time,
	}


func resize(frame = null) -> void:
	if frame == null:
		frame = get_parent().get_node("NoteFrame")
	frame_radius = frame.radius
	note_width = frame.width / 8


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_tree().get_root().size_changed.connect(resize)
	
	resize()
		
	begin_time = Time.get_ticks_usec()


func render():
	width = pow(process, 3) * note_width
	radius = frame_radius * pow(process, 4)
	queue_redraw()


func _process(_delta: float) -> void:
	if not manual:
		process = (Time.get_ticks_usec() - begin_time) / 1_000_000.0 * speed
	
	render()
	
	var dt = (process - 1.0) / speed
	if not processed:
		if abs(dt) <= Globals.judgement_info[Globals.Judgements.MISS]["precision"] and Input.is_action_just_pressed("CriticalPress"):
			processed = true
			for i in range(Globals.judgement_info.size() - 1):
				if abs(dt) <= Globals.judgement_info[i]["precision"]:
					pressed.emit(i, rotation, true, dt)
					break
			queue_free()
		elif dt > Globals.judgement_info[Globals.Judgements.MISS]["precision"]:
			pressed.emit(Globals.Judgements.MISS, rotation, true, dt)
			processed = true
	
	if dt > Globals.judgement_info[Globals.Judgements.MISS]["precision"] and radius > (get_window().size/2).length() + width * 2:
		queue_free()



func _draw():
	if radius > 0 and process < 2.0:
		var color = Globals.note_type_info[Globals.NoteTypes.CRITICAL]['color']
		
		if temporary:
			color.a = 0.5
		
		draw_circle(Vector2.ZERO, radius, color, false, width, true)
