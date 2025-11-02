extends Node

var score: int = 0

func add_score(amount: int):
	score += amount
	# Émettre un signal pour prévenir l'UI
	score_changed.emit(score)

signal score_changed(new_score)
