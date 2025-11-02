extends Label

var player : joueur

func _ready() -> void:
	var players = get_tree().get_nodes_in_group('joueur')
	if players.size() > 0:
		player = players[0]
	player.connect("mise_a_jour_vie_joueur", set_life)
	

func set_life(life: int):
	text = str(life)
	
