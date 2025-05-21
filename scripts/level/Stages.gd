extends TileMapLayer

@export var stage: int
@export var switches: Array


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if GameManager.player_stage >= stage:
		for child in self.get_children():
			if child.name in switches and not GameManager.closed_doors[child.id]:
				child.disabled = false
