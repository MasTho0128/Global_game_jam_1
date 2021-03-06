extends KinematicBody2D

export(Vector2) var direccion = Vector2(1, 0)
export(float) var max_velocidad = 30

func _physics_process(delta):
	#global_position += direccion*max_velocidad*delta
	var colision = move_and_collide(direccion*max_velocidad*delta)
	if colision:
		var body = colision.collider
		if body.has_method("actualizar_vida"):
			body.actualizar_vida(1)
#			body.fknockback((colision.position - position).normalized())# lo quito xq ahora lo hace el area del jugador
			

func cambiar_direccion(nueva_direccion, flipH, flipV):
	direccion = nueva_direccion
	$AnimatedSprite.rotation_degrees = rad2deg(direccion.angle())
	$CollisionShape2D.rotation_degrees = rad2deg(direccion.angle())
	if flipH == true:
		if $AnimatedSprite.flip_h == true:
			$AnimatedSprite.flip_h = false
		else:
			$AnimatedSprite.flip_h = true
			
	if flipV == true:
		if $AnimatedSprite.flip_v == true:
			$AnimatedSprite.flip_v = false
		else:
			$AnimatedSprite.flip_v = true
	
