extends CollisionShape2D

@export var facing_left_position : Vector2
@export var facing_right_position : Vector2
@export var player : joueur

func _ready() -> void:
	player.connect("changement_de_direction", on_player_facing_direction_changed)

func on_player_facing_direction_changed(facing_left):
	if facing_left:
		position = facing_left_position
	else:
		position = facing_right_position
