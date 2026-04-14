extends Node2D
@onready var cursor = $Cursor 
@onready var tilemap = $TileMapLayer
var selected_entity: Entity = null
# Ładujemy naszą scenę jednostki z dysku
var entity_scene = preload("res://scenes//entity.tscn")

func _ready():
	# Stwórzmy testowego mecha na samym początku gry!
	create_entity(Vector2i(2, 2)) # Chcemy go na kratce x:2, y:2
	#create_entity(Vector2i(4, 3)) # I drugiego obok
func _process(_delta):
	# Sprawdzamy, czy gracz właśnie wcisnął lewy przycisk myszy
	if Input.is_action_just_pressed("mouse_left"):
		handle_click()
func create_entity(spawn_grid_pos: Vector2i):
	# 1. Tworzymy nową instancję (kopię) sceny z pamięci
	var new_entity = entity_scene.instantiate()
	
	# 2. Ważne: Dodajemy mecha jako dziecko do TileMapLayer!
	# Dzięki temu Y-Sort zadziała perfekcyjnie i góry zasłonią mecha
	tilemap.add_child(new_entity) 
	
	# 3. Wywołujemy naszą funkcję z Entity.gd
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
	
	# 1. KLIKNIĘCIE NA JEDNOSTKĘ (Wybór)
	if clicked_entity:
		selected_entity = clicked_entity
		cursor.modulate = Color.GREEN
		print("Wybrano jednostkę. Zasięg: ", selected_entity.movement_range)
	
	# 2. KLIKNIĘCIE NA POLE (Ruch)
	elif selected_entity:
		# Sprawdzamy 3 warunki:
		# - Czy pole istnieje w TileMapie?
		# - Czy pole jest w zasięgu mecha?
		# - Czy pole jest puste (brak innej jednostki)?
		
		var is_on_map = tilemap.get_cell_source_id(grid_pos) != -1
		var in_range = selected_entity.can_move_to(grid_pos)
		var is_empty = get_entity_at(grid_pos) == null
		
		if is_on_map and in_range and is_empty:
			selected_entity.move_to(grid_pos)
			selected_entity = null # Odznaczamy po ruchu
			cursor.modulate = Color.WHITE
		else:
			print("Ruch niemożliwy!")
			# Opcjonalnie: odznacz mecha przy błędnym kliknięciu
			selected_entity = null
			cursor.modulate = Color.WHITE
