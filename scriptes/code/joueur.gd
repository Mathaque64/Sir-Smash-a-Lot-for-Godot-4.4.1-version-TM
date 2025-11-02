extends CharacterBody2D
class_name joueur


#paramètre joueur
var vitesse : int = 100
var max_vie : int = 150
var vie : int = 100
var regen_amount: int = 10
var degat : int = 10
var score : int = 0
enum Etats {INACTIF, DEPLACEMENT, ATTAQUE, EPUISE, BLESSE, MORT}
enum Directions {GAUCHE, DROIT}

#signaux joueur
signal changement_de_direction(face_gauche: bool)
signal mise_a_jour_vie_joueur(nb_vie: int)

#initialisation joueur
var etat : Etats = Etats.INACTIF
var direction : Directions = Directions.DROIT
var mouvement : Vector2
var IsInvincible = false
var IsStun = false
var ennemis = null # initialisation pour la function trouver_ennemis
func _ready() -> void:
	add_to_group('joueur') #pour que les ennemis puisse facilement récuperer le joueur
	emit_signal('mise_a_jour_vie_joueur', vie)

func _physics_process(_delta: float) -> void:
	mise_a_jour()
	trouver_ennemis()
	mouvement_joueur()
	attaque()
	animation()
	
func mise_a_jour():
	if vie <= 0:
		etat = Etats.MORT
	emit_signal("changement_de_direction", direction == Directions.GAUCHE) #mise à jour de la direction du joueur
	emit_signal("mise_a_jour_vie_joueur", vie)

func trouver_ennemis():
	if etat != Etats.MORT:
		ennemis = get_tree().get_nodes_in_group('ennemis')

func mouvement_joueur():
	#faire que si dans ces états là
	if etat in [Etats.INACTIF, Etats.DEPLACEMENT]:
		#pour le déplacement horizontal
		if Input.is_action_pressed("ui_left") and not Input.is_action_pressed("ui_right"):
			mouvement.x = -1
			direction = Directions.GAUCHE
		elif Input.is_action_pressed("ui_right") and not Input.is_action_pressed("ui_left"):
			mouvement.x = 1
			direction = Directions.DROIT
		else:
			mouvement.x = 0
			
		#pour le déplacement vertical
		if Input.is_action_pressed("ui_up") and not Input.is_action_pressed("ui_down"):
			mouvement.y = -1
		elif Input.is_action_pressed("ui_down") and not Input.is_action_pressed("ui_up"):
			mouvement.y = 1
		else:
			mouvement.y = 0
		
		#si déplacement sur les deux axe en même temps réduire la distance parcouru pour pas aller trop vite
		if mouvement.x and mouvement.y:
			mouvement = mouvement/sqrt(2)
		
		#changement d'états
		if mouvement.x or mouvement.y:
			etat = Etats.DEPLACEMENT
		else:
			etat = Etats.INACTIF
			
		velocity = mouvement * vitesse 
		move_and_slide()
		
func attaque():
	if etat in [Etats.INACTIF, Etats.DEPLACEMENT] and Input.is_action_just_pressed("attack"):
		etat = Etats.ATTAQUE
	if etat == Etats.ATTAQUE:
		for bodies in $AttackRange.get_overlapping_bodies():
			if bodies.is_in_group("enemie"):
				bodies.call("hit", degat)

func animation():
	$AnimatedSprite2D.flip_h = direction == Directions.GAUCHE
	if etat == Etats.INACTIF:
		$AnimatedSprite2D.play('idle')
	if etat == Etats.DEPLACEMENT:
		$AnimatedSprite2D.play('walk')
	if etat == Etats.ATTAQUE:
		$AnimatedSprite2D.play("attack")
	if etat == Etats.BLESSE:
		$AnimatedSprite2D.play("damage")
	if etat == Etats.MORT:
		$AnimatedSprite2D.play("death")
		set_physics_process(false)
		$CollisionShape2D.disabled = true
		$Mort.start()

func update_health(amount : int) -> void:
	vie += amount
	print("joueur a perdu ", amount, "PV")
	if vie < max_vie:
		$Regen.start()

func hit(amount : int) -> void:
	if not IsInvincible:
		update_health(-amount)
		IsStun = true
		etat = Etats.BLESSE
		$Stun.start()
		IsInvincible = true
		$Frame_invincible.start()

func _on_animated_sprite_2d_animation_finished() -> void:
	etat = Etats.INACTIF

func _on_frame_invincible_timeout() -> void:
	IsInvincible = false

func _on_stun_timeout() -> void:
	IsStun = false
	etat = Etats.INACTIF

func _on_regen_timeout() -> void:
	if vie < max_vie:
		vie += regen_amount
		if vie > max_vie:
			vie = max_vie
	else:
		pass

func _on_mort_timeout() -> void:
	self.queue_free()
	get_tree().change_scene_to_file("res://scriptes/scènes/main_menu.tscn")
