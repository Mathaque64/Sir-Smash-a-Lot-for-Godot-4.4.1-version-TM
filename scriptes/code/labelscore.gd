extends Label

func _ready():
	text = "%d" % Global.score
	Global.score_changed.connect(_on_score_changed)

func _on_score_changed(new_score: int):
	text = "%d" % new_score
