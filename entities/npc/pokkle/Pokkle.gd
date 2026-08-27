extends NPC

# ============================================================
# HUNTER ONLINE - NPC: POKKLE (ARCO 1 — EXAME HUNTER Nº 53)
# ============================================================
#
# Arqueiro tático com profunda percepção espacial e uso de venenos
# de ação rápida na ponta de suas flechas.
#
# ============================================================

func _ready() -> void:
	super()
	npc_name = "Pokkle"


func _on_interacted(_player: CharacterBody2D) -> void:
	print("[Pokkle] Conversando com Pokkle...")
	QuestSystem.register_npc_visit(&"pokkle")

	var visual_dialogue = get_tree().get_first_node_in_group("visual_dialogue_ui")
	if visual_dialogue != null:
		var falas: Array[Dictionary] = [
			{
				"falante": "Pokkle (Nº 53)",
				"texto": "Cuidado onde pisa nesse nevoeiro! As criaturas do Pantanal Numere não atacam de frente... elas usam mimetismo para atrair presas desprevenidas."
			},
			{
				"falante": "Pokkle (Nº 53)",
				"texto": "Minhas flechas estão embebidas com toxina paralítica de rápida absorção. Se alguma fera saltar sobre você, mire na articulação ou no abdômen, que é onde a carapaça é mais fina."
			},
			{
				"falante": "Pokkle (Nº 53)",
				"texto": "E fique atento... aquele sujeito vestido de mágico, Hisoka... sinto uma sede de sangue descomunal emanando dele."
			}
		]
		visual_dialogue.exibir_sequencia_falas(falas)
	else:
		falar_balao("Mantenha o arco em prontidão. O nevoeiro esconde predadores perigosos!", 4.0, Color(0.3, 0.8, 0.7, 1.0))
