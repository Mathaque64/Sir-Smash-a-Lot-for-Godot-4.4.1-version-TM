extends Node2D

@onready var music1 = $Music1
@onready var music2 = $Music2
var current_track = 1

func _ready():
	# Démarrer la première musique
	music1.play()
	# Connecter le signal de fin de lecture
	music1.finished.connect(_on_music_finished)
	music2.finished.connect(_on_music_finished)

func _on_music_finished():
	if current_track == 1:
		music2.play()
		current_track = 2
	else:
		music1.play()
		current_track = 1
