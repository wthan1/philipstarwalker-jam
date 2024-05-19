extends Node2D

var color = Color(1,1,1)

@onready var sprite = $shape

var posGoal = Vector2(0,0)
var rotGoal = 0

func _ready():
	sprite.frame = randi()%sprite.hframes
	posGoal = position+(Vector2(sign((randi()%3)-1)*50,-40).rotated(rotation))
	
	sprite.modulate = color

func _physics_process(_delta):
	scale *= randf_range(.89,.94)
	if (scale.length()<.1): queue_free()
	
	posGoal.x += ((randi()%3)-1)*((randi()%4)+1)
	position.x += toval.mul(position.x,posGoal.x,8)
	posGoal.y += ((randi()%3)-1)*((randi()%4)+1)
	position.y += toval.mul(position.y,posGoal.y,8)
	
	rotGoal += ((randi()%3)-1)*((randi()%4)+1)*.2
	rotation += toval.mul(rotation,rotGoal,4)
