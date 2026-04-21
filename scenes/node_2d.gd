extends Node2D

@onready var cursor = $Cursor 
@onready var tilemap = $TileMapLayer

var selected_entity: Entity = null
var entity_scene = preload("res://scenes/entity.tscn")

func _ready():
	create_entity(Vector2i(2, 2))
	create_entity(Vector2i(2, 4))

func _process(_delta):
	if Input.is_action_just_pressed("mouse_left"):
		handle_click()
	elif Input.is_action_just_pressed("mouse_right"):
		handle_right_click()

func create_entity(spawn_grid_pos: Vector2i):
	var new_entity = entity_scene.instantiate()
	tilemap.add_child(new_entity) 
	new_entity.spawn(spawn_grid_pos, tilemap)

func get_entity_at(target_grid_pos: Vector2i) -> Entity:
	for child in tilemap.get_children():
		if child is Entity:
			if child.grid_pos == target_grid_pos:
				return child
	return null

func handle_click():
	var mouse_pos = tilemap.get_local_mouse_position()
	var grid_pos = tilemap.local_to_map(mouse_pos)
	var clicked_entity = get_entity_at(grid_pos)
	
	if clicked_entity:
		selected_entity = clicked_entity
		cursor.modulate = Color.GREEN
	elif selected_entity:
		var is_on_map = tilemap.get_cell_source_id(grid_pos) != -1
		var in_range = selected_entity.can_move_to(grid_pos)
		var is_empty = get_entity_at(grid_pos) == null
		
		if is_on_map and in_range and is_empty:
			selected_entity.move_to(grid_pos)
			selected_entity = null
			cursor.modulate = Color.WHITE
		else:
			selected_entity = null
			cursor.modulate = Color.WHITE

func handle_right_click():
	var mouse_pos = tilemap.get_local_mouse_position()
	var grid_pos = tilemap.local_to_map(mouse_pos)
	var target = get_entity_at(grid_pos)
	
	if selected_entity and target:
		if target != selected_entity:
			selected_entity.attack(target)
