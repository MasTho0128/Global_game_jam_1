extends Area2D


func _on_meta_body_entered(body):
	if body.is_in_group("player"):
		$AnimationPlayer.play("NuevaAnimacion")
		$AnimatedSprite.hide()
		$CollisionShape2D.queue_free()
