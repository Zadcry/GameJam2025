extends Node2D

@onready var personaje : CharacterBody2D = $PersonajePrincipal
@onready var aliado1 : Area2D = $AliadosInocentes
@onready var enemigos : Node = $Enemigos

const enemy_grown_speed : float = 0.015
const enemy_move_speed : float = 15
const MAX_POSITION_Y = 325.0
const MAX_SCALE = 2.0
const MAX_COLLIDER_EXTENTS = Vector2(64, 64)
const MAX_COLLIDER_RADIUS = 64.0

func _process(delta: float) -> void:
	for enemigo in enemigos.get_children():
		if enemigo is Area2D:
			acercar_personaje(enemigo, delta)

func acercar_personaje(personaje: Area2D, delta):
	# Movimiento hacia abajo con límite
	if personaje.position.y < MAX_POSITION_Y:
		personaje.position.y += enemy_move_speed * delta
		if personaje.position.y > MAX_POSITION_Y:
			personaje.position.y = MAX_POSITION_Y

	# Crecimiento visual con límite
	if personaje.scale.x < MAX_SCALE - 0.01 or personaje.scale.y < MAX_SCALE - 0.01:
		var nueva_escala = personaje.scale + Vector2.ONE * enemy_grown_speed * delta
		nueva_escala.x = min(nueva_escala.x, MAX_SCALE)
		nueva_escala.y = min(nueva_escala.y, MAX_SCALE)
		personaje.scale = nueva_escala
	else:
		personaje.scale = Vector2(MAX_SCALE, MAX_SCALE)  # Forzar escala exacta al límite

	# Crecimiento del collider con límite
	var collider = personaje.get_node_or_null("CollisionShape2D")
	if collider and collider.shape:
		var shape = collider.shape
		if shape is RectangleShape2D:
			if shape.extents.x < MAX_COLLIDER_EXTENTS.x - 0.1 or shape.extents.y < MAX_COLLIDER_EXTENTS.y - 0.1:
				var new_extents = shape.extents + Vector2.ONE * enemy_grown_speed * delta * 10
				new_extents.x = min(new_extents.x, MAX_COLLIDER_EXTENTS.x)
				new_extents.y = min(new_extents.y, MAX_COLLIDER_EXTENTS.y)
				shape.extents = new_extents
			else:
				shape.extents = MAX_COLLIDER_EXTENTS  # Forzar extents exactos al límite
		elif shape is CircleShape2D:
			if shape.radius < MAX_COLLIDER_RADIUS - 0.1:
				var new_radius = shape.radius + enemy_grown_speed * delta * 10
				shape.radius = min(new_radius, MAX_COLLIDER_RADIUS)
			else:
				shape.radius = MAX_COLLIDER_RADIUS  # Forzar radio exacto al límite
