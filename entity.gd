class_name Entity extends Node2D

@export var max_health: int = 3
@export var movement_range: int = 2
@export var attack_damage: int = 1
@export var attack_range: int = 1
@export var is_player: bool = true
@export var is_hard_cover: bool = false
@export var can_be_attacked: bool = true

var current_health: int
var grid_pos: Vector2i
var board: TileMapLayer

func _ready():
	current_health = max_health

func spawn(start_grid_pos: Vector2i, tilemap: TileMapLayer):
	board = tilemap
	grid_pos = start_grid_pos
	var local_center = board.map_to_local(grid_pos)
	position = local_center

func move_to(new_grid_pos: Vector2i):
	grid_pos = new_grid_pos
	var target_local = board.map_to_local(grid_pos)
	var tween = create_tween()
	tween.tween_property(self, "position", target_local, 0.25).set_trans(Tween.TRANS_SINE)

func can_move_to(target_grid_pos: Vector2i) -> bool:
	var diff = (target_grid_pos - grid_pos).abs()
	var distance = diff.x + diff.y
	return distance <= movement_range

func attack(target: Entity):
	var diff = (target.grid_pos - grid_pos).abs()
	var distance = diff.x + diff.y
	
	if distance <= attack_range:
		if target.can_be_attacked:
			var original_pos = position
			var target_pos = target.position
			var mid_point = original_pos.lerp(target_pos, 0.3)
			
			var tween = create_tween()
			tween.tween_property(self, "position", mid_point, 0.1)
			tween.tween_property(self, "position", original_pos, 0.1)
			
			target.take_damage(attack_damage)

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
	queue_free()
