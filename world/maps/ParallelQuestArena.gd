extends Node2D

# ============================================================
# HUNTER ONLINE - PARALLEL QUEST ARENA (DIMENSIONAL RIFT)
# ============================================================
#
# Arena de batalha de Missões Paralelas e What-Ifs (estilo Xenoverse).
# Gerencia spawn de ondas sequenciais de inimigos/bosses, contagem de abates,
# HUD de tempo/ondas, entrega canônica de recompensas e telas de vitória/derrota.
#
# ============================================================

@onready var player: CharacterBody2D = $Player
@onready var hud: CanvasLayer = $Hud

var pq_id: int = 1
var quest_data: Dictionary = {}
var ondas: Array = []
var onda_atual_idx: int = 0

var inimigos_onda_totais: int = 0
var inimigos_onda_derrotados: int = 0
var inimigos_totais_missao: int = 0
var inimigos_derrotados_global: int = 0

var tempo_decorrido: float = 0.0
var missao_concluida: bool = false
var missao_derrota: bool = false

var lbl_status_pq: Label
var lbl_banner_onda: Label
var panel_vitoria: PanelContainer
var panel_derrota: PanelContainer


func _ready() -> void:
	pq_id = PlayerData.missao_paralela_ativa_id
	if pq_id <= 0:
		pq_id = 1
		
	quest_data = ParallelQuestCatalog.obter_missao_por_id(pq_id)
	ondas = quest_data.get("waves", [])
	
	# Calcular total de inimigos em toda a missão
	inimigos_totais_missao = 0
	for w in ondas:
		inimigos_totais_missao += w.get("count", 1)
	
	print("[ParallelQuestArena] Carregando Fenda Temporal PQ %d: %s (%d ondas, %d inimigos)" % [
		pq_id, quest_data.get("title", ""), ondas.size(), inimigos_totais_missao
	])

	if AudioManager != null:
		AudioManager.tocar_musica_missao_paralela(pq_id)

	# Restaurar vida e aura do jogador para 100% ao entrar na arena
	_restaurar_jogador_total()
	
	_criar_hud_paralela()
	_exibir_briefing_narrativo_npc()


func _exibir_briefing_narrativo_npc() -> void:
	var canvas := CanvasLayer.new()
	canvas.layer = 20
	add_child(canvas)
	
	var panel := PanelContainer.new()
	panel.position = Vector2(30, 20)
	panel.custom_minimum_size = Vector2(260, 110)
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.06, 0.09, 0.16, 0.96)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = Color(0.3, 0.8, 1.0, 1.0)
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_right = 4
	style.corner_radius_bottom_left = 4
	panel.add_theme_stylebox_override("panel", style)
	canvas.add_child(panel)
	
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 8)
	margin.add_theme_constant_override("margin_top", 6)
	margin.add_theme_constant_override("margin_right", 8)
	margin.add_theme_constant_override("margin_bottom", 6)
	panel.add_child(margin)
	
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 3)
	margin.add_child(vbox)
	
	var lbl_npc := Label.new()
	lbl_npc.text = "🌌 Examinador Temporal Chrono (Briefing de Missão):"
	lbl_npc.add_theme_font_size_override("font_size", 4)
	lbl_npc.add_theme_color_override("font_color", Color(0.4, 0.9, 1.0, 1.0))
	vbox.add_child(lbl_npc)
	
	var lbl_title := Label.new()
	lbl_title.text = quest_data.get("title", "Missão Paralela")
	lbl_title.add_theme_font_size_override("font_size", 4)
	lbl_title.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3, 1.0))
	vbox.add_child(lbl_title)
	
	var lbl_lore := Label.new()
	lbl_lore.text = quest_data.get("what_if_lore", "Prepare-se para o combate dimensional.")
	lbl_lore.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl_lore.add_theme_font_size_override("font_size", 3)
	lbl_lore.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9, 1.0))
	vbox.add_child(lbl_lore)
	
	var lbl_enemies := Label.new()
	lbl_enemies.text = "Ameaças: " + quest_data.get("inimigos_descricao", "Inimigos de Nen")
	lbl_enemies.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl_enemies.add_theme_font_size_override("font_size", 3)
	lbl_enemies.add_theme_color_override("font_color", Color(1.0, 0.6, 0.4, 1.0))
	vbox.add_child(lbl_enemies)
	
	var btn_comecar := Button.new()
	btn_comecar.text = "⚔️ Iniciar Batalha de Ondas"
	btn_comecar.custom_minimum_size = Vector2(120, 14)
	btn_comecar.add_theme_font_size_override("font_size", 4)
	btn_comecar.pressed.connect(func():
		canvas.queue_free()
		_iniciar_onda(0)
	)
	vbox.add_child(btn_comecar)


func _restaurar_jogador_total() -> void:
	var hp_max: int = int(PlayerData.attributes.get("vida_max", 100))
	var aura_max: float = float(PlayerData.attributes.get("aura_max", 0.0))
	PlayerData.attributes["vida"] = hp_max
	PlayerData.attributes["aura"] = aura_max
	
	if player != null:
		player.controles_travados = false
		var combat = player.get_node_or_null("CombatSystem") as HunterCombatSystem
		if combat != null:
			combat.estado = HunterCombatSystem.Estado.NORMAL
			combat.pode_atacar = true
			combat.pode_esquivar = true
			combat.invulneravel = false


func _process(delta: float) -> void:
	if not missao_concluida and not missao_derrota:
		tempo_decorrido += delta
		_atualizar_hud()
		
		# Checar derrota do jogador
		var hp: int = int(PlayerData.attributes.get("vida", 100))
		if hp <= 0:
			_ao_derrotar_jogador()


func _criar_hud_paralela() -> void:
	var canvas := CanvasLayer.new()
	canvas.layer = 10
	add_child(canvas)

	# Card Inferior Direito com Informações da Fenda (evita sobrepor a barra de vida no topo esquerdo)
	var panel := PanelContainer.new()
	panel.position = Vector2(165, 148)
	panel.custom_minimum_size = Vector2(151, 28)
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.04, 0.08, 0.14, 0.9)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.border_color = Color(0.2, 0.8, 1.0, 0.9)
	style.corner_radius_top_left = 2
	style.corner_radius_top_right = 2
	style.corner_radius_bottom_right = 2
	style.corner_radius_bottom_left = 2
	panel.add_theme_stylebox_override("panel", style)
	canvas.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 3)
	margin.add_theme_constant_override("margin_top", 2)
	margin.add_theme_constant_override("margin_right", 3)
	margin.add_theme_constant_override("margin_bottom", 2)
	panel.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 1)
	margin.add_child(vbox)

	var lbl_titulo := Label.new()
	lbl_titulo.text = quest_data.get("title", "Missão Paralela")
	lbl_titulo.add_theme_font_size_override("font_size", 4)
	lbl_titulo.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3, 1.0))
	vbox.add_child(lbl_titulo)

	lbl_status_pq = Label.new()
	lbl_status_pq.text = "⚔️ Onda 1/1 | Vivos: 0 | ⏱️ 00:00"
	lbl_status_pq.add_theme_font_size_override("font_size", 3)
	lbl_status_pq.add_theme_color_override("font_color", Color(0.3, 0.9, 1.0, 1.0))
	vbox.add_child(lbl_status_pq)

	# Banner central de transição de onda
	lbl_banner_onda = Label.new()
	lbl_banner_onda.text = ""
	lbl_banner_onda.position = Vector2(80, 50)
	lbl_banner_onda.custom_minimum_size = Vector2(160, 20)
	lbl_banner_onda.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_banner_onda.add_theme_font_size_override("font_size", 6)
	lbl_banner_onda.add_theme_color_override("font_color", Color(1.0, 0.9, 0.2, 1.0))
	canvas.add_child(lbl_banner_onda)

	# Botão de Retornar ao Lobby no Canto Superior Direito
	var btn_sair := Button.new()
	btn_sair.text = "🚪 Sair da Fenda"
	btn_sair.position = Vector2(250, 4)
	btn_sair.custom_minimum_size = Vector2(65, 12)
	btn_sair.add_theme_font_size_override("font_size", 3)
	btn_sair.pressed.connect(_retornar_ao_lobby)
	canvas.add_child(btn_sair)


func _atualizar_hud() -> void:
	if lbl_status_pq:
		var mins := int(tempo_decorrido) / 60
		var secs := int(tempo_decorrido) % 60
		var restantes = max(0, inimigos_onda_totais - inimigos_onda_derrotados)
		var num_ondas = max(1, ondas.size())
		lbl_status_pq.text = "⚔️ Onda %d/%d | Vivos: %d | ⏱️ %02d:%02d" % [
			onda_atual_idx + 1, num_ondas, restantes, mins, secs
		]


func _iniciar_onda(indice_onda: int) -> void:
	if indice_onda >= ondas.size():
		_ao_vencer_missao()
		return
		
	onda_atual_idx = indice_onda
	var wave: Dictionary = ondas[indice_onda]
	
	var count: int = wave.get("count", 1)
	var nome: String = wave.get("nome", "Inimigo Dimensional")
	var hp: int = wave.get("hp", 150)
	var defesa: int = wave.get("defesa", 5)
	var forca: int = wave.get("forca", 15)
	var xp: int = wave.get("xp", 300)
	var is_boss: bool = wave.get("is_boss", false)
	var cor: Color = wave.get("cor", Color(1, 1, 1))

	inimigos_onda_totais = count
	inimigos_onda_derrotados = 0

	# Banner de aviso
	if lbl_banner_onda:
		if is_boss:
			lbl_banner_onda.text = "⚠️ ALERTA: CHEFE APARECEU!"
			lbl_banner_onda.add_theme_color_override("font_color", Color(1.0, 0.2, 0.3, 1.0))
		else:
			lbl_banner_onda.text = "⚔️ ONDA %d / %d" % [indice_onda + 1, ondas.size()]
			lbl_banner_onda.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2, 1.0))
		_animar_banner()

	var enemy_scene = load("res://scripts/systems/EnemySystem/Enemy.tscn")
	if enemy_scene == null:
		push_error("[ParallelQuestArena] Cena de Enemy não encontrada!")
		return

	var spawner_posicoes: Array[Vector2] = [
		Vector2(120, -50), Vector2(-120, -50), Vector2(130, 50), Vector2(-130, 50),
		Vector2(0, -90), Vector2(0, 90), Vector2(160, 0), Vector2(-160, 0)
	]

	for i in range(count):
		var spawn_pos: Vector2 = spawner_posicoes[i % spawner_posicoes.size()]
		spawn_pos += Vector2(randf_range(-12, 12), randf_range(-12, 12))

		var enemy_inst = enemy_scene.instantiate() as CharacterBody2D
		enemy_inst.position = spawn_pos
		enemy_inst.collision_layer = 4
		enemy_inst.collision_mask = 1
		add_child(enemy_inst)

		var enemy_sys: EnemySystem = enemy_inst.get_node_or_null("EnemySystem") as EnemySystem
		if enemy_sys:
			enemy_sys.enemy_id = StringName(nome.to_lower().replace(" ", "_"))
			enemy_sys.enemy_name = nome
			enemy_sys.max_health = hp
			enemy_sys.health = hp
			enemy_sys.defense = defesa
			enemy_sys.strength = forca
			enemy_sys.xp_reward = xp
			enemy_sys.is_boss = is_boss
			enemy_sys.died.connect(_on_inimigo_derrotado)
			
			var hp_bar = enemy_inst.get_node_or_null("HPBar")
			if hp_bar and hp_bar.has_method("atualizar"):
				hp_bar.atualizar(hp, hp)

		var spr = enemy_inst.get_node_or_null("Sprite2D")
		if spr:
			spr.modulate = cor
			if enemy_sys:
				enemy_sys.original_modulate = cor
			if is_boss:
				spr.scale = Vector2(1.4, 1.4)
				var hurtbox = enemy_inst.get_node_or_null("HurtBox")
				if hurtbox:
					var col_shape = hurtbox.get_node_or_null("CollisionShape2D") as CollisionShape2D
					if col_shape and col_shape.shape is CircleShape2D:
						var new_shape := CircleShape2D.new()
						new_shape.radius = 34.0
						col_shape.shape = new_shape
				var enemy_ai = enemy_inst.get_node_or_null("EnemyAI")
				if enemy_ai:
					enemy_ai.attack_range = 55.0
					enemy_ai.stop_distance = 35.0

	print("[ParallelQuestArena] Onda %d iniciada: %d inimigos de '%s'" % [
		indice_onda + 1, count, nome
	])


func _animar_banner() -> void:
	if lbl_banner_onda == null:
		return
	lbl_banner_onda.visible = true
	lbl_banner_onda.modulate.a = 1.0
	var tween := create_tween()
	tween.tween_interval(1.8)
	tween.tween_property(lbl_banner_onda, "modulate:a", 0.0, 0.5)
	tween.tween_callback(func():
		if is_instance_valid(lbl_banner_onda):
			lbl_banner_onda.visible = false
	)


func _on_inimigo_derrotado(_enemy_id: StringName = &"") -> void:
	inimigos_onda_derrotados += 1
	inimigos_derrotados_global += 1
	_atualizar_hud()
	
	if inimigos_onda_derrotados >= inimigos_onda_totais and not missao_concluida:
		# Próxima onda ou vitória
		if onda_atual_idx + 1 < ondas.size():
			await get_tree().create_timer(1.0).timeout
			if not missao_concluida and not missao_derrota:
				_iniciar_onda(onda_atual_idx + 1)
		else:
			_ao_vencer_missao()


func _ao_vencer_missao() -> void:
	if missao_concluida or missao_derrota:
		return
	missao_concluida = true
	print("[ParallelQuestArena] FENDA TEMPORAL CONCLUÍDA COM SUCESSO!")

	# Calcular Rank (S, A, B)
	var rank := "B"
	if tempo_decorrido < 65.0:
		rank = "S"
	elif tempo_decorrido < 120.0:
		rank = "A"

	# Entregar Recompensas
	var xp: int = quest_data.get("reward_xp", 2000)
	var gold: int = quest_data.get("reward_gold", 10000)
	var items: Array = quest_data.get("reward_items", [])

	# XP
	var xp_sys = get_tree().get_first_node_in_group("xp_system")
	if xp_sys == null:
		xp_sys = get_tree().root.find_child("XPSystem", true, false)
	if xp_sys and xp_sys.has_method("adicionar_xp"):
		xp_sys.adicionar_xp(xp, "Missão Paralela")

	# Gold
	Economy.adicionar_gold(gold)

	# Items & Materiais Raros
	for it in items:
		var item_id: String = it.get("id", "")
		var qtd: int = it.get("qtd", 1)
		PlayerData.adicionar_item(StringName(item_id), qtd)

	var materials: Array = quest_data.get("reward_materials", [])
	for mat in materials:
		var mat_id: String = mat.get("id", "")
		var qtd: int = mat.get("qtd", 1)
		PlayerData.adicionar_item(StringName(mat_id), qtd)

	# Salvar conclusão
	PlayerData.concluir_missao_paralela(pq_id)

	# Exibir Tela de Vitória
	_exibir_tela_vitoria(rank, xp, gold, items + materials)


func _ao_derrotar_jogador() -> void:
	if missao_derrota or missao_concluida:
		return
	missao_derrota = true
	print("[ParallelQuestArena] JOGADOR DERROTADO NA FENDA!")

	var canvas := CanvasLayer.new()
	canvas.layer = 25
	add_child(canvas)

	panel_derrota = PanelContainer.new()
	panel_derrota.custom_minimum_size = Vector2(200, 100)
	panel_derrota.position = Vector2(60, 40)
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.02, 0.02, 0.95)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = Color(1.0, 0.2, 0.2, 1.0)
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_right = 4
	style.corner_radius_bottom_left = 4
	panel_derrota.add_theme_stylebox_override("panel", style)
	canvas.add_child(panel_derrota)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 6)
	margin.add_theme_constant_override("margin_top", 4)
	margin.add_theme_constant_override("margin_right", 6)
	margin.add_theme_constant_override("margin_bottom", 4)
	panel_derrota.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 2)
	margin.add_child(vbox)

	var lbl_tit := Label.new()
	lbl_tit.text = "💀 DERROTA NA FENDA TEMPORAL 💀"
	lbl_tit.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_tit.add_theme_font_size_override("font_size", 5)
	lbl_tit.add_theme_color_override("font_color", Color(1.0, 0.3, 0.3, 1.0))
	vbox.add_child(lbl_tit)

	var lbl_msg := Label.new()
	lbl_msg.text = "Você sucumbiu diante dos ecos dimensionais de Nen.\nRecupere seu fôlego e tente novamente!"
	lbl_msg.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_msg.add_theme_font_size_override("font_size", 3)
	lbl_msg.add_theme_color_override("font_color", Color(0.85, 0.85, 0.85, 1.0))
	vbox.add_child(lbl_msg)

	var sep := HSeparator.new()
	vbox.add_child(sep)

	var hbox_btns := HBoxContainer.new()
	hbox_btns.add_theme_constant_override("separation", 4)
	vbox.add_child(hbox_btns)

	var btn_retry := Button.new()
	btn_retry.text = "🔄 TENTAR NOVAMENTE"
	btn_retry.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_retry.add_theme_font_size_override("font_size", 3)
	btn_retry.pressed.connect(_reiniciar_missao)
	hbox_btns.add_child(btn_retry)

	var btn_sair := Button.new()
	btn_sair.text = "🚪 RETORNAR AO LOBBY"
	btn_sair.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_sair.add_theme_font_size_override("font_size", 3)
	btn_sair.pressed.connect(_retornar_ao_lobby)
	hbox_btns.add_child(btn_sair)


func _reiniciar_missao() -> void:
	_restaurar_jogador_total()
	get_tree().reload_current_scene()


func _exibir_tela_vitoria(rank: String, xp: int, gold: int, items: Array) -> void:
	var canvas := CanvasLayer.new()
	canvas.layer = 20
	add_child(canvas)

	panel_vitoria = PanelContainer.new()
	panel_vitoria.custom_minimum_size = Vector2(220, 120)
	panel_vitoria.position = Vector2(50, 30)
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.02, 0.05, 0.1, 0.95)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = Color(1.0, 0.85, 0.2, 1.0)
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_right = 4
	style.corner_radius_bottom_left = 4
	panel_vitoria.add_theme_stylebox_override("panel", style)
	canvas.add_child(panel_vitoria)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 6)
	margin.add_theme_constant_override("margin_top", 4)
	margin.add_theme_constant_override("margin_right", 6)
	margin.add_theme_constant_override("margin_bottom", 4)
	panel_vitoria.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 2)
	margin.add_child(vbox)

	var lbl_vit := Label.new()
	lbl_vit.text = "★ VITÓRIA NA FENDA TEMPORAL! ★"
	lbl_vit.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_vit.add_theme_font_size_override("font_size", 5)
	lbl_vit.add_theme_color_override("font_color", Color(1.0, 0.9, 0.3, 1.0))
	vbox.add_child(lbl_vit)

	var lbl_rank := Label.new()
	lbl_rank.text = "RANK OBTIDO: [ %s ]" % rank
	lbl_rank.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_rank.add_theme_font_size_override("font_size", 5)
	var cor_rank := Color(1.0, 0.3, 0.3) if rank == "B" else (Color(0.2, 0.8, 1.0) if rank == "A" else Color(1.0, 0.85, 0.1))
	lbl_rank.add_theme_color_override("font_color", cor_rank)
	vbox.add_child(lbl_rank)

	var sep := HSeparator.new()
	vbox.add_child(sep)

	var item_str := ""
	for it in items:
		item_str += "+%dx %s  " % [it.get("qtd", 1), str(it.get("id", "")).capitalize()]

	var lbl_recomp := Label.new()
	lbl_recomp.text = "🎁 Recompensas Entregues:\n+ %d XP  |  + %d Jenny (Ouro)\n🎒 %s" % [xp, gold, item_str]
	lbl_recomp.add_theme_font_size_override("font_size", 3)
	lbl_recomp.add_theme_color_override("font_color", Color(0.3, 1.0, 0.6, 1.0))
	vbox.add_child(lbl_recomp)

	var btn_retornar := Button.new()
	btn_retornar.text = "🚪 RETORNAR AO LOBBY"
	btn_retornar.add_theme_font_size_override("font_size", 4)
	btn_retornar.custom_minimum_size = Vector2(0, 14)
	btn_retornar.pressed.connect(_retornar_ao_lobby)
	vbox.add_child(btn_retornar)


func _retornar_ao_lobby() -> void:
	print("[ParallelQuestArena] Retornando ao Lobby...")
	_restaurar_jogador_total()
	var trans = get_node_or_null("/root/SceneTransition")
	if trans != null and trans.has_method("mudar_cena"):
		trans.mudar_cena("res://world/lobby.tscn", "Capital dos Caçadores", "Hunter Plaza — Hub Central")
	else:
		get_tree().change_scene_to_file("res://world/lobby.tscn")
