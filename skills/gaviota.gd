extends Node2D
class_name Gaviota

var jugador
var radio
var angulo_inicial
var velocidad = 2.0
var tiempo = 0.0
var posicion_anterior = Vector2.ZERO

@onready var animacion = $AnimatedSprite2D
@onready var timer = $Timer

func _ready():
	animacion.play("fly")
	timer.start()
	add_to_group("Gaviotas")
	posicion_anterior = global_position
	
func iniciar(_jugador, i, total, _radio):
	jugador = _jugador
	radio = _radio
	angulo_inicial = (TAU / total) * i
	
	 

func _process(delta):
	tiempo += delta * velocidad
	var angulo = angulo_inicial + tiempo
	var posicion = jugador.global_position + Vector2(cos(angulo), sin(angulo)) * radio
	
	var movimiento = posicion - posicion_anterior
	
	if movimiento.length() > 0.1:
		rotation = movimiento.angle()
	
	
	global_position = posicion
	posicion_anterior = posicion


func _on_timer_timeout() -> void:
	queue_free()
