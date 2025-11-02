extends MarginContainer


func _on_label_continue_pressed() -> void:
	Global.score = 0
	get_tree().change_scene_to_file("res://scriptes/scènes/monde.tscn")

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		get_tree().quit()

func _on_label_quitter_pressed() -> void:
	get_tree().quit()
