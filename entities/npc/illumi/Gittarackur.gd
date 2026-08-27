extends NPC

# ============================================================
# HUNTER ONLINE - NPC: GITTARACKUR / ILLUMI (ARCO 1 — Nº 301)
# ============================================================
#
# Illumi Zoldyck disfarçado sob o pseudônimo de Gittarackur.
# O corpo e rosto estão perfurados por dezenas de agulhas de manipulação,
# alterando sua estrutura óssea e emitindo estalidos metálicos perturbadores.
#
# ============================================================

func _ready() -> void:
	super()
	npc_name = "Gittarackur"


func _on_interacted(_player: CharacterBody2D) -> void:
	print("[Gittarackur] Interagindo com o misterioso Nº 301...")
	QuestSystem.register_npc_visit(&"gittarackur")

	var visual_dialogue = get_tree().get_first_node_in_group("visual_dialogue_ui")
	if visual_dialogue != null:
		var falas: Array[Dictionary] = [
			{
				"falante": "Gittarackur (Nº 301)",
				"texto": "Klak... Klak-klak-klak..."
			},
			{
				"falante": "Gittarackur (Nº 301)",
				"texto": "Voc-c-cê... está me observando demais. As agulhas no meu rosto não são enfeites... elas moldam minha carne e meus ossos."
			},
			{
				"falante": "Gittarackur (Nº 301)",
				"texto": "Estou aqui apenas para garantir que um certo garoto não se desvie do seu destino. Se cruzar o meu caminho... uma agulha perfurará sua testa antes de você piscar. Klak-klak."
			}
		]
		visual_dialogue.exibir_sequencia_falas(falas)
	else:
		falar_balao("Klak-klak... Klak... Não fique no meu caminho.", 4.0, Color(0.6, 0.4, 0.9, 1.0))
