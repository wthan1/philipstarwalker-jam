extends CharacterBody2D

@onready var sprite = $sprite

@onready var cam = $cam

@onready var stuckcheck = $stuckcheck
var lastFree = 0

@onready var timerHolder = $speedruntimer
@onready var timerLabel = $speedruntimer/label
var time = 0

var inside = true
var lastFlip = 0
var lastBonk = 0
var turnSinceBonk = 0
var kewlflip = preload("res://nodes/particles/360/360.tscn")

var coyote = 0
var jumping = false
var lastJump = 0

var gravAngle = 0

var rotGoal = 0

var spawnFrozen = false

var exitFrozen = false
var exitGoalX
var exitPipe

var menuFrozen = false

var scaleGoal = Vector2(1,1)

var walkDist = 0

var sounds = {
	flip=preload("res://nodes/player/sounds/flip1.wav"),
	jump=preload("res://nodes/player/sounds/jump.wav"),
	steps=[
		preload("res://nodes/player/sounds/step1.wav"),
		preload("res://nodes/player/sounds/step2.wav"),
		preload("res://nodes/player/sounds/step3.wav")
	]
}

func _ready():
	cam.global_position = Vector2(0,0)
	cam.global_rotation = 0
	#steal curtain
	if get_tree().root.has_node("gamecontroller"):
		var controller = get_tree().root.get_node("gamecontroller")
		controller.curtain.get_parent().remove_child(controller.curtain)
		cam.add_child(controller.curtain)

@onready var menu = $cam/pausemenu
func _physics_process(delta):
	if Input.is_action_just_pressed("menu"):
		menuFrozen = not menuFrozen
	var goal = -960
	if menuFrozen: goal = 0
	
	menu.global_scale = Vector2(1,1)
	menu.position.x += toval.lin_to_mul(menu.position.x,goal,96,4)
	
	if menuFrozen: return
	
	var inVec = Input.get_vector("left","right","down","up")
	inVec = inVec.rotated(gravAngle)
	var mousepos = get_viewport().get_mouse_position()+cam.global_position
	
	scale.x += toval.mul(scale.x,scaleGoal.x,8)
	scale.y += toval.mul(scale.y,scaleGoal.y,8)
	if (exitFrozen and (scale.y<(scaleGoal.y+.01))): exitPipe.entered(time)
	
	var col = get_last_slide_collision()
	if col:
		spawnFrozen = false
		
		var dist = col.get_position().distance_to(global_position-Vector2(0,48).rotated(rotGoal))
		if (dist<5):
			#check for level exit
			for v in floorcheck.get_overlapping_areas(): if (v is playerExit):
				exitPipe = v
				exitFrozen = true
				scaleGoal.y = .4
				exitGoalX = v.position.x
				
				#fix curtain
				if cam.has_node("transition"):
					var controller = get_tree().root.get_node("gamecontroller")
					cam.remove_child(controller.curtain)
					controller.add_child(controller.curtain)
				
			#try to flip
			if (((Time.get_ticks_msec()-lastFlip)>100) and !over_body(wallcheck) and !exitFrozen
			and (not (PhysicsServer2D.body_get_collision_layer(col.get_collider_rid())>1))):
				flip_player(col)
				lastFlip = Time.get_ticks_msec()
			elif !exitFrozen:
				if ((Time.get_ticks_msec()-lastBonk)>100):
					#bonk
					sound.create(sounds.jump,self)
					
					if ((abs(abs(turnSinceBonk)-TAU)<1) and (Time.get_ticks_msec()-lastBonk<1000)):
						var cool = kewlflip.instantiate()
						cool.position = position-(Vector2(0,120).rotated(gravAngle))
						if !inside: cool.frame = 1
						get_parent().add_child(cool)
					turnSinceBonk = 0
					
					velocity *= 1.25
					velocity += col.get_normal()*250
				lastBonk = Time.get_ticks_msec()
	
	if (abs(inVec.x)>.1): sprite.flip_h = (inVec.x<0)
	sprite.frame_coords.y = bool_sign(inside,1,0)
	
	var moveMod = 42
	if over_body(floorcheck):
		if (((abs(wrapf(rotation-gravAngle,-PI,PI))>.01) or jumping) and ((Time.get_ticks_msec()-lastFlip)>100)
		and ((Time.get_ticks_msec()-lastJump)>100)):
			ground_player()
		
		velocity = mult_vector_axis_by_angle(velocity,"x",.8,gravAngle)
		
		walkDist += abs(inVec.x)
		if (walkDist>14):
			walkDist = 0
			sound.create(sounds.steps[randi()%len(sounds.steps)],self)
		
		coyote = Time.get_ticks_msec()
	else:
		if (!spawnFrozen and !exitFrozen): rotGoal = position.angle_to_point(mousepos)+(PI/2)
		
		moveMod = 4
		
		velocity = mult_vector_axis_by_angle(velocity,"x",.985,gravAngle)
	
	#jump
	if ((inVec.y>0.1) and !jumping and ((Time.get_ticks_msec()-coyote)<100)
	and ((Time.get_ticks_msec()-lastJump)>100) and ((Time.get_ticks_msec()-lastFlip)>300)):
		sound.create(sounds.jump,self)
		
		jumping = true
		lastJump = Time.get_ticks_msec()
		velocity -= Vector2(0,312.5).rotated(gravAngle)
	
	#fix rot
	if exitFrozen: rotGoal = gravAngle-PI
	rotGoal = wrapf(rotGoal,-PI,PI)
	#NEVER TOUCH THIS LINE ITS CURSED I CAN NEVER RE EXPLAIN OR RE MAKE IT
	var realGoal = closer(rotation,rotGoal-closer(rotGoal,-PI,PI)+closer(rotation,-PI,PI),rotGoal)
	var turn = toval.lin_to_mul(rotation,realGoal,.6,2)
	rotation += turn
	turnSinceBonk += turn
	
	clearcheck.global_rotation = rotGoal
	
	if spawnFrozen: moveMod = 0
	
	velocity += Vector2(inVec.x*moveMod,10).rotated(gravAngle)
	if exitFrozen: velocity = Vector2(0,180).rotated(gravAngle)+Vector2((exitGoalX-position.x)*4,0)
	move_and_slide()
	floorcheck.rotation = -rotation+gravAngle
	
	#fix cam
	var sideAllowence = 80
	var sizex = 960
	var sizey = 720
	cam.global_position = Vector2(0,0)
	cam.global_rotation = 0
	if !inside:
		if (global_position.x>(sizex-sideAllowence)):
			cam.global_position.x = clamp(global_position.x-sizex+sideAllowence,0,INF)
		elif (global_position.x<sideAllowence):
			cam.global_position.x = clamp(global_position.x-sideAllowence,-INF,0)
		
		if (global_position.y>(sizey-sideAllowence)):
			cam.global_position.y = clamp(global_position.y-sizey+sideAllowence,0,INF)
		elif (global_position.y<sideAllowence):
			cam.global_position.y = clamp(global_position.y-sideAllowence,-INF,0)
	
	#respawn
	var deathDist = 200
	if ((global_position.x!=clamp(global_position.x,-deathDist,deathDist+sizex))
	or (global_position.y!=clamp(global_position.y,-deathDist,deathDist+sizey))): respawn()
	if Input.is_action_just_pressed("respawn"): respawn()
	
	#fix stuck
	if !over_body(stuckcheck): lastFree = Time.get_ticks_msec()
	if ((Time.get_ticks_msec()-lastFree)>1000): respawn()
	
	#speedrun timer
	timerHolder.visible = settings.timer
	if !(exitFrozen or spawnFrozen or ("levelselector" in get_parent().scene_file_path)): time += delta
	timerHolder.global_position = global_position-Vector2(0,80)
	timerHolder.global_rotation = 0
	timerHolder.global_scale = Vector2(1,1)
	
	var mils = fmod(time,1)*100
	var secs = fmod(time,60)
	var mins = fmod(time,3600)/60
	timerLabel.text = "%02d:%02d.%02d"%[mins,secs,mils]
	
	#TEMP !
	#if Input.is_action_just_pressed("PARTICLETEST"):
		#var particle = load("res://nodes/particles/shapeout/shapeout.tscn").instantiate()
		#particle.position = position-(Vector2(0,60).rotated(rotation))
		#particle.rotation = rotation
		#if inside: particle.color = Color(1,1,0)
		#get_parent().add_child(particle)

@onready var floorcheck = $floorcheck
func over_body(check):
	for v in check.get_overlapping_bodies(): if ((v is TileMap) or (v is StaticBody2D)): return true
	return false

func ground_player():
	rotGoal = gravAngle
	jumping = false
	
	#check for climbing
	var spaceState = get_world_2d().direct_space_state
	
	var headPos = global_position-Vector2(0,48).rotated(rotation)
	var headQuery = PhysicsRayQueryParameters2D.create(headPos,headPos+(Vector2(0,400).rotated(gravAngle)),1,[self])
	var headRay = spaceState.intersect_ray(headQuery)
	var footQuery = PhysicsRayQueryParameters2D.create(global_position,global_position+(Vector2(0,400).rotated(gravAngle)),1,[self])
	var footRay = spaceState.intersect_ray(footQuery)
	
	if (headRay and footRay and ((headRay.position-footRay.position).rotated(-gravAngle).y<-10)):
		sound.create(sounds.jump,self)
		position = headRay.position-(Vector2(0,40).rotated(gravAngle))

@onready var clearcheck = $clearcheck
@onready var wallcheck = $clearcheck/wallcheck
var shapeout = preload("res://nodes/particles/shapeout/shapeout.tscn")
func flip_player(col):
	for v in range(randi_range(2,3)):
		var particle = shapeout.instantiate()
		particle.position = col.get_position()
		particle.rotation = col.get_normal().angle()+(PI/2)
		if inside: particle.color = Color(1,1,0)
		get_parent().add_child(particle)
	
	sound.create(sounds.flip,self)
	
	inside = (len(clearcheck.get_overlapping_bodies())>0)
	
	velocity -= col.get_normal()*438
	gravAngle = col.get_normal().angle()-(PI/2)
	position = col.get_position()-Vector2(0,40).rotated(gravAngle)
	
	if inside: gravAngle = 0

func respawn():
	if get_tree().root.has_node("gamecontroller"):
		var controller = get_tree().root.get_node("gamecontroller")
		controller.startTransition(get_parent().scene_file_path)
		controller.plyTime = time
	else: get_tree().reload_current_scene()

func bool_sign(b:bool,fval:float=-1,tval:float=1):
	if b: return tval
	return fval

func mult_vector_axis_by_angle(vector:Vector2,axis:String,multiplier:float,angle:float):
	var vel = vector.rotated(-angle)
	vel[axis] *= multiplier
	return vel.rotated(angle)

func closer(val:float,num1:float,num2:float):
	if (abs(val-num1)>abs(val-num2)): return num2
	return num1
	
