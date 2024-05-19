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

var mouseIn = false
func _on_mouse_entered(): mouseIn = true
func _on_mouse_exited(): mouseIn = false

func _physics_process(_delta):
	mouseIn = (mouseIn and get_parent().active)
	
	var goal = startX
	if mouseIn:
		if !wasMouseIn: sound.create(sounds.outs[randi()%len(sounds.outs)],self)
		
		goal += 12
		if Input.is_action_pressed("click"): goal -= 6
		if Input.is_action_just_pressed("click"): sound.create(sounds.ins[randi()%len(sounds.ins)],self)
		if Input.is_action_just_released("click"):
			sound.create(sounds.outs[randi()%len(sounds.outs)],self)
			pressed.emit()
	position.x += toval.mul(position.x,goal,2)
	shape.position.x = (startX-position.x)+(shape.shape.size.x/2)
	
	wasMouseIn = mouseIn
