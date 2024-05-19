extends Sprite2D

var goalPos = Vector2(0,0)
var goalRot = 0
var tovalSpeed = 4

var spawnTime = 0

var bang = preload("res://nodes/particles/360/bang.wav")
func _ready():
	sound.create(bang,self).pitch_scale = randf_range(.9,1.1)
	scale = Vector2(.1,.1)
	
	goalPos = position-Vector2(0,10)
	goalRot = randf_range(-.3,.5)
	
	spawnTime = Time.get_ticks_msec()

func _physics_process(_delta):
	position.y += toval.mul(position.y,goalPos.y,tovalSpeed)
	var s = toval.mul(scale.x,1,tovalSpeed)
	scale += Vector2(s,s)
	rotation += toval.mul(rotation,goalRot,4)
	
	if ((Time.get_ticks_msec()-spawnTime)>1000):
		if (tovalSpeed<20): goalPos.y += 20
		tovalSpeed = 20
		modulate.a += toval.mul(modulate.a,0,tovalSpeed)
		if (modulate.a<.02): queue_free()
		
