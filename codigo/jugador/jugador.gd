extends KinematicBody2D
class_name jugador

const ITEM_NESECITA = preload("res://escenas/jugador/item_que_nesecita.tscn")

signal sig_estado(nuevo_estado)
onready var spr_player = $AnimatedSprite
onready var sudor_dere = $sudor_panico_dere
onready var sudor_izq = $sudor_panico_izq
onready var girar_cosas = $giros
onready var nuevo_item = $item_nesecita


#velocidades, gravedad y direccion
var velocidad = Vector2()
export(float) var vel_caminar = 120
export(float) var vel_salto = 300
export(float) var gravedad = 500
export(float) var fuerza_knockback = 100
var dir = 0
var snap_vector = Vector2.DOWN * 16
var pend_max = deg2rad(46)
var puede_saltar = false


#eventos con los items
var tiene_linterna = false
var tiene_tijeras = false

#relacionado con salud,vida, etc player
var vida = 3 setget actualizar_vida
var vida_max = 4
var inmune = false
var regenerar_vida = true

var R
var old_vida = 0
var b_vol_corazon
var m_vol_corazon
var frec_corazon
var texture_scale_ini
var tween_estado = 0
var muerte_pantalla

func _ready():
	OS.center_window()
	for t in get_tree().get_nodes_in_group("pos_ini"):self.global_position = t.global_position
	for t in get_tree().get_nodes_in_group("pos_muerte"):muerte_pantalla = t.global_position
	
	texture_scale_ini = $Light2D.texture_scale
	b_vol_corazon = -$AudioCorazon.volume_db / vida_max
	m_vol_corazon = $AudioCorazon.volume_db / (vida_max - 1)
	spr_player.play("levantar")
	
	
func _physics_process(delta):
	aplicar_gravedad(delta)
	mov_jugador()
	salto_jugador()
	girar_spr()
	item_activado()
#	if Input.is_action_just_pressed("ui_accept"):actualizar_vida(1)
	#Efecto de que la luz oscila
	R = texture_scale_ini*(1 + old_vida)/(vida_max - 1)
	if old_vida >= vida:
		$Light2D.texture_scale = R + 0.1*R*sin( OS.get_ticks_msec()*0.006/old_vida)
		$Light2D.energy = 0.95 + 0.05*sin( OS.get_ticks_msec()*0.006/old_vida)
	else:
		$Light2D.texture_scale = R
	
	$AudioCorazon.volume_db = old_vida*m_vol_corazon + b_vol_corazon
	frec_corazon = (vida_max - old_vida)*0.16 / (vida_max - 1)
#	print($AudioCorazon.volume_db)
#	
	#Regeneración de vida
	if regenerar_vida:
		vida = clamp(vida + 0.01, 0, vida_max)
		apgar_sudor()
	old_vida = lerp(old_vida, vida, 0.1)
	if abs(old_vida-vida)<0.001: old_vida = vida

func aplicar_gravedad(delta):
	if is_on_floor():
		puede_saltar = true
		velocidad.y = 0
		snap_vector = Vector2.DOWN * 16
	else:
		puede_saltar = false
		velocidad.y += gravedad * delta
	if muerte_pantalla != null:
		if self.global_position.y > muerte_pantalla.y:
			$AnimationPlayer.play("desvanecer")

func mov_jugador():
	if !inmune and spr_player.animation != "levantar":
		dir = int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"))
		if spr_player.animation == "desmayo": dir = 0
		velocidad.x = dir * vel_caminar
	velocidad = move_and_slide_with_snap(velocidad, snap_vector, Vector2.UP,true, 4, pend_max)

func salto_jugador():
	if spr_player.animation == "desmayo" or spr_player.animation == "levantar":return
	if Input.is_action_just_released("up"):frenar_salto()
	if Input.is_action_just_pressed("up") and puede_saltar:
		snap_vector.y = 0
		velocidad.y = -vel_salto
		velocidad = move_and_slide(velocidad,Vector2(0,-1))
		senal_cambiar_estado("saltar")
		$Audio2DPasos.stop()

func frenar_salto():
	if velocidad.y < -140:
		velocidad.y = -80

func senal_cambiar_estado(estado_sig:String):#para cambiar el estado ponga el nombre del estado a cambiar y mande a llamar esta funcion
	emit_signal("sig_estado",estado_sig)

func girar_spr():
	if velocidad.x < 0:
		spr_player.flip_h = true
		girar_cosas.scale.x = -1
	elif velocidad.x > 0:
		spr_player.flip_h = false
		girar_cosas.scale.x = 1

func item_activado():
	if tiene_linterna and spr_player.animation != "desmayo":
		girar_cosas.show()
	if tiene_tijeras:
		pass

func actualizar_vida(_valor):
	if old_vida <= 3 and !sudor_dere.emitting and !sudor_izq.emitting:
		sudor_dere.emitting = true
		sudor_izq.emitting = true
	if old_vida <= 2:
		sudor_dere.amount = 20
		sudor_izq.amount = 20
	if old_vida <= 1:
		sudor_dere.emitting = false
		sudor_izq.emitting = false
		girar_cosas.hide()
		girar_cosas.get_node("Light2DLinterna").texture = null
		girar_cosas.get_node("Sprite").texture = null
		senal_cambiar_estado("desmayo")
	$lbl_control.text = str(vida)

func _on_TimerInmunidad_timeout():
	inmune = false

func _on_TimerRegenVida_timeout():
	regenerar_vida = true

func _on_aplicar_knocbag_body_entered(body):
	if spr_player.animation == "desmayo":return
	if !inmune and body.is_in_group("enemigos"):
		$TimerInmunidad.start()
		$TimerRegenVida.start()
		old_vida = vida
		vida = clamp(int(vida) - 1, 1, vida_max)
		actualizar_vida(1)
		inmune = true
		regenerar_vida = false
		var hitbox = global_position - body.global_position
		velocidad.x = sign(hitbox.x)*(100)
		snap_vector.y = 0
		velocidad.y = -vel_salto
		velocidad = move_and_slide(velocidad,Vector2(0,-1))
		$TimerInmunidad.start()

func generar_item(obj_nuevo)->void:
	var requiero_item = ITEM_NESECITA.instance()
	requiero_item.get_node("AnimatedSprite").play(obj_nuevo)
	get_parent().call_deferred("add_child",requiero_item)
	requiero_item.global_position = nuevo_item.global_position

func _on_AudioCorazon_finished():
	$AudioCorazon.play(frec_corazon)

func _on_AnimatedSprite_animation_finished():
	if spr_player.animation == "desmayo":$AnimationPlayer.play("desvanecer")
	if spr_player.animation == "levantar":senal_cambiar_estado("quieto")


func _on_AnimationPlayer_animation_finished(_anim_name):
	if get_tree().reload_current_scene() == OK:pass

func apgar_sudor():
	sudor_dere.emitting = false
	sudor_izq.emitting = false
	sudor_dere.amount = 8
	sudor_izq.amount = 8


#	yield(get_tree().create_timer(1),"timeout")
