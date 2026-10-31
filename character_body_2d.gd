extends CharacterBody2D

const Speed = 300
const multiplication_sprint = 2

@export var max_health: int = 100
var current_health: int

signal stamina_changed(value: float)

@export var max_stamina := 100.0
@export var drain_per_second := 8.0
@export var regen_per_second := 15.0
@export var regen_delay := 0.5
@export var min_stamina_to_sprint := 10.0

var stamina := 100.0
var exhausted := false
var _time_without_sprint := 0.0
var is_hiding := false

func set_hidden(value: bool) -> void:
	is_hiding = value

@onready var sprite: Sprite2D = $Sprite2D
@onready var flashlight: PointLight2D = $PointLight2D

const TILE_SIZE: Vector2 = Vector2(60, 60)

var pos_up: Rect2 = Rect2(0, 62, TILE_SIZE.x, TILE_SIZE.y)
var pos_down: Rect2 = Rect2(0, 0, TILE_SIZE.x, TILE_SIZE.y)
var pos_left: Rect2 = Rect2(62, 62, TILE_SIZE.x, TILE_SIZE.y)
var pos_right: Rect2 = Rect2(60, 0, TILE_SIZE.x, TILE_SIZE.y)

signal health_changed(new_health)
signal died

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("light"):
		flashlight.enabled = not flashlight.enabled

func _ready() -> void:
	current_health = max_health
	stamina = max_stamina
	flashlight.enabled = false
	if sprite:
		sprite.region_enabled = true
		sprite.region_rect = Rect2(0, 0, TILE_SIZE.x, TILE_SIZE.y)

func _physics_process(delta: float) -> void:
	var direction = Input.get_vector("left", "right", "up", "down")

	if direction != Vector2.ZERO:
		if abs(direction.x) > abs(direction.y):
			if direction.x > 0:
				sprite.region_rect = pos_right
			else:
				sprite.region_rect = pos_left
		else:
			if direction.y > 0:
				sprite.region_rect = pos_down
			else:
				sprite.region_rect = pos_up

	var sprinting := Input.is_action_pressed("sprint") and direction != Vector2.ZERO and not exhausted

	if sprinting:
		stamina = maxf(stamina - drain_per_second * delta, 0.0)
		_time_without_sprint = 0.0
		if stamina <= 0.0:
			exhausted = true
	else:
		_time_without_sprint += delta
		if _time_without_sprint >= regen_delay:
			stamina = minf(stamina + regen_per_second * delta, max_stamina)
		if exhausted and stamina >= min_stamina_to_sprint:
			exhausted = false

	stamina_changed.emit(stamina)

	var Speed_now = Speed
	if sprinting:
		Speed_now *= multiplication_sprint

	velocity = direction * Speed_now
	move_and_slide()

func take_damage(amount: int) -> void:
	if current_health <= 0:
		return

	current_health -= amount
	current_health = clamp(current_health, 0, max_health)

	health_changed.emit(current_health)

	if current_health <= 0:
		die()

func heal(amount: int) -> void:
	if current_health <= 0:
		return

	current_health += amount
	current_health = clamp(current_health, 0, max_health)

	health_changed.emit(current_health)

func die() -> void:
	died.emit()
	print("Died")
	queue_free()
