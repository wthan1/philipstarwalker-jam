extends Node2D
class_name playerSpawn

@export_range(-PI,PI) var angle:float = 0
@export var velocity:Vector2 = Vector2(0,0)
@export var inside:bool = true

var playerNode = preload("res://nodes/player/player.tscn")

func _ready():
	add_to_group("playerSpawn")
	if !get_tree().root.has_node("gamecontroller"): spawn()

func spawn(time:float=0):
	var ply = playerNode.instantiate()
	get_parent().add_child.call_deferred(ply)
	ply.global_position = global_position
	ply.velocity = velocity
	ply.rotation = angle
	ply.rotGoal = angle
	ply.scale.x = .6
	ply.spawnFrozen = true
	ply.time = time
	ply.inside = inside
