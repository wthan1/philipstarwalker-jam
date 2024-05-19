extends Node2D

var gameController = preload("res://scenes/gamecontroller/gamecontroller.tscn")

func _on_play_pressed():
	var controller = gameController.instantiate()
	controller.toLoadLevel = "res://scenes/levels/1.tscn"
	get_parent().add_child(controller)
	queue_free()

func _on_levelselect_pressed():
	var controller = gameController.instantiate()
	get_parent().add_child(controller)
	queue_free()

func _on_quit_pressed(): get_tree().quit()

func _on_settings_pressed(): swap_panel("settings")

func _on_credits_pressed(): swap_panel("credits")

func _on_back_pressed(): swap_panel("main")

func _on_timer_pressed(val): settings.timer = val

func swap_panel(newPanel):
	for v in get_children():
		if (v is buttonholder):
			v.active = (v.name==newPanel)
