extends Node2D

@onready var cursor = $Cursor 
@onready var tilemap = $TileMapLayer
@onready var turn_label = $CanvasLayer/Label
var round_number: int = 0


var selected_entity: Entity = null
var grid_map: Dictionary = {}

var ally1_scene = preload("res://scenes/ally1.tscn")
var enemy_scene = preload("res://scenes/enemy1.tscn")
var is_player_turn : bool= true



func _ready():
	create_entity(Vector2i(4,3), enemy_scene)
	create_entity(Vector2i(2,4), ally1_scene)
	var i=1
	var j=2
	start_player_turn()
	
	
	
	
func create_entity(spawn_grid_pos: Vector2i, scene_to_spawn: PackedScene):
	var new_entity = scene_to_spawn.instantiate()
	tilemap.add_child(new_entity) 
	new_entity.spawn(spawn_grid_pos, tilemap)
	
	grid_map[spawn_grid_pos] = new_entity
	new_entity.died.connect(_on_entity_died)

func _on_entity_died(dead_pos: Vector2i):
	grid_map.erase(dead_pos)

func get_entity_at(target_grid_pos: Vector2i) -> Entity:
	return grid_map.get(target_grid_pos)

func _process(_delta):
	if Input.is_action_just_pressed("mouse_left"):
		handle_click()
	elif Input.is_action_just_pressed("mouse_right"):
		handle_right_click()
	
	if Input.is_action_just_pressed("space"):
		end_player_turn()
func get_grid_distance(pos1: Vector2i, pos2: Vector2i) -> int:
	var q1 = pos1.x - int(floor(pos1.y / 2.0))
	var r1 = pos1.y
	var q2 = pos2.x - int(floor(pos2.y / 2.0))
	var r2 = pos2.y
	
	return (abs(q1 - q2) + abs(q1 + r1 - q2 - r2) + abs(r1 - r2)) / 2
func handle_click():
	if is_player_turn==false:
		return
	var mouse_pos = tilemap.get_local_mouse_position()
	var grid_pos = tilemap.local_to_map(mouse_pos)
	var clicked_entity = get_entity_at(grid_pos)
	
	if clicked_entity:
		
		print("clicked: ", clicked_entity.name, " | is_player: ", clicked_entity.is_player)
		
		if clicked_entity.is_player:
			selected_entity = clicked_entity
			cursor.modulate = Color.GREEN
	elif selected_entity:
		
		var is_on_map = tilemap.get_cell_source_id(grid_pos) != -1
		var is_empty = get_entity_at(grid_pos) == null
		
		
		var distance = get_grid_distance(selected_entity.grid_pos, grid_pos)
		var in_range = distance <= selected_entity.movement_range
		
		if is_on_map and in_range and is_empty:
			grid_map.erase(selected_entity.grid_pos)
			selected_entity.move_to(grid_pos)
			grid_map[grid_pos] = selected_entity
			selected_entity.movement_range-=distance
			print(selected_entity.movement_range)
			selected_entity = null
			cursor.modulate = Color.WHITE
		else:
			selected_entity = null
			cursor.modulate = Color.WHITE

func handle_right_click():
	if selected_entity==null:
		return 
	var mouse_pos = tilemap.get_local_mouse_position()
	var grid_pos = tilemap.local_to_map(mouse_pos)
	var target = get_entity_at(grid_pos)
	if selected_entity.can_attack==false:
		return 
	if selected_entity and target:
		if target != selected_entity:
			selected_entity.melee_attack(target)
			
			selected_entity=null
			cursor.modulate = Color.YELLOW

func process_enemy_turn():
	
	print("enemy turn")
	
	
	await get_tree().create_timer(5.0).timeout
	
	
	print("pass turn.")
	start_player_turn()
func start_player_turn():
	print("player turn start")
	round_number += 1
	turn_label.text = "Player's Turn - Round " + str(round_number)
	turn_label.modulate = Color.GREEN # Optional: Make it green for the player
	
	print("player turn start")
	is_player_turn = true
	cursor.visible = true
	
	is_player_turn=true
	cursor.visible=true
	for ent in grid_map.values():
		
		if ent.is_player:
			ent.movement_range = ent.max_movement_range
			ent.can_attack = true

	return 0
func end_player_turn():
	turn_label.text = "Enemy's Turn - Round " + str(round_number)
	turn_label.modulate = Color.RED
	selected_entity = null
	cursor.visible = false 
	
	is_player_turn=false
	print("--- TURA WROGA ---")
	
	
	process_enemy_turn()
	return 0
