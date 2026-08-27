class_name NenBeastCatalogUI
extends CanvasLayer

# ============================================================
# HUNTER ONLINE - NEN BEAST SANCTUARY & CATALOG UI
# ============================================================
#
# Interface completa e visual para gerenciamento de Bestas de Nen:
# - Aba 1: Besta Ativa (Estatísticas, IV, Habilidade, Nível)
# - Aba 2: Catálogo Kakin (Guia de Bestas Canônicas do Mangá)
#   -> Exige desbloqueio prévio via Ritual da Urna para equipar!
# - Aba 3: Despertar Ritual (Comunhão Sagrada por 250k Jenny / RNG)
#
# ============================================================

signal fechado

var tab_container: TabContainer
var panel_main: PanelContainer
const CUSTO_RITUAL: int = 250000


func _ready() -> void:
	layer = 40
	process_mode = Node.PROCESS_MODE_ALWAYS
	_construir_ui()
	get_tree().paused = true


func _construir_ui() -> void:
	# Fundo Escurecido
	var bg := ColorRect.new()
	bg.color = Color(0, 0, 0, 0.75)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	panel_main = PanelContainer.new()
	panel_main.position = Vector2(15, 10)
	panel_main.custom_minimum_size = Vector2(290, 160)

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.06, 0.08, 0.14, 0.98)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = Color(0.85, 0.4, 1.0, 1.0)
	style.corner_radius_top_left = 5
	style.corner_radius_top_right = 5
	style.corner_radius_bottom_right = 5
	style.corner_radius_bottom_left = 5
	panel_main.add_theme_stylebox_override("panel", style)
	add_child(panel_main)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 6)
	margin.add_theme_constant_override("margin_right", 6)
	margin.add_theme_constant_override("margin_top", 4)
	margin.add_theme_constant_override("margin_bottom", 4)
	panel_main.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 3)
	margin.add_child(vbox)

	# Cabeçalho
	var hbox_hdr := HBoxContainer.new()
	vbox.add_child(hbox_hdr)

	var lbl_tit := Label.new()
	lbl_tit.text = "🐉 SANTUÁRIO DAS BESTAS DE NEN"
	lbl_tit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lbl_tit.add_theme_font_size_override("font_size", 5)
	lbl_tit.add_theme_color_override("font_color", Color(0.9, 0.5, 1.0))
	hbox_hdr.add_child(lbl_tit)

	var btn_fechar := Button.new()
	btn_fechar.text = "✖ Sair"
	btn_fechar.add_theme_font_size_override("font_size", 4)
	btn_fechar.pressed.connect(_ao_fechar)
	hbox_hdr.add_child(btn_fechar)

	# Tab Container
	tab_container = TabContainer.new()
	tab_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	tab_container.add_theme_font_size_override("font_size", 4)
	vbox.add_child(tab_container)

	_criar_aba_ativa()
	_criar_aba_catalogo()
	_criar_aba_despertar()


# ============================================================
# ABA 1: BESTA ATIVA ATUALMENTE
# ============================================================
func _criar_aba_ativa() -> void:
	var scroll := ScrollContainer.new()
	scroll.name = "Besta Ativa"
	tab_container.add_child(scroll)

	var vbox_ativa := VBoxContainer.new()
	vbox_ativa.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox_ativa.add_theme_constant_override("separation", 2)
	scroll.add_child(vbox_ativa)

	var b: NenBeastData = PlayerData.besta_nen_equipada
	if b == null:
		var lbl_vazio := Label.new()
		lbl_vazio.text = "\nNenhuma Besta de Nen despertada no momento.\nRealize a comunhão na aba 'Despertar Ritual' para obter sua primeira Besta!"
		lbl_vazio.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl_vazio.add_theme_font_size_override("font_size", 3)
		lbl_vazio.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
		vbox_ativa.add_child(lbl_vazio)
		return

	var lbl_nome := Label.new()
	lbl_nome.text = "✨ %s (Lv. %d)" % [b.nome_besta, b.nivel]
	lbl_nome.add_theme_font_size_override("font_size", 4)
	lbl_nome.add_theme_color_override("font_color", Color(1.0, 0.9, 0.3))
	vbox_ativa.add_child(lbl_nome)

	var lbl_tipo := Label.new()
	lbl_tipo.text = "⚡ Poder: %s" % b.obter_nome_tipo()
	lbl_tipo.add_theme_font_size_override("font_size", 3)
	lbl_tipo.add_theme_color_override("font_color", Color(0.4, 1.0, 0.7))
	vbox_ativa.add_child(lbl_tipo)

	var lbl_iv := Label.new()
	lbl_iv.text = "🧬 Potencial de Aura (IV): %.2fx Multiplicador" % b.potencial_iv
	lbl_iv.add_theme_font_size_override("font_size", 3)
	lbl_iv.add_theme_color_override("font_color", Color(0.7, 0.7, 1.0))
	vbox_ativa.add_child(lbl_iv)

	var lbl_desc := Label.new()
	lbl_desc.text = "📜 Efeito Passivo em Batalha:\n%s" % b.obter_descricao()
	lbl_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl_desc.add_theme_font_size_override("font_size", 3)
	vbox_ativa.add_child(lbl_desc)

	var btn_desequipar := Button.new()
	btn_desequipar.text = "Guardar / Desativar Besta"
	btn_desequipar.add_theme_font_size_override("font_size", 3)
	btn_desequipar.pressed.connect(func():
		PlayerData.besta_nen_equipada = null
		_reconstruir_tudo()
	)
	vbox_ativa.add_child(btn_desequipar)


# ============================================================
# ABA 2: CATÁLOGO DE BESTAS CANÔNICAS (MANGÁ)
# ============================================================
func _criar_aba_catalogo() -> void:
	var scroll := ScrollContainer.new()
	scroll.name = "Catálogo Kakin"
	tab_container.add_child(scroll)

	var vbox_cat := VBoxContainer.new()
	vbox_cat.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox_cat.add_theme_constant_override("separation", 4)
	scroll.add_child(vbox_cat)

	var bestas_canon = CanonGuardianBeasts.obter_bestas_guardias_manga()
	for b_info in bestas_canon:
		var card := PanelContainer.new()
		var s := StyleBoxFlat.new()
		s.bg_color = Color(0.1, 0.12, 0.18, 0.9)
		s.border_width_left = 1
		s.border_width_top = 1
		s.border_width_right = 1
		s.border_width_bottom = 1
		s.border_color = Color(0.4, 0.4, 0.6)
		card.add_theme_stylebox_override("panel", s)
		vbox_cat.add_child(card)

		var m := MarginContainer.new()
		m.add_theme_constant_override("margin_left", 4)
		m.add_theme_constant_override("margin_right", 4)
		m.add_theme_constant_override("margin_top", 2)
		m.add_theme_constant_override("margin_bottom", 2)
		card.add_child(m)

		var h := HBoxContainer.new()
		m.add_child(h)

		var v_info := VBoxContainer.new()
		v_info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		h.add_child(v_info)

		# Procurar se o jogador possui essa besta desbloqueada no inventário
		var besta_desbloqueada: NenBeastData = null
		for desb in PlayerData.bestas_nen_desbloqueadas:
			if desb is NenBeastData and desb.nome_besta == b_info["nome_besta"]:
				besta_desbloqueada = desb
				break

		var possui_besta: bool = (besta_desbloqueada != null)
		var esta_equipada: bool = (PlayerData.besta_nen_equipada != null and PlayerData.besta_nen_equipada.nome_besta == b_info["nome_besta"])

		var lbl_t := Label.new()
		lbl_t.text = "%s — %s" % [b_info["principe"], b_info["nome_besta"]]
		lbl_t.add_theme_font_size_override("font_size", 3)
		lbl_t.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3) if possui_besta else Color(0.5, 0.5, 0.6))
		v_info.add_child(lbl_t)

		var lbl_ef := Label.new()
		lbl_ef.text = b_info["efeito"]
		lbl_ef.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		lbl_ef.add_theme_font_size_override("font_size", 3)
		lbl_ef.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9) if possui_besta else Color(0.4, 0.4, 0.5))
		v_info.add_child(lbl_ef)

		var btn_equip := Button.new()
		if not possui_besta:
			btn_equip.text = "🔒 Bloqueada"
			btn_equip.disabled = true
		elif esta_equipada:
			btn_equip.text = "✅ Equipada"
			btn_equip.disabled = true
		else:
			btn_equip.text = "Equipar Besta"
			btn_equip.disabled = false

		btn_equip.add_theme_font_size_override("font_size", 3)
		
		var b_salva = besta_desbloqueada
		btn_equip.pressed.connect(func():
			if b_salva != null:
				PlayerData.equipar_besta_nen(b_salva)
				_reconstruir_tudo()
		)
		h.add_child(btn_equip)


# ============================================================
# ABA 3: DESPERTAR / COMUNHÃO ESPIRITUAL
# ============================================================
func _criar_aba_despertar() -> void:
	var scroll := ScrollContainer.new()
	scroll.name = "Despertar Ritual"
	tab_container.add_child(scroll)

	var vbox_desp := VBoxContainer.new()
	vbox_desp.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox_desp.add_theme_constant_override("separation", 3)
	scroll.add_child(vbox_desp)

	var lbl_lore := Label.new()
	lbl_lore.text = "🏺 O Ritual da Urna Sagrada de Kakin:\nDesperta uma Besta de Nen aleatória na sorte (incluindo as Bestas Canônicas dos Príncipes do anime/mangá), com sorteio exclusivo de Potencial (IV) e Cor de Aura."
	lbl_lore.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl_lore.add_theme_font_size_override("font_size", 3)
	lbl_lore.add_theme_color_override("font_color", Color(0.8, 0.9, 1.0))
	vbox_desp.add_child(lbl_lore)

	var gold_atual = Economy.obter_gold()
	var tem_ouro = gold_atual >= CUSTO_RITUAL

	var lbl_custo := Label.new()
	lbl_custo.text = "💰 Custo do Ritual: %s Jenny (Seu Saldo: %s J)" % [
		Economy.formatar_numero(CUSTO_RITUAL), Economy.formatar_numero(gold_atual)
	]
	lbl_custo.add_theme_font_size_override("font_size", 3)
	lbl_custo.add_theme_color_override("font_color", Color(0.4, 1.0, 0.4) if tem_ouro else Color(1.0, 0.3, 0.3))
	vbox_desp.add_child(lbl_custo)

	var btn_despertar := Button.new()
	btn_despertar.text = "🔮 Realizar Comunhão Sagrada (Despertar Nova Besta na Sorte)" if tem_ouro else "❌ Saldo Insuficiente (250k J)"
	btn_despertar.disabled = not tem_ouro
	btn_despertar.add_theme_font_size_override("font_size", 3)
	btn_despertar.pressed.connect(func():
		if Economy.remover_gold(CUSTO_RITUAL):
			var nova = NenBeastManager.gerar_besta_aleatoria()
			PlayerData.desbloquear_besta_nen(nova)
			PlayerData.equipar_besta_nen(nova)
			_reconstruir_tudo()
			var hud = get_tree().get_first_node_in_group("player_hud")
			if hud and hud.has_method("exibir_notificacao"):
				hud.exibir_notificacao("🐉 NOVA BESTA DE NEN DESPERTADA!\n%s (IV: %.2fx)" % [nova.nome_besta, nova.potencial_iv])
	)
	vbox_desp.add_child(btn_despertar)


func _reconstruir_tudo() -> void:
	for child in tab_container.get_children():
		child.queue_free()
	_criar_aba_ativa()
	_criar_aba_catalogo()
	_criar_aba_despertar()


func _ao_fechar() -> void:
	get_tree().paused = false
	fechado.emit()
	queue_free()
