class_name ArenaCelestialMap
extends Node2D
const StoryGate = preload("res://world/components/StoryGate.gd")

# ============================================================
# HUNTER ONLINE - MAPA DA ARENA CELESTIAL (ARCO 3 - 26 ETAPAS)
# ============================================================
#
# Coordena os eventos do Arco 3 (Arena Celestial):
# - Popula NPCs: Recepcionista, Zushi, Mestre Wing e Hisoka.
# - Configura os Lutadores dos primeiros andares e Mestres do 200º Andar.
# - Rastreia marcos dos andares e exibe notificações de imersão.
# - STORY GATE: Exige conclusão das 26 etapas antes de Yorknew.
#
# ============================================================

var _marcos_notificados: Dictionary = {
	"recepcao": false,
	"ringues_inferiores": false,
	"ringues_superiores": false,
	"topo": false
}


func _ready() -> void:
	MapAtmosphereDecorator.attach(self, MapAtmosphereDecorator.MapKind.ARENA)
	_garantir_dialogue_ui()
	_popular_npcs_arco3()
	_garantir_objeto_teste_agua()
	_configurar_inimigos()
	_densificar_corredor_arena()
	_configurar_portal_conclusao()
	_garantir_quest_ativa()
	_garantir_tower_ui()
	if QuestSystem != null:
		QuestSystem.sincronizar_inimigos_do_mapa(self)


func _process(_delta: float) -> void:
	_atualizar_marcos_andar()


func _atualizar_marcos_andar() -> void:
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return
	var x: float = player.global_position.x
	_tentar_marco("recepcao", x, -50.0, 350.0, "🏛️ Recepção da Arena Celestial — registre-se antes de subir.")
	_tentar_marco("ringues_inferiores", x, 500.0, 1300.0, "⚔️ Ringues Inferiores — andares de aquecimento.")
	_tentar_marco("ringues_superiores", x, 1500.0, 2800.0, "🔥 Ringues Superiores — oposição com Nen real.")
	_tentar_marco("topo", x, 3200.0, 4600.0, "👑 Topo / 200º Andar — apenas mestres sobrevivem aqui.")


func _tentar_marco(id: String, x: float, x_min: float, x_max: float, msg: String) -> void:
	if bool(_marcos_notificados.get(id, false)):
		return
	if x < x_min or x > x_max:
		return
	_marcos_notificados[id] = true
	if EventBus != null:
		EventBus.emit_toast(msg, Color(0.75, 0.9, 1.0))


func _garantir_tower_ui() -> void:
	if get_tree().get_first_node_in_group("heavens_arena_tower_ui") != null:
		return
	var ui_script = load("res://ui/Arena/HeavensArenaTowerUI.gd")
	if ui_script == null:
		return
	var ui = ui_script.new()
	ui.name = "HeavensArenaTowerUI"
	ui.add_to_group("heavens_arena_tower_ui")
	add_child(ui)

	var recep = get_node_or_null("Recepcionista")
	if recep == null:
		return
	# Área de interação dedicada ao torneio de andares
	if get_node_or_null("TorneioAndaresTrigger") != null:
		return
	var area := Area2D.new()
	area.name = "TorneioAndaresTrigger"
	area.position = Vector2(80, 0)
	area.collision_layer = 0
	area.collision_mask = 2
	var col := CollisionShape2D.new()
	var circ := CircleShape2D.new()
	circ.radius = 28.0
	col.shape = circ
	area.add_child(col)
	var inter := InteractionComponent.new()
	inter.name = "InteractionComponent"
	inter.interaction_text = "[E] Abrir Torneio de Andares (200 Floors)"
	inter.interaction_radius = 30.0
	inter.interacted.connect(func(_p):
		var tower = get_tree().get_first_node_in_group("heavens_arena_tower_ui")
		if tower != null and tower.has_method("abrir_torneio"):
			tower.abrir_torneio()
	)
	area.add_child(inter)
	var lbl := Label.new()
	lbl.text = "🏛️ Torneio 200 Andares\n[E] Desafiar"
	lbl.position = Vector2(-50, -36)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.add_theme_font_size_override("font_size", 5)
	lbl.add_theme_color_override("font_color", Color(0.7, 0.9, 1.0))
	area.add_child(lbl)
	add_child(area)


func _garantir_dialogue_ui() -> void:
	var visual_dialogue = get_tree().get_first_node_in_group("visual_dialogue_ui")
	if visual_dialogue == null:
		var scene = load("res://ui/dialogue/VisualDialogueUI.tscn")
		if scene:
			var ui = scene.instantiate()
			add_child(ui)


func _garantir_quest_ativa() -> void:
	if QuestSystem != null and QuestSystem.active_quests.is_empty():
		QuestSystem.garantir_quest_do_arco(3)


func _popular_npcs_arco3() -> void:
	var scn_npc = load("res://entities/npc/NPC.tscn")
	if scn_npc == null:
		print("[ArenaCelestialMap] ERRO: NPC.tscn não encontrado!")
		return

	# 1. Recepcionista da Arena
	if get_node_or_null("Recepcionista") == null:
		var recepcionista = scn_npc.instantiate()
		recepcionista.name = "Recepcionista"
		recepcionista.position = Vector2(50, 0)
		recepcionista.npc_name = "Recepcionista da Arena"
		recepcionista.fala_padrao = "Bem-vindo à Arena Celestial! Por favor, preencha este formulário para se registrar. Boa sorte nas lutas e tente não morrer nos andares mais altos!"
		NpcSpriteBinder.aplicar(recepcionista, ["npc_recepcionista_elena"])
		add_child(recepcionista)

	# 2. Zushi
	if get_node_or_null("Zushi") == null:
		var zushi = scn_npc.instantiate()
		zushi.name = "Zushi"
		zushi.position = Vector2(1000, -80)
		zushi.npc_name = "Zushi"
		zushi.fala_padrao = "Osu! Sou Zushi, discípulo do mestre Wing! Estou aprendendo o estilo Shingen-ryu de Kung Fu. Preciso treinar mais duro! Osu!"
		NpcSpriteBinder.aplicar(zushi, ["npc_discipulo_zushi"])
		add_child(zushi)

	# 3. Mestre Wing (Dojo — alinhado ao Teste da Água)
	if get_node_or_null("Wing") == null:
		var scn_wing = load("res://entities/npc/wing/Wing.tscn")
		var wing
		if scn_wing:
			wing = scn_wing.instantiate()
		else:
			wing = scn_npc.instantiate()
			wing.script = load("res://entities/npc/wing/Wing.gd")
		wing.name = "Wing"
		wing.position = Vector2(1100, -80)
		add_child(wing)
	else:
		# Cena base spawna Wing em (300,-100); realinha ao cluster do dojo
		var wing_existente = get_node_or_null("Wing")
		if wing_existente != null and wing_existente.position.x < 900.0:
			wing_existente.position = Vector2(1100, -80)

	# 4. Hisoka (Barreira do 200º Andar & Ringue Principal)
	if get_node_or_null("Hisoka") == null:
		var scn_hisoka = load("res://entities/npc/hisoka/Hisoka.tscn")
		var hisoka
		if scn_hisoka:
			hisoka = scn_hisoka.instantiate()
		else:
			hisoka = scn_npc.instantiate()
			NpcSpriteBinder.aplicar(hisoka, ["npc_hisoka"])
		
		hisoka.name = "Hisoka"
		hisoka.position = Vector2(3500, -100)
		hisoka.npc_name = "Hisoka Morow"
		hisoka.fala_padrao = "Oh... Você chegou até aqui? Suas frutas ainda estão muito verdes... Continue amadurecendo para que eu possa esmagá-las de uma vez. ♥"
		add_child(hisoka)


func _garantir_objeto_teste_agua() -> void:
	if get_node_or_null("TesteAguaWing") != null:
		return

	var trigger := Area2D.new()
	trigger.name = "TesteAguaWing"
	trigger.position = Vector2(1160, -80)
	trigger.collision_layer = 0
	trigger.collision_mask = 2

	var col := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 24.0
	col.shape = shape
	trigger.add_child(col)

	var inter := InteractionComponent.new()
	inter.name = "InteractionComponent"
	inter.interaction_text = "[E] Realizar o Teste da Água (Water Divination)"
	inter.interaction_radius = 28.0
	trigger.add_child(inter)

	var lbl := Label.new()
	lbl.name = "VisualLabel"
	lbl.text = "🍵 Teste da Água (Folha de Nen)\n[E] Inspecionar"
	lbl.position = Vector2(-70, -32)
	lbl.custom_minimum_size = Vector2(140, 14)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.add_theme_font_size_override("font_size", 4)
	lbl.add_theme_color_override("font_color", Color(0.4, 0.9, 1.0))
	trigger.add_child(lbl)

	inter.interacted.connect(func(_player):
		print("[ArenaCelestial] Jogador inspecionou o Teste da Água!")
		if QuestSystem != null:
			QuestSystem.register_investigation(&"teste_agua_wing")
		var afinidade_nome := NenAffinityData.obter_nome_afinidade(PlayerData.afinidade_nen)
		if EventBus != null:
			EventBus.emit_toast("🍵 A água reagiu! Afinidade revelada: %s!" % afinidade_nome.to_upper(), Color(0.2, 1.0, 0.6))
		var visual_dialogue = get_tree().get_first_node_in_group("visual_dialogue_ui")
		if visual_dialogue != null:
			visual_dialogue.exibir_sequencia_falas([
				{"falante": "Mestre Wing", "texto": "Incrível! Ao aproximar suas mãos do copo com aura concentrada, a reação foi instantânea!"},
				{"falante": "Mestre Wing", "texto": "Sua afinidade é oficialmente comprovada como: %s!" % afinidade_nome.to_upper()},
				{"falante": "Mestre Wing", "texto": "Agora que sua natureza de Nen foi revelada, fale comigo para abrir seus poros e dominar o TEN!"}
			])
	)
	add_child(trigger)


func _configurar_inimigos() -> void:
	# Lutadores dos Andares Inferiores (Arco 3, Etapas 2, 3, 4, 5)
	var lutadores = ["LutadorArena1", "LutadorArena2", "LutadorArena3", "LutadorArena4"]
	var posicoes_padrao = [
		Vector2(600, -80),   # 1º Andar
		Vector2(1100, 150),  # 50º Andar
		Vector2(1600, -120), # 100º Andar
		Vector2(2100, 100)   # 190º Andar
	]
	var scn_enemy = load("res://scripts/systems/EnemySystem/Enemy.tscn")

	for i in range(lutadores.size()):
		var nome = lutadores[i]
		var node = get_node_or_null(nome)
		if node == null and scn_enemy != null:
			node = scn_enemy.instantiate()
			node.name = nome
			node.position = posicoes_padrao[i]
			add_child(node)

		if node != null:
			node.add_to_group("enemy")
			node.add_to_group("enemies")
			var es = node.get_node_or_null("EnemySystem")
			if es != null:
				es.is_mission_enemy = true
				es.quest_arc = 3
				es.quest_etapa = 2 + i
				es.enemy_id = &"lutador_arena"
				es.enemy_name = "Lutador da Arena (%dº Andar)" % ((i + 1) * 45)
				if not es.died.is_connected(QuestSystem.register_enemy_kill):
					es.died.connect(QuestSystem.register_enemy_kill)
				if QuestSystem != null:
					QuestSystem.registrar_spawn_posicao_missao(&"lutador_arena", node.global_position, 3, 2 + i, -1, null, es.enemy_name)

	# Mestres do 200º Andar (Gido, Riehlvelt, Kastro, Hisoka Boss)
	var configs = {
		"LutadorAndar200Gido": {"id": &"piao_gido", "nome": "Gido (Piões de Nen)", "etapa": 18},
		"LutadorAndar200Riehlvelt": {"id": &"riehlvelt", "nome": "Riehlvelt (Cadeira Elétrica)", "etapa": 19},
		"LutadorAndar200Kastro": {"id": &"kastro", "nome": "Kastro (Clone de Nen)", "etapa": 21},
		"MestreAndar200": {"id": &"hisoka_boss", "nome": "Hisoka Boss (200º Andar)", "etapa": 25}
	}
	
	for nome in configs:
		var node = get_node_or_null(nome)
		if node != null:
			node.add_to_group("enemy")
			node.add_to_group("enemies")
			var es = node.get_node_or_null("EnemySystem")
			if es != null:
				es.is_mission_enemy = true
				es.quest_arc = 3
				es.quest_etapa = configs[nome]["etapa"]
				es.enemy_id = configs[nome]["id"]
				es.enemy_name = configs[nome]["nome"]
				if not es.died.is_connected(QuestSystem.register_enemy_kill):
					es.died.connect(QuestSystem.register_enemy_kill)
				if QuestSystem != null:
					QuestSystem.registrar_spawn_posicao_missao(es.enemy_id, node.global_position, 3, es.quest_etapa, -1, null, es.enemy_name)


func _densificar_corredor_arena() -> void:
	# Lutadores ambient (não-missão) entre os ringues da história
	var scn_enemy = load("res://scripts/systems/EnemySystem/Enemy.tscn")
	if scn_enemy == null:
		return
	var fillers := [
		{"name": "LutadorAmbient_A", "pos": Vector2(850, -40), "label": "Lutador Amador (20º)"},
		{"name": "LutadorAmbient_B", "pos": Vector2(1350, 80), "label": "Lutador Veterano (70º)"},
		{"name": "LutadorAmbient_C", "pos": Vector2(1850, -60), "label": "Lutador Elite (120º)"},
		{"name": "LutadorAmbient_D", "pos": Vector2(2500, 40), "label": "Lutador do Corredor (160º)"},
		{"name": "LutadorAmbient_E", "pos": Vector2(2900, -50), "label": "Lutador do 180º"},
		{"name": "LutadorAmbient_F", "pos": Vector2(3200, 70), "label": "Desafiante do Corredor"},
	]
	for f in fillers:
		if get_node_or_null(f["name"]) != null:
			continue
		var mob = scn_enemy.instantiate()
		mob.name = f["name"]
		mob.position = f["pos"]
		mob.add_to_group("enemy")
		mob.add_to_group("enemies")
		var es = mob.get_node_or_null("EnemySystem")
		if es != null:
			es.is_mission_enemy = false
			es.enemy_id = &"lutador_arena"
			es.enemy_name = f["label"]
		add_child(mob)

	# Placas de andar — quebram o corredor vazio
	var placas := [
		{"name": "PlacaAndar1", "pos": Vector2(200, -60), "text": "📍 1º Andar — Recepção"},
		{"name": "PlacaAndar50", "pos": Vector2(1000, -140), "text": "📍 50º Andar — Dojo Wing"},
		{"name": "PlacaAndar100", "pos": Vector2(1600, -160), "text": "📍 100º Andar — Ringues Médios"},
		{"name": "PlacaAndar190", "pos": Vector2(2100, -140), "text": "📍 190º Andar — Pré-Final"},
		{"name": "PlacaAndar200", "pos": Vector2(3400, -140), "text": "📍 200º Andar — Topo"},
	]
	for p in placas:
		if get_node_or_null(p["name"]) != null:
			continue
		var marker := Node2D.new()
		marker.name = p["name"]
		marker.position = p["pos"]
		var lbl := Label.new()
		lbl.text = p["text"]
		lbl.position = Vector2(-55, -10)
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.add_theme_font_size_override("font_size", 5)
		lbl.add_theme_color_override("font_color", Color(0.85, 0.9, 1.0, 0.95))
		lbl.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.85))
		marker.add_child(lbl)
		add_child(marker)


func _configurar_portal_conclusao() -> void:
	var portal = get_node_or_null("PortalYorknew") as MapTransitionArea
	if portal != null:
		portal.portal_name = "Yorknew City"
		portal.map_subtitle = "Arco 4 — O Leilão Subterrâneo & A Trupe Fantasma"
		portal.story_gate = StoryGate.new(3, 26, true)
		portal.story_gate.gate_title = "Saída da Arena Celestial"
		portal.story_gate.default_locked_message = "Você precisa concluir todas as 26 etapas da Arena Celestial e devolver a placa a Hisoka antes de partir para Yorknew!"
		portal.callback_dialogo_previo = func(mudar_cena_cb: Callable):
			StoryCutsceneManager.executar_arena_celestial_cutscene(get_tree(), mudar_cena_cb)