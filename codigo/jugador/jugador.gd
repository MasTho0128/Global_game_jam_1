extends KinematicBody2D
class_name jugador

signal sig_estado(nuevo_estado)
onready var spr_player = $AnimatedSprite


#velocidades, gravedad y direccion
var velocidad = Vector2()
var vel_caminar = 120
var vel_salto = 250
var gravedad = 400
var dir = 0
var snap_vector = Vector2.DOWN * 16
var pend_max = deg2rad(46)
var puede_saltar = false

#eventos con los items
var tiene_linterna = false
var tiene_tijeras = false


func _ready():
	OS.center_window()
	for t in get_tree().get_nodes_in_group("pos_ini"):self.global_position = t.global_position

func _physics_process(delta):
	aplicar_gravedad(delta)
	mov_jugador()
	salto_jugador()
	girar_spr()
	item_activado()

func aplicar_gravedad(delta):
	if is_on_floor():
		puede_saltar = true
		velocidad.y = 0
		snap_vector = Vector2.DOWN * 16
	else:
		puede_saltar = false
		velocidad.y += gravedad * delta

func mov_jugador():
	dir = int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"))
	velocidad.x = dir * vel_caminar
	velocidad.y = move_and_slide_with_snap(velocidad,snap_vector,Vector2.UP,true,4,pend_max).y

func salto_jugador():
	if Input.is_action_just_released("up"):frenar_salto()
	if Input.is_action_just_pressed("up") and puede_saltar:
		snap_vector.y = 0
		velocidad.y = -vel_salto
		velocidad = move_and_slide(velocidad,Vector2(0,-1))
		senal_cambiar_estado("saltar")

func frenar_salto():
	if velocidad.y < -140:
		velocidad.y = -80

func senal_cambiar_estado(estado_sig:String):#para cambiar el estado ponga el nombre del estado a cambiar y mande a llamar esta funcion
	emit_signal("sig_estado",estado_sig)

func girar_spr():
	if velocidad.x < 0:spr_player.flip_h = true
	elif velocidad.x > 0:spr_player.flip_h = false

func item_activado():
	if tiene_linterna:
		pass
	if tiene_tijeras:
		pass
