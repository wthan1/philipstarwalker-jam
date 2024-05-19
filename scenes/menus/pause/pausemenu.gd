extends Node2D

@onready var player = get_parent().get_parent()

func _on_respawn_pressed(): player.respawn()

var mainmenu = preload("res://scenes/menus/main/mainmenu.tscn")
func _on_mainmenu_pressed():
	get_tree().change_scene_to_packed(mainmenu)
	player.get_parent().get_parent().queue_free()

func _on_quit_pressed(): get_tree().quit()
