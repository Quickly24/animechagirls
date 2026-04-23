class_name Entity extends Node2D

signal died(grid_pos: Vector2i)

@export var max_health: int = 3
@export var max_movement_range: int = 5
@export var movement_range: int=5
@export var melee_attack_damage: int = 1
@export var melee_attack_range: int = 1
@export var is_player: bool = true
@export var is_hard_cover: bool = false
@export var can_be_attacked: bool = true
@export var can_attack: bool = true
var current_health: int
var grid_pos: Vector2i
var board: TileMapLayer

func _ready():
	current_health = max_health
func get_grid_distance(pos1: Vector2i, pos2: Vector2i) -> int:
	var q1 = pos1.x - int(floor(pos1.y / 2.0))
	var r1 = pos1.y
	var q2 = pos2.x - int(floor(pos2.y / 2.0))
	var r2 = pos2.y
	
	return (abs(q1 - q2) + abs(q1 + r1 - q2 - r2) + abs(r1 - r2)) / 2
func spawn(start_grid_pos: Vector2i, tilemap: TileMapLayer):
	board = tilemap
	grid_pos = start_grid_pos
	position = board.map_to_local(grid_pos)

func move_to(new_grid_pos: Vector2i):
	
	
	grid_pos = new_grid_pos
	var target_local = board.map_to_local(grid_pos)
	var tween = create_tween()
	tween.tween_property(self, "position", target_local, 0.25).set_trans(Tween.TRANS_SINE)
	

func melee_attack(target: Entity):
	var diff = (target.grid_pos - grid_pos).abs()
	var distance = get_grid_distance(target.grid_pos, grid_pos)
	
	if distance <= melee_attack_range:
		if target.can_be_attacked:
			var original_pos = position
			var target_pos = target.position
			var mid_point = original_pos.lerp(target_pos, 0.3)
			
			var tween = create_tween()
			tween.tween_property(self, "position", mid_point, 0.1)
			tween.tween_property(self, "position", original_pos, 0.1)
			
			target.take_damage(melee_attack_damage)
			can_attack=false

func take_damage(amount: int):
	var damage_to_deal = amount
	if is_hard_cover and damage_to_deal > 1:
		damage_to_deal = 1
	
	current_health -= damage_to_deal
	flash_red()
	
	if current_health <= 0:
		die()

func flash_red():
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.RED, 0.1)
	tween.tween_property(self, "modulate", Color.WHITE, 0.1)

func die():
	died.emit(grid_pos)
	queue_free()

	
