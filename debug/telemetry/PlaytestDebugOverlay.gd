class_name PlaytestDebugOverlay
extends CanvasLayer

# ============================================================
# HUNTER ONLINE - PLAYTEST DEBUG OVERLAY UI
# ============================================================
#
# Interface visual de depuração em tempo real:
# - Tecla F3: Abrir / Fechar Overlay
# - Tecla F4: Alternar World Density Heatmap
# - Tecla F5: Abrir Content Director Inspector
# - Tecla F6: Iniciar / Parar / Exportar Sessão de Playtest
# ============================================================

enum TabIndex {
	OVERVIEW,
	COMBAT_NPC,
	NEN_DISCOVERY,
	CONTENT_DIRECTOR,
	INSPECTOR,
	HISTORY,
	SESSION,
	HEATMAP
}

const WorldDensityHeatmapScript = preload("res://debug/telemetry/WorldDensityHeatmap.gd")

var current_tab: TabIndex = TabIndex.OVERVIEW
var is_overlay_visible: bool = false
var heatmap_instance: Node2D = null

# Nós de UI
@onready var main_panel: PanelContainer = $MainContainer
@onready var tab_container: TabContainer = %TabContainer
@onready var lbl_header_status: Label = %LblHeaderStatus
@onready var lbl_session_badge: Label = %LblSessionBadge

# Tab 1: Overview
@onready var lbl_player_stats: Label = %LblPlayerStats
@onready var lbl_world_stats: Label = %LblWorldStats
@onready var lbl_perf_stats: Label = %LblPerfStats

# Tab 2: Combat & NPC
@onready var lbl_combat_stats: Label = %LblCombatStats
@onready var lbl_npc_stats: Label = %LblNpcStats

# Tab 3: Nen & Discovery
@onready var lbl_nen_stats: Label = %LblNenStats
@onready var lbl_discovery_stats: Label = %LblDiscoveryStats

# Tab 4: Content Director
@onready var lbl_director_stats: Label = %LblDirectorStats
@onready var lbl_breakdown_stats: Label = %LblBreakdownStats

# Tab 5: Inspector
@onready var inspector_coords_edit: LineEdit = %InspectorCoordsEdit
@onready var btn_inspect_player_pos: Button = %BtnInspectPlayerPos
@onready var btn_inspect_coords: Button = %BtnInspectCoords
@onready var inspector_results_label: RichTextLabel = %InspectorResultsLabel

# Tab 6: History
@onready var history_text_label: RichTextLabel = %HistoryTextLabel

# Tab 7: Session
@onready var lbl_session_summary: RichTextLabel = %LblSessionSummary
@onready var btn_toggle_session: Button = %BtnToggleSession
@onready var btn_export_session: Button = %BtnExportSession
@onready var lbl_export_result: Label = %LblExportResult

# Tab 8: Heatmap
@onready var btn_toggle_heatmap: Button = %BtnToggleHeatmap
@onready var opt_heatmap_mode: OptionButton = %OptHeatmapMode


func _ready() -> void:
	layer = 125
	visible = is_overlay_visible
	
	_configurar_conexoes_botoes()
	_criar_heatmap_se_necessario()


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_F3:
				toggle_overlay()
				get_viewport().set_input_as_handled()
			KEY_F4:
				toggle_heatmap()
				get_viewport().set_input_as_handled()
			KEY_F5:
				if not is_overlay_visible:
					toggle_overlay(true)
				_mudar_tab(TabIndex.INSPECTOR)
				get_viewport().set_input_as_handled()
			KEY_F6:
				_on_btn_toggle_session_pressed()
				get_viewport().set_input_as_handled()
			KEY_F10:
				_on_ativar_hunter_lvl100()
				get_viewport().set_input_as_handled()


func toggle_overlay(forced_state: Variant = null) -> bool:
	if forced_state != null and forced_state is bool:
		is_overlay_visible = forced_state
	else:
		is_overlay_visible = not is_overlay_visible
		
	visible = is_overlay_visible
	if is_overlay_visible:
		_atualizar_dados_aba_ativa()
	return is_overlay_visible


func toggle_heatmap(forced_state: Variant = null) -> bool:
	_criar_heatmap_se_necessario()
	if heatmap_instance != null:
		return heatmap_instance.toggle_heatmap(forced_state)
	return false


func _process(_delta: float) -> void:
	if not is_overlay_visible:
		return
		
	_atualizar_header()
	_atualizar_dados_aba_ativa()


func _configurar_conexoes_botoes() -> void:
	# Botões de Debug Hunter Level 100 no Header
	var header_node = get_node_or_null("MainContainer/VBox/HeaderBar")
	if header_node != null:
		var btn_lvl100 := Button.new()
		btn_lvl100.name = "BtnLvl100"
		btn_lvl100.text = "⚡ Lvl 100 (F10)"
		btn_lvl100.add_theme_font_size_override("font_size", 9)
		btn_lvl100.add_theme_color_override("font_color", Color(0.3, 1.0, 0.5, 1.0))
		btn_lvl100.pressed.connect(_on_ativar_hunter_lvl100)
		header_node.add_child(btn_lvl100)

		var btn_reset_lvl100 := Button.new()
		btn_reset_lvl100.name = "BtnResetLvl100"
		btn_reset_lvl100.text = "🔄 Reset Debug"
		btn_reset_lvl100.add_theme_font_size_override("font_size", 9)
		btn_reset_lvl100.add_theme_color_override("font_color", Color(1.0, 0.5, 0.3, 1.0))
		btn_reset_lvl100.pressed.connect(_on_resetar_hunter_debug)
		header_node.add_child(btn_reset_lvl100)

	if btn_inspect_player_pos:
		btn_inspect_player_pos.pressed.connect(_on_inspect_player_position)
	if btn_inspect_coords:
		btn_inspect_coords.pressed.connect(_on_inspect_custom_coords)
	if btn_toggle_session:
		btn_toggle_session.pressed.connect(_on_btn_toggle_session_pressed)
	if btn_export_session:
		btn_export_session.pressed.connect(_on_btn_export_session_pressed)
	if btn_toggle_heatmap:
		btn_toggle_heatmap.pressed.connect(func(): toggle_heatmap())
	if opt_heatmap_mode:
		opt_heatmap_mode.clear()
		opt_heatmap_mode.add_item("🔥 Geral & Zonas Mortas", 0)
		opt_heatmap_mode.add_item("🔵 Densidade de NPCs", 1)
		opt_heatmap_mode.add_item("🔴 Densidade PvE (Monstros)", 2)
		opt_heatmap_mode.add_item("🟡 Densidade de Eventos", 3)
		opt_heatmap_mode.add_item("🟢 Densidade de POIs/Segredos", 4)
		opt_heatmap_mode.item_selected.connect(_on_heatmap_mode_selected)


func _on_ativar_hunter_lvl100() -> void:
	PlayerData.debug_create_level_100_hunter(true)
	_atualizar_dados_aba_ativa()
	if EventBus != null and EventBus.has_signal("toast_requested"):
		EventBus.emit_toast("⚡ Hunter Level 100 Ativado com Sucesso!", Color(0.3, 1.0, 0.5))


func _on_resetar_hunter_debug() -> void:
	PlayerData.reset_debug_character()
	_atualizar_dados_aba_ativa()
	if EventBus != null and EventBus.has_signal("toast_requested"):
		EventBus.emit_toast("🔄 Personagem de Debug Resetado!", Color(1.0, 0.5, 0.3))


func _criar_heatmap_se_necessario() -> void:
	if heatmap_instance == null or not is_instance_valid(heatmap_instance):
		var root_map = get_tree().current_scene
		if root_map != null:
			heatmap_instance = WorldDensityHeatmapScript.new()
			heatmap_instance.name = "WorldDensityHeatmap"
			root_map.add_child(heatmap_instance)


func _mudar_tab(idx: TabIndex) -> void:
	current_tab = idx
	if tab_container != null:
		tab_container.current_tab = int(idx)


func _atualizar_header() -> void:
	var tele = _obter_telemetria()
	if tele == null:
		return
		
	var sess_active = tele.is_session_active()
	if lbl_session_badge:
		if sess_active:
			var s = tele.get_session_summary()
			var sec = int(s.get("duration_seconds", 0.0))
			lbl_session_badge.text = "🔴 GRAVANDO SESSÃO [%02d:%02d]" % [int(sec / 60), sec % 60]
			lbl_session_badge.modulate = Color(1.0, 0.3, 0.3, 1.0)
		else:
			lbl_session_badge.text = "⚪ SESSÃO INATIVA"
			lbl_session_badge.modulate = Color(0.7, 0.7, 0.7, 1.0)
			
	if lbl_header_status:
		var perf = tele.get_performance_metrics()
		lbl_header_status.text = "HUNTER ONLINE TELEMETRIA  |  FPS: %d  |  RAM: %.1f MB" % [
			perf.get("fps", 60),
			perf.get("memory_mb", 0.0)
		]


func _atualizar_dados_aba_ativa() -> void:
	var tele = _obter_telemetria()
	if tele == null:
		return
		
	match current_tab:
		TabIndex.OVERVIEW:
			_atualizar_tab_overview(tele)
		TabIndex.COMBAT_NPC:
			_atualizar_tab_combat_npc(tele)
		TabIndex.NEN_DISCOVERY:
			_atualizar_tab_nen_discovery(tele)
		TabIndex.CONTENT_DIRECTOR:
			_atualizar_tab_content_director(tele)
		TabIndex.INSPECTOR:
			pass # Atualizado sob demanda por botão ou seleção
		TabIndex.HISTORY:
			_atualizar_tab_history(tele)
		TabIndex.SESSION:
			_atualizar_tab_session(tele)
		TabIndex.HEATMAP:
			pass


# ------------------------------------------------------------
# ATUALIZAÇÃO DAS ABAS
# ------------------------------------------------------------
func _atualizar_tab_overview(tele: Node) -> void:
	var ply = tele.get_player_metrics()
	var w = tele.get_world_metrics()
	var p = tele.get_performance_metrics()
	var chars: Dictionary = tele.get_character_system_metrics() if tele.has_method("get_character_system_metrics") else {}
	
	if lbl_player_stats:
		lbl_player_stats.text = """[PLAYER & CHARACTER DATA]
🆔 ID: %s  |  Nome: %s (Slot %d)
💾 Save Status: %s  |  Load: %s  |  Pronto: %s
📍 Posição: (%.0f, %.0f)  |  Tile: (%d, %d)
🗺️ Mapa: %s (%s)
🎖️ Level Normal: %d  |  Level Nen: %d
❤️ HP: %d / %d (%.0f%%)
✨ Aura: %.0f / %.0f (%.0f%%)
🥋 Nen Ativo: %s
⚔️ Estado de Combate: %s
🏃 Velocidade: %.1f px/s  |  Sprint: %s
📖 História: %s  |  Tutorial: %s
📜 Quest Atual: %s""" % [
			chars.get("selected_character_id", "N/A"), chars.get("character_name", "Hunter"), chars.get("selected_slot", 1),
			chars.get("save_status", "VALID"), chars.get("load_status", "SUCCESS"), "SIM" if chars.get("is_character_ready", false) else "NÃO",
			ply.get("position", Vector2.ZERO).x, ply.get("position", Vector2.ZERO).y,
			ply.get("tile_coords", Vector2i.ZERO).x, ply.get("tile_coords", Vector2i.ZERO).y,
			ply.get("map_name", ""), ply.get("scene_path", ""),
			ply.get("level", 1), ply.get("level_nen", 0),
			ply.get("hp", 100), ply.get("hp_max", 100), ply.get("hp_pct", 100.0),
			ply.get("aura", 0.0), ply.get("aura_max", 0.0), ply.get("aura_pct", 0.0),
			", ".join(ply.get("active_nen_techniques", [])) if not ply.get("active_nen_techniques", []).is_empty() else "Nenhum",
			ply.get("combat_state", "NORMAL"),
			ply.get("movement_speed", 64.0),
			"SIM (Shift)" if ply.get("is_sprinting", false) else "NÃO",
			chars.get("story_progress", "Arco 1"), chars.get("tutorial_progress", "CONCLUÍDO"),
			ply.get("current_quest", "Nenhuma")
		]
		
	if lbl_world_stats:
		lbl_world_stats.text = """[WORLD & REGION DATA]
⏰ Horário: %s  |  Fase Solar: %s
📍 Zona Atual: %s
⚠️ Grau de Perigo: Nível %d
📦 Chunk Atual: (%d, %d)
🔵 NPCs Próximos (<600px): %d
🔴 Inimigos Próximos (<600px): %d
🟡 Eventos Ativos na Região: %d""" % [
			w.get("current_time", ""), w.get("phase", ""),
			w.get("zone_name", ""),
			w.get("danger_level", 0),
			w.get("current_chunk", Vector2i.ZERO).x, w.get("current_chunk", Vector2i.ZERO).y,
			w.get("nearby_npcs_count", 0),
			w.get("nearby_enemies_count", 0),
			w.get("nearby_events_count", 0)
		]
		
	if lbl_perf_stats:
		var input_ctx = get_node_or_null("/root/InputContextManager")
		var ctx_name: String = input_ctx.get_context_name() if input_ctx != null else "N/A"
		var foc_ctrl: String = input_ctx.get_focused_control_name() if input_ctx != null else "None"
		var txt_foc: bool = input_ctx.is_text_input_focused() if input_ctx != null else false
		var hotkey_ok: bool = input_ctx.is_global_hotkey_allowed() if input_ctx != null else true

		lbl_perf_stats.text = """[ENGINE & INPUT CONTEXT]
⚡ FPS: %d  |  Frame Time: %.2f ms
🌲 Total Nodes: %d  |  RAM: %.2f MB
🎮 INPUT CONTEXT: %s
🎯 FOCUSED CONTROL: %s
⌨️ KEYBOARD CAPTURE: %s
🔥 GLOBAL HOTKEYS: %s""" % [
			p.get("fps", 60), p.get("frame_time_ms", 16.6),
			p.get("node_count", 0),
			p.get("memory_mb", 0.0),
			ctx_name,
			foc_ctrl,
			"TRUE (Digitação Ativa)" if txt_foc else "FALSE",
			"ENABLED" if hotkey_ok else "DISABLED"
		]


func _atualizar_tab_combat_npc(tele: Node) -> void:
	var c = tele.get_combat_metrics()
	var npc = tele.get_npc_proximity_metrics()
	
	if lbl_combat_stats:
		if c.get("in_combat", false):
			lbl_combat_stats.text = """[LIVE COMBAT & ENEMY AI]
🎯 Alvo Mais Próximo: %s (%.0f px)
🥋 Arquétipo do Inimigo: %s
🤖 Estado da IA: %s
⏱️ Windup Atual: %.2fs  |  Cooldown de Ataque: %.2fs
🛡️ Postura (Stagger): %.1f / %.1f %s
💥 Último Dano Desferido: %d
🩸 Último Dano Recebido: %d""" % [
				c.get("target_name", ""), c.get("distance", 0.0),
				c.get("archetype", "").to_upper(),
				c.get("enemy_state", "IDLE"),
				c.get("attack_windup", 0.0), c.get("attack_cooldown", 0.0),
				c.get("postura", 100.0), c.get("postura_max", 100.0),
				"⚡ (EM STAGGER!)" if c.get("em_stagger", false) else "(Firme)",
				c.get("recent_damage_dealt", 0),
				c.get("recent_damage_received", 0)
			]
		else:
			lbl_combat_stats.text = """[LIVE COMBAT & ENEMY AI]
⚪ Nenhum inimigo em combate direto próximo.
💥 Último Dano Desferido: %d  |  🩸 Último Dano Recebido: %d""" % [
				c.get("recent_damage_dealt", 0),
				c.get("recent_damage_received", 0)
			]
			
	if lbl_npc_stats:
		if npc.get("has_nearby_npc", false):
			lbl_npc_stats.text = """[NPC INTELLIGENCE & PROXIMITY (<300px)]
👤 NPC: %s (Distância: %.0f px)
🏛️ Facção: %s
🤝 Disposição: %s (Score: %d)
⚖️ Influência de Reputação: %s
🚶 Atividade Atual: %s  |  Rotina: %s
🧠 CONTEXTO IA (Why NPC is doing this):
"%s" """ % [
				npc.get("npc_name", ""), npc.get("distance", 0.0),
				npc.get("faction", ""),
				npc.get("disposition", ""), npc.get("relationship_score", 0),
				npc.get("reputation_influence", ""),
				npc.get("current_activity", ""), npc.get("current_routine", ""),
				npc.get("why_npc_doing_this", "")
			]
		else:
			lbl_npc_stats.text = """[NPC INTELLIGENCE & PROXIMITY]
⚪ Nenhum NPC a menos de 300px de distância."""


func _atualizar_tab_nen_discovery(tele: Node) -> void:
	var n = tele.get_nen_metrics()
	var d = tele.get_discovery_metrics()
	
	if lbl_nen_stats:
		var tech_str = n.get("current_technique", "NENHUMA")
		var drain_str = "%.1f/s" % n.get("aura_rate_per_sec", 0.0)
		var eff_str = "\n".join(n.get("active_effects", ["Nenhum efeito ativo"]))
		
		var interactions_str = "Nenhuma interação de mundo no alcance."
		var inter_list = n.get("detected_world_interactions", [])
		if not inter_list.is_empty():
			var lines: Array[String] = []
			for item in inter_list:
				lines.append("• %s (%.0f px)" % [item.get("name", ""), item.get("dist", 0.0)])
			interactions_str = "\n".join(lines)
			
		lbl_nen_stats.text = """[NEN TECHNIQUES & WORLD SENSORS]
🥋 Técnica Ativa: %s  |  Taxa de Aura: %s
✨ Efeitos Ativos:
%s

🔍 INTERAÇÕES DE MUNDO DETECTADAS:
%s""" % [tech_str, drain_str, eff_str, interactions_str]
		
	if lbl_discovery_stats:
		if d.get("has_nearby_discovery", false):
			lbl_discovery_stats.text = """[NEARBY POI & SECRETS]
📍 Ponto Notável: %s
🏷️ Categoria de Segredo: %s
📏 Distância: %.0f px (~%d tiles)
🔍 Estado: %s
🔑 Requisito de Acesso: %s""" % [
				d.get("name", ""),
				d.get("type", "VISIBLE"),
				d.get("distance_px", 0.0), d.get("distance_tiles", 0),
				d.get("discovery_state", "DESCONHECIDO"),
				d.get("required_condition", "")
			]
		else:
			lbl_discovery_stats.text = """[NEARBY POI & SECRETS]
⚪ Nenhum POI ou segredo mapeado no raio de 1200px."""


func _atualizar_tab_content_director(tele: Node) -> void:
	var cd = tele.get_content_director_metrics()
	if lbl_director_stats:
		lbl_director_stats.text = """[CONTENT DIRECTOR LIVE METRICS]
📍 Zona Atual: %s (Grau de Risco: %d)
🔵 NPCs Ativos: %d  |  🔴 Inimigos Ativos: %d
🟡 Eventos Ativos: %d  |  ✨ Encontros Ativos: %d  |  🟢 POIs: %d
📏 Distância Percorrida: %.0f px  |  Dist. Desde Último Evento: %.0f px
🎯 Próximo Evento Estimado em: ~%.0f px
⏱️ Cooldown Eventos: %.1fs  |  Cooldown Encontros: %.1fs""" % [
			cd.get("zone_name", ""), cd.get("risk_level", 0),
			cd.get("active_npcs", 0), cd.get("active_enemies", 0),
			cd.get("active_events", 0), cd.get("active_encounters", 0), cd.get("registered_pois", 0),
			cd.get("distance_travelled", 0.0), cd.get("distance_since_last_event", 0.0),
			cd.get("next_event_distance_estimate", 0.0),
			cd.get("event_cooldown", 0.0), cd.get("encounter_cooldown", 0.0)
		]
		
	if lbl_breakdown_stats:
		lbl_breakdown_stats.text = """[REGION CONTENT DENSITY BREAKDOWN]
⚔️ COMBAT %%:     [ %.1f%% ]
👥 NPC %%:        [ %.1f%% ]
🌟 EVENT %%:      [ %.1f%% ]
🗺️ DISCOVERY %%:  [ %.1f%% ]

Candidatos Permitidos na Zona: %s""" % [
			cd.get("combat_pct", 0.0),
			cd.get("npc_pct", 0.0),
			cd.get("event_pct", 0.0),
			cd.get("discovery_pct", 0.0),
			", ".join(cd.get("event_candidates", []))
		]


func _atualizar_tab_history(tele: Node) -> void:
	if history_text_label == null:
		return
		
	var hist = tele.get_event_history_metrics()
	if hist.is_empty():
		history_text_label.text = "[color=#888888]Nenhum evento registrado no histórico ainda.[/color]"
		return
		
	var bb_text = ""
	for e in hist:
		var cor = "#00d2ff"
		var t = e.get("type", "")
		if "DEATH" in t: cor = "#ff3333"
		elif "DAMAGE" in t or "COMBAT" in t: cor = "#ffaa00"
		elif "QUEST" in t: cor = "#ffff00"
		elif "DISCOVERY" in t: cor = "#00ff88"
		elif "NEN" in t: cor = "#d400ff"
		
		bb_text += "[color=#aaaaaa][%s][/color] [color=%s][b]%s[/b][/color] - %s\n" % [
			e.get("timestamp", "00:00"),
			cor,
			e.get("title", ""),
			e.get("details", "")
		]
	history_text_label.text = bb_text


func _atualizar_tab_session(tele: Node) -> void:
	var s = tele.get_session_summary()
	var sec = int(s.get("duration_seconds", 0.0))
	var is_act = tele.is_session_active()
	
	if btn_toggle_session:
		btn_toggle_session.text = "⏹️ FINALIZAR SESSÃO" if is_act else "🔴 INICIAR NOVA SESSÃO"
		btn_toggle_session.modulate = Color(1.0, 0.4, 0.4) if is_act else Color(0.4, 1.0, 0.5)
		
	if lbl_session_summary:
		lbl_session_summary.text = """[color=#00e1ff][b]ID DA SESSÃO:[/b][/color] %s
[b]Status:[/b] %s
[b]Duração:[/b] %02d:%02d (%d segundos)
[b]Distância Percorrida:[/b] %.0f px (~%d tiles)
[b]Inimigos Derrotados:[/b] %d
[b]Dano Desferido:[/b] %d (Maior Golpe: %d)
[b]Dano Recebido:[/b] %d
[b]Quests Concluídas:[/b] %d
[b]NPCs Interagidos:[/b] %d
[b]Eventos Encontrados:[/b] %d
[b]Mortes do Jogador:[/b] %d
[b]Jenny Ganho / Gasto:[/b] +%d / -%d Jenny""" % [
			s.get("session_id", "Nenhuma"),
			"[color=#00ff88]GRAVANDO[/color]" if is_act else "[color=#aaaaaa]FINALIZADA / INATIVA[/color]",
			int(sec / 60), sec % 60, sec,
			s.get("distance_traveled_px", 0.0), s.get("distance_traveled_tiles", 0),
			s.get("enemies_killed", 0),
			s.get("damage_dealt", 0), s.get("max_single_hit", 0),
			s.get("damage_received", 0),
			s.get("quests_completed", 0),
			s.get("npcs_interacted", 0),
			s.get("events_encountered", 0),
			s.get("deaths", 0),
			s.get("gold_gained", 0), s.get("gold_spent", 0)
		]


# ------------------------------------------------------------
# HANDLERS DE AÇÕES
# ------------------------------------------------------------
func _on_inspect_player_position() -> void:
	var tele = _obter_telemetria()
	if tele == null:
		return
	var ply = tele.get_player_metrics()
	var pos = ply.get("position", Vector2.ZERO)
	if inspector_coords_edit:
		inspector_coords_edit.text = "%d, %d" % [int(pos.x), int(pos.y)]
	_executar_inspecao_em_coords(pos)


func _on_inspect_custom_coords() -> void:
	if inspector_coords_edit == null:
		return
	var raw = inspector_coords_edit.text.split(",")
	if raw.size() >= 2:
		var x = float(raw[0].strip_edges())
		var y = float(raw[1].strip_edges())
		_executar_inspecao_em_coords(Vector2(x, y))


func _executar_inspecao_em_coords(target_pos: Vector2) -> void:
	var director = get_tree().get_first_node_in_group("content_director") as ContentDirector
	if director == null or not director.has_method("evaluate_event_candidates_at_pos"):
		if inspector_results_label:
			inspector_results_label.text = "[color=#ff5555]ContentDirector não encontrado na cena atual.[/color]"
		return
		
	var candidates = director.evaluate_event_candidates_at_pos(target_pos)
	var bb_text = "[b]AVALIAÇÃO DE EVENTOS EM (%d, %d):[/b]\n\n" % [int(target_pos.x), int(target_pos.y)]
	
	var accepted_count = 0
	var rejected_count = 0
	
	for c in candidates:
		if c.get("is_accepted", false):
			accepted_count += 1
			bb_text += "[color=#00ff88]✔ ACEITO: %s[/color] (Tipo: %s | Peso: %.2f)\n  Status: %s\n\n" % [
				c.get("title", ""), c.get("type", ""), c.get("weight_chance", 0.0), c.get("primary_reason", "")
			]
		else:
			rejected_count += 1
			bb_text += "[color=#ff4444]✖ REJEITADO: %s[/color] (Tipo: %s)\n  [color=#ffaaaa]Motivo: %s[/color]\n\n" % [
				c.get("title", ""), c.get("type", ""), c.get("primary_reason", "")
			]
			
	bb_text = "[color=#00e1ff]Resumo: %d Candidatos Aceitos  |  %d Candidatos Rejeitados[/color]\n\n" % [accepted_count, rejected_count] + bb_text
	if inspector_results_label:
		inspector_results_label.text = bb_text


func _on_btn_toggle_session_pressed() -> void:
	var tele = _obter_telemetria()
	if tele == null:
		return
	if tele.is_session_active():
		tele.end_session()
	else:
		tele.start_session()
	_atualizar_tab_session(tele)


func _on_btn_export_session_pressed() -> void:
	var tele = _obter_telemetria()
	if tele == null:
		return
	var path = tele.export_session_json()
	if lbl_export_result:
		lbl_export_result.text = "Exportado: " + path
		lbl_export_result.modulate = Color(0.2, 1.0, 0.5)


func _on_heatmap_mode_selected(idx: int) -> void:
	_criar_heatmap_se_necessario()
	if heatmap_instance != null:
		heatmap_instance.set_mode(idx as WorldDensityHeatmapScript.HeatmapMode)


func _obter_telemetria() -> Node:
	if Engine.has_singleton("PlaytestTelemetry"):
		return Engine.get_singleton("PlaytestTelemetry")
	return get_tree().root.get_node_or_null("PlaytestTelemetry")
