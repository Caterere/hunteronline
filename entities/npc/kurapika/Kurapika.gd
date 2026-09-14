extends NPC

# ============================================================
# HUNTER ONLINE - NPC: KURAPIKA (OLHOS ESCARLATES & BLACKLIST)
# ============================================================
#
# Sobrevivente do Clã Kurta, Caçador da Lista Negra e Zodíaco.
# Oferece recrutamento para a facção Blacklist Hunters, ensina o
# segredo dos Juramentos de Nen (Vows) e comanda contratos de caça.
#
# ============================================================


func _ready() -> void:
	super()
	npc_name = "Kurapika"
	fala_padrao = "Eu não temo a morte. O que eu temo é que minha raiva se apague com o tempo."


func _on_interacted(_player: CharacterBody2D) -> void:
	print("[Kurapika] Interagindo com Kurapika...")
	QuestSystem.register_npc_visit(&"kurapika")

	var visual_dialogue = get_tree().get_first_node_in_group("visual_dialogue_ui")

	if visual_dialogue != null:
		var falas: Array[Dictionary] = []
		var nivel_nen = PlayerData.attributes.get("nivel_nen", 0) if PlayerData else 0
		var ja_e_blacklist = (PlayerData.faccao_atual == "blacklist") if PlayerData else false

		if ja_e_blacklist:
			var rank_nome = FactionManager.obter_nome_rank_atual() if FactionManager else "Rastreador"
			falas = [
				{"falante": "Kurapika", "texto": "Companheiro Caçador da Lista Negra (%s)..." % rank_nome},
				{"falante": "Kurapika", "texto": "Nossa missão não é apenas punir o crime, mas resgatar as relíquias culturais arrancadas de povos que não podem mais se defender."},
				{"falante": "Kurapika", "texto": "Alvos S-rank no Quadro de Bounties são caças abertas: party, threat compartilhado e loot por contribuição. Inicie Karkov ou Drakon quando estiver pronto."}
			]
			# Oferece atalho para a caça aberta mais próxima (Karkov)
			_oferecer_open_hunt_atalho()
		elif nivel_nen >= 8:
			falas = [
				{"falante": "Kurapika", "texto": "Você tem um olhar resoluto. O Nen que flui em seu corpo carrega peso e disciplina."},
				{"falante": "Kurapika", "texto": "Eu sou Kurapika, o último sobrevivente do Clã Kurta. Dediquei minha vida a caçar os monstros da Lista Negra e recuperar os Olhos Escarlates roubados do meu povo."},
				{"falante": "Kurapika", "texto": "Se você compartilha da busca pela justiça e está disposto a impor Restrições severas ao seu poder, junte-se aos Caçadores da Lista Negra!"},
				{"falante": "Kurapika", "texto": "Acesse a aba de Facções no Jornal de Missões [J] para selar sua aliança."}
			]
			if FactionManager and PlayerData.faccao_atual.is_empty():
				FactionManager.ingressar_faccao("blacklist")
				PlayerData.registrar_segredo("recrutado_blacklist")
		else:
			falas = [
				{"falante": "Kurapika", "texto": "Os criminosos da Lista Negra não hesitam em matar. Desenvolva seu Nen até o Nível 8 antes de tentar rastrear alvos de alto calibre."}
			]

		visual_dialogue.exibir_sequencia_falas(falas)
	else:
		falar_balao(fala_padrao, 3.8, Color(1.0, 0.3, 0.3, 1.0))


func _oferecer_open_hunt_atalho() -> void:
	# Sem UI modal aqui: se não houver caça ativa, deixa rumor + toast apontando o quadro
	if not BlacklistOpenHunt.active_hunts.is_empty():
		return
	if EventBus != null:
		EventBus.emit_toast("🏴 Abra o Quadro de Procurados [Lobby] para iniciar Caça Aberta", Color(1.0, 0.55, 0.35))
	if RumorSystem != null and RumorSystem.has_method("criar_rumor"):
		RumorSystem.criar_rumor(
			"rumor_blacklist_open_hint",
			"Caça Aberta disponível",
			"Karkov e Drakon estão no Quadro de Procurados como caças abertas S-rank.",
			"lobby",
			""
		)
