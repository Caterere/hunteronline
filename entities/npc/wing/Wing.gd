extends NPC

# ============================================================
# HUNTER ONLINE - NPC: WING (ARCO 3 — ARENA CELESTIAL)
# ============================================================
#
# Mestre de Nen na Arena Celestial.
# Realiza o secreto Teste da Água (Water Divination Test) e
# ensina Ten e Ren aos discípulos.
#
# ============================================================

@export var quest: Quest


func _ready() -> void:
	npc_name = "Wing"
	super()


func _on_interacted(_player: CharacterBody2D) -> void:
	print("[Wing] Interagindo com Mestre Wing...")
	if QuestSystem != null and QuestSystem.has_method("register_npc_visit"):
		QuestSystem.register_npc_visit(&"wing")

	var falas_wing: Array[Dictionary] = []
	var afinidade_nome: String = NenAffinityData.obter_nome_afinidade(PlayerData.afinidade_nen)
	var afinidade_desc: String = NenAffinityData.obter_descricao_afinidade(PlayerData.afinidade_nen)

	var etapa_atual: int = PlayerData.etapa_quest_arco if PlayerData != null else 1
	var arco_atual: int = PlayerData.arco_atual if PlayerData != null else 1

	if arco_atual == 3 and etapa_atual == 10:
		# Etapa 10: Jogador deve inspecionar o copo de água
		falas_wing.append({"falante": "Mestre Wing", "texto": "Para descobrir qual das 6 categorias de Nen você nasceu com, realizaremos o TESTE DA ÁGUA (Water Divination Test)!"})
		falas_wing.append({"falante": "Mestre Wing", "texto": "Posicione suas mãos ao redor do copo d'água com a folha na mesa logo ao meu lado [E] e libere sua aura!"})

	elif not PlayerData.despertou_nen or (arco_atual == 3 and etapa_atual == 11):
		PlayerData.despertou_nen = true
		PlayerData.aplicar_nivel_nen(1)
		PlayerData.aplicar_bonuses_afinidade()

		falas_wing.append({"falante": "Mestre Wing", "texto": "Parabéns por realizar o Teste da Água! Sua Afinidade Natal é oficialmente comprovada como: " + afinidade_nome.to_upper() + "!"})
		falas_wing.append({"falante": "Mestre Wing", "texto": afinidade_desc})
		falas_wing.append({"falante": "Mestre Wing", "texto": "Abrirei suavemente seus nós de aura... Sinta a energia fluir sem escapar: você despertou o TEN (Envolver)!"})
		falas_wing.append({"falante": "Mestre Wing", "texto": "O Ten envolve seu corpo como um manto protetor, reduzindo drasticamente qualquer impacto recebido."})
		falas_wing.append({"falante": "Mestre Wing", "texto": "Durante o combate, segure [Q] para abrir a Barra de Ação Rápida de Nen e alternar suas posturas."})
		PlayerData.quest_states["wing_tutorial_progresso"] = 2

	elif arco_atual == 3 and etapa_atual == 12:
		falas_wing.append({"falante": "Mestre Wing", "texto": "Agora que domina o Ten, você deve aprender a expandir a aura explosivamente: o REN (Expandir)!"})
		falas_wing.append({"falante": "Mestre Wing", "texto": "O Ren multiplica seu poder destrutivo e intimida oponentes fracos, mas drena aura continuamente."})
		falas_wing.append({"falante": "Mestre Wing", "texto": "Pratique a transição rápida entre Ten e Ren em combate!"})

	else:
		falas_wing.append({"falante": "Mestre Wing", "texto": "Continue praticando os 4 princípios fundamentais (Ten, Ren, Zetsu e Gyo). Segure [Q] em combate para alternar rapidamente entre eles."})
		falas_wing.append({"falante": "Mestre Wing", "texto": "Consulte seu Diário de Treino ou a Árvore de Habilidades em [N] para aprofundar suas técnicas."})

	var visual_dialogue = get_tree().get_first_node_in_group("visual_dialogue_ui")
	if visual_dialogue != null:
		visual_dialogue.exibir_sequencia_falas(falas_wing)
