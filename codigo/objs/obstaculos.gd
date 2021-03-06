tool
extends KinematicBody2D
export (String,"nada","puas") var obj
var usar = true
var nombre_anim = ""
var sonido = null
var gravedad = 200
var velocidad = Vector2()
var pos_ini

func _physics_process(delta):
	if usar:$AnimatedSprite.play(obj)
	if !Engine.editor_hint:
		velocidad.y += gravedad * delta
		velocidad = move_and_slide(velocidad*Vector2.DOWN)
		global_position.x = pos_ini.x
		if $RayCast2D.is_colliding():
			set_physics_process(false)

func _ready():
	if !Engine.editor_hint:
		pos_ini = global_position
		match obj:
			"puas":nombre_anim = "cizallas"
			"otro item":nombre_anim = "nombre de la animacion "

func _on_Area2D_body_entered(body)->void:
	var anim:String = ""
	if body.is_in_group("player"):
		usar = false
		match obj:
			"puas":
				if body.tiene_tijeras:
					anim = "dest_puas"
					sonido = $audios/AudioPuas
					$CollisionShape2D.queue_free()
					$Area2D.queue_free()
		if anim == "":
			usar = true
			body.generar_item(nombre_anim)
			$Area2D/CollisionShape2D.set_deferred("disabled",true)
			$Timer.start()
	if anim != "":
		$AnimatedSprite.play(anim)
	if sonido != null:
		sonido.play()
		


func _on_Timer_timeout():
	if $Area2D != null and is_instance_valid($Area2D):$Area2D/CollisionShape2D.set_deferred("disabled",false)
