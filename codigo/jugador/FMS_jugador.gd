extends Node
class_name FMS_JUGADOR

export (NodePath) var anim

var estado
var animacion_actual
var nueva_animacion

func _ready():
	transition_to("quieto")
	return owner.connect("sig_estado",self,"transition_to")

var lista_estados:Array = [
	"quieto",
	"caminar",
	"saltar",
	"caer",
	"ganar",
	"desmayo",
]

func transition_to(nuevo_estado):
	estado = nuevo_estado
	match estado:
		"quieto":
			nueva_animacion = "quieto"
		"caminar":
			nueva_animacion = "caminar"
		"saltar":
			nueva_animacion = "saltar"
		"caer":
			nueva_animacion = "caer"
		"ganar":
			nueva_animacion = "ganar"
		"desmayo":
			nueva_animacion = "desmayo"

func maquina_estados(_delta):
	if animacion_actual != nueva_animacion:
		animacion_actual = nueva_animacion
		get_node(anim).play(animacion_actual)
	if estado == "quieto" and owner.velocidad.x != 0:
		transition_to("caminar")
		owner.get_node("Audio2DPasos").play()
	if estado == "caminar" and owner.velocidad.x == 0 and owner.is_on_floor():
		transition_to("quieto")
		owner.get_node("Audio2DPasos").stop()
	if estado == "saltar" and owner.is_on_floor():
		transition_to("quieto")
		owner.get_node("Audio2DPasos").stop()
	if estado == "caer" and owner.is_on_floor():
		transition_to("quieto")
		owner.get_node("Audio2DPasos").stop()
	if estado == "saltar" and owner.velocidad.y > 0 and !owner.is_on_floor():
		transition_to("caer")
		owner.get_node("Audio2DPasos").stop()
	if estado == "caminar" and owner.velocidad.y > 0 and !owner.is_on_floor():
		transition_to("caer")
		owner.get_node("Audio2DPasos").stop()
	if estado == "desmayo":
		owner.velocidad = Vector2(0,0)

func _physics_process(delta):
	maquina_estados(delta)
	owner.get_node("estado").text = estado

"""
utilizar owner para referirse al nodo padre de esta escena , no lo hago en el script del jugador
pa que no quede tan copado, esas animaciones de ganar y desmayo son opcionales
aunq el personaje nunca muere pero seria la animacion de desmayarse o algo x el estilo
"""
