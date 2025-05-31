extends Area2D

@onready var sprite = $alive_anim
@onready var dead_sprite = $dead_anim

@export var personaje_principal : CharacterBody2D

const ALIVE_ANIM = preload("res://sprites/enemigoFrente.tres")
const DEAD_ANIM = preload("res://sprites/enemigoFrente.tres")

var impacto_cordura : int
var is_dead = false

func _ready():
	randomize()
	sprite.play()
	impacto_cordura = randi_range(1, 3)
	dead_sprite.visible = false

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if not is_dead:
			is_dead = true
			sprite.visible = false
			dead_sprite.visible = true
			dead_sprite.modulate = Color.RED
			print("¡Disparo! Cordura bajará: ", impacto_cordura)

			# Buscar al personaje principal
			if personaje_principal:
				personaje_principal.reducir_cordura(impacto_cordura)
				personaje_principal.iniciar_flash()
				print("Bajó la cordura")
