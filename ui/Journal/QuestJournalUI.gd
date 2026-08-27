class_name QuestJournalUI
extends CanvasLayer

# ============================================================
# HUNTER ONLINE - JORNAL DE MISSÕES, FACÇÕES & SEGREDOS (3 ABAS)
# ============================================================
#
# Interface completa de Capítulos, Facções e Segredos de Hunter x Hunter:
# - ABA 1: Campanha dos 9 Arcos Canônicos (com capítulos individuais).
# - ABA 2: 6 Facções & Guildas (Trupe Fantasma, Zoldyck, Associação, Máfia, Gourmet, Blacklist).
# - ABA 3: Missões Secretas & Terciárias (com recompensas de Hatsu e Títulos Lendários).
# - Atalhos: [J] ou [Q], ou clicando no QuestHUD.
#
# ============================================================

signal fechado

enum Aba { CANONICA, FACCOES, SECRETAS }
var aba_atual: Aba = Aba.CANONICA

var selected_arc: int = 1
var selected_etapa: int = 1
var selected_faction_id: String = "genei_ryodan"
var selected_secret_id: String = "secret_kurta_vow"
var expanded_arcs: Dictionary = {1: true}

# Nós da UI
var btn_aba_canonica: Button
var btn_aba_faccoes: Button
var btn_aba_secretas: Button
var vbox_lista_esquerda: VBoxContainer
var lbl_detalhe_titulo: Label
var lbl_detalhe_status: Label
var lbl_detalhe_desc: Label
var vbox_objetivos: VBoxContainer
var lbl_recompensas: Label
var btn_acao_principal: Button
var btn_fechar: Button

const ARCO_INFOS: Dictionary = {
	1: {"nome": "Exame Hunter", "icone": "🏹", "cena": "res://world/maps/exame_maratona.tscn"},
	2: {"nome": "Montanha Kukuroo", "icone": "⛰️", "cena": "res://world/maps/montanha_kukuroo.tscn"},
	3: {"nome": "Arena Celestial", "icone": "🥋", "cena": "res://world/maps/arena_celestial.tscn"},
	4: {"nome": "Yorknew City", "icone": "🕷️", "cena": "res://world/maps/yorknew_city.tscn"},
	5: {"nome": "Greed Island", "icone": "🎮", "cena": "res://world/maps/greed_island.tscn"},
	6: {"nome": "Formigas Chimera", "icone": "🐜", "cena": "res://world/maps/ngl_formigas.tscn"},
	7: {"nome": "Eleição Hunter", "icone": "🗳️", "cena": "res://world/maps/associacao_hunter.tscn"},
	8: {"nome": "Continente Negro", "icone": "🌳", "cena": "res://world/maps/continente_negro.tscn"},
	9: {"nome": "Black Whale 1", "icone": "🚢", "cena": "res://world/maps/black_whale_1.tscn"}
}


func _ready() -> void:
	layer = 35
	visible = false
	selected_arc = PlayerData.arco_atual if PlayerData else 1
	selected_etapa = PlayerData.etapa_quest_arco if PlayerData else 1
	expanded_arcs[selected_arc] = true
	_construir_ui()


func alternar_menu() -> void:
	if visible:
		fechar()
	else:
		abrir()


func abrir() -> void:
	selected_arc = PlayerData.arco_atual if PlayerData else 1
	selected_etapa = PlayerData.etapa_quest_arco if PlayerData else 1
	expanded_arcs[selected_arc] = true
	visible = true
	_atualizar_abas()


func fechar() -> void:
	visible = false
	fechado.emit()


func _construir_ui() -> void:
	for c in get_children():
		c.queue_free()

	# Fundo Escurecido
	var bg := ColorRect.new()
	bg.color = Color(0, 0, 0, 0.8)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	# Janela Principal Centralizada
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(304, 168)
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.position = Vector2(8, 6)

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.06, 0.08, 0.12, 0.98)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.border_color = Color(0.95, 0.78, 0.25, 1.0)
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_right = 4
	style.corner_radius_bottom_left = 4
	panel.add_theme_stylebox_override("panel", style)
	add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 6)
	margin.add_theme_constant_override("margin_top", 4)
	margin.add_theme_constant_override("margin_right", 6)
	margin.add_theme_constant_override("margin_bottom", 4)
	panel.add_child(margin)

	var main_vbox := VBoxContainer.new()
	main_vbox.add_theme_constant_override("separation", 3)
	margin.add_child(main_vbox)

	# Topo: Cabeçalho com Abas de Navegação e Botão Fechar
	var hbox_header := HBoxContainer.new()
	main_vbox.add_child(hbox_header)

	btn_aba_canonica = Button.new()
	btn_aba_canonica.text = "📜 9 Arcos"
	btn_aba_canonica.add_theme_font_size_override("font_size", 4)
	btn_aba_canonica.pressed.connect(func():
		aba_atual = Aba.CANONICA
		_atualizar_abas()
	)
	hbox_header.add_child(btn_aba_canonica)

	btn_aba_faccoes = Button.new()
	btn_aba_faccoes.text = "⚜️ 6 Facções"
	btn_aba_faccoes.add_theme_font_size_override("font_size", 4)
	btn_aba_faccoes.pressed.connect(func():
		aba_atual = Aba.FACCOES
		_atualizar_abas()
	)
	hbox_header.add_child(btn_aba_faccoes)

	btn_aba_secretas = Button.new()
	btn_aba_secretas.text = "🔍 Segredos"
	btn_aba_secretas.add_theme_font_size_override("font_size", 4)
	btn_aba_secretas.pressed.connect(func():
		aba_atual = Aba.SECRETAS
		_atualizar_abas()
	)
	hbox_header.add_child(btn_aba_secretas)

	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox_header.add_child(spacer)

	btn_fechar = Button.new()
	btn_fechar.text = "✕ Fechar [ESC/J]"
	btn_fechar.add_theme_font_size_override("font_size", 4)
	btn_fechar.pressed.connect(fechar)
	hbox_header.add_child(btn_fechar)

	# Divisor de Conteúdo (Duas Colunas)
	var hbox_content := HBoxContainer.new()
	hbox_content.add_theme_constant_override("separation", 6)
	hbox_content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_vbox.add_child(hbox_content)

	# COLUNA ESQUERDA
	var scroll_left := ScrollContainer.new()
	scroll_left.custom_minimum_size = Vector2(130, 130)
	scroll_left.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	hbox_content.add_child(scroll_left)

	vbox_lista_esquerda = VBoxContainer.new()
	vbox_lista_esquerda.add_theme_constant_override("separation", 2)
	vbox_lista_esquerda.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll_left.add_child(vbox_lista_esquerda)

	# COLUNA DIREITA
	var panel_detalhes := PanelContainer.new()
	panel_detalhes.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel_detalhes.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	var style_det := StyleBoxFlat.new()
	style_det.bg_color = Color(0.03, 0.04, 0.07, 0.9)
	style_det.border_width_left = 1
	style_det.border_width_top = 1
	style_det.border_width_right = 1
	style_det.border_width_bottom = 1
	style_det.border_color = Color(0.3, 0.45, 0.65, 0.8)
	style_det.corner_radius_top_left = 3
	style_det.corner_radius_top_right = 3
	style_det.corner_radius_bottom_right = 3
	style_det.corner_radius_bottom_left = 3
	panel_detalhes.add_theme_stylebox_override("panel", style_det)
	hbox_content.add_child(panel_detalhes)

	var margin_det := MarginContainer.new()
	margin_det.add_theme_constant_override("margin_left", 6)
	margin_det.add_theme_constant_override("margin_top", 4)
	margin_det.add_theme_constant_override("margin_right", 6)
	margin_det.add_theme_constant_override("margin_bottom", 4)
	panel_detalhes.add_child(margin_det)

	var vbox_det := VBoxContainer.new()
	vbox_det.add_theme_constant_override("separation", 2)
	margin_det.add_child(vbox_det)

	lbl_detalhe_titulo = Label.new()
	lbl_detalhe_titulo.text = "Título"
	lbl_detalhe_titulo.add_theme_font_size_override("font_size", 5)
	lbl_detalhe_titulo.add_theme_color_override("font_color", Color(0.3, 0.9, 1.0, 1.0))
	lbl_detalhe_titulo.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox_det.add_child(lbl_detalhe_titulo)

	lbl_detalhe_status = Label.new()
	lbl_detalhe_status.text = "Status: [DISPONÍVEL]"
	lbl_detalhe_status.add_theme_font_size_override("font_size", 4)
	lbl_detalhe_status.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2, 1.0))
	vbox_det.add_child(lbl_detalhe_status)

	lbl_detalhe_desc = Label.new()
	lbl_detalhe_desc.text = "Descrição..."
	lbl_detalhe_desc.add_theme_font_size_override("font_size", 4)
	lbl_detalhe_desc.add_theme_color_override("font_color", Color(0.85, 0.85, 0.85, 1.0))
	lbl_detalhe_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox_det.add_child(lbl_detalhe_desc)

	var lbl_obj_header := Label.new()
	lbl_obj_header.name = "LblObjHeader"
	lbl_obj_header.text = "🎯 Detalhes / Objetivos:"
	lbl_obj_header.add_theme_font_size_override("font_size", 4)
	lbl_obj_header.add_theme_color_override("font_color", Color(1.0, 0.9, 0.4, 1.0))
	vbox_det.add_child(lbl_obj_header)

	var scroll_obj := ScrollContainer.new()
	scroll_obj.custom_minimum_size = Vector2(140, 34)
	scroll_obj.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox_det.add_child(scroll_obj)

	vbox_objetivos = VBoxContainer.new()
	vbox_objetivos.add_theme_constant_override("separation", 1)
	scroll_obj.add_child(vbox_objetivos)

	lbl_recompensas = Label.new()
	lbl_recompensas.text = "🎁 Recompensas:"
	lbl_recompensas.add_theme_font_size_override("font_size", 4)
	lbl_recompensas.add_theme_color_override("font_color", Color(0.4, 1.0, 0.5, 1.0))
	vbox_det.add_child(lbl_recompensas)

	btn_acao_principal = Button.new()
	btn_acao_principal.text = "▶ Ação"
	btn_acao_principal.add_theme_font_size_override("font_size", 4)
	vbox_det.add_child(btn_acao_principal)

	_atualizar_abas()


func _atualizar_abas() -> void:
	if btn_aba_canonica == null:
		return
		
	btn_aba_canonica.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3, 1.0) if aba_atual == Aba.CANONICA else Color(0.7, 0.7, 0.7, 1.0))
	btn_aba_faccoes.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3, 1.0) if aba_atual == Aba.FACCOES else Color(0.7, 0.7, 0.7, 1.0))
	btn_aba_secretas.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3, 1.0) if aba_atual == Aba.SECRETAS else Color(0.7, 0.7, 0.7, 1.0))

	match aba_atual:
		Aba.CANONICA:
			_renderizar_aba_canonica()
		Aba.FACCOES:
			_renderizar_aba_faccoes()
		Aba.SECRETAS:
			_renderizar_aba_secretas()


# ============================================================
# 1. ABA CANÔNICA (9 ARCOS)
# ============================================================
func _renderizar_aba_canonica() -> void:
	for c in vbox_lista_esquerda.get_children():
		c.queue_free()

	var max_liberado: int = max(1, PlayerData.max_arco_desbloqueado) if PlayerData else 1

	for arco_id in range(1, 10):
		var info = ARCO_INFOS.get(arco_id, {"nome": "Saga", "icone": "📜"})
		var total_etapas = CanonQuestCatalog.obter_total_quests_do_arco(arco_id)
		var is_desbloqueado: bool = arco_id <= max_liberado
		var is_expanded: bool = expanded_arcs.get(arco_id, false)
		
		var btn_arco := Button.new()
		var seta = "▼" if is_expanded else "▶"
		var lock_txt = "" if is_desbloqueado else " 🔒"
		btn_arco.text = "%s %s Arco %d: %s (%d Caps)%s" % [seta, info["icone"], arco_id, info["nome"], total_etapas, lock_txt]
		btn_arco.add_theme_font_size_override("font_size", 4)
		btn_arco.alignment = HORIZONTAL_ALIGNMENT_LEFT
		
		if arco_id == (PlayerData.arco_atual if PlayerData else 1):
			btn_arco.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2, 1.0))
		elif not is_desbloqueado:
			btn_arco.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5, 1.0))

		btn_arco.pressed.connect(func():
			expanded_arcs[arco_id] = not expanded_arcs.get(arco_id, false)
			_renderizar_aba_canonica()
		)
		vbox_lista_esquerda.add_child(btn_arco)

		if is_expanded:
			var container_caps := VBoxContainer.new()
			container_caps.add_theme_constant_override("separation", 1)
			vbox_lista_esquerda.add_child(container_caps)

			for etapa_id in range(1, total_etapas + 1):
				var quest_cap = CanonQuestCatalog.obter_quest_da_etapa(arco_id, etapa_id)
				var btn_cap := Button.new()
				
				var icone_status = "⬜"
				var p_arco = PlayerData.arco_atual if PlayerData else 1
				var p_etapa = PlayerData.etapa_quest_arco if PlayerData else 1
				
				if arco_id < p_arco or (arco_id == p_arco and etapa_id < p_etapa):
					icone_status = "✅"
				elif arco_id == p_arco and etapa_id == p_etapa:
					icone_status = "⏳"
				elif not is_desbloqueado:
					icone_status = "🔒"

				var nome_simplificado = quest_cap.quest_name
				if ":" in nome_simplificado:
					nome_simplificado = nome_simplificado.split(":")[1].strip_edges()

				btn_cap.text = "   %s %d/%d: %s" % [icone_status, etapa_id, total_etapas, nome_simplificado]
				btn_cap.add_theme_font_size_override("font_size", 3)
				btn_cap.alignment = HORIZONTAL_ALIGNMENT_LEFT
				
				if arco_id == selected_arc and etapa_id == selected_etapa:
					btn_cap.add_theme_color_override("font_color", Color(0.3, 0.9, 1.0, 1.0))

				btn_cap.pressed.connect(func():
					selected_arc = arco_id
					selected_etapa = etapa_id
					_atualizar_detalhe_canonico()
					_renderizar_aba_canonica()
				)
				container_caps.add_child(btn_cap)

	_atualizar_detalhe_canonico()


func _atualizar_detalhe_canonico() -> void:
	var quest = CanonQuestCatalog.obter_quest_da_etapa(selected_arc, selected_etapa)
	if quest == null:
		return

	var info_arco = ARCO_INFOS.get(selected_arc, {"nome": "Saga", "icone": "📜"})
	lbl_detalhe_titulo.text = "%s %s" % [info_arco["icone"], quest.quest_name]
	lbl_detalhe_desc.text = quest.description

	var is_atual: bool = (selected_arc == PlayerData.arco_atual and selected_etapa == PlayerData.etapa_quest_arco)
	var is_concluido: bool = (selected_arc < PlayerData.arco_atual or (selected_arc == PlayerData.arco_atual and selected_etapa < PlayerData.etapa_quest_arco))
	var is_desbloqueado: bool = selected_arc <= max(1, PlayerData.max_arco_desbloqueado)

	if is_atual:
		lbl_detalhe_status.text = "Status: ⏳ [EM ANDAMENTO / CAPÍTULO ATUAL]"
		lbl_detalhe_status.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2, 1.0))
		btn_acao_principal.text = "🧭 Rastrear Este Capítulo no GPS"
		btn_acao_principal.disabled = false
	elif is_concluido:
		lbl_detalhe_status.text = "Status: ✅ [CAPÍTULO JÁ CONCLUÍDO - JOGAR NOVAMENTE]"
		lbl_detalhe_status.add_theme_color_override("font_color", Color(0.3, 1.0, 0.4, 1.0))
		btn_acao_principal.text = "▶ Jogar Novamente Este Capítulo"
		btn_acao_principal.disabled = false
	elif is_desbloqueado:
		lbl_detalhe_status.text = "Status: 🔓 [DISPONÍVEL PARA JOGAR]"
		lbl_detalhe_status.add_theme_color_override("font_color", Color(0.3, 0.8, 1.0, 1.0))
		btn_acao_principal.text = "▶ Iniciar Este Capítulo Agora"
		btn_acao_principal.disabled = false
	else:
		lbl_detalhe_status.text = "Status: 🔒 [BLOQUEADO — Conclua os arcos anteriores]"
		lbl_detalhe_status.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6, 1.0))
		btn_acao_principal.text = "🔒 Bloqueado"
		btn_acao_principal.disabled = true

	for c in vbox_objetivos.get_children():
		c.queue_free()

	for i in range(quest.objectives.size()):
		var obj = quest.objectives[i]
		var prog = PlayerData.get_quest_objective_progress(quest, i) if is_atual else (obj.required_amount if is_concluido else 0)
		var completo = prog >= obj.required_amount
		var icone = "✅ " if completo else "⬜ "
		
		var lbl_obj := Label.new()
		lbl_obj.text = "%s%s (%d/%d)" % [icone, obj.describe(), prog, obj.required_amount]
		lbl_obj.add_theme_font_size_override("font_size", 3)
		lbl_obj.add_theme_color_override("font_color", Color(0.3, 1.0, 0.5, 1.0) if completo else Color(0.9, 0.9, 0.9, 1.0))
		vbox_objetivos.add_child(lbl_obj)

	lbl_recompensas.text = "🎁 Recompensas: +%d XP  |  +%d Jenny (Gold)" % [quest.reward_xp, quest.reward_gold]
	
	if btn_acao_principal.pressed.is_connected(_on_iniciar_missao_clicado):
		btn_acao_principal.pressed.disconnect(_on_iniciar_missao_clicado)
	btn_acao_principal.pressed.connect(_on_iniciar_missao_clicado)


func _on_iniciar_missao_clicado() -> void:
	var quest = CanonQuestCatalog.obter_quest_da_etapa(selected_arc, selected_etapa)
	if quest == null:
		return

	PlayerData.arco_atual = selected_arc
	PlayerData.etapa_quest_arco = selected_etapa
	
	if QuestSystem != null:
		QuestSystem.active_quests.clear()
		QuestSystem.start_quest(quest)

	fechar()

	var hud = get_tree().get_first_node_in_group("player_hud")
	if hud != null and hud.has_method("exibir_notificacao"):
		hud.exibir_notificacao("📜 Missão Ativa: %s" % quest.quest_name)

	var info_arco = ARCO_INFOS.get(selected_arc)
	if info_arco != null and "cena" in info_arco:
		var cena_mapa = info_arco["cena"]
		var cena_atual = get_tree().current_scene.scene_file_path if get_tree().current_scene else ""
		if cena_atual != cena_mapa:
			print("[QuestJournalUI] Viajando para o mapa do capítulo: ", cena_mapa)
			var trans = get_node_or_null("/root/SceneTransition")
			if trans != null and trans.has_method("mudar_cena"):
				trans.mudar_cena(cena_mapa)
			else:
				get_tree().change_scene_to_file(cena_mapa)


# ============================================================
# 2. ABA FACÇÕES & GUILDAS
# ============================================================
func _renderizar_aba_faccoes() -> void:
	for c in vbox_lista_esquerda.get_children():
		c.queue_free()

	for f_id in FactionManager.DADOS_FACCOES.keys():
		var faccao_data = FactionManager.DADOS_FACCOES[f_id]
		var btn_f := Button.new()
		var is_minha = (PlayerData.faccao_atual == f_id) if PlayerData else false
		var tag = " [FILIADO]" if is_minha else ""
		
		btn_f.text = "%s%s" % [faccao_data["nome"], tag]
		btn_f.add_theme_font_size_override("font_size", 4)
		btn_f.alignment = HORIZONTAL_ALIGNMENT_LEFT
		
		if f_id == selected_faction_id:
			btn_f.add_theme_color_override("font_color", Color(0.3, 0.9, 1.0, 1.0))
		elif is_minha:
			btn_f.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2, 1.0))

		btn_f.pressed.connect(func():
			selected_faction_id = f_id
			_renderizar_aba_faccoes()
		)
		vbox_lista_esquerda.add_child(btn_f)

	_atualizar_detalhe_faccao()


func _atualizar_detalhe_faccao() -> void:
	if not FactionManager.DADOS_FACCOES.has(selected_faction_id):
		return
		
	var faccao = FactionManager.DADOS_FACCOES[selected_faction_id]
	var is_minha = (PlayerData.faccao_atual == selected_faction_id) if PlayerData else false
	
	lbl_detalhe_titulo.text = "%s (Líder: %s)" % [faccao["nome"], faccao["lider"]]
	lbl_detalhe_desc.text = faccao["descricao"]
	
	if is_minha:
		var rank_nome = FactionManager.obter_nome_rank_atual()
		lbl_detalhe_status.text = "Status: ⚜️ [MEMBRO OFICIAL — %s]" % rank_nome
		lbl_detalhe_status.add_theme_color_override("font_color", Color(0.3, 1.0, 0.4, 1.0))
		btn_acao_principal.text = "⚜️ Você já é membro desta Organização"
		btn_acao_principal.disabled = true
	else:
		var nivel_nen = PlayerData.attributes.get("nivel_nen", 0) if PlayerData else 0
		var req = faccao["requisito_nen"]
		if nivel_nen >= req:
			lbl_detalhe_status.text = "Status: 🔓 [QUALIFICADO PARA INGRESSAR (Nen Lv.%d)]" % req
			lbl_detalhe_status.add_theme_color_override("font_color", Color(0.3, 0.9, 1.0, 1.0))
			btn_acao_principal.text = "🤝 Jurar Lealdade & Ingressar"
			btn_acao_principal.disabled = false
		else:
			lbl_detalhe_status.text = "Status: 🔒 [BLOQUEADO — Requer Nen Lv.%d]" % req
			lbl_detalhe_status.add_theme_color_override("font_color", Color(0.7, 0.3, 0.3, 1.0))
			btn_acao_principal.text = "🔒 Nível de Nen Insuficiente"
			btn_acao_principal.disabled = true

	for c in vbox_objetivos.get_children():
		c.queue_free()

	for perk in faccao["perks"]:
		var lbl_p := Label.new()
		lbl_p.text = "⭐ %s" % perk
		lbl_p.add_theme_font_size_override("font_size", 3)
		lbl_p.add_theme_color_override("font_color", Color(0.95, 0.9, 0.4, 1.0))
		vbox_objetivos.add_child(lbl_p)

	lbl_recompensas.text = "🎁 Título Exclusivo de Entrada: [%s]" % faccao["ranks"][1]["titulo"]

	if btn_acao_principal.pressed.is_connected(_on_iniciar_missao_clicado):
		btn_acao_principal.pressed.disconnect(_on_iniciar_missao_clicado)
	if btn_acao_principal.pressed.is_connected(_on_ingressar_faccao_clicado):
		btn_acao_principal.pressed.disconnect(_on_ingressar_faccao_clicado)
	btn_acao_principal.pressed.connect(_on_ingressar_faccao_clicado)


func _on_ingressar_faccao_clicado() -> void:
	if FactionManager:
		FactionManager.ingressar_faccao(selected_faction_id)
		_renderizar_aba_faccoes()


# ============================================================
# 3. ABA MISSÕES SECRETAS & TERCIÁRIAS
# ============================================================
func _renderizar_aba_secretas() -> void:
	for c in vbox_lista_esquerda.get_children():
		c.queue_free()

	var lista_secrets = SecretQuestCatalog.obter_todas_missoes_secretas()
	for s_info in lista_secrets:
		var btn_s := Button.new()
		var ja_descoberto = (PlayerData.segredos_descobertos.has(s_info["id"])) if PlayerData else false
		var icone = "✅" if ja_descoberto else "🔍"
		
		btn_s.text = "%s %s" % [icone, s_info["nome"]]
		btn_s.add_theme_font_size_override("font_size", 3)
		btn_s.alignment = HORIZONTAL_ALIGNMENT_LEFT
		
		if s_info["id"] == selected_secret_id:
			btn_s.add_theme_color_override("font_color", Color(0.3, 0.9, 1.0, 1.0))
		elif ja_descoberto:
			btn_s.add_theme_color_override("font_color", Color(0.3, 1.0, 0.5, 1.0))

		btn_s.pressed.connect(func():
			selected_secret_id = s_info["id"]
			_renderizar_aba_secretas()
		)
		vbox_lista_esquerda.add_child(btn_s)

	_atualizar_detalhe_secreto()


func _atualizar_detalhe_secreto() -> void:
	var lista_secrets = SecretQuestCatalog.obter_todas_missoes_secretas()
	var s_info: Dictionary = {}
	for s in lista_secrets:
		if s["id"] == selected_secret_id:
			s_info = s
			break
			
	if s_info.is_empty():
		return

	var ja_descoberto = (PlayerData.segredos_descobertos.has(s_info["id"])) if PlayerData else false
	
	lbl_detalhe_titulo.text = "%s (NPC: %s)" % [s_info["nome"], s_info["npc"]]
	lbl_detalhe_desc.text = s_info["lore"]
	
	if ja_descoberto:
		lbl_detalhe_status.text = "Status: ✅ [SEGREDO DESCOBERTO & RECOMPENSA OBTIDA]"
		lbl_detalhe_status.add_theme_color_override("font_color", Color(0.3, 1.0, 0.4, 1.0))
		btn_acao_principal.text = "✅ Segredo Já Concluído"
		btn_acao_principal.disabled = true
	else:
		lbl_detalhe_status.text = "Status: 🔍 [REQUISITO: %s]" % s_info["requisito"]
		lbl_detalhe_status.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2, 1.0))
		btn_acao_principal.text = "🧭 Aceitar & Rastrear no GPS"
		btn_acao_principal.disabled = false

	for c in vbox_objetivos.get_children():
		c.queue_free()

	var lbl_req := Label.new()
	lbl_req.text = "📍 Local / Condição de Gatilho: %s" % s_info["requisito"]
	lbl_req.add_theme_font_size_override("font_size", 3)
	lbl_req.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9, 1.0))
	vbox_objetivos.add_child(lbl_req)

	lbl_recompensas.text = "🎁 Recompensa Secreta: %s" % s_info["recompensa_desc"]

	if btn_acao_principal.pressed.is_connected(_on_iniciar_missao_clicado):
		btn_acao_principal.pressed.disconnect(_on_iniciar_missao_clicado)
	if btn_acao_principal.pressed.is_connected(_on_ingressar_faccao_clicado):
		btn_acao_principal.pressed.disconnect(_on_ingressar_faccao_clicado)
	if btn_acao_principal.pressed.is_connected(_on_aceitar_secret_clicado):
		btn_acao_principal.pressed.disconnect(_on_aceitar_secret_clicado)
	btn_acao_principal.pressed.connect(_on_aceitar_secret_clicado)


func _on_aceitar_secret_clicado() -> void:
	var q = SecretQuestCatalog.criar_quest_secreta(selected_secret_id)
	if q and QuestSystem:
		QuestSystem.start_quest(q)
		fechar()
		var hud = get_tree().get_first_node_in_group("player_hud")
		if hud and hud.has_method("exibir_notificacao"):
			hud.exibir_notificacao("🔍 Nova Missão Secreta Ativa: %s" % q.quest_name)
