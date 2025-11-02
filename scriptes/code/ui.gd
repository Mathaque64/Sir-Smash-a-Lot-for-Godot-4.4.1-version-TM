extends CanvasLayer

@onready var life_label = $Control/life
@onready var status_label = $Control/statutpartie
@onready var restart_button = $Control/RestartButton

var player : joueur

func _ready() -> void:
	var players = get_tree().get_nodes_in_group('joueur')
	if players.size() > 0:
		player = players[0]
	player.connect("mise_a_jour_vie_joueur", set_life)



func set_life (life: int):
	life_label.text = str(life)

func show_win_screen():
	status_label.text = "Tu as gagné"
	status_label.visible = true
	restart_button.visible = true

func show_lose_screen():
	status_label.text = "Tu es mort"
	status_label.visible = true
	restart_button.visible = true

func _on_restart_button_pressed() -> void:
	print("restart")
	get_tree().reload_current_scene()
