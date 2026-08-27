extends NPC

# ============================================================
# HUNTER ONLINE - NPC: BUHARA (2ª FASE — HUNTER GOURMET)
# ============================================================
#
# Examinador da 2ª Fase na Floresta Biska.
# Um gigante jovial com apetite insaciável que desafia os candidatos
# a caçar o perigoso Great Stamp Pig (Grande Javali Selvagem).
#
# ============================================================

func _ready() -> void:
	super()
	npc_name = "Buhara"


func _on_interacted(_player: CharacterBody2D) -> void:
	print("[Buhara] Conversando com o Examinador Buhara...")
	QuestSystem.register_npc_visit(&"buhara")

	var visual_dialogue = get_tree().get_first_node_in_group("visual_dialogue_ui")
	if visual_dialogue != null:
		var falas: Array[Dictionary] = [
			{
				"falante": "Examinador Buhara",
				"texto": "*Gooorrrr...* Meu estômago está roncando! Bem-vindos à 2ª Fase do Exame Hunter aqui na Floresta Biska!"
			},
			{
				"falante": "Examinador Buhara",
				"texto": "O meu menu de avaliação é simples: quero que vocês cacem o Grande Javali Selvagem (Great Stamp)! Eles são carnívoros ferozes com a testa dura como aço."
			},
			{
				"falante": "Examinador Buhara",
				"texto": "O segredo para derrotá-los é mirar bem no topo central da cabeça com um golpe preciso. Traga a carne assada se quiser minha aprovação!"
			}
		]
		visual_dialogue.exibir_sequencia_falas(falas)
	else:
		falar_balao("Estou faminto! Tragam a carne do Grande Javali da floresta!", 4.0, Color(0.9, 0.5, 0.2, 1.0))
