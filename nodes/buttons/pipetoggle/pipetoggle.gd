extends Area2D

signal pressed

@export var text:String

@onready var label = $text

@onready var back = $back
@onready var front = $front
@onready var middle = $middle

@export var spriteSize = 90
@export var textRoom = 34

@onready var shape = $shape

var startX

@onready var box = $front/box
@onready var check = $front/box/check

@export var active = false

var sounds = {
	ins=[
		preload("res://nodes/buttons/sounds/mkin1.wav"),
		preload("res://nodes/buttons/sounds/mkin2.wav"),
		preload("res://nodes/buttons/sounds/mkin3.wav")
	],
	outs=[
		preload("res://nodes/buttons/sounds/mkout1.wav"),
		preload("res://nodes/buttons/sounds/mkout2.wav"),
		preload("res://nodes/buttons/sounds/mkout3.wav")
	]
}
var wasMouseIn = false

func _ready():
	startX = position.x
	
	var textSize = label.get_theme_default_font().get_string_size(text.to_upper()).x
	label.text = text.to_upper()
	front.position.x = clamp((textSize*2)+textRoom,spriteSize*1.5,INF)
	if (front.position.x>(spriteSize*1.5)):
		middle.visible = true
		var dif = front.position.x-(spriteSize*1.5)
		middle.scale.x = dif/spriteSize
		middle.position.x = spriteSize+(dif/2)
	else: middle.visible = false
	
	shape.shape = shape.shape.duplicate()
	shape.shape.size.x = front.position.x-(spriteSize/2.0)
	shape.position.x = shape.shape.size.x/2.0
	
	check.visible = active

var mouseIn = false
func _on_mouse_entered(): mouseIn = true
func _on_mouse_exited(): mouseIn = false

func _physics_process(_delta):
	mouseIn = (mouseIn and get_parent().active)
	
	var goal = startX
	var bgoal = -25
	if mouseIn:
		if !wasMouseIn: sound.create(sounds.outs[randi()%len(sounds.outs)],self)
		
		goal += 12
		bgoal += 42
		if Input.is_action_pressed("click"):
			goal -= 6
			bgoal += 6
		if Input.is_action_just_pressed("click"): sound.create(sounds.ins[randi()%len(sounds.ins)],self)
		if Input.is_action_just_released("click"):
			sound.create(sounds.outs[randi()%len(sounds.outs)],self)
			
			active = not active
			check.visible = active
			
			box.scale = Vector2(.7,.7)
			
			pressed.emit(active)
	position.x += toval.mul(position.x,goal,2)
	shape.position.x = (startX-position.x)+(shape.shape.size.x/2)
	
	box.position.x += toval.mul(box.position.x,bgoal,2)
	box.scale.x += toval.mul(box.scale.x,1,4)
	box.scale.y += toval.mul(box.scale.y,1,4)
	
	wasMouseIn = mouseIn
