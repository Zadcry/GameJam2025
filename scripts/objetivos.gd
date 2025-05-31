extends Area2D

@onready var sprite = $Sprite

const ALIVE_TEXTURE = preload("res://images/perro_vivo.png")
const DEAD_TEXTURE = preload("res://images/animal_muerto.png")

var impacto_cordura : int
var is_dead = false

func _ready():
	randomize()
	sprite.texture = ALIVE_TEXTURE
	impacto_cordura = randi_range(1, 3)

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if not is_dead:
			is_dead = true
			sprite.modulate = Color.RED
			print("¡Objetivo clickeado! Cordura bajará: ", impacto_cordura)

			# Buscar al personaje principal
			var personaje = get_parent().get_node("personaje_principal")
			if personaje:
				personaje.reducir_cordura(impacto_cordura)
				print("Bajó la cordura")
