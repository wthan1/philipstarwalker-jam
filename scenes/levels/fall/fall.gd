extends Node2D

var destination = "res://scenes/levels/levelselector.tscn"

func _ready(): $exit.destination = destination
