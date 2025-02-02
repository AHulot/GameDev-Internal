extends CharacterBody2D

@export var GRAVITY : int = 10
@export var SPEED : int = 75
@export var speed_div : int = 60
@export var MAX_HEALTH : int = 10

@onready var player = get_node("/root/World/Player")
@onready var blocks = get_node("/root/World/TileMap")

var health
var player_chase = false
var can_hit = true
var state
var enemy_id

enum { WANDER, CHASE, HIT }


func _ready():
	health = MAX_HEALTH
	state = WANDER
	
	enemy_id = global_position
	
	$AnimationPlayer.play("move")
	
	set_meta("Enemy", 1)
	set_meta("Flying", 2)


func _physics_process(_delta):
	match state:
		WANDER : wander_state()
		CHASE : chase_state()
		HIT : hit_state()
	
	if is_instance_valid(player) and player.is_alive:
		# If player is in range, attack or chase them.
		if player in $BodyArea.get_overlapping_bodies():
			attack_player()
		elif player in $DetectRange.get_overlapping_bodies():
			state = CHASE
	else:
		# Otherwise stay in normal state.
		state = WANDER
	
	var health_comp = $HealthComponent
	health_comp.update_battlehealth()


func wander_state():  # Idle / Waiting
	$AnimationPlayer.play("move")
	
	if $Ray_V.is_colliding():  # "Rest" upside down. 
		$Sprite2D.flip_v = true
		$AnimationPlayer.play("RESET")
	else:  # Go to nearby ceiling if in range.
		if is_instance_valid(blocks) and blocks in $DetectRange.get_overlapping_bodies():
			if blocks.position.y > position.y and position.distance_to(blocks.position) < 250:
				position.y += (position.y - blocks.position.y) / speed_div
				
		$Sprite2D.flip_v = false
		$AnimationPlayer.play("move")
	

func chase_state():  # Chase Player
	
	# Follow the player while true.
	if player_chase:
		$Sprite2D.flip_v = false
		$AnimationPlayer.play("move")
		
		position += (player.position - position) / speed_div
	
	else:  # Return to normal state.
		state = WANDER


func hit_state():  # Hit
	if state != HIT:
		state = HIT
	
	if $HitRecovery.is_stopped():
		$HitRecovery.start()
	
	$AnimationPlayer.stop()
	$AnimationPlayer.play("hit")


func attack_player():  # Attack Player
	if can_hit:  # Start cooldown and attack if can hit.
		var hitbox = get_node("/root/World/Player/HitboxComponent")
		var attack = Attack.new()
		
		attack.attack_damage = 10
		hitbox.damage(attack)
		
		can_hit = false

		$AttackCooldown.start()


func _on_detect_range_body_entered(body):
	if body == player:
		state = CHASE
		
		player_chase = true


func _on_detect_range_body_exited(body):
	if body == player:
		state = WANDER
		player_chase = false


func _on_hit_recovery_timeout():
	$Sprite2D.flip_v = false
	$AnimationPlayer.play("move")
	
	if player in $BodyArea.get_overlapping_bodies():
		attack_player()
	else:
		player_chase = true
		state = CHASE


func _on_body_area_body_entered(body):  # Slow down when moving through objects.
	if body != player:
		speed_div += 100


func _on_body_area_body_exited(body):  # Speed up when exiting objects.
	if body != player:
		speed_div -= 100


func _on_attack_cooldown_timeout():
	can_hit = true
