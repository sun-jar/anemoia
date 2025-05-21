extends TileMapLayer

@export var stage: int
@export var switches: Array

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if stage == 2:
		$PowerSource.play("inactive_2")
	if GameManager.player_stage >= stage:
		for child in self.get_children():
			if child.name in switches and not GameManager.closed_doors[child.id]:
				child.toggle_enable(str(stage))
				
	open_doors()


func open_doors():
	for id in range(1, 12):
		if GameManager.closed_doors[id]:
			if id in [1, 2, 6, 8, 10]:
				if stage > 1:
					self._delete_4x3_door(GameManager.doors[id], 2, Vector2i(5, 2))
				else:
					self._delete_4x3_door(GameManager.doors[id], 2, Vector2i(4, 3))
			if id in [3, 5, 11]:
				if stage > 1:
					self._delete_4x1_door(GameManager.doors[id], 2, Vector2i(5, 2))
				else:
					self._delete_4x1_door(GameManager.doors[id], 2, Vector2i(4, 3))
			if id == 11:
				if stage > 1:
					self._delete_5x1_door(GameManager.doors[id], 2, Vector2i(5, 2))
				else:
					self._delete_5x1_door(GameManager.doors[id], 2, Vector2i(4, 3))
			if id == 4:
				if stage > 1:
					self._delete_6x3_door(GameManager.doors[id], 2, Vector2i(5, 2))
				else:
					self._delete_6x3_door(GameManager.doors[id], 2, Vector2i(4, 3))
				
func _delete_4x3_door(top_left, tile_source, tile_coords):
	for i in range(0, 3):
		for j in range(0, 4):
			self.set_cell(top_left + Vector2i(j, i), tile_source, tile_coords)

func _delete_6x3_door(top_left, tile_source, tile_coords):
	for i in range(0, 3):
		for j in range(0, 6):
			self.set_cell(top_left + Vector2i(j, i), tile_source, tile_coords)

func _delete_4x1_door(top_left, tile_source, tile_coords):
		for i in range(0, 4):
			self.set_cell(top_left + Vector2i(0, i), tile_source, tile_coords)
			
func _delete_5x1_door(top_left, tile_source, tile_coords):
		for i in range(0, 5):
			self.set_cell(top_left + Vector2i(0, i), tile_source, tile_coords)
