extends Area2D

@onready var sprite = $alive_anim
@onready var dead_sprite = $dead_anim
@onready var shooting_sprite = $shooting_anim
@onready var shooting_sfx = $shooting_sfx

@export var personaje_principal : CharacterBody2D

const ALIVE_ANIM = preload("res://sprites/enemigoFrente.tres")
const DEAD_ANIM = preload("res://sprites/EnemigoMuerto.png")
const SHOOTING_ANIM = preload("res://sprites/enemigoDisparando.tres")

var impacto_cordura : int
var is_dead = false
var is_shooting = false

func _process(_delta: float) -> void:
	if is_shooting:
		sprite.visible = false
		shooting_sprite.visible = true
		shooting_sprite.play()

	if is_dead: 
		sprite.visible = false
		shooting_sprite.visible = false
		dead_sprite.visible = true
		is_shooting = false

func _ready():
	randomize()
	sprite.play()
	dead_sprite.texture = DEAD_ANIM
	impacto_cordura = randi_range(1, 3)
	dead_sprite.visible = false
	shooting_sprite.visible = false

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and GLOBAL.scoped:
		if not is_dead:
			is_dead = true
			sprite.visible = false
			shooting_sprite.visible = false
			dead_sprite.visible = true
			print("¡Disparo! Cordura bajará: ", impacto_cordura)

			# Buscar al personaje principal
			if personaje_principal:
				personaje_principal.reducir_cordura(impacto_cordura)
				personaje_principal.iniciar_flash()
				print("Bajó la cordura")
