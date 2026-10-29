class_name StoryGatewayNPC
extends NPC

# ============================================================
# HUNTER ONLINE — STORY GATEWAY (despacho à missão atual)
# ============================================================
# # continua do checkpoint atual, sem seletor de saga/dificuldade.
# ============================================================

@export var prompt_interaction: String = "[E] Continuar Missão Atual"


func _ready() -> void:
	npc_name = "Guia da História"
	fala_padrao = "Fale comigo para ir automaticamente à área da sua missão atual."
	super()
	var inter := get_node_or_null("InteractionComponent") as InteractionComponent
	if inter != null:
		inter.interaction_text = prompt_interaction


func _on_interacted(_player: CharacterBody2D) -> void:
	_despachar_para_missao_atual()


func _despachar_para_missao_atual() -> void:
	if StoryManager == null:
		return
	# Evita reentrância durante cutscene / diálogo já aberto (double teleport).
	if StoryCutsceneManager.em_cutscene:
		if EventBus != null and EventBus.has_method("emit_toast"):
			EventBus.emit_toast("Aguarde a cena terminar...", Color(1.0, 0.85, 0.4))
		return

	var cp: Dictionary = {}
	if StoryManager.has_method("obter_checkpoint_ativo"):
		cp = StoryManager.obter_checkpoint_ativo()
	var nome_cp := str(cp.get("nome", "Missão Atual"))

	var visual_dialogue = get_tree().get_first_node_in_group("visual_dialogue_ui")
	if visual_dialogue != null and visual_dialogue.has_method("exibir_sequencia_falas"):
		var saga_id: int = StoryManager.current_saga
		var cap_id: int = StoryManager.current_chapter
		var nome_saga: String = StoryManager.obter_nome_saga(saga_id)
		visual_dialogue.exibir_sequencia_falas([
			{"falante": "Guia da História", "texto": "Sem seletor de saga ou dificuldade — só a sua missão atual."},
			{"falante": "Guia da História", "texto": "Progresso: Arco %d (%s) | Cap. %d." % [saga_id, nome_saga, cap_id]},
			{"falante": "Guia da História", "texto": "🚩 Destino: %s" % nome_cp},
			{"falante": "Guia da História", "texto": "Confirmando despacho..."}
		])
		var ao_ir := func():
			if StoryManager != null:
				StoryManager.continuar_do_checkpoint(get_tree())
		if visual_dialogue.has_method("when_done"):
			visual_dialogue.when_done(ao_ir)
		else:
			visual_dialogue.dialogo_concluido.connect(ao_ir, CONNECT_ONE_SHOT)
	else:
		if EventBus != null and EventBus.has_method("emit_toast"):
			EventBus.emit_toast("🚩 Indo para: %s" % nome_cp, Color(0.2, 0.9, 1.0))
		StoryManager.continuar_do_checkpoint(get_tree())
