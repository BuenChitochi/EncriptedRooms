extends CharacterBody2D

@export var speed := 240.0
@export var damage := 10
@export var change_time := 0.5
@export var damage_cooldown := 1.0
@export var shake_strength := 0.5
@export var lifetime := 30.0
@export var despawn_distance := 1500.0

var _direction := Vector2.ZERO
var _timer := 0.0
var _life_left := 0.0
var _can_damage := true
var _despawning := false

@onready var sprite: Sprite2D = $Sprite2D
@onready var particles: CPUParticles2D = $Particles
@onready var hit_sound: AudioStreamPlayer2D = $HitSound
@onready var ambient_sound: AudioStreamPlayer2D = $AmbientSound

func _ready() -> void:
	$Area2D.body_entered.connect(_on_body_entered)
	particles.emitting = true
	ambient_sound.play()
	_life_left = lifetime
	_pick_direction()

func _process(delta: float) -> void:
	if _despawning:
		return
	sprite.position = Vector2(
		randf_range(-shake_strength, shake_strength),
		randf_range(-shake_strength, shake_strength)
	)
	_life_left -= delta
	if _life_left <= 0.0 or _too_far():
		despawn()

func _physics_process(delta: float) -> void:
	if _despawning:
		return
	_timer -= delta
	if _timer <= 0.0 or is_on_wall():
		_pick_direction()
	velocity = _direction * speed
	move_and_slide()

func _too_far() -> bool:
	var player := get_tree().get_first_node_in_group("player")
	if player == null:
		return false
	return global_position.distance_to(player.global_position) > despawn_distance

func despawn() -> void:
	if _despawning:
		return
	_despawning = true
	ambient_sound.stop()
	particles.emitting = false
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	if hit_sound.playing:
		tween.tween_callback(func(): await hit_sound.finished)
	tween.tween_callback(queue_free)

func _on_body_entered(body: Node2D) -> void:
	if _despawning or not _can_damage or not body.is_in_group("player"):
		return
	if body.hidden:
		return
	if _despawning or not _can_damage or not body.is_in_group("player"):
		return
	_can_damage = false
	hit_sound.play()
	body.take_damage(damage)
	await get_tree().create_timer(damage_cooldown).timeout
	_can_damage = true
func _pick_direction() -> void:
	_timer = change_time
	if randf() < 0.25:
		_direction = Vector2.ZERO
	else:
		_direction = Vector2.from_angle(randf() * TAU)
