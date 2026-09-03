class_name StoryGatewayNPC
extends NPC

# ============================================================
# HUNTER ONLINE — STORY GATEWAY NPC (HUB WORLD DESPATCHER)
# ============================================================
#
# Ponto de acesso central e seguro ao Story Mode:
# - Localizado no Hub World (Lobby / Hunter Plaza).
# - O jogador conversa com este NPC para continuar sua aventura a
#   partir do Story Checkpoint seguro mais recente.
# - Desacopla a exploração da cidade das missões de combate.
# ============================================================

@export var prompt_interaction: String = "[E] Falar com o Guia da História (Story Gateway)"


func _ready() -> void:
	npc_name = "Guia da História"
	fala_padrao = "Sou o Guia Oficial de Missões da Associação Hunter. Interaja comigo para continuar sua jornada canônica!"
	super()


func _on_interacted(_player: CharacterBody2D) -> void:
	print("[StoryGatewayNPC] Interagindo com o Guia da História...")

	var saga_id: int = StoryManager.current_saga if StoryManager != null else 1
	var cap_id: int = StoryManager.current_chapter if StoryManager != null else 1
	var nome_saga: String = StoryManager.obter_nome_saga(saga_id) if StoryManager != null else "Exame Hunter"

	var cp_dados: Dictionary = StoryManager.obter_checkpoint_ativo() if StoryManager != null else {}
	var nome_cp: String = str(cp_dados.get("nome", "Início do Exame Hunter"))
	var safe_name: String = str(cp_dados.get("safe_name", "Hunter Plaza"))

	var visual_dialogue = get_tree().get_first_node_in_group("visual_dialogue_ui")
	if visual_dialogue != null and visual_dialogue.has_method("exibir_sequencia_falas"):
		visual_dialogue.exibir_sequencia_falas([
			{"falante": "Guia da História", "texto": "Saudações, Caçador! Eu coordeno as expedições oficiais da história pelo continente."},
			{"falante": "Guia da História", "texto": "Seu Progresso Atual é no Arco %d: %s | Capítulo %d." % [saga_id, nome_saga, cap_id]},
			{"falante": "Guia da História", "texto": "🚩 Checkpoint Ativo: %s (Ponto Seguro: %s)." % [nome_cp, safe_name]},
			{"falante": "Guia da História", "texto": "Pressione [E] para ser despachado imediatamente até o seu Checkpoint!"}
		])
		visual_dialogue.dialogo_concluido.connect(func():
			if StoryManager != null:
				StoryManager.continuar_do_checkpoint(get_tree())
		, CONNECT_ONE_SHOT)
	else:
		# Fallback direto se UI de diálogo estiver indisponível
		if EventBus != null and EventBus.has_signal("toast_requested"):
			EventBus.emit_toast("🚩 Despachando para Checkpoint: %s" % nome_cp, Color(0.2, 0.9, 1.0))
		if StoryManager != null:
			StoryManager.continuar_do_checkpoint(get_tree())
