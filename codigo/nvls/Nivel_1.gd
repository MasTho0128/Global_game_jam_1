extends Node2D
class_name control_nvls

const JUGADOR = preload("res://escenas/jugador/jugador.tscn")
var player

func _ready():
	crear_jugador()
	for h in get_tree().get_nodes_in_group("colores"):h.visible = true

func crear_jugador():
	player = JUGADOR.instance()
	call_deferred("add_child",player)
