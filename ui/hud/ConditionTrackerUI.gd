class_name ConditionTrackerUI
extends PanelContainer

# ============================================================
# HUNTER ONLINE — CONDITION TRACKER UI (MODULAR & REUTILIZÁVEL)
# ============================================================
#
# Componente modular para rastreamento de condições em tempo real:
# - Suporta:
#   1. Hatsu Condicional (ex: Godspeed, Bodhisattva, Juramentos e Restrições)
#   2. Fases e Desafios de Chefes
#   3. Quests com Condições Especiais de Combate
#   4. Conquistas e Requisitos de Treinamento
# - Formato visual canônico:
#   ┌──────────────────────────────┐
#   │ ⚡ GODSPEED                  │
#   │ ✓ Alvo Detectado             │
#   │ ✓ Vida Abaixo de 50%         │
#   │ ○ Permanecer no Campo de En  │
#   │ 2 / 3 Condições Atendidas    │
#   └──────────────────────────────┘
# ============================================================

const HunterUIStyle = preload("res://ui/theme/HunterUIStyle.gd")

var lbl_titulo: Label
var vbox_lista: VBoxContainer
var lbl_contador: Label
var btn_toggle: Button
var vbox_conteudo: VBoxContainer

var _expandido: bool = true
var _condicoes_armazenadas: Array[Dictionary] = []
var _titulo_atual: String = ""


func _ready() -> void:
	custom_minimum_size = Vector2(120, 24)
	add_theme_stylebox_override("panel", HunterUIStyle.criar_style_card_interno(HunterUIStyle.COLOR_BORDER_CYAN, 3))
	_construir_ui()
	visible = false


func _construir_ui() -> void:
	for child in get_children():
		child.queue_free()

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 5)
	margin.add_theme_constant_override("margin_right", 5)
	margin.add_theme_constant_override("margin_top", 3)
	margin.add_theme_constant_override("margin_bottom", 3)
	add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 2)
	margin.add_child(vbox)

	# Linha 1: Título e Botão Minimizar
	var hbox_header := HBoxContainer.new()
	vbox.add_child(hbox_header)

	lbl_titulo = Label.new()
	lbl_titulo.text = "⚡ CONDIÇÃO ATIVA"
	lbl_titulo.add_theme_font_size_override("font_size", 5)
	lbl_titulo.add_theme_color_override("font_color", HunterUIStyle.COLOR_AURA_CYAN)
	lbl_titulo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox_header.add_child(lbl_titulo)

	btn_toggle = Button.new()
	btn_toggle.text = "−"
	btn_toggle.custom_minimum_size = Vector2(10, 10)
	btn_toggle.add_theme_font_size_override("font_size", 4)
	HunterUIStyle.aplicar_estilo_botao(btn_toggle, HunterUIStyle.COLOR_BORDER_SUBTLE)
	btn_toggle.pressed.connect(_toggle_expandir)
	hbox_header.add_child(btn_toggle)

	# Container de Itens Recolhível
	vbox_conteudo = VBoxContainer.new()
	vbox_conteudo.add_theme_constant_override("separation", 1)
	vbox.add_child(vbox_conteudo)

	vbox_lista = VBoxContainer.new()
	vbox_lista.add_theme_constant_override("separation", 1)
	vbox_conteudo.add_child(vbox_lista)

	var sep := HSeparator.new()
	vbox_conteudo.add_child(sep)

	lbl_contador = Label.new()
	lbl_contador.text = "0 / 0 Atendidas"
	lbl_contador.add_theme_font_size_override("font_size", 4)
	lbl_contador.add_theme_color_override("font_color", HunterUIStyle.COLOR_TEXT_GOLD)
	lbl_contador.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	vbox_conteudo.add_child(lbl_contador)


func _toggle_expandir() -> void:
	_expandido = not _expandido
	vbox_conteudo.visible = _expandido
	btn_toggle.text = "−" if _expandido else "+"


## Rastreia diretamente uma lista declarativa de condições
func rastrear_condicoes(titulo: String, lista_condicoes: Array[Dictionary]) -> void:
	_titulo_atual = titulo
	_condicoes_armazenadas = lista_condicoes
	_renderizar()


## Avalia e rastreia automaticamente um Hatsu condicional usando GameplayCondition
func rastrear_hatsu(hatsu_res: Resource, contexto: Dictionary = {}) -> void:
	if hatsu_res == null:
		limpar()
		return

	var titulo = hatsu_res.nome if "nome" in hatsu_res else "Habilidade Hatsu"
	var lista: Array[Dictionary] = []

	var conditions: Array = []
	if "conditions" in hatsu_res and hatsu_res.conditions is Array:
		conditions = hatsu_res.conditions
	elif hatsu_res.has_method("get_conditions"):
		conditions = hatsu_res.get_conditions()

	if conditions.is_empty():
		# Hatsu sem restrições ou condições complexas
		limpar()
		return

	for cond in conditions:
		if cond is GameplayCondition:
			var res: Dictionary = cond.evaluate(contexto)
			lista.append({
				"texto": cond.description if not cond.description.is_empty() else cond.get_editor_summary(),
				"atendida": res.get("met", false)
			})
		elif cond is Dictionary:
			lista.append({
				"texto": cond.get("texto", "Requisito"),
				"atendida": cond.get("atendida", false)
			})

	rastrear_condicoes("⚡ " + titulo.to_upper(), lista)


func _renderizar() -> void:
	if _condicoes_armazenadas.is_empty():
		visible = false
		return

	visible = true
	lbl_titulo.text = _titulo_atual

	for child in vbox_lista.get_children():
		child.queue_free()

	var total_atendidas: int = 0
	var total_condicoes: int = _condicoes_armazenadas.size()

	for item in _condicoes_armazenadas:
		var texto: String = item.get("texto", "")
		var atendida: bool = item.get("atendida", false)
		if atendida:
			total_atendidas += 1

		var hbox := HBoxContainer.new()
		hbox.add_theme_constant_override("separation", 3)

		var lbl_icone := Label.new()
		lbl_icone.text = "✓" if atendida else "○"
		lbl_icone.add_theme_font_size_override("font_size", 5)
		lbl_icone.add_theme_color_override("font_color", HunterUIStyle.COLOR_HUNTER_GREEN if atendida else HunterUIStyle.COLOR_TEXT_MUTED)
		hbox.add_child(lbl_icone)

		var lbl_desc := Label.new()
		lbl_desc.text = texto
		lbl_desc.add_theme_font_size_override("font_size", 4)
		lbl_desc.add_theme_color_override("font_color", HunterUIStyle.COLOR_TEXT_PRIMARY if atendida else HunterUIStyle.COLOR_TEXT_SECONDARY)
		lbl_desc.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		lbl_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		hbox.add_child(lbl_desc)

		vbox_lista.add_child(hbox)

	lbl_contador.text = "%d / %d Atendidas" % [total_atendidas, total_condicoes]
	var todas_ok: bool = (total_atendidas >= total_condicoes and total_condicoes > 0)
	lbl_contador.add_theme_color_override("font_color", HunterUIStyle.COLOR_HUNTER_GREEN if todas_ok else HunterUIStyle.COLOR_TEXT_GOLD)


func limpar() -> void:
	_condicoes_armazenadas.clear()
	_titulo_atual = ""
	visible = false
