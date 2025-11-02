extends CharacterBody2D

#paramètre slime
var vitesse : float = 0.9
var vie : int = 40
var degat : int = 5
var stop_dist : int = 30
enum Etats {INACTIF, DEPLACEMENT, ATTAQUE, BLESSE, MORT}
enum Directions {GAUCHE, DROITE}

#signal de l'ennemie
signal changement_de_direction(face_gauche: bool)
signal mise_a_jour_vie_ennemie(nb_vie: int)

#initialisation ennemie
var etat : Etats = Etats.INACTIF
var directions : Directions = Directions.DROITE
var mouvement : Vector2
var player : Node = null
var player_chase = false
var player_attackable = false
var attackCoolDown = false
var IsStun = false
var IsInvincible = false

func _ready() -> void:
	add_to_group('enemie')
	emit_signal("mise_a_jour_vie_ennemie", vie)
	var players = get_tree().get_nodes_in_group('joueur')
	if players.size() > 0:
		player = players[0]

func _physics_process(_delta):
	mise_a_jour()
	animation()
	if not IsStun:
		mouvement_slime()
		attack()
	

func mise_a_jour():
	if vie <= 0 :
		IsInvincible = true
		etat = Etats.MORT
	emit_signal("changement_de_direction", directions == Directions.GAUCHE)
	emit_signal("mise_a_jour_vie_ennemie", vie)

func mouvement_slime():
	if player_chase == true :
		mouvement = player.position - position
		if mouvement.length()>stop_dist:
			etat = Etats.DEPLACEMENT
			if abs(mouvement.x) >= abs(mouvement.y):
				position += (Vector2(sign(mouvement.x),0))*vitesse
			else:
				position += (Vector2(0,sign(mouvement.y)))*vitesse
			if(player.position.x - position.x) < 0:
				directions = Directions.GAUCHE
			else:
				directions = Directions.DROITE
	if player_chase == false:
		etat = Etats.INACTIF
	move_and_slide()

func vie_update(amount : int) -> void:
	vie += amount
	print("vie slime ", vie, "PV")

func attack():
	if player_attackable and not attackCoolDown:
		etat = Etats.ATTAQUE
		mouvement = Vector2.ZERO
		player.hit(degat)
		attackCoolDown = true
		$Attackcooldown.start()

func hit(amount : int):
	if not IsInvincible:
		vie_update(-amount)
		IsStun = true
		etat = Etats.BLESSE
		$Stun.start()
		IsInvincible = true
		$Frame_invincible.start()

func animation():
	if directions == Directions.GAUCHE:
		$AnimatedSprite2D.flip_h = true
	else:
		$AnimatedSprite2D.flip_h = false
	if etat == Etats.INACTIF:
		$AnimatedSprite2D.play("idle")
	if etat == Etats.DEPLACEMENT:
		$AnimatedSprite2D.play("movement")
	if etat == Etats.ATTAQUE:
		$AnimatedSprite2D.play("attack")
	if etat == Etats.BLESSE:
		$AnimatedSprite2D.play("damage")
	if etat == Etats.MORT:
		$AnimatedSprite2D.play("death")
		set_physics_process(false) # évite qu'il bouge
		$CollisionShape2D.disabled = true  # désactive sa collision
		$Mort.start()

func _on_animation_finished() -> void:
	etat = Etats.INACTIF

func _on_zone_attack_body_entered(body: Node2D) -> void:
	if body is joueur:
		player_attackable = true

func _on_zone_attack_body_exited(body: Node2D) -> void:
	if body is joueur:
		player_attackable = false

func _on_zone_chasse_body_entered(body: Node2D) -> void:
	if body is joueur:
		player_chase = true

func _on_zone_chasse_body_exited(body: Node2D) -> void:
	if body is joueur:
		player_chase = false

func _on_attackcooldown_timeout() -> void:
	attackCoolDown = false

func _on_stun_timeout() -> void:
	IsStun = false

func _on_mort_timeout() -> void:
	Global.add_score(1) #ajoute le score
	queue_free()

func _on_frame_invincible_timeout() -> void:
	IsInvincible = false
