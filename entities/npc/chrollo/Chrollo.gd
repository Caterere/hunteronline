extends NPC

# ============================================================
# HUNTER ONLINE - NPC: CHROLLO LUCILFER (LÍDER DA TRUPE FANTASMA)
# ============================================================
#
# Líder da Genei Ryodan (Especialista - Skill Hunter).
# Permite recrutamento na facção da Aranha, missões clandestinas de roubo
# e liberação de componentes de Hatsu sombrios.
#
# ============================================================

@export var dialogue_tree: DialogueTree


func _ready() -> void:
	super()
	npc_name = "Chrollo Lucilfer"
	fala_padrao = "... Nós não rejeitamos ninguém. Portanto, não tire nada de nós."


func _on_interacted(player: CharacterBody2D) -> void:
	print("[Chrollo] Interagindo com o líder da Genei Ryodan...")
	QuestSystem.register_npc_visit(&"chrollo")

	var visual_dialogue = get_tree().get_first_node_in_group("visual_dialogue_ui")

	if visual_dialogue != null:
		var falas: Array[Dictionary] = []
		var nivel_nen = PlayerData.attributes.get("nivel_nen", 0) if PlayerData else 0
		var ja_e_aranha = (PlayerData.faccao_atual == "genei_ryodan") if PlayerData else false

		if ja_e_aranha:
			var rank_nome = FactionManager.obter_nome_rank_atual() if FactionManager else "Membro"
			falas = [
				{"falante": "Chrollo Lucilfer", "texto": "Bem-vindo de volta, meu caro companheiro da Aranha (%s)." % rank_nome},
				{"falante": "Chrollo Lucilfer", "texto": "A cabeça dá as ordens, mas a cabeça é apenas outro órgão. Se eu cair, a Aranha continuará andando sobre as cinzas de seus inimigos."},
				{"falante": "Chrollo Lucilfer", "texto": "Traga relíquias raras e cumpra os contratos de roubo para elevar seu status entre as patas da Trupe."}
			]
		elif nivel_nen >= 10:
			falas = [
				{"falante": "Chrollo Lucilfer", "texto": "Você possui uma aura interessante... Não é pura, nem ingênua. Há sede de descoberta e desapego em seus olhos."},
				{"falante": "Chrollo Lucilfer", "texto": "Eu sou Chrollo Lucilfer, líder da Genei Ryodan — a Trupe Fantasma de Meteor City."},
				{"falante": "Chrollo Lucilfer", "texto": "Se aceitar a tatuagem da aranha de doze patas e jurar lealdade ao bando, você se tornará o 14º Membro Titular."},
				{"falante": "Chrollo Lucilfer", "texto": "Consulte o menu de Facções no seu Jornal de Missões [J] para formalizar seu juramento com a Aranha."}
			]
			if FactionManager and PlayerData.faccao_atual.is_empty():
				FactionManager.ingressar_faccao("genei_ryodan")
				PlayerData.registrar_segredo("recrutado_genei_ryodan")
		else:
			falas = [
				{"falante": "Chrollo Lucilfer", "texto": "... Sua aura ainda é tênue demais para suportar a escuridão de Meteor City."},
				{"falante": "Chrollo Lucilfer", "texto": "Treine seu Nen até o Nível 10. Quando você não temer mais o abismo, nos falaremos novamente."}
			]

		visual_dialogue.exibir_sequencia_falas(falas)
	else:
		falar_balao(fala_padrao, 4.0, Color(0.4, 0.1, 0.6, 1.0), Color(0.9, 0.8, 1.0, 1.0))
