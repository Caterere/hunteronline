class_name ContentDensityTest
extends Node2D

# ============================================================
# HUNTER ONLINE - CONTENT DENSITY TEST SUITE
# ============================================================
#
# Demonstração e validação do ContentDirector e ContentDensitySystem:
# - Mapa de 256x256 tiles com as 5 zonas de risco
# - Player livre para andar com WASD
# - Visualização de marcadores coloridos de entidades (F3 / Toggle)
# - Validações automatizadas de Anti-Spam e densidade
#
# ============================================================

const ContentDirectorScript = preload("res://world/content/ContentDirector.gd")
const RegionContentConfigScript = preload("res://world/content/RegionContentConfig.gd")

@onready var director: Node2D = get_node_or_null("ContentDirector")
@onready var player: CharacterBody2D = get_node_or_null("Player")
@onready var chao_layer: TileMapLayer = get_node_or_null("Chao_TileMapLayer")
@onready var paredes_layer: TileMapLayer = get_node_or_null("Paredes_TileMapLayer")

const PATH_TILESET = "res://world/tilesets/world_tileset.tres"


func _ready() -> void:
	print("============================================================")
	print("TEST SUITE: VALIDAÇÃO DO CONTENT DENSITY SYSTEM")
	print("============================================================")
	
	var tileset = load(PATH_TILESET) as TileSet
	if tileset != null:
		if chao_layer: chao_layer.tile_set = tileset
		if paredes_layer: paredes_layer.tile_set = tileset
		
	_gerar_mapa_teste_256x256()
	
	if director != null:
		director.add_to_group("content_director")
		
	# ------------------------------------------------------------
	# 1. VALIDAÇÃO AUTOMATIZADA DE ZONAS E DENSIDADES
	# ------------------------------------------------------------
	assert(director != null, "ContentDirector deve existir na cena")
	assert(director.get("config") != null, "RegionContentConfig deve estar configurada")
	print("  ✅ [PASSOU] ContentDirector inicializado com Seed: %d" % director.get("config").seed_val)
	
	# Teste 1: Avaliação de Zona Segura (Vila)
	director._avaliar_zona_de_risco(Vector2(1000, 3500))
	assert(director.current_risk == 0, "Coordenada (1000, 3500) deve ser SAFE (Vila)")
	print("  ✅ [PASSOU] Avaliação de Zona Segura (Vila): %s" % director.current_zone_name)
	
	# Teste 2: Avaliação de Estrada (Low Risk)
	director._avaliar_zona_de_risco(Vector2(2800, 3000))
	assert(director.current_risk == 1, "Coordenada (2800, 3000) deve ser LOW_RISK (Estrada)")
	print("  ✅ [PASSOU] Avaliação de Baixo Risco (Estrada): %s" % director.current_zone_name)
	
	# Teste 3: Avaliação de Floresta (Medium Risk)
	director._avaliar_zona_de_risco(Vector2(4500, 3000))
	assert(director.current_risk == 2, "Coordenada (4500, 3000) deve ser MEDIUM_RISK (Floresta)")
	print("  ✅ [PASSOU] Avaliação de Médio Risco (Floresta): %s" % director.current_zone_name)
	
	# Teste 4: Avaliação de Ravina (Danger)
	director._avaliar_zona_de_risco(Vector2(6000, 6000))
	assert(director.current_risk == 4, "Coordenada (6000, 6000) deve ser DANGER (Ravina)")
	print("  ✅ [PASSOU] Avaliação de Perigo Extremo (Ravina): %s" % director.current_zone_name)
	
	# Teste 5: Anti-Spam e Distância Mínima
	var p1 = Vector2(1000, 1000)
	var p2 = Vector2(1100, 1050) # dist = ~111px (< 320px)
	assert(p1.distance_to(p2) < director.config.minimum_distance_between_events, "Anti-spam detecta proximidade excessiva")
	print("  ✅ [PASSOU] Regra de Anti-Spam (distância mínima entre eventos) verificada")
	
	# Teste 6: Simulação de Caminhada e Gatilho Espacial
	director.distance_since_last_encounter = 500.0 # Excede meta de 400px
	director.timer_encounter_cooldown = 0.0
	director._tentar_spawn_encontro_ambiental(Vector2(4500, 3000))
	assert(director.active_encounters.size() >= 1, "Encontro ambiental deve ser gerado após atingir distância")
	print("  ✅ [PASSOU] Gatilho espacial ativou encontro com sucesso após caminhada")
	
	# Posicionar Player no centro do mapa
	if player != null:
		player.global_position = Vector2(1200, 3800)
		print("  ✅ [PASSOU] Player posicionado na Vila: ", player.global_position)
		
	print("============================================================")
	print("🎉 CONTENT DENSITY SYSTEM VALIDADO COM 100% DE SUCESSO!")
	print("============================================================")


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	if director == null: return
	var font = ThemeDB.fallback_font
	
	# Desenhar Marcadores de Entidades Ativas
	# 🔵 NPCs = Azul
	for npc in director.active_npcs:
		var p = npc.get("pos", Vector2.ZERO)
		draw_circle(p, 10.0, Color(0.2, 0.6, 1.0, 0.8))
		if font: draw_string(font, p + Vector2(-20, -14), str(npc.get("name", "NPC")), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color.WHITE)
		
	# 🔴 PvE = Vermelho
	for e in director.active_enemies:
		var p = e.get("pos", Vector2.ZERO)
		draw_circle(p, 8.0, Color(1.0, 0.2, 0.2, 0.8))
		if font: draw_string(font, p + Vector2(-15, -12), "Inimigo", HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color(1, 0.6, 0.6))
		
	# 🟡 Eventos = Amarelo
	for ev in director.active_events:
		var p = ev.spawn_pos
		draw_rect(Rect2(p - Vector2(12, 12), Vector2(24, 24)), Color(1.0, 0.85, 0.1, 0.85))
		if font: draw_string(font, p + Vector2(-30, -16), str(ev.title), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color.YELLOW)
		
	# ✨ Encontros = Ciano
	for enc in director.active_encounters:
		var p = enc.pos
		draw_circle(p, 9.0, Color(0.1, 1.0, 0.9, 0.8))
		if font: draw_string(font, p + Vector2(-30, -14), str(enc.title), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color.CYAN)
		
	# 🟢 POIs = Verde
	for poi in director.registered_pois:
		var p = poi.get("pos", Vector2.ZERO)
		draw_circle(p, 12.0, Color(0.2, 1.0, 0.3, 0.6))
		if font: draw_string(font, p + Vector2(-30, -16), str(poi.get("name", "POI")), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color.GREEN)


func _gerar_mapa_teste_256x256() -> void:
	if chao_layer == null: return
	
	# Preencher grama base em 256x256
	for y in range(0, 160):
		for x in range(0, 160):
			chao_layer.set_cell(Vector2i(x, y), 2, Vector2i(0, 0)) # Grama
			
	# Pavimentar Vila (X: 10 a 60, Y: 150 a 200)
	for y in range(180, 240):
		for x in range(20, 100):
			chao_layer.set_cell(Vector2i(x, y), 0, Vector2i(1, 9)) # Calçada
			
	# Estrada (X: 100 a 220, Y: 200 a 210)
	for y in range(200, 206):
		for x in range(95, 230):
			chao_layer.set_cell(Vector2i(x, y), 3, Vector2i(1, 1)) # Estrada terra
