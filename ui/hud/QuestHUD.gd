extends PanelContainer

# ============================================================
# HUNTER ONLINE - QUEST HUD EXCLUSIVO POR ARCO (MODO HISTÓRIA)
# ============================================================
#
# Interface de Quest no HUD (canto superior direito em 320x180):
# - Ativa automaticamente a Missão CanÃ´nica exclusiva do Arco Atual.
# - Exibe o Arco atual, título da missão e objetivos com marcadores (✅ / ⬜).
# - BÚSSOLA / DIRECIONADOR DINÃ‚MICO EM TEMPO REAL:
#   Rastreia a posição dos NPCs de missão (Satotz, Gon, Hisoka, Wing, etc.)
#   ou monstros no mapa e calcula o ângulo cardinal com setas e distância em metros.
# - Botão minimizar [âˆ’] / [+] para recolher sem atrapalhar a visão do combate.
#
# ============================================================

var lbl_arco: Label
var lbl_quest_nome: Label
var lbl_objetivo: Label
var lbl_bussola: Label
var btn_toggle: Button
var vbox_detalhes: VBoxContainer

var _timer_update: float = 0.0
var _expandido: bool = true
var _player_ref: Node2D = null

const ARCO_NOMES: Dictionary = {
	1: "EXAME HUNTER",
	2: "MONTANHA KUKUROO",
	3: "ARENA CELESTIAL",
	4: "YORKNEW CITY",
	5: "GREED ISLAND",
	6: "FORMIGAS CHIMERA",
	7: "ELEIÇÃO HUNTER",
	8: "CONTINENTE NEGRO",
	9: "BLACK WHALE 1"
}


func _ready() -> void:
	for child in get_children():
		child.queue_free()

	_construir_ui()

	if QuestSystem != null and PlayerData != null:
		QuestSystem.garantir_quest_do_arco(PlayerData.arco_atual)

	_atualizar_hud()


func _construir_ui() -> void:
	custom_minimum_size = Vector2(132, 20)
	set_anchors_preset(Control.PRESET_TOP_RIGHT)
	grow_horizontal = Control.GROW_DIRECTION_BEGIN
	grow_vertical = Control.GROW_DIRECTION_END
	offset_left = -138.0
	offset_top = 6.0
	offset_right = -6.0

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.06, 0.08, 0.12, 0.92)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.border_color = Color(0.9, 0.75, 0.2, 0.95)
	style.corner_radius_top_left = 3
	style.corner_radius_top_right = 3
	style.corner_radius_bottom_right = 3
	style.corner_radius_bottom_left = 3
	add_theme_stylebox_override("panel", style)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 4)
	margin.add_theme_constant_override("margin_top", 3)
	margin.add_theme_constant_override("margin_right", 4)
	margin.add_theme_constant_override("margin_bottom", 3)
	add_child(margin)

	var vbox_main := VBoxContainer.new()
	vbox_main.add_theme_constant_override("separation", 1)
	margin.add_child(vbox_main)

	# Header (Arco + Botão Jornal + Botão Minimizar)
	var hbox_header := HBoxContainer.new()
	vbox_main.add_child(hbox_header)

	lbl_arco = Label.new()
	lbl_arco.text = "🏛️ ARCO %d: %s" % [PlayerData.arco_atual, ARCO_NOMES.get(PlayerData.arco_atual, "HISTÓRIA")]
	lbl_arco.add_theme_font_size_override("font_size", 7)
	lbl_arco.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2, 1.0))
	lbl_arco.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox_header.add_child(lbl_arco)

	var btn_jornal := Button.new()
	btn_jornal.text = "📜"
	btn_jornal.tooltip_text = "Abrir Jornal de Missões [J]"
	btn_jornal.add_theme_font_size_override("font_size", 7)
	btn_jornal.custom_minimum_size = Vector2(13, 12)
	btn_jornal.pressed.connect(_abrir_jornal)
	hbox_header.add_child(btn_jornal)

	btn_toggle = Button.new()
	btn_toggle.text = "−"
	btn_toggle.add_theme_font_size_override("font_size", 7)
	btn_toggle.custom_minimum_size = Vector2(12, 12)
	btn_toggle.pressed.connect(_toggle_expandir)
	hbox_header.add_child(btn_toggle)

	# Detalhes da Missão
	vbox_detalhes = VBoxContainer.new()
	vbox_detalhes.add_theme_constant_override("separation", 1)
	vbox_main.add_child(vbox_detalhes)

	lbl_quest_nome = Label.new()
	lbl_quest_nome.text = "📜 Missão Ativa"
	lbl_quest_nome.add_theme_font_size_override("font_size", 6)
	lbl_quest_nome.add_theme_color_override("font_color", Color(0.3, 0.9, 1.0, 1.0))
	lbl_quest_nome.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox_detalhes.add_child(lbl_quest_nome)

	lbl_objetivo = Label.new()
	lbl_objetivo.text = "- Carregando objetivo..."
	lbl_objetivo.add_theme_font_size_override("font_size", 6)
	lbl_objetivo.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9, 1.0))
	lbl_objetivo.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox_detalhes.add_child(lbl_objetivo)

	# Bússola & Direcionador de Rota
	lbl_bussola = Label.new()
	lbl_bussola.text = "🧭 Direção: Buscando..."
	lbl_bussola.add_theme_font_size_override("font_size", 6)
	lbl_bussola.add_theme_color_override("font_color", Color(0.3, 1.0, 0.5, 1.0))
	lbl_bussola.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox_detalhes.add_child(lbl_bussola)


func _toggle_expandir() -> void:
	_expandido = not _expandido
	vbox_detalhes.visible = _expandido
	btn_toggle.text = "−" if _expandido else "+"


func _process(delta: float) -> void:
	_timer_update += delta
	if _timer_update >= 0.2:
		_timer_update = 0.0
		_atualizar_hud()


func _atualizar_hud() -> void:
	if QuestSystem == null or PlayerData == null:
		return

	var tree := get_tree()
	if tree == null:
		return

	var cur_scn := tree.current_scene
	if cur_scn == null:
		return

	var cena_atual: String = cur_scn.scene_file_path.to_lower() if cur_scn.scene_file_path != null else ""
	var is_lobby: bool = ("lobby" in cena_atual or cur_scn.name == "Lobby")

	# =========================================================
	# CONTEXTO 1: LOBBY HUB
	# =========================================================
	if is_lobby:
		lbl_arco.text = "🏛️ PRAÇA CENTRAL (LOBBY)"
		lbl_quest_nome.text = "📜 Guia da Cidade dos Caçadores"
		if not PlayerData.tour_lobby_concluido:
			lbl_objetivo.text = "👉 Passo 1/2: Fale com a Recepcionista Elena\n⬜ Passo 2/2: Siga até o Portal Hunter a Leste"
			lbl_bussola.text = "💬 [E] Fale com Elena para conhecer os Mestres e Distritos!"
			lbl_bussola.add_theme_color_override("font_color", Color(0.3, 0.9, 1.0, 1.0))
		else:
			lbl_objetivo.text = "✅ Passo 1/2: Apresentação da Cidade Concluída\n👉 Passo 2/2: Siga até o Portal Hunter a Leste"
			lbl_bussola.text = "⛩️ Dirija-se ao Portal Hunter (Leste) para Iniciar a História!"
			lbl_bussola.add_theme_color_override("font_color", Color(0.3, 1.0, 0.5, 1.0))
		return

	# =========================================================
	# CONTEXTO 2: MISSÃO ATIVA DA SAGA
	# =========================================================
	var quest: Quest = QuestSystem.active_quests[0] if (QuestSystem != null and not QuestSystem.active_quests.is_empty()) else null
	if quest == null and QuestSystem != null and QuestSystem.has_method("garantir_quest_do_arco"):
		QuestSystem.garantir_quest_do_arco(PlayerData.arco_atual)
		if not QuestSystem.active_quests.is_empty():
			quest = QuestSystem.active_quests[0]
	if quest == null:
		lbl_arco.text = "🏛️ ARCO %d: %s" % [PlayerData.arco_atual, ARCO_NOMES.get(PlayerData.arco_atual, "HISTÓRIA")]
		lbl_quest_nome.text = "📜 Sem Missão Ativa"
		lbl_objetivo.text = "Aguardando início de novo arco narrativo..."
		lbl_bussola.text = "Explore o mundo e converse com os cidadãos."
		lbl_bussola.add_theme_color_override("font_color", Color(0.7, 0.8, 0.9, 1.0))
		return

	lbl_arco.text = "🏛️ ARCO %d: %s" % [PlayerData.arco_atual, ARCO_NOMES.get(PlayerData.arco_atual, "HISTÓRIA")]
	lbl_quest_nome.text = "📜 " + quest.quest_name

	var mand_text: String = ""
	var opt_text: String = ""
	var objetivo_pendente: QuestObjective = null
	var pendente_idx: int = 0
	var total_objetivos: int = quest.objectives.size()

	for i in range(total_objetivos):
		var obj: QuestObjective = quest.objectives[i]
		var progresso: int = PlayerData.get_quest_objective_progress(quest, i)
		var completo: bool = progresso >= obj.required_amount
		var is_optional: bool = obj.is_optional if "is_optional" in obj else false
		
		var icone: String = "✓ "
		if not completo:
			if objetivo_pendente == null:
				icone = "○ " # Objetivo Atual em Andamento
				objetivo_pendente = obj
				pendente_idx = i
			else:
				icone = "🔒 " # Passo Futuro

		var linha: String = "%sPasso %d/%d: %s (%d/%d)\n" % [icone, i + 1, total_objetivos, obj.describe(), progresso, obj.required_amount]
		if is_optional:
			opt_text += linha
		else:
			mand_text += linha

	# Cálculo de Progresso Canônico da Saga
	var pct_saga: float = 0.0
	if StoryManager != null and StoryManager.has_method("obter_progresso_saga_atual"):
		pct_saga = StoryManager.obter_progresso_saga_atual()
	else:
		pct_saga = clampf((float(PlayerData.etapa_quest_arco) / max(1.0, float(total_objetivos))) * 100.0, 0.0, 100.0)

	var barra_ascii: String = _gerar_barra_progresso_ascii(pct_saga, 10)

	# Seção de Atividades Secundárias (Fase F - Seção 5)
	var atividades_texto: String = "\n📋 ATIVIDADES"
	var treino_status: String = "Disponível com Instrutores"
	if StoryManager != null and StoryManager.get_story_flag("zaban_treino_concluido", false):
		treino_status = "Básico de Ten Concluído"
	atividades_texto += "\n○ Treino: " + treino_status

	# Verificar Side Quests ativas
	var side_quest_nome: String = "Nenhuma ativa"
	if QuestSystem != null and QuestSystem.active_quests.size() > 1:
		side_quest_nome = QuestSystem.active_quests[1].quest_name
	elif SurpriseQuestSystem != null and SurpriseQuestSystem.has_method("tem_missao_ativa") and SurpriseQuestSystem.tem_missao_ativa():
		side_quest_nome = SurpriseQuestSystem.obter_nome_missao_ativa()
	atividades_texto += "\n○ Side Quest: " + side_quest_nome

	var evento_txt: String = "Região Segura"
	if WorldEventManager != null and WorldEventManager.has_method("obter_eventos_ativos"):
		var evs = WorldEventManager.obter_eventos_ativos()
		if not evs.is_empty():
			evento_txt = evs[0].get("titulo", "Alerta Local")
	atividades_texto += "\n○ Evento: " + evento_txt

	var final_obj_text := "HISTÓRIA PRINCIPAL\nProgresso: %s\n\n%s" % [
		barra_ascii,
		mand_text.strip_edges()
	]
	if not opt_text.is_empty():
		final_obj_text += "\n\n🎯 OPCIONAIS:\n" + opt_text.strip_edges()

	final_obj_text += "\n" + atividades_texto

	lbl_objetivo.text = final_obj_text

	# Calcular Bússola e Direção até o alvo
	_atualizar_bussola(objetivo_pendente, pendente_idx, total_objetivos)


func _gerar_barra_progresso_ascii(percentual: float, blocos_total: int = 10) -> String:
	var preenchidos: int = int(round((clampf(percentual, 0.0, 100.0) / 100.0) * float(blocos_total)))
	var vazios: int = blocos_total - preenchidos
	var barra: String = "["
	for j in range(preenchidos):
		barra += "█"
	for k in range(vazios):
		barra += "░"
	barra += "] %d%%" % int(round(percentual))
	return barra


func _obter_player() -> Node2D:
	if _player_ref != null and is_instance_valid(_player_ref):
		return _player_ref
	var players := get_tree().get_nodes_in_group("player")
	if not players.is_empty():
		_player_ref = players[0] as Node2D
		return _player_ref
	return null


func _atualizar_bussola(obj: QuestObjective, pendente_idx: int = 0, total_objetivos: int = 1) -> void:
	if obj == null:
		lbl_bussola.text = "✅ Todos os requisitos cumpridos! Missão concluída."
		lbl_bussola.add_theme_color_override("font_color", Color(0.2, 1.0, 0.4, 1.0))
		return

	var player = _obter_player()
	if player == null:
		lbl_bussola.text = "🧭 Passo %d/%d: %s" % [pendente_idx + 1, total_objetivos, obj.describe()]
		lbl_bussola.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3, 1.0))
		return

	var alvo_pos := Vector2.ZERO
	var encontrou_alvo := false
	var nome_alvo := ""

	match obj.type:
		QuestObjective.Type.VISIT:
			var npcs := get_tree().get_nodes_in_group("npc")
			var target_str: String = str(obj.target_npc_id).to_lower()
			var target_name_str: String = obj.target_npc_name.to_lower()
			nome_alvo = obj.target_npc_name if not obj.target_npc_name.is_empty() else "NPC"

			for n in npcs:
				if n is Node2D and is_instance_valid(n):
					var n_name: String = n.name.to_lower()
					var n_custom: String = ""
					if "npc_name" in n:
						n_custom = str(n.npc_name).to_lower()

					var bateu: bool = (
						target_str in n_name
						or n_name in target_str
						or target_name_str in n_name
						or (!n_custom.is_empty() and (target_str in n_custom or target_name_str in n_custom or n_custom in target_name_str))
					)

					if bateu:
						alvo_pos = n.global_position
						encontrou_alvo = true
						break

			# Se não achou pelo nome exato, pega o primeiro NPC da cena
			if not encontrou_alvo and not npcs.is_empty() and npcs[0] is Node2D:
				alvo_pos = npcs[0].global_position
				encontrou_alvo = true

		QuestObjective.Type.KILL:
			var enemy_type_str = str(obj.enemy_type).to_lower()
			nome_alvo = "Inimigos" if enemy_type_str.is_empty() else enemy_type_str.replace("_", " ").capitalize()
			var enemies := get_tree().get_nodes_in_group("enemies")
			if enemies.is_empty():
				enemies = get_tree().get_nodes_in_group("enemy")
			
			var living_matching: Array[Node2D] = []
			var living_all: Array[Node2D] = []
			var keywords = enemy_type_str.split("_")

			for e in enemies:
				if e is Node2D and is_instance_valid(e) and not e.is_queued_for_deletion():
					var esys = e.get_node_or_null("EnemySystem")
					if esys != null and ("is_dead" in esys and esys.is_dead):
						continue
					living_all.append(e)
					var e_id = str(esys.enemy_id).to_lower() if esys != null and "enemy_id" in esys else ""
					var e_name = str(esys.enemy_name).to_lower() if esys != null and "enemy_name" in esys else ""
					var n_name = e.name.to_lower()
					var bate: bool = (enemy_type_str.is_empty() or enemy_type_str in e_id or e_id in enemy_type_str or enemy_type_str in n_name or enemy_type_str in e_name)
					if not bate:
						for kw in keywords:
							if kw.length() >= 4 and (kw in e_id or kw in n_name or kw in e_name):
								bate = true
								break
					if bate:
						living_matching.append(e)

			var pool = living_matching if not living_matching.is_empty() else living_all
			var menor_dist: float = 999999.0
			for e in pool:
				var d = player.global_position.distance_to(e.global_position)
				if d < menor_dist:
					menor_dist = d
					alvo_pos = e.global_position
					encontrou_alvo = true
					var esys = e.get_node_or_null("EnemySystem")
					if esys != null and "enemy_name" in esys and not str(esys.enemy_name).is_empty():
						nome_alvo = str(esys.enemy_name)

		QuestObjective.Type.COLLECT:
			nome_alvo = str(obj.item_id).replace("_", " ").capitalize()
			var drops := get_tree().get_nodes_in_group("loot")
			if not drops.is_empty() and drops[0] is Node2D:
				alvo_pos = drops[0].global_position
				encontrou_alvo = true

	if not encontrou_alvo:
		var portais = get_tree().get_nodes_in_group("portal")
		if not portais.is_empty() and portais[0] is Node2D:
			alvo_pos = portais[0].global_position
			nome_alvo = "Portal de Transição"
			encontrou_alvo = true

	var prefixo_passo = "👉 Requisito %d/%d" % [pendente_idx + 1, total_objetivos]

	if encontrou_alvo:
		var dist = player.global_position.distance_to(alvo_pos)
		var metros = max(1, int(dist / 10.0))
		if dist <= 36.0:
			match obj.type:
				QuestObjective.Type.VISIT:
					lbl_bussola.text = "💬 [E] Fale com %s aqui!" % nome_alvo
					lbl_bussola.add_theme_color_override("font_color", Color(0.2, 1.0, 0.4, 1.0))
				QuestObjective.Type.KILL:
					lbl_bussola.text = "⚔️ [Ataque] Derrote %s!" % nome_alvo
					lbl_bussola.add_theme_color_override("font_color", Color(1.0, 0.35, 0.35, 1.0))
				QuestObjective.Type.COLLECT:
					lbl_bussola.text = "ðŸŽ’ [E] Colete %s!" % nome_alvo
					lbl_bussola.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3, 1.0))
				_:
					lbl_bussola.text = "🎯 Alvo Próximo: %s" % nome_alvo
					lbl_bussola.add_theme_color_override("font_color", Color(0.2, 1.0, 0.4, 1.0))
		else:
			var dir_vec = (alvo_pos - player.global_position).normalized()
			var seta = _vetor_para_seta(dir_vec)
			match obj.type:
				QuestObjective.Type.VISIT:
					lbl_bussola.text = "%s: Fale com %s\nâž” %s (%dm)" % [prefixo_passo, nome_alvo, seta, metros]
					lbl_bussola.add_theme_color_override("font_color", Color(0.3, 0.9, 1.0, 1.0))
				QuestObjective.Type.KILL:
					lbl_bussola.text = "%s: Derrote %s\nâž” %s (%dm)" % [prefixo_passo, nome_alvo, seta, metros]
					lbl_bussola.add_theme_color_override("font_color", Color(1.0, 0.4, 0.4, 1.0))
				_:
					lbl_bussola.text = "%s: %s\nâž” %s (%dm)" % [prefixo_passo, nome_alvo, seta, metros]
					lbl_bussola.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3, 1.0))
	else:
		lbl_bussola.text = "%s: %s" % [prefixo_passo, _obter_dica_estatica(obj)]
		lbl_bussola.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3, 1.0))


func _vetor_para_seta(dir: Vector2) -> String:
	var angle_deg = rad_to_deg(dir.angle())
	if angle_deg >= -22.5 and angle_deg < 22.5:
		return "âž¡ï¸ Leste"
	elif angle_deg >= 22.5 and angle_deg < 67.5:
		return "â†˜ï¸ Sudeste"
	elif angle_deg >= 67.5 and angle_deg < 112.5:
		return "â¬‡ï¸ Sul"
	elif angle_deg >= 112.5 and angle_deg < 157.5:
		return "â†™ï¸ Sudoeste"
	elif angle_deg >= -67.5 and angle_deg < -22.5:
		return "â†—ï¸ Nordeste"
	elif angle_deg >= -112.5 and angle_deg < -67.5:
		return "â¬†ï¸ Norte"
	elif angle_deg >= -157.5 and angle_deg < -112.5:
		return "â†–ï¸ Noroeste"
	else:
		return "â¬…ï¸ Oeste"


func _obter_dica_estatica(obj: QuestObjective) -> String:
	match obj.type:
		QuestObjective.Type.KILL:
			return "⚔️ Derrote criaturas na área"
		QuestObjective.Type.VISIT:
			if not obj.target_npc_name.is_empty():
				return "ðŸ—£ï¸ Encontre " + obj.target_npc_name
			return "ðŸ—£ï¸ Fale com o NPC da história"
		QuestObjective.Type.COLLECT:
			return "ðŸŽ’ Colete itens e cartas no mapa"
	return "Siga em frente no caminho"


func _abrir_jornal() -> void:
	var j_ui = get_tree().root.get_node_or_null("QuestJournalUI")
	if j_ui != null and j_ui.has_method("alternar_menu"):
		j_ui.alternar_menu()
	else:
		var hud = get_tree().get_first_node_in_group("player_hud")
		if hud != null:
			var journal = hud.get_node_or_null("QuestJournalUI")
			if journal != null and journal.has_method("alternar_menu"):
				journal.alternar_menu()
