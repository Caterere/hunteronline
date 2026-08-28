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
	super()
	npc_name = "Wing"


func _on_interacted(_player: CharacterBody2D) -> void:
	print("[Wing] Interagindo com Mestre Wing...")
	if QuestSystem != null and QuestSystem.has_method("register_npc_visit"):
		QuestSystem.register_npc_visit(&"wing")

	var falas_wing: Array[Dictionary] = []

	if not PlayerData.despertou_nen:
		PlayerData.despertou_nen = true
		PlayerData.aplicar_nivel_nen(1)
		PlayerData.aplicar_bonuses_afinidade()

		var afinidade_nome: String = NenAffinityData.obter_nome_afinidade(PlayerData.afinidade_nen)
		var afinidade_desc: String = NenAffinityData.obter_descricao_afinidade(PlayerData.afinidade_nen)
		
		falas_wing.append({"falante": "Mestre Wing", "texto": "Parabéns por alcançar os andares superiores da Arena Celestial! Chegou o momento de conhecer o verdadeiro poder: o NEN."})
		falas_wing.append({"falante": "Mestre Wing", "texto": "Nen é a capacidade de controlar a energia vital (Aura) que flui de todo ser vivo."})
		falas_wing.append({"falante": "Mestre Wing", "texto": "Para descobrir qual das 6 categorias de Nen você nasceu com, realizaremos o TESTE DA ÁGUA (Water Divination Test)!"})
		falas_wing.append({"falante": "Mestre Wing", "texto": "Colocarei uma folha de árvore sobre este copo d'água... Posicione suas mãos em volta do copo e libere sua aura!"})
		falas_wing.append({"falante": "Mestre Wing", "texto": "A água está reagindo! Sua Afinidade Natal Secreta de Nen foi revelada: " + afinidade_nome.to_upper() + "!"})
		falas_wing.append({"falante": "Mestre Wing", "texto": afinidade_desc})
		falas_wing.append({"falante": "Mestre Wing", "texto": "Você despertou o TEN (proteção) e o REN (potência). Durante o combate, segure [Q] para abrir a Barra de Ação Rápida de Nen e selecione suas técnicas!"})
		falas_wing.append({"falante": "Mestre Wing", "texto": "Pressione [TAB] para abrir seu Hunter Menu completo ou [J] para consultar a Enciclopédia de Nen a qualquer momento."})
		PlayerData.quest_states["wing_tutorial_progresso"] = 2
	else:
		falas_wing.append({"falante": "Mestre Wing", "texto": "Continue praticando os 4 princípios fundamentais (Ten, Ren, Zetsu e Gyo). Segure [Q] em combate para alternar rapidamente entre eles."})
		falas_wing.append({"falante": "Mestre Wing", "texto": "Consulte seu Diário de Treino em [J] para revisar o conhecimento de cada técnica."})

	var visual_dialogue = get_tree().get_first_node_in_group("visual_dialogue_ui")
	if visual_dialogue != null:
		visual_dialogue.exibir_sequencia_falas(falas_wing)

	if quest != null and not PlayerData.is_quest_active(quest) and not PlayerData.is_quest_completed(quest):
		QuestSystem.start_quest(quest)
