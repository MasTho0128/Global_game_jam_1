extends Node2D

func _ready():
	OS.center_window()


func _on_AnimationPlayer_animation_finished(anim_name):
	if get_tree().change_scene("res://escenas/nvls/Nivel_1.tscn") == OK:pass
