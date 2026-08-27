class_name CombatInstructorNPC
extends NPC

# ============================================================
# HUNTER ONLINE - NPC: INSTRUTOR DE COMBATE (SATOTZ / SHINGEN-RYU)
# ============================================================
#
# Oferece o tutorial narrativo completo de combate, movimentação,
# Esquiva Perfeita (Perfect Dodge), Táticas de Nen e Hatsu.
#
# ============================================================

var tutorial_concluido: bool = false


func _ready() -> void:
	npc_name = "Instrutor de Combate"
	fala_padrao = "Deseja aprender os segredos do combate e das técnicas de Nen?"
	super()


func _on_interacted(_player: CharacterBody2D) -> void:
	QuestSystem.register_npc_visit(&"instrutor_combate")
	
	var visual_dialogue = get_tree().get_first_node_in_group("visual_dialogue_ui")
	if visual_dialogue == null:
		return

	var falas: Array[Dictionary] = []
	falas.append({
		"falante": "Instrutor de Combate",
		"texto": "⚔️ Saudações, jovem Hunter! Bem-vindo à Área de Treinamento da Associação. Aqui você aprenderá a sobreviver contra feras e usuários assassinos de Nen!"
	})
	falas.append({
		"falante": "Lição 1: Ataques e Combos",
		"texto": "👊 Pressione [ESPAÇO] ou clique com o [BOTÃO ESQUERDO] para desferir sequências de ataques físicos. Mantenha o ritmo para emendar combos fluídos."
	})
	falas.append({
		"falante": "Lição 2: Esquiva e PERFECT DODGE",
		"texto": "⚡ Pressione [SHIFT] ou [BOTÃO DIREITO] para esquivar. Se você esquivar na fração de segundo exata do golpe inimigo, ativará o PERFECT DODGE! Isso anula o dano, desacelera o inimigo e restaura +15 de Aura!"
	})
	falas.append({
		"falante": "Lição 3: Táticas de Nen em Batalha",
		"texto": "🥋 No menu [N], você alterna suas 9 técnicas de Nen:\n• TEN: Aumenta a defesa e bloqueia danos pesados.\n• REN: Expande o alcance dos seus golpes.\n• GYO: Revela pontos fracos e golpes invisíveis.\n• ZETSU: Apaga sua aura para causar DANO CRÍTICO x3 pelas costas!\n• KO: Concentra 100% da aura para QUEBRAR A GUARDA de inimigos com Ken!"
	})
	falas.append({
		"falante": "Lição 4: Hatsu e Supremos",
		"texto": "✨ Use as teclas [1], [2], [3] e [4] para disparar seus Hatsus equipados. Hatsu consome Aura rapidamente, então use o Perfect Dodge para recarregar sua energia!"
	})

	if not tutorial_concluido:
		tutorial_concluido = true
		Economy.adicionar_gold(500)
		var xp_sys = get_tree().get_first_node_in_group("xp_system") as XPSystem
		if xp_sys != null:
			xp_sys.adicionar_xp(200, "Tutorial de Combate")
		falas.append({
			"falante": "Recompensa de Treino",
			"texto": "🎁 Excelente dedicação! Você recebeu +200 XP, 500 Jenny e um kit inicial de suprimentos de Caçador!"
		})

	visual_dialogue.exibir_sequencia_falas(falas)
