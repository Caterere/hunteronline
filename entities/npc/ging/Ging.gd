extends NPC

# ============================================================
# HUNTER ONLINE - NPC: GING FREECSS (ARCOS 7 E 8)
# ============================================================
#
# Hunter de 3 Estrelas lendário e Zodíaco Javali.
# Lidera a expedição ao Continente Negro e compartilha suas reflexões.
#
# ============================================================


func _ready() -> void:
	super()
	npc_name = "Ging Freecss"


func _on_interacted(_player: CharacterBody2D) -> void:
	print("[Ging] Interagindo com Ging Freecss...")
	QuestSystem.register_npc_visit(&"ging")
	if QuestSystem.has_method("register_persuasion"):
		QuestSystem.register_persuasion(&"ging")

	var visual_dialogue = get_tree().get_first_node_in_group("visual_dialogue_ui")
	if visual_dialogue == null:
		falar_balao(fala_padrao if not fala_padrao.is_empty() else "ORDEM: Fale comigo. Depois GPS — um passo.", 3.8, Color(0.3, 0.7, 0.35, 1.0))
		return

	var falas: Array[Dictionary] = []
	var arco = PlayerData.arco_atual

	if arco == 7:
		falas = [
			{"falante": "Ging", "texto": "Yo! Finalmente nos encontramos... Você percorreu um longo caminho."},
			{"falante": "Ging", "texto": "Aproveite os pequenos desvios no caminho. É neles que encontramos o que realmente importa."}
		]
	elif arco >= 8:
		falas = [
			{"falante": "Ging", "texto": "ORDEM: Fale comigo / teste Nen. Depois [G] Lago Mobius → [Z] Águas. Sem pular o caminho."},
			{"falante": "Ging", "texto": "O mundo que conhecemos é apenas o centro do Lago Mobius. Calamidades à frente — GPS um de cada vez."},
			{"falante": "Ging", "texto": "No topo a gente conversa de novo. Até lá: não rush."}
		]
	else:
		falas = [
			{"falante": "Ging", "texto": "...Você ainda não está pronto pra me encontrar. Continue crescendo."}
		]

	visual_dialogue.exibir_sequencia_falas(falas)
