extends Area2D

@onready var sprite = $Sprite2D

@export var personaje_principal: CharacterBody2D

const ALIVE_TEXTURE = preload("res://sprites/Aliado1.png")
const DEAD_TEXTURE = preload("res://sprites/AliadoMuerto.png")

var impacto_cordura : int
var is_dead = false


func _ready():
	randomize()
	sprite.texture = ALIVE_TEXTURE
	impacto_cordura = randi_range(5, 10)

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and GLOBAL.scoped:
		if not is_dead:
			is_dead = true
			sprite.texture = DEAD_TEXTURE
			sprite.modulate = Color.RED
			print("¡Fuego amigo! Cordura bajará: ", impacto_cordura)

			# Buscar al personaje principal
			if personaje_principal:
				personaje_principal.reducir_cordura(impacto_cordura)
				personaje_principal.iniciar_flash()
				print("Bajó la cordura")
