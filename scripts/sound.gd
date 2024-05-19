extends Node

var sounds = []

func create(audio,parent:Node):
	var player = AudioStreamPlayer.new()
	player.stream = audio
	parent.add_child(player)
	player.play()
	sounds.append(player)
	return player

func _physics_process(_delta):
	var k = 0
	for v in sounds:
		if ((v==null) or !v.playing):
			if (v!=null): v.queue_free()
			sounds.remove_at(k)
		k += 1
