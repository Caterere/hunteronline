class_name BountiesBoardUI
extends CanvasLayer

var panel_main: PanelContainer
var vbox_content: VBoxContainer
var container_bounties: VBoxContainer
var btn_fechar: Button

var bounties = [
	{"id": "bounty_criminoso", "nome": "Criminoso de Yorknew", "recompensa": "500 Jenny, 100 XP, Espada de Aço", "desc": "Derrote o criminoso foragido."},
	{"id": "bounty_slimes", "nome": "Caçar Slimes", "recompensa": "200 Jenny, 50 XP, Poção de Cura", "desc": "Elimine 10 Slimes."},
	{"id": "bounty_guardas", "nome": "Guardas Renegados", "recompensa": "800 Jenny, 200 XP, Armadura de Ferro", "desc": "Lide com os guardas corruptos."}
]

func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS
	layer = 12
	visible = false
	_construir_ui()

func abrir() -> void:
	visible = true
	get_tree().paused = true
	_atualizar_ui()

func fechar() -> void:
	visible = false
	get_tree().paused = false

func _construir_ui() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0, 0, 0, 0.7)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	panel_main = PanelContainer.new()
	panel_main.custom_minimum_size = Vector2(280, 160)
	panel_main.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.12, 0.1, 0.1, 0.95)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.border_color = Color(0.8, 0.2, 0.2, 1.0)
	style.corner_radius_top_left = 3
	style.corner_radius_top_right = 3
	style.corner_radius_bottom_right = 3
	style.corner_radius_bottom_left = 3
	panel_main.add_theme_stylebox_override("panel", style)
	add_child(panel_main)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 6)
	margin.add_theme_constant_override("margin_top", 4)
	margin.add_theme_constant_override("margin_right", 6)
	margin.add_theme_constant_override("margin_bottom", 4)
	panel_main.add_child(margin)

	vbox_content = VBoxContainer.new()
	vbox_content.add_theme_constant_override("separation", 3)
	margin.add_child(vbox_content)

	var lbl_titulo := Label.new()
	lbl_titulo.text = "QUADRO DE CAÇAS (BOUNTIES)"
	lbl_titulo.add_theme_font_size_override("font_size", 8)
	lbl_titulo.add_theme_color_override("font_color", Color(1, 0.3, 0.3, 1))
	vbox_content.add_child(lbl_titulo)

	container_bounties = VBoxContainer.new()
	container_bounties.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox_content.add_child(container_bounties)

	btn_fechar = Button.new()
	btn_fechar.text = "Sair do Quadro"
	btn_fechar.add_theme_font_size_override("font_size", 5)
	btn_fechar.pressed.connect(fechar)
	vbox_content.add_child(btn_fechar)

func _atualizar_ui() -> void:
	for child in container_bounties.get_children():
		child.queue_free()

	for bounty in bounties:
		# Check if already active
		var aceita = false
		if PlayerData.attributes.has("quests") and PlayerData.attributes["quests"].has(bounty["id"]):
			aceita = true
			
		var hbox = HBoxContainer.new()
		
		var lbl = Label.new()
		lbl.text = "%s\nRecompensa: %s\n%s" % [bounty["nome"], bounty["recompensa"], bounty["desc"]]
		lbl.add_theme_font_size_override("font_size", 5)
		lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hbox.add_child(lbl)
		
		var btn = Button.new()
		if aceita:
			btn.text = "Aceita"
			btn.disabled = true
		else:
			btn.text = "Aceitar"
			btn.pressed.connect(func():
				_aceitar_bounty(bounty["id"])
			)
		btn.add_theme_font_size_override("font_size", 5)
		hbox.add_child(btn)
		
		container_bounties.add_child(hbox)

func _aceitar_bounty(id: String) -> void:
	if not PlayerData.attributes.has("quests"):
		PlayerData.attributes["quests"] = []
	
	if not PlayerData.attributes["quests"].has(id):
		PlayerData.attributes["quests"].append(id)
		print("Bounty aceita: ", id)
		
	_atualizar_ui()
