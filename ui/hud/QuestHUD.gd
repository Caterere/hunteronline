extends PanelContainer

# ============================================================
# HUNTER ONLINE - QUEST HUD EXCLUSIVO POR ARCO (MODO HISTÃ“RIA)
# ============================================================
#
# Interface de Quest no HUD (canto superior direito em 320x180):
# - Ativa automaticamente a MissÃ£o CanÃ´nica exclusiva do Arco Atual.
# - Exibe o Arco atual, tÃ­tulo da missÃ£o e objetivos com marcadores (âœ… / â¬œ).
# - BÃšSSOLA / DIRECIONADOR DINÃ‚MICO EM TEMPO REAL:
#   Rastreia a posiÃ§Ã£o dos NPCs de missÃ£o (Satotz, Gon, Hisoka, Wing, etc.)
#   ou monstros no mapa e calcula o Ã¢ngulo cardinal com setas e distÃ¢ncia em metros.
# - BotÃ£o minimizar [âˆ’] / [+] para recolher sem atrapalhar a visÃ£o do combate.
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
	7: "ELEIÃ‡ÃƒO HUNTER",
	8: "CONTINENTE NEGRO",
	9: "BLACK WHALE 1"
}


func _ready() -> void:
	# Garantir estilo e limpeza de nÃ³s duplicados
	for child in get_children():
		child.queue_free()

	_construir_ui()

	# Ativar automaticamente a quest do modo histÃ³ria para o arco atual
	if QuestSystem != null and PlayerData != null:
		QuestSystem.garantir_quest_do_arco(PlayerData.arco_atual)

	_atualizar_hud()


func _construir_ui() -> void:
	custom_minimum_size = Vector2(110, 20)
	size = Vector2(110, 48)
	set_anchors_preset(Control.PRESET_TOP_RIGHT)
	grow_horizontal = Control.GROW_DIRECTION_BEGIN
	offset_left = -114.0
	offset_top = 4.0
	offset_right = -4.0
	offset_bottom = 52.0

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
	margin.add_theme_constant_override("margin_left", 3)
	margin.add_theme_constant_override("margin_top", 2)
	margin.add_theme_constant_override("margin_right", 3)
	margin.add_theme_constant_override("margin_bottom", 2)
	add_child(margin)

	var vbox_main := VBoxContainer.new()
	vbox_main.add_theme_constant_override("separation", 1)
	margin.add_child(vbox_main)

	# Header (Arco + BotÃ£o Jornal + BotÃ£o Minimizar)
	var hbox_header := HBoxContainer.new()
	vbox_main.add_child(hbox_header)

	lbl_arco = Label.new()
	lbl_arco.text = "ðŸ¹ ARCO %d: %s" % [PlayerData.arco_atual, ARCO_NOMES.get(PlayerData.arco_atual, "HISTÃ“RIA")]
	lbl_arco.add_theme_font_size_override("font_size", 4)
	lbl_arco.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2, 1.0))
	lbl_arco.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox_header.add_child(lbl_arco)

	var btn_jornal := Button.new()
	btn_jornal.text = "ðŸ“œ"
	btn_jornal.tooltip_text = "Abrir Jornal de MissÃµes [J / Q]"
	btn_jornal.add_theme_font_size_override("font_size", 4)
	btn_jornal.custom_minimum_size = Vector2(10, 10)
	btn_jornal.pressed.connect(_abrir_jornal)
	hbox_header.add_child(btn_jornal)

	btn_toggle = Button.new()
	btn_toggle.text = "âˆ’"
	btn_toggle.add_theme_font_size_override("font_size", 4)
	btn_toggle.custom_minimum_size = Vector2(10, 10)
	btn_toggle.pressed.connect(_toggle_expandir)
	hbox_header.add_child(btn_toggle)

	# Detalhes da MissÃ£o
	vbox_detalhes = VBoxContainer.new()
	vbox_detalhes.add_theme_constant_override("separation", 1)
	vbox_main.add_child(vbox_detalhes)

	lbl_quest_nome = Label.new()
	lbl_quest_nome.text = "ðŸ“œ MissÃ£o Ativa"
	lbl_quest_nome.add_theme_font_size_override("font_size", 4)
	lbl_quest_nome.add_theme_color_override("font_color", Color(0.3, 0.9, 1.0, 1.0))
	lbl_quest_nome.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox_detalhes.add_child(lbl_quest_nome)

	lbl_objetivo = Label.new()
	lbl_objetivo.text = "- Carregando objetivo..."
	lbl_objetivo.add_theme_font_size_override("font_size", 4)
	lbl_objetivo.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9, 1.0))
	lbl_objetivo.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox_detalhes.add_child(lbl_objetivo)

	# BÃºssola & Direcionador de Rota
	lbl_bussola = Label.new()
	lbl_bussola.text = "ðŸ§­ DireÃ§Ã£o: Buscando..."
	lbl_bussola.add_theme_font_size_override("font_size", 4)
	lbl_bussola.add_theme_color_override("font_color", Color(0.3, 1.0, 0.5, 1.0))
	lbl_bussola.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox_detalhes.add_child(lbl_bussola)


func _toggle_expandir() -> void:
	_expandido = not _expandido
	vbox_detalhes.visible = _expandido
	btn_toggle.text = "âˆ’" if _expandido else "+"


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
		lbl_arco.text = "ðŸ›ï¸ PRAÃ‡A CENTRAL (LOBBY)"
		lbl_quest_nome.text = "ðŸ“œ Guia da Cidade dos CaÃ§adores"
		if not PlayerData.tour_lobby_concluido:
			lbl_objetivo.text = "ðŸ‘‰ Passo 1/2: Fale com a Recepcionista Elena\nâ¬œ Passo 2/2: Siga atÃ© o Portal Hunter a Leste"
			lbl_bussola.text = "ðŸ’¬ [E] Fale com Elena para conhecer os Mestres e Distritos!"
			lbl_bussola.add_theme_color_override("font_color", Color(0.3, 0.9, 1.0, 1.0))
		else:
			lbl_objetivo.text = "âœ… Passo 1/2: ApresentaÃ§Ã£o da Cidade ConcluÃ­da\nðŸ‘‰ Passo 2/2: Siga atÃ© o Portal Hunter a Leste"
			lbl_bussola.text = "â›©ï¸ Dirija-se ao Portal Hunter (Leste) para Iniciar a HistÃ³ria!"
			lbl_bussola.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3, 1.0))
		return

	# =========================================================
	# CONTEXTO 2: MAPA DE MISSÃƒO DA HISTÃ“RIA
	# =========================================================
	# Garantir que a quest do arco esteja ativa
	if QuestSystem.active_quests.is_empty():
		QuestSystem.garantir_quest_do_arco(PlayerData.arco_atual)

	var quests_ativas: Array = QuestSystem.active_quests
	if quests_ativas.is_empty():
		lbl_arco.text = "ðŸ¹ ARCO %d: %s" % [PlayerData.arco_atual, ARCO_NOMES.get(PlayerData.arco_atual, "HISTÃ“RIA")]
		lbl_quest_nome.text = "ðŸ“œ Sem MissÃ£o Ativa"
		lbl_objetivo.text = "Fale com os personagens da Ã¡rea para avanÃ§ar."
		lbl_bussola.text = "ðŸ—ºï¸ Explore o mapa da missÃ£o"
		return

	var quest: Quest = quests_ativas[0] as Quest
	if quest == null:
		return

	lbl_arco.text = "ðŸ¹ ARCO %d: %s" % [PlayerData.arco_atual, ARCO_NOMES.get(PlayerData.arco_atual, "HISTÃ“RIA")]
	lbl_quest_nome.text = "ðŸ“œ " + quest.quest_name

	var texto_obj: String = ""
	var objetivo_pendente: QuestObjective = null
	var pendente_idx: int = 0
	var total_objetivos: int = quest.objectives.size()

	for i in range(total_objetivos):
		var obj: QuestObjective = quest.objectives[i]
		var progresso: int = PlayerData.get_quest_objective_progress(quest, i)
		var completo: bool = progresso >= obj.required_amount
		
		var icone: String = "âœ… "
		if not completo:
			if objetivo_pendente == null:
				icone = "ðŸ‘‰ " # Requisito Atual Ativo
				objetivo_pendente = obj
				pendente_idx = i
			else:
				icone = "â¬œ "

		texto_obj += "%sPasso %d/%d: %s (%d/%d)\n" % [icone, i + 1, total_objetivos, obj.describe(), progresso, obj.required_amount]

	lbl_objetivo.text = texto_obj.strip_edges()

	# Calcular BÃºssola e DireÃ§Ã£o atÃ© o alvo
	_atualizar_bussola(objetivo_pendente, pendente_idx, total_objetivos)


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
		lbl_bussola.text = "âœ¨ Todos os requisitos cumpridos! MissÃ£o concluÃ­da."
		lbl_bussola.add_theme_color_override("font_color", Color(0.2, 1.0, 0.4, 1.0))
		return

	var player = _obter_player()
	if player == null:
		lbl_bussola.text = "ðŸ§­ Passo %d/%d: %s" % [pendente_idx + 1, total_objetivos, obj.describe()]
		lbl_bussola.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3, 1.0))
		return

	var alvo_pos := Vector2.ZERO
	var encontrou_alvo := false
	var nome_alvo := ""

	match obj.type:
		QuestObjective.Type.VISIT:
			var npcs := get_tree().get_nodes_in_group("npc")
			var target_str: String = String(obj.target_npc_id).to_lower()
			var target_name_str: String = obj.target_npc_name.to_lower()
			nome_alvo = obj.target_npc_name if not obj.target_npc_name.is_empty() else "NPC"

			for n in npcs:
				if n is Node2D and is_instance_valid(n):
					var n_name: String = n.name.to_lower()
					var n_custom: String = ""
					if "npc_name" in n:
						n_custom = String(n.npc_name).to_lower()

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

			# Se nÃ£o achou pelo nome exato, pega o primeiro NPC da cena
			if not encontrou_alvo and not npcs.is_empty() and npcs[0] is Node2D:
				alvo_pos = npcs[0].global_position
				encontrou_alvo = true

		QuestObjective.Type.KILL:
			var enemy_type_str = String(obj.enemy_type).to_lower()
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
					var e_id = String(esys.enemy_id).to_lower() if esys != null and "enemy_id" in esys else ""
					var e_name = String(esys.enemy_name).to_lower() if esys != null and "enemy_name" in esys else ""
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
					if esys != null and "enemy_name" in esys and not String(esys.enemy_name).is_empty():
						nome_alvo = String(esys.enemy_name)

		QuestObjective.Type.COLLECT:
			nome_alvo = String(obj.item_id).replace("_", " ").capitalize()
			var drops := get_tree().get_nodes_in_group("loot")
			if not drops.is_empty() and drops[0] is Node2D:
				alvo_pos = drops[0].global_position
				encontrou_alvo = true

	if not encontrou_alvo:
		var portais = get_tree().get_nodes_in_group("portal")
		if not portais.is_empty() and portais[0] is Node2D:
			alvo_pos = portais[0].global_position
			nome_alvo = "Portal de TransiÃ§Ã£o"
			encontrou_alvo = true

	var prefixo_passo = "ðŸ‘‰ Requisito %d/%d" % [pendente_idx + 1, total_objetivos]

	if encontrou_alvo:
		var dist = player.global_position.distance_to(alvo_pos)
		var metros = max(1, int(dist / 10.0))
		if dist <= 36.0:
			match obj.type:
				QuestObjective.Type.VISIT:
					lbl_bussola.text = "ðŸ’¬ [E] Fale com %s aqui!" % nome_alvo
					lbl_bussola.add_theme_color_override("font_color", Color(0.2, 1.0, 0.4, 1.0))
				QuestObjective.Type.KILL:
					lbl_bussola.text = "âš”ï¸ [Ataque] Derrote %s!" % nome_alvo
					lbl_bussola.add_theme_color_override("font_color", Color(1.0, 0.35, 0.35, 1.0))
				QuestObjective.Type.COLLECT:
					lbl_bussola.text = "ðŸŽ’ [E] Colete %s!" % nome_alvo
					lbl_bussola.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3, 1.0))
				_:
					lbl_bussola.text = "ðŸŽ¯ Alvo PrÃ³ximo: %s" % nome_alvo
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
			return "âš”ï¸ Derrote criaturas na Ã¡rea"
		QuestObjective.Type.VISIT:
			if not obj.target_npc_name.is_empty():
				return "ðŸ—£ï¸ Encontre " + obj.target_npc_name
			return "ðŸ—£ï¸ Fale com o NPC da histÃ³ria"
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
