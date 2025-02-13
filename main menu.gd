extends Control



func _on_Start_pressed():
	get_tree().change_scene("res://lvl 01.tscn")

func _on_quit_pressed():
	get_tree().quit()
