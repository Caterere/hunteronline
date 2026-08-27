extends NPC

# ============================================================
# HUNTER ONLINE - NPC: MENCHI (LÍDER DOS HUNTERS GOURMET)
# ============================================================
#
# Hunter Gourmet de 1 Estrela e co-examinadora da 2ª Fase.
# Rigorosa e apaixonada pela culinária de feras míticas, oferece
# recrutamento para a Guilda Gourmet e receitas secretas.
#
# ============================================================

func _ready() -> void:
	super()
	npc_name = "Menchi"
	fala_padrao = "Hunters Gourmets arriscam a vida por ingredientes lendários! Não tolero covardia."


func _on_interacted(_player: CharacterBody2D) -> void:
	print("[Menchi] Conversando com a Examinadora Menchi...")
	QuestSystem.register_npc_visit(&"menchi")

	var visual_dialogue = get_tree().get_first_node_in_group("visual_dialogue_ui")
	if visual_dialogue != null:
		var nivel_nen = PlayerData.attributes.get("nivel_nen", 0) if PlayerData else 0
		var ja_e_gourmet = (PlayerData.faccao_atual == "gourmet") if PlayerData else false

		var falas: Array[Dictionary] = []
		if ja_e_gourmet:
			var rank_nome = FactionManager.obter_nome_rank_atual() if FactionManager else "Cozinheiro"
			falas = [
				{"falante": "Examinadora Menchi", "texto": "Excelente ver você na cozinha, meu caro Caçador Gourmet (%s)!" % rank_nome},
				{"falante": "Examinadora Menchi", "texto": "Continue caçando feras raras e colhendo temperos proibidos para preparar os Banquetes Mágicos que fortalecem o corpo e a aura!"}
			]
		elif nivel_nen >= 2:
			falas = [
				{"falante": "Examinadora Menchi", "texto": "Vocês acham que ser um Hunter Gourmet é apenas cozinhar pratos bonitinhos? Quanta ignorância!"},
				{"falante": "Examinadora Menchi", "texto": "Nós arriscamos a vida em abismos e vulcões para extrair o melhor sabor do mundo! Se você ama a caça culinária e quer banquetes que aumentam sua vida e aura permanentemente, junte-se à Guilda dos Hunters Gourmet!"},
				{"falante": "Examinadora Menchi", "texto": "Consulte o Jornal de Missões [J] na aba de Facções para ingressar na nossa guilda!"}
			]
			if FactionManager and PlayerData.faccao_atual.is_empty():
				FactionManager.ingressar_faccao("gourmet")
				PlayerData.registrar_segredo("recrutado_gourmet")
		else:
			falas = [
				{"falante": "Examinadora Menchi", "texto": "Se não demonstrarem coragem, respeito pelos ingredientes e precisão técnica contra os javalis da floresta, eu reprovarei todos vocês sem hesitar!"}
			]

		visual_dialogue.exibir_sequencia_falas(falas)
	else:
		falar_balao(fala_padrao, 4.0, Color(0.9, 0.3, 0.5, 1.0))
