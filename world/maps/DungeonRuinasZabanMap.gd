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


func _ready() -> void:
	var tileset = load(PATH_TILESET) as TileSet
	if tileset != null:
		if chao_layer: chao_layer.tile_set = tileset
		if paredes_layer: paredes_layer.tile_set = tileset
		if decor_layer: decor_layer.tile_set = tileset
		
	_gerar_mapa_dungeon()
	_instanciar_boss_e_sentinelas()
	_configurar_audio_e_hud()
	if QuestSystem != null:
		QuestSystem.sincronizar_inimigos_do_mapa(self)


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
		
	# Spawna Baú Dourado no local do chefe
	_spawna_bau_dourado(Vector2(320, 120))


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
	portal.target_scene_path = "res://world/maps/regiao_vale_padokia.tscn"
	portal.portal_name = "Retornar ao Vale de Padokia"
	portal.requires_e_key = true
	
	var col = CollisionShape2D.new()
	var box = RectangleShape2D.new()
	box.size = Vector2(48, 32)
	col.shape = box
	portal.add_child(col)
	add_child(portal)
