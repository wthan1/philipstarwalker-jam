extends Node2D

var plyTime = 0

var transitioning = false
var transitionState = 0

var curLevel
@export var toLoadLevel:String

@onready var curtain = $transition

func _ready():
	startTransition(toLoadLevel)

func _process(_delta):
	if transitioning:
		match transitionState:
			0:
				curtain.position.y += toval.linear(curtain.position.y,0,20)
				
				if (curtain.position.y<1):
					if !has_node("transition"):
						curtain.get_parent().remove_child(curtain)
						add_child(curtain)
					
					if curLevel: curLevel.queue_free()
					
					var newLevel
					if ((randi()%20)==0):
						newLevel = load("res://scenes/levels/fall/fall.tscn").instantiate()
						newLevel.destination = toLoadLevel
					else: newLevel = load(toLoadLevel).instantiate()
					add_child(newLevel)
					curLevel = newLevel
					
					transitionState = 1
			1:
				curtain.position.y += toval.lin_to_mul(curtain.position.y,-721,20,2)
				
				if (curtain.position.y<-720):
					transitioning = false
					get_tree().get_nodes_in_group("playerSpawn")[0].spawn(plyTime)

func startTransition(level):
	if transitioning: return
	
	if ResourceLoader.exists(level): toLoadLevel = level
	else: toLoadLevel = "res://scenes/levels/levelselector.tscn"
	
	curtain.position.y = 720
	transitioning = true
	transitionState = 0
