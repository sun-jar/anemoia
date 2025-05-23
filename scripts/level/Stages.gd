extends TileMapLayer

@export var stage: int
@export var switches: Array

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if stage >= 2:
		var power = get_node_or_null("PowerSource1")
		if power != null:
			power.play("inactive_2")
	if stage >= 3:
		var power = get_node_or_null("PowerSource2")
		if power != null:
			power.play("inactive_3")
	if stage >= 4:
		var power = get_node_or_null("PowerSource3")
		if power != null:
			power.play("inactive_3")
	if GameManager.player_stage >= stage:
		for child in self.get_children():
			if child.name in switches and not GameManager.closed_doors[child.id]:
				var temp_stage = "2" if stage >= 2 else "1"
				child.toggle_enable(temp_stage)
				
	open_doors()


func open_doors():
	if GameManager.player_stage == 4:
		self._delete_8x1_door(GameManager.doors[7], 2, Vector2i(5, 2))
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
			if id == 7:
				if stage > 1:
					self._delete_8x1_door(GameManager.doors[id], 2, Vector2i(5, 2))
				else:
					self._delete_8x1_door(GameManager.doors[id], 2, Vector2i(4, 3))
			
			delete_door_instance(id)
				
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
			
func _delete_8x1_door(top_left, tile_source, tile_coords):
		for i in range(0, 8):
			self.set_cell(top_left + Vector2i(0, i), tile_source, tile_coords)
			
func delete_door_instance(id):
	var door = get_node_or_null("Door%d" % id)
	if door != null:
		door.queue_free()
