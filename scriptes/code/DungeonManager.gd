extends Node2D

@export var player_path: NodePath
var player: Node2D
@export var enemy_scene: Array [PackedScene] = [
	preload("res://scriptes/scènes/orc.tscn"),
	preload("res://scriptes/scènes/squelette_armure.tscn"),
	preload("res://scriptes/scènes/slime.tscn")
]
@export var number_of_enemies: int = 4
@export var increase_amount: int = 1

var room_scenes = [
	preload("res://scriptes/scènes/rooms/RoomBasic.tscn"),
	preload("res://scriptes/scènes/rooms/RoomBasic2.tscn"),
	preload("res://scriptes/scènes/rooms/RoomBasic3.tscn"),
	preload("res://scriptes/scènes/rooms/RoomBasic4.tscn")
]

var starter_room = preload("res://scriptes/scènes/rooms/starterRoom.tscn")
var active_rooms: Array = []

func _ready():
	player = get_node(player_path) as Node2D
	
	# génération initiale
	var first_room = spawn_room(null)
	var _second_room = spawn_room(first_room)
	var _third_room = spawn_room(active_rooms[-1])



func spawn_room(previous_room: Node2D):
	if previous_room == null:
		var starter = starter_room.instantiate() as Node2D
		add_child(starter)
		starter.position = Vector2.ZERO
		active_rooms.append(starter)
		starter.z_index = int(clamp(starter.position.y, 0, 10000))
		starter.add_to_group("rooms")
		active_rooms.append(starter)
		return starter
	else:
		var room_scene = room_scenes.pick_random()
		var room = room_scene.instantiate() as Node2D
		add_child(room)
		var prev_exit = previous_room.get_node("Exit").global_position
		var new_entrance = room.get_node("Entrance").position
		room.position = prev_exit - new_entrance
		room.z_index = int(clamp(room.position.y, 0, 10000))
		room.add_to_group("rooms")
		active_rooms.append(room)
		
		# Spawn les ennemis seulement dans la nouvelle pièce
		_spawn_enemies_in_room(room)
		
		return room

func _update_teleporters():
	# Parcours toutes les salles sauf la starter (indice 0)
	for i in range(1, active_rooms.size()):
		var room = active_rooms[i]
		var teleporter = room.get_node_or_null("point_téléportation")
		if teleporter:
			if i < active_rooms.size() - 1:
				# Salle suivante existante
				teleporter.target_room_index = i + 1
				#print("Téléporteur de", room.name, "-> vers salle index", teleporter.target_room_index)
			else:
				# Dernière salle : désactive ou met à -1
				teleporter.target_room_index = -1
				#print("Téléporteur de", room.name, "-> pas de salle suivante")

func _process(_delta):
	update_rooms()
	# Mise à jour des téléporteurs après génération
	_update_teleporters()


func update_rooms():
	if active_rooms.is_empty():
		return
	
	var current_room = get_current_room()
	
	while active_rooms.find(current_room) > active_rooms.size() - 3:
		spawn_room(active_rooms[-1])
	
	for r in active_rooms.duplicate():
		if r.global_position.y - player.position.y > 3000:
			r.queue_free()
			active_rooms.erase(r)


func get_current_room():
	for room in active_rooms:
		var entrance = room.get_node("Entrance").global_position
		var exit = room.get_node("Exit").global_position
		if player.position.y <= entrance.y and player.position.y >= exit.y:
			return room
	return active_rooms[0]


# spawn uniquement dans une pièce donnée
func _spawn_enemies_in_room(room: Node2D):
	if enemy_scene == null:
		#print("Aucun ennemi assigné à 'enemy_scene'")
		return
	
	# récupérer les markers dans la pièce
	var spawn_points = room.get_tree().get_nodes_in_group("ennemie_position")
	
	if spawn_points.is_empty():
		#print("Aucun point de spawn trouvé dans la pièce : ", room.name)
		return
	
	# Shuffle pour éviter de toujours prendre les mêmes markers
	spawn_points.shuffle()
	
	var spawned_count := 0
	
	for marker in spawn_points:
		# ignorer les markers déjà utilisés
		if marker.used:
			continue
		# probabilité de spawn
		if randf() > marker.spawn_chance:
			continue
		# instancier l’ennemi
		var chosen_enemy_scene = enemy_scene.pick_random()
		var enemy = chosen_enemy_scene.instantiate()
		add_child(enemy)
		enemy.global_position = marker.global_position
		# marquer le marker comme utilisé
		marker.used = true
		spawned_count += 1
		# stopper quand on atteint le nombre voulu
		if spawned_count >= number_of_enemies:
			break

func reset_room_spawns(room: Node2D):
	for marker in room.get_tree().get_nodes_in_group("ennemie_position"):
		if marker.has_variable("used"):
			marker.used = false

func _on_difficulté_timeout() -> void:
	if number_of_enemies <= 9:
		number_of_enemies += increase_amount
		print("Nombre d'ennemis augmenté à :", number_of_enemies)
	# spawn dans la dernière pièce active
	if not active_rooms.is_empty():
		_spawn_enemies_in_room(active_rooms[-1])
