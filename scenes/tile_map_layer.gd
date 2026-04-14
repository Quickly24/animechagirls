extends TileMapLayer

@onready var cursor = $"../Cursor" 
var debug_label: Label

func _ready():
	pass
	
	
	
	


func _process(_delta):
	var local_mouse = get_local_mouse_position()
	var grid_pos = local_to_map(local_mouse)
	var local_center = map_to_local(grid_pos)
	var zawartosc_pola = get_cell_source_id(grid_pos)
	if zawartosc_pola!=-1:
		
		cursor.global_position = to_global(local_center)
	



		
