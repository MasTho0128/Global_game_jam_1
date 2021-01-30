tool
extends Area2D
export (String,"vacio","linterna","tijeras")var item:String

func _physics_process(_delta):
	$AnimatedSprite.play(item)

func _ready():
	$AnimatedSprite.play(item)

func _on_Items_body_entered(body):
	if body.is_in_group("player"):
		match item:
			"linterna":
				body.tiene_linterna = true
			"tijeras":
				body.tiene_tijeras = true
		queue_free()
