class_name QuadroBounties
extends StaticBody2D

# ============================================================
# HUNTER ONLINE - QUADRO DE PROCURADOS (BOUNTIES BOARD)
# ============================================================
#
# Quadro de avisos com cartazes de procurados (Blacklist).
# Permite abrir o BountiesBoardUI para caçar criminosos.
#
# ============================================================

@onready var interaction: InteractionComponent = $InteractionComponent as InteractionComponent
var ui_instance: BountiesBoardUI = null


func _ready() -> void:
	if interaction != null:
		interaction.interaction_text = "[E] Ver Quadro de Procurados"
		if not interaction.interacted.is_connected(_on_interacted):
			interaction.interacted.connect(_on_interacted)


func _on_interacted(_player: CharacterBody2D) -> void:
	if ui_instance == null:
		var scene = load("res://ui/Bounties/BountiesBoardUI.tscn")
		if scene:
			ui_instance = scene.instantiate()
			get_tree().root.add_child(ui_instance)
		else:
			ui_instance = BountiesBoardUI.new()
			get_tree().root.add_child(ui_instance)
			
	ui_instance.abrir()
