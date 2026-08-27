extends NPC

# ============================================================
# HUNTER ONLINE - NPC: GUIA DO PORTAL (LOBBY → MODO HISTÓRIA)
# ============================================================
#
# NPC do Lobby (lobby.tscn) que abre a interface de seleção
# de Sagas/Arcos e Dificuldade para o Modo História.
#
# ============================================================


func _ready() -> void:
	super()
	npc_name = "Guia do Portal"
	fala_padrao = "Olá, Hunter! Fale comigo para acessar o menu de Sagas e viajar pelo Modo História!"


func _on_interacted(_player: CharacterBody2D) -> void:
	QuestSystem.register_npc_visit(&"portal_hunter")

	# Se já houver uma UI aberta, não duplicar
	var ui_existente = get_tree().root.get_node_or_null("PortalHunterUI")
	if ui_existente != null:
		return

	var visual_dialogue = get_tree().get_first_node_in_group("visual_dialogue_ui")
	if visual_dialogue != null:
		var falas: Array[Dictionary] = [
			{"falante": "Guia do Portal", "texto": "Bem-vindo ao Portal de Nen! Selecione para qual saga da história deseja viajar."}
		]
		visual_dialogue.exibir_sequencia_falas(falas)
		await visual_dialogue.dialogo_concluido

	_abrir_menu_portal()


func _abrir_menu_portal() -> void:
	var portal_ui := PortalHunterUI.new()
	portal_ui.name = "PortalHunterUI"
	get_tree().root.add_child(portal_ui)
