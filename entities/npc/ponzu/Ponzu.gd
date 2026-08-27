extends NPC

# ============================================================
# HUNTER ONLINE - NPC: PONZU (ARCO 1 — EXAME HUNTER Nº 246)
# ============================================================
#
# Especialista química e controladora de colônias de abelhas venenosas
# alojadas em seu chapéu.
#
# ============================================================

func _ready() -> void:
	super()
	npc_name = "Ponzu"


func _on_interacted(_player: CharacterBody2D) -> void:
	print("[Ponzu] Conversando com Ponzu...")
	QuestSystem.register_npc_visit(&"ponzu")

	var visual_dialogue = get_tree().get_first_node_in_group("visual_dialogue_ui")
	if visual_dialogue != null:
		var falas: Array[Dictionary] = [
			{
				"falante": "Ponzu (Nº 246)",
				"texto": "Pshiu! Não faça movimentos bruscos perto do meu chapéu. Minhas abelhas químicas atacam por reflexo caso sintam vibrações agressivas."
			},
			{
				"falante": "Ponzu (Nº 246)",
				"texto": "Este pântano é infestado por cogumelos com esporos alucinógenos e borboletas soníferas. Se inalar o pólen cinzento, você cairá adormecido e servirá de refeição para as plantas carnívoras."
			},
			{
				"falante": "Ponzu (Nº 246)",
				"texto": "Tenho comigo antídotos químicos condensados, mas não pretendo desperdiçar com quem não sabe manter o ritmo!"
			}
		]
		visual_dialogue.exibir_sequencia_falas(falas)
	else:
		falar_balao("Cuidado com os esporos do pântano! Minhas abelhas estão alertas.", 4.0, Color(0.9, 0.4, 0.7, 1.0))
