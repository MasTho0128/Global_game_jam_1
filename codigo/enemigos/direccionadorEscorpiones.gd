extends Area2D

export(Vector2) var direccion = Vector2(1, 0)
export(bool) var flipH = false
export(bool) var flipV = false



func _on_direccionadorEscorpiones_body_entered(body):
	if body.has_method("cambiar_direccion"):
		body.cambiar_direccion(direccion, flipH, flipV)
