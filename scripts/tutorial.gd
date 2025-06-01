extends Node2D

@onready var pato1 : Area2D = $Animales
@onready var pato2 : Area2D = $Animales2

var PATO1_SPEED : float = randf_range(85, 105)
var PATO2_SPEED_X : float = randf_range(55, 75)
var PATO2_SPEED_Y : float = randf_range(40, 60)

const SCREEN_LIMIT_X = 1280
const SCREEN_LIMIT_Y = 0
const RESET_POSITION_X = -100
const RESET_POSITION_Y = 720

func _ready() -> void:
	var anim1 = pato1.get_node_or_null("AnimatedSprite2D")
	if anim1:
		anim1.play() 
		anim1.speed_scale = 1.5

	var anim2 = pato2.get_node_or_null("AnimatedSprite2D")
	if anim2:
		anim2.play()
		anim2.speed_scale = 1.7


func _process(delta: float) -> void:
	pato1.position.x += PATO1_SPEED * delta
	if pato1.position.x > SCREEN_LIMIT_X:
		pato1.position.x = RESET_POSITION_X

	# Movimiento diagonal pato2
	if pato2:
		pato2.position.x += PATO2_SPEED_X * delta
		pato2.position.y -= PATO2_SPEED_Y * delta


	if pato2.position.x > SCREEN_LIMIT_X or pato2.position.y < SCREEN_LIMIT_Y:
		pato2.position.x = RESET_POSITION_X
		pato2.position.y = RESET_POSITION_Y
