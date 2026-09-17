extends PanelContainer

# ============================================================
# HUNTER ONLINE - QUEST HUD (objetivo claro + bússola sincronizada)
# Consome MissionObjectiveResolver — mesma fonte do GPS.
# ============================================================

const HunterUIStyle = preload("res://ui/theme/HunterUIStyle.gd")
const MissionObjectiveResolverScript = preload("res://scripts/missions/MissionObjectiveResolver.gd")

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
	custom_minimum_size = Vector2(138, 22)
	set_anchors_preset(Control.PRESET_TOP_RIGHT)
	grow_horizontal = Control.GROW_DIRECTION_BEGIN
	grow_vertical = Control.GROW_DIRECTION_END
	offset_left = -144.0
	offset_top = 6.0
	offset_right = -6.0
	scale = Vector2(0.75, 0.75)

	add_theme_stylebox_override("panel", HunterUIStyle.criar_style_quest_tracker())

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 5)
	margin.add_theme_constant_override("margin_top", 3)
	margin.add_theme_constant_override("margin_right", 5)
	margin.add_theme_constant_override("margin_bottom", 3)
	add_child(margin)

	var vbox_main := VBoxContainer.new()
	vbox_main.add_theme_constant_override("separation", 1)
	margin.add_child(vbox_main)

	var hbox_header := HBoxContainer.new()
	vbox_main.add_child(hbox_header)

	lbl_arco = Label.new()
	lbl_arco.text = "🏛️ ARCO %d: %s" % [PlayerData.arco_atual, ARCO_NOMES.get(PlayerData.arco_atual, "HISTÓRIA")]
	HunterUIStyle.aplicar_fonte_licenca(lbl_arco, 9, HunterUIStyle.COLOR_GOLD_LIGHT)
	lbl_arco.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox_header.add_child(lbl_arco)

	var btn_jornal := Button.new()
	btn_jornal.text = "📜"
	btn_jornal.tooltip_text = "Abrir Jornal de Missões [J]"
	HunterUIStyle.aplicar_fonte_pixel(btn_jornal, 7, HunterUIStyle.COLOR_GOLD_LIGHT)
	btn_jornal.custom_minimum_size = Vector2(14, 13)
	HunterUIStyle.aplicar_estilo_botao(btn_jornal, HunterUIStyle.COLOR_BORDER_GOLD)
	btn_jornal.pressed.connect(_abrir_jornal)
	hbox_header.add_child(btn_jornal)

	btn_toggle = Button.new()
	btn_toggle.text = "−"
	HunterUIStyle.aplicar_fonte_pixel(btn_toggle, 7, HunterUIStyle.COLOR_TEXT_PRIMARY)
	btn_toggle.custom_minimum_size = Vector2(13, 13)
	HunterUIStyle.aplicar_estilo_botao(btn_toggle, HunterUIStyle.COLOR_BORDER_SUBTLE)
	btn_toggle.pressed.connect(_toggle_expandir)
	hbox_header.add_child(btn_toggle)

	vbox_detalhes = VBoxContainer.new()
	vbox_detalhes.add_theme_constant_override("separation", 1)
	vbox_main.add_child(vbox_detalhes)

	lbl_quest_nome = Label.new()
	lbl_quest_nome.text = "📜 Missão Ativa"
	HunterUIStyle.aplicar_fonte_licenca(lbl_quest_nome, 9, HunterUIStyle.COLOR_AURA_CYAN)
	lbl_quest_nome.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox_detalhes.add_child(lbl_quest_nome)

	lbl_objetivo = Label.new()
	lbl_objetivo.text = "- Carregando objetivo..."
	HunterUIStyle.aplicar_fonte_pixel(lbl_objetivo, 7, HunterUIStyle.COLOR_TEXT_PRIMARY)
	lbl_objetivo.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox_detalhes.add_child(lbl_objetivo)

	lbl_bussola = Label.new()
	lbl_bussola.text = "🧭 Direção: Buscando..."
	HunterUIStyle.aplicar_fonte_pixel_bold(lbl_bussola, 7, HunterUIStyle.COLOR_HUNTER_GREEN_LIGHT)
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

	var player := _obter_player()
	var resolved: Dictionary = MissionObjectiveResolverScript.resolve(tree, player)

	if resolved.get("is_lobby", false):
		lbl_arco.text = "🏛️ PRAÇA CENTRAL (LOBBY)"
		lbl_quest_nome.text = "📜 " + str(resolved.get("hud_title", "Guia da Cidade"))
		lbl_objetivo.text = str(resolved.get("hud_objective", ""))
		lbl_bussola.text = str(resolved.get("hud_action", resolved.get("gps_label", "")))
		lbl_bussola.add_theme_color_override("font_color", resolved.get("gps_color", Color(0.3, 0.9, 1.0, 1.0)))
		return

	lbl_arco.text = "🏛️ ARCO %d: %s" % [PlayerData.arco_atual, ARCO_NOMES.get(PlayerData.arco_atual, "HISTÓRIA")]

	var quest: Quest = resolved.get("quest", null)
	if quest == null:
		lbl_quest_nome.text = "📜 Sem Missão Ativa"
		lbl_objetivo.text = str(resolved.get("hud_objective", "Aguardando..."))
		lbl_bussola.text = str(resolved.get("hud_action", ""))
		lbl_bussola.add_theme_color_override("font_color", Color(0.7, 0.8, 0.9, 1.0))
		return

	lbl_quest_nome.text = "📜 " + str(resolved.get("hud_title", quest.quest_name))

	# Lista curta: passos concluídos + atual + próximos bloqueados (máx. 4 linhas)
	var linhas: PackedStringArray = PackedStringArray()
	var total: int = quest.objectives.size()
	var pendente_idx: int = int(resolved.get("objective_index", -1))
	for i in range(total):
		var obj: QuestObjective = quest.objectives[i]
		var progresso: int = PlayerData.get_quest_objective_progress(quest, i)
		var completo: bool = progresso >= obj.required_amount
		var icone := "✓ "
		if not completo:
			if i == pendente_idx:
				icone = "👉 "
			else:
				icone = "🔒 "
		linhas.append("%s%d/%d %s (%d/%d)" % [icone, i + 1, total, obj.describe(), progresso, obj.required_amount])

	var obj_block := "\n".join(linhas)
	if resolved.get("stage_complete", false):
		obj_block = "✅ Etapa completa — avance pelo portal da história."

	lbl_objetivo.text = obj_block
	lbl_bussola.text = str(resolved.get("hud_action", resolved.get("gps_label", "")))
	lbl_bussola.add_theme_color_override("font_color", resolved.get("gps_color", Color(1.0, 0.85, 0.3, 1.0)))


func _obter_player() -> Node2D:
	if _player_ref != null and is_instance_valid(_player_ref):
		return _player_ref
	var players := get_tree().get_nodes_in_group("player")
	if not players.is_empty():
		_player_ref = players[0] as Node2D
		return _player_ref
	return null


func _abrir_jornal() -> void:
	var j_ui = QuestJournalUI.obter_ou_criar(get_tree())
	if j_ui != null and j_ui.has_method("alternar_menu"):
		j_ui.alternar_menu()
