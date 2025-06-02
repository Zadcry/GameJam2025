extends Area2D

@onready var sprite = $Sprite2D
@export var personaje_principal: CharacterBody2D

const ALIVE_TEXTURE = preload("res://sprites/Aliado1.png")
const DEAD_TEXTURE = preload("res://sprites/AliadoMuerto.png")
const ENEMY_TEXTURE = preload("res://sprites/EnemigoIdle.png")

var impacto_cordura : int
var is_dead = false
var alucinando = false

func _ready():
	randomize()
	sprite.texture = ALIVE_TEXTURE
	impacto_cordura = randi_range(7, 11)
	iniciar_alucinaciones_periodicas()

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and GLOBAL.scoped:
		if not is_dead:
			is_dead = true
			sprite.texture = DEAD_TEXTURE
			print("¡Fuego amigo! Cordura bajará: ", impacto_cordura)

			if personaje_principal:
				personaje_principal.reducir_cordura(impacto_cordura)
				personaje_principal.iniciar_flash()

func iniciar_alucinaciones_periodicas():
	await get_tree().create_timer(randf_range(1.0, 2.0)).timeout
	while true:
		if not is_dead and not alucinando:
			var probabilidad = obtener_probabilidad_alucinacion()
			if randi() % 100 < probabilidad:
				await alucinar()
		var intervalo = obtener_intervalo_alucinacion()
		await get_tree().create_timer(randf_range(intervalo.x, intervalo.y)).timeout

func obtener_probabilidad_alucinacion() -> int:
	var cordura = GLOBAL.cordura
	if cordura <= 0:
		return 100
	elif cordura <= 10:
		return 80
	elif cordura <= 25:
		return 55
	elif cordura <= 40:
		return 35
	elif cordura <= 60:
		return 15
	else:
		return 0

func obtener_intervalo_alucinacion() -> Vector2:
	var cordura = GLOBAL.cordura
	if cordura <= 0:
		return Vector2(0.8, 1.5)
	elif cordura <= 10:
		return Vector2(1.5, 2.5)
	elif cordura <= 25:
		return Vector2(2.5, 4.0)
	elif cordura <= 40:
		return Vector2(3.5, 5.0)
	elif cordura <= 60:
		return Vector2(4.5, 6.0)
	else:
		return Vector2(6.5, 7.0)

func alucinar():
	alucinando = true
	var textura_original = sprite.texture
	sprite.texture = ENEMY_TEXTURE
	await get_tree().create_timer(1.2).timeout
	sprite.texture = textura_original
	alucinando = false
