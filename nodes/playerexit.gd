extends Area2D
class_name playerExit

@export var destination:String

func entered(time:float=0):
	var controller = get_tree().root.get_node("gamecontroller")
	if !controller: get_tree().reload_current_scene()
	else:
		controller.startTransition(destination)
		controller.plyTime = time
