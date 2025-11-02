extends Area2D

@export var target_room_index: int = -1
@export var target_marker_name: String = "Entrance"

var player_in_area: Node2D = null
var room_manager: Node = null

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))
	
	# On récupère le gestionnaire de salles automatiquement
	room_manager = get_tree().get_root().get_node("monde/DungeonManager")


func _process(_delta):
	# si le joueur est dans la zone et appuie sur la touche d’interaction
	if player_in_area and Input.is_action_just_pressed("interact"):
		teleport_player()


func _on_body_entered(body):
	if body.is_in_group("joueur"):
		player_in_area = body
		print("Appuyez sur Q pour utiliser le téléporteur.")


func _on_body_exited(body):
	if body == player_in_area:
		player_in_area = null
		print("Vous avez quitté la zone du téléporteur.")


func teleport_player():
	if room_manager == null:
		room_manager = get_tree().current_scene.get_node_or_null("DungeonManager")
	if target_room_index == -1:
	# Essaye de deviner la salle précédente automatiquement
		var this_room = get_parent()
		if room_manager and this_room in room_manager.active_rooms:
			var index = room_manager.active_rooms.find(this_room)
			if index > 0:
				target_room_index = index - 1
	# Si malgré tout on n’a pas trouvé, on annule
	if target_room_index == -1 or room_manager == null:
		#print("Erreur : pas de cible ou de room_manager.")
		return
	
	var rooms = room_manager.active_rooms
	
	if target_room_index >= 0 and target_room_index < rooms.size():
		var target_room = rooms[target_room_index]
		var marker = target_room.get_node(target_marker_name)
		player_in_area.global_position = marker.global_position
		#print("Téléporté vers :", target_room.name)
	else:
		#print("Indice de salle invalide :", target_room_index)
		pass
