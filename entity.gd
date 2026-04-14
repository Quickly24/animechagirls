class_name Entity extends Node2D

# Zmienne statystyk (widoczne w edytorze dzięki @export)
@export var max_health: int = 3
@export var movement_range: int = 2
@export var is_player: bool = true # Czy to nasz mech, czy wróg?

var current_health: int
var grid_pos: Vector2i # Gdzie logicznie znajduje się jednostka (np. 2, 4)

# Referencja do naszej planszy (żeby mech umiał przeliczać piksele na kratki)
var board: TileMapLayer 

func _ready():
	current_health = max_health

# Funkcja wywoływana przy stawianiu mecha na planszy
func spawn(start_grid_pos: Vector2i, tilemap: TileMapLayer):
	board = tilemap
	grid_pos = start_grid_pos
	
	# Natychmiastowe przyciągnięcie grafiki do środka kafelka
	var local_center = board.map_to_local(grid_pos)
	global_position = board.to_global(local_center)

# Funkcja do ruchu (animowanego!)
func move_to(new_grid_pos: Vector2i):
	# 1. Zmieniamy logiczną pozycję w pamięci komputera
	grid_pos = new_grid_pos
	
	# 2. Obliczamy nowy punkt na ekranie
	var target_local = board.map_to_local(grid_pos)
	var target_global = board.to_global(target_local)
	
	# 3. Zamiast teleportować, płynnie przesuwamy obrazek używając Tweena
	var tween = create_tween()
	# Przesuń global_position do target_global w czasie 0.25 sekundy
	tween.tween_property(self, "global_position", target_global, 0.25).set_trans(Tween.TRANS_SINE)
# Wewnątrz Entity.gd

# Sprawdza, czy cel jest w zasięgu movement_range
func can_move_to(target_grid_pos: Vector2i) -> bool:
	# Obliczamy różnicę pól
	var diff = (target_grid_pos - grid_pos).abs()
	var distance = diff.x + diff.y
	
	# Zwraca true, jeśli dystans jest mniejszy lub równy zasięgowi
	return distance <= movement_range
