extends Marker2D

@export var spawn_chance: float = 1.0
var used: bool = false #indique si le marker est déjà servi

func _ready():
	add_to_group("ennemie_position")
