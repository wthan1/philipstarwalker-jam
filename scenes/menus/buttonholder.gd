extends Node2D
class_name buttonholder

@export var active = true

func _physics_process(_delta):
	var goal = -600
	if active: goal = 0
	position.x += toval.lin_to_mul(position.x,goal,24,6)
