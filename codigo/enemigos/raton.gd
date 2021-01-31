extends KinematicBody2D
var velocidad = Vector2()
var dir = 1
var snap_vector = Vector2.DOWN * 16
var pend_max = deg2rad(46)
onready var spr_raton = $AnimatedSprite

func _physics_process(_delta):
	if is_on_wall():dir *= -1
	velocidad.x = dir * 70
	velocidad = move_and_slide_with_snap(velocidad, snap_vector, Vector2.UP,true, 4, pend_max)
	if velocidad.x < 0:spr_raton.flip_h = true
	elif velocidad.x > 0:spr_raton.flip_h = false
