class_name NenBeastHandlerNPC
extends NPC

# ============================================================
# HUNTER ONLINE - NPC: CURADOR DAS BESTAS DE NEN
# ============================================================
#
# NPC Guardião e especialista nas Bestas Espirituais de Kakin.
# Permite ao jogador inspecionar o Catálogo de Bestas, entender
# os efeitos de cada uma, trocar/equipar e despertar novas criaturas.
#
# ============================================================

const NenBeastCatalogUI = preload("res://ui/NenBeast/NenBeastCatalogUI.gd")


func _ready() -> void:
	npc_name = "Curador de Bestas de Nen"
	fala_padrao = "As Bestas de Nen são manifestações vivas da sua determinação e instinto de sobrevivência!"
	super()


func _on_interacted(_player: CharacterBody2D) -> void:
	QuestSystem.register_npc_visit(&"curador_bestas_nen")

	# Abrir Interface do Catálogo e Santuário de Bestas
	var ui := NenBeastCatalogUI.new()
	get_tree().root.add_child(ui)
