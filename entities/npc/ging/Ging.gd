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
	npc_name = "Ging"


func _on_interacted(_player: CharacterBody2D) -> void:
	print("[Ging] Interagindo com Ging Freecss...")
	QuestSystem.register_npc_visit(&"ging")

	var visual_dialogue = get_tree().get_first_node_in_group("visual_dialogue_ui")
	if visual_dialogue == null:
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
			{"falante": "Ging", "texto": "O mundo que conhecemos é apenas o centro do Lago de Mebius."},
			{"falante": "Ging", "texto": "Além das fronteiras fica o Continente Negro — um mundo vasto de calamidades e riquezas."},
			{"falante": "Ging", "texto": "É para lá que estamos indo. Você vem comigo?"}
		]
	else:
		falas = [
			{"falante": "Ging", "texto": "...Você ainda não está pronto pra me encontrar. Continue crescendo."}
		]

	visual_dialogue.exibir_sequencia_falas(falas)
