class_name DungeonRuinasZabanMap
extends Node2D

# ============================================================
# HUNTER ONLINE - DUNGEON: RUÍNAS DE ZABAN (SANTUÁRIO ANCESTRAL)
# ============================================================
#
# Mapa interno da Dungeon das Ruínas de Zaban:
# - Corredores de pedra ancestral e pilares
# - Sentinelas de Pedra no corredor principal
# - Câmara do Chefe com o Guardião Ancestral de Zaban (Boss)
# - Barra de Chefe (Boss Bar) no topo da tela do PlayerHUD
# - Baú Dourado de Recompensas após vitória
# - Portal de Retorno ao Vale de Padokia
#
# ============================================================

const PATH_TILESET = "res://world/tilesets/world_tileset.tres"

@onready var chao_layer: TileMapLayer = get_node_or_null("Chao_TileMapLayer")
@onready var paredes_layer: TileMapLayer = get_node_or_null("Paredes_TileMapLayer")
@onready var decor_layer: TileMapLayer = get_node_or_null("Decor_TileMapLayer")
@onready var player: CharacterBody2D = get_node_or_null("Player")

var boss_node: Node = null
var boss_derrotado: bool = false
var raid_instance = null
var _raid_catalog_entry: Dictionary = {}


func _ready() -> void:
	var tileset = load(PATH_TILESET) as TileSet
	if tileset != null:
		if chao_layer: chao_layer.tile_set = tileset
		if paredes_layer: paredes_layer.tile_set = tileset
		if decor_layer: decor_layer.tile_set = tileset
		
	_garantir_spawn_points()
	_gerar_mapa_dungeon()
	_instanciar_boss_e_sentinelas()
	_posicionar_player()
	_configurar_audio_e_hud()
	_iniciar_raid_vertical()
	if QuestSystem != null:
		QuestSystem.sincronizar_inimigos_do_mapa(self)
	MapAtmosphereDecorator.attach(self, MapAtmosphereDecorator.MapKind.DUNGEON)


func _garantir_spawn_points() -> void:
	if get_node_or_null("SpawnEntrada") == null:
		var sp := SpawnPoint.new()
		sp.name = "SpawnEntrada"
		sp.spawn_id = &"entrada"
		sp.is_default_spawn = true
		sp.position = Vector2(320, 410)
		add_child(sp)
		if WorldProgressionManager != null:
			WorldProgressionManager.registrar_spawn_point(sp)


func _posicionar_player() -> void:
	if player == null:
		var players = get_tree().get_nodes_in_group("player")
		if not players.is_empty():
			player = players[0] as CharacterBody2D
			
	if player != null:
		if WorldProgressionManager != null:
			WorldProgressionManager.posicionar_player_no_spawn(player)
		else:
			player.global_position = Vector2(320, 410)


func _configurar_audio_e_hud() -> void:
	if AudioManager != null and AudioManager.has_method("tocar_bgm"):
		AudioManager.tocar_bgm("dungeon_ruins")
		
	var hud = get_tree().get_first_node_in_group("player_hud")
	if hud and hud.has_method("exibir_notificacao"):
		hud.exibir_notificacao("🏛️ Você adentrou as [Ruínas de Zaban] — Perigo Extremo (Dungeon)")


func _gerar_mapa_dungeon() -> void:
	if chao_layer == null or paredes_layer == null:
		return
		
	# Dimensões da Dungeon: 40x30 tiles (640x480 px)
	# 1. Preencher paredes em toda a borda externa
	for y in range(0, 30):
		for x in range(0, 40):
			if x == 0 or x == 39 or y == 0 or y == 29:
				paredes_layer.set_cell(Vector2i(x, y), 4, Vector2i(0, 0)) # Rocha sólida
			else:
				chao_layer.set_cell(Vector2i(x, y), 0, Vector2i(1, 9)) # Calçada / Piso de pedra
				
	# 2. Paredes de divisão da antecâmara (Y: 14) com passagem central (X: 18 a 22)
	for x in range(1, 39):
		if x < 18 or x > 22:
			paredes_layer.set_cell(Vector2i(x, 14), 4, Vector2i(0, 0))
			
	# 3. Pilares decorativos na Câmara do Chefe
	var pilares = [Vector2i(8, 6), Vector2i(32, 6), Vector2i(8, 22), Vector2i(32, 22)]
	for p in pilares:
		if decor_layer:
			decor_layer.set_cell(p, 9, Vector2i(0, 2)) # Pilar de ruína


func _instanciar_boss_e_sentinelas() -> void:
	# 1. Sentinelas na Antecâmara (Y: 20)
	_instanciar_mob(Vector2(200, 360), "Sentinela de Pedra 1", false)
	_instanciar_mob(Vector2(440, 360), "Sentinela de Pedra 2", false)
	
	# 2. Guardião Ancestral de Zaban (Boss) no centro da câmara norte (X: 320, Y: 120)
	_instanciar_mob(Vector2(320, 120), "Guardião Ancestral de Zaban", true)
	
	# 3. Portal de Saída (X: 320, Y: 440)
	_criar_portal_saida(Vector2(320, 440))

	_instanciar_sensores_nen_ruinas()


func _instanciar_sensores_nen_ruinas() -> void:
	# Gyo pós-despertar; Ko/Zetsu ficam disponíveis como exploração física
	if PlayerData != null and PlayerData.despertou_nen:
		NenSensorFactory.criar_gyo(
			self, "GyoClueAntecâmara", Vector2(320, 300),
			&"zaban_selo_antecamara", "Selo de Pedra Resonante",
			"A antecâmara guarda um selo de Nen. O Guardião Ancestral está vinculado a esta marca.",
			"Especialização", 1, Color(0.85, 0.75, 0.35, 0.9)
		)
		NenSensorFactory.criar_gyo(
			self, "GyoClueCamaraBoss", Vector2(200, 140),
			&"zaban_fissura_aura", "Fissura de Aura Ancestral",
			"Uma rachadura no piso emana aura densa. KO concentrado poderia abrir um atalho lateral.",
			"Intensificação", 2, Color(1.0, 0.45, 0.3, 0.9)
		)
	NenSensorFactory.criar_ko(
		self, "KoObstacleCamaraLateral", Vector2(480, 160),
		"Pilar Rachado da Câmara", &"pedra_aura"
	)
	NenSensorFactory.criar_zetsu(
		self, "ZetsuCorredorSentinelas", Vector2(320, 360),
		&"zaban_corredor_sentinelas", "Corredor das Sentinelas",
		Vector2(200, 80)
	)


func _instanciar_mob(pos: Vector2, nome: String, is_boss: bool) -> void:
	var enemy_scn = load("res://scripts/systems/EnemySystem/Enemy.tscn")
	if enemy_scn:
		var enemy = enemy_scn.instantiate()
		enemy.name = nome.replace(" ", "_")
		enemy.position = pos
		add_child(enemy)
		
		var es = enemy.get_node_or_null("EnemySystem")
		if es:
			if is_boss:
				boss_node = enemy
				es.is_boss = true
				es.max_health = 600
				es.health = 600
				es.defense = 15
				es.strength = 32
				es.defesa_barra_max = 280.0
				es.defesa_barra_atual = 280.0
				es.tempo_defesa_quebrada = 4.0
				es.xp_reward = 800
				es.nen_xp_reward = 600
				es.enemy_id = &"guardiao_ancestral"
				es.enemy_name = nome
				
				# Conectar derrota do chefe
				es.died.connect(_on_boss_derrotado)
				if not es.died.is_connected(QuestSystem.register_enemy_kill):
					es.died.connect(QuestSystem.register_enemy_kill)
				if QuestSystem != null:
					QuestSystem.registrar_spawn_posicao_missao(&"guardiao_ancestral", pos, 0, 0, -1, null, nome)
				
				# Ativar Boss Bar no HUD
				var hud = get_tree().get_first_node_in_group("player_hud")
				if hud and hud.has_method("registrar_boss"):
					hud.registrar_boss(es)
			else:
				es.max_health = 140
				es.health = 140
				es.defense = 10
				es.strength = 18
				es.defesa_barra_max = 120.0
				es.defesa_barra_atual = 120.0
				es.tempo_defesa_quebrada = 3.0
				es.xp_reward = 120
				es.nen_xp_reward = 80
				es.enemy_id = &"sentinela_pedra"
				es.enemy_name = nome
				if not es.died.is_connected(QuestSystem.register_enemy_kill):
					es.died.connect(QuestSystem.register_enemy_kill)
				if QuestSystem != null:
					QuestSystem.registrar_spawn_posicao_missao(&"sentinela_pedra", pos, 0, 0, -1, null, nome)


func _on_boss_derrotado(_enemy_type: StringName) -> void:
	if boss_derrotado: return
	boss_derrotado = true
	
	print("============================================================")
	print("🏆 BOSS DERROTADO: Guardião Ancestral de Zaban foi vencido!")
	print("============================================================")
	
	if EventBus != null:
		EventBus.enemy_defeated.emit("guardiao_ancestral", 800, 600)
		EventBus.emit_toast("🏆 CHEFE DERROTADO! Guardião Ancestral de Zaban", Color(1.0, 0.85, 0.2))

	if raid_instance != null and raid_instance.has_method("complete_raid"):
		var result: Dictionary = raid_instance.complete_raid()
		_spawn_raid_loot_ground(result)
		if PartyManager != null and PartyManager.has_method("sair_modo_raid"):
			PartyManager.sair_modo_raid()
		if EventBus != null:
			EventBus.emit_toast("Raid limpa — loot distribuído", Color(0.45, 0.95, 0.7))
		
	# Spawna Baú Dourado no local do chefe
	_spawna_bau_dourado(Vector2(320, 120))


func _iniciar_raid_vertical() -> void:
	var RaidCatalogScript = load("res://resource/raid/RaidCatalog.gd")
	var RaidInstanceScript = load("res://scripts/network/RaidInstance.gd")
	if RaidCatalogScript == null or RaidInstanceScript == null:
		return
	if not RaidCatalogScript.has_raid("ruins_zaban_vertical"):
		return
	_raid_catalog_entry = RaidCatalogScript.get_raid("ruins_zaban_vertical")
	var members: Array[int] = []
	if PartyManager != null and PartyManager.has_method("obter_membros"):
		for m in PartyManager.obter_membros():
			members.append(int(m))
	if members.is_empty():
		var local_id := 1
		if NetworkManager != null and "local_peer_id" in NetworkManager:
			local_id = maxi(1, int(NetworkManager.local_peer_id))
		members = [local_id]
	if PartyManager != null and PartyManager.has_method("entrar_modo_raid"):
		PartyManager.entrar_modo_raid()
	raid_instance = RaidInstanceScript.new()
	raid_instance.name = "RaidInstanceZaban"
	add_child(raid_instance)
	if not raid_instance.start_raid("ruins_zaban_vertical", members, _raid_catalog_entry):
		push_warning("[DungeonRuinasZaban] Falha ao iniciar raid vertical")
		raid_instance = null
		if PartyManager != null and PartyManager.has_method("sair_modo_raid"):
			PartyManager.sair_modo_raid()
		return
	if raid_instance.has_signal("phase_changed"):
		raid_instance.phase_changed.connect(_on_raid_phase_changed)
	if raid_instance.has_signal("enrage_started"):
		raid_instance.enrage_started.connect(_on_raid_enrage)
	var hud = get_tree().get_first_node_in_group("player_hud")
	if hud != null and hud.has_method("exibir_notificacao"):
		hud.exibir_notificacao("⚔️ Raid: %s" % str(_raid_catalog_entry.get("title", "Ruínas de Zaban")))


func _process(delta: float) -> void:
	if raid_instance == null or boss_derrotado:
		return
	if raid_instance.has_method("tick_enrage"):
		raid_instance.tick_enrage(delta)
	if boss_node == null or not is_instance_valid(boss_node):
		return
	var es = boss_node.get_node_or_null("EnemySystem")
	if es == null:
		return
	var max_hp: float = maxf(1.0, float(es.max_health))
	var ratio: float = float(es.health) / max_hp
	if raid_instance.has_method("update_boss_hp_ratio"):
		raid_instance.update_boss_hp_ratio(ratio)


func _on_raid_phase_changed(phase_index: int, phase_id: String) -> void:
	if EventBus != null:
		EventBus.emit_toast("Fase %d — %s" % [phase_index + 1, phase_id], Color(1.0, 0.55, 0.3))
	if AudioManager != null:
		AudioManager.tocar_sfx_tipo("boss_phase", 1.1)


func _on_raid_enrage(_seconds: float) -> void:
	if EventBus != null:
		EventBus.emit_toast("⚠ ENRAGE! O Guardião entra em frenesi!", Color(1.0, 0.2, 0.2))
	if AudioManager != null:
		AudioManager.tocar_sfx_tipo("boss_intro", 1.2)


func _spawn_raid_loot_ground(result: Dictionary) -> void:
	var loot_list: Array = result.get("loot", [])
	var base_pos := Vector2(320, 140)
	var jenny_total := 0
	for entry in loot_list:
		if entry is Dictionary:
			jenny_total += int(entry.get("jenny", entry.get("gold", 25)))
	if jenny_total <= 0:
		jenny_total = 120
	LootDrop.spawn_jenny(self, base_pos, jenny_total)
	LootDrop.spawn_item_drop(self, base_pos + Vector2(14, 0), "fragmento_aura_ancestral")


func _spawna_bau_dourado(pos: Vector2) -> void:
	var bau := Area2D.new()
	bau.name = "BauDouradoRecompensa"
	bau.position = pos
	
	var col := CollisionShape2D.new()
	var box := RectangleShape2D.new()
	box.size = Vector2(32, 32)
	col.shape = box
	bau.add_child(col)
	
	var inter = load("res://entities/components/InteractionComponent.gd").new()
	inter.interaction_text = "Abrir Baú Dourado Ancestral [E]"
	inter.interacted.connect(func():
		_abrir_bau(bau)
	)
	bau.add_child(inter)
	add_child(bau)


func _abrir_bau(bau_node: Node) -> void:
	if EventBus:
		EventBus.emit_toast("✨ Recompensa Coletada: Licença Hunter, Amuleto de Força & 5000 Jenny!", Color(0.2, 1.0, 0.4))
		
	if PlayerData:
		PlayerData.adicionar_item(&"licenca_hunter", 1)
		PlayerData.adicionar_item(&"amuleto_forca", 1)
		PlayerData.adicionar_item(&"pocao_vida", 5)
		if Economy != null and Economy.has_method("adicionar_gold"):
			Economy.adicionar_gold(5000)
		PlayerData.aplicar_nivel_nen(2)
		
	bau_node.queue_free()


func _criar_portal_saida(pos: Vector2) -> void:
	var portal = load("res://world/components/MapTransitionArea.gd").new()
	portal.name = "PortalSaidaDungeon"
	portal.position = pos
	portal.target_scene_path = "res://world/maps/floresta_vestigios.tscn"
	portal.target_spawn_id = &"from_dungeon"
	portal.portal_name = "Retornar à Floresta dos Vestígios"
	portal.requires_e_key = true
	
	var col = CollisionShape2D.new()
	var box = RectangleShape2D.new()
	box.size = Vector2(48, 32)
	col.shape = box
	portal.add_child(col)
	add_child(portal)
