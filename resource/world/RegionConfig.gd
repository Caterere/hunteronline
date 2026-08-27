class_name RegionConfig
extends Resource

# ============================================================
# HUNTER ONLINE - REGION CONFIG (CONFIGURAÇÃO DATA-DRIVEN DE REGIÃO)
# ============================================================
#
# Define todos os parâmetros estruturais, de level design e
# procedurais de uma região de 512x512 tiles:
# - Dimensões e Seed determinística
# - Zonas e Biomas
# - Posicionamento Macro de POIs, Vila, Ravina e Dungeon
# - Configuração de Spawn e Densidades
#
# ============================================================

const POIDataScript = preload("res://resource/world/POIData.gd")
const ZoneDataScript = preload("res://resource/world/ZoneData.gd")

@export_category("Informações Básicas")
@export var region_id: StringName = &"vale_padokia"
@export var region_name: String = "Vale de Padokia"
@export var region_subtitle: String = "Região Inicial dos Caçadores — Tier 1"
@export var recommended_tier: int = 1
@export var default_bgm: String = "world_adventure"

@export_category("Dimensões & Seed")
@export var width_tiles: int = 512
@export var height_tiles: int = 512
@export var tile_size: int = 16
@export var generation_seed: int = 184729

@export_category("Pontos Estruturais Macro (Coordenadas em Tiles)")
@export var spawn_tile: Vector2i = Vector2i(75, 255) # Praça da Vila
@export var town_rect: Rect2i = Rect2i(20, 200, 110, 110) # 110x110 tiles
@export var danger_rect: Rect2i = Rect2i(340, 340, 140, 140) # Ravina da Névoa
@export var dungeon_rect: Rect2i = Rect2i(380, 40, 110, 110) # Ruínas de Zaban
@export var north_ridge_rect: Rect2i = Rect2i(180, 30, 120, 100) # Colinas / Caverna
@export var river_x: int = 180 # Eixo do Grande Rio que corta a região

@export_category("POIs & Sub-Zonas")
@export var pois: Array = []
@export var sub_zones: Array = []


static func create_default_padokia() -> Resource:
	var script_res = load("res://resource/world/RegionConfig.gd") as GDScript
	var cfg = script_res.new()
	cfg.region_id = &"vale_padokia"
	cfg.region_name = "Vale de Padokia"
	cfg.region_subtitle = "Região Inicial dos Caçadores — Tier 1"
	cfg.width_tiles = 512
	cfg.height_tiles = 512
	cfg.tile_size = 16
	cfg.generation_seed = 184729
	cfg.spawn_tile = Vector2i(75, 255)
	cfg.town_rect = Rect2i(20, 200, 110, 110)
	cfg.danger_rect = Rect2i(340, 340, 140, 140)
	cfg.dungeon_rect = Rect2i(380, 40, 110, 110)
	cfg.north_ridge_rect = Rect2i(180, 30, 120, 100)
	cfg.river_x = 180

	# 1. POIs Principais (14 POIs)
	cfg.pois.clear()
	cfg.pois.append(_criar_poi(&"praca_vila", "Praça Central de Padokia", POIData.POIType.TOWN, false, NenSystem.Tecnica.TEN, "Coração seguro da vila com a Fonte da Prosperidade e comerciantes.", Vector2(75 * 16, 255 * 16)))
	cfg.pois.append(_criar_poi(&"casa_player", "Residência do Caçador", POIData.POIType.TOWN, false, NenSystem.Tecnica.TEN, "Sua casa com cama de descanso, baú e boneco de treino.", Vector2(45 * 16, 225 * 16)))
	cfg.pois.append(_criar_poi(&"dojo_wing", "Dojo de Treinamento de Nen", POIData.POIType.TRAINER_SHRINE, false, NenSystem.Tecnica.TEN, "Local de meditação e treino com o Mestre Wing.", Vector2(105 * 16, 225 * 16)))
	cfg.pois.append(_criar_poi(&"emporio_loja", "Empório de Padokia", POIData.POIType.TOWN, false, NenSystem.Tecnica.TEN, "Comércio de poções, equipamentos e provisões de caça.", Vector2(45 * 16, 285 * 16)))
	cfg.pois.append(_criar_poi(&"ponte_rio", "Grande Ponte de Pedra do Rio", POIData.POIType.OUTPOST, false, NenSystem.Tecnica.TEN, "Ponte ancestral que liga a zona urbana às terras selvagens.", Vector2(180 * 16, 255 * 16)))
	cfg.pois.append(_criar_poi(&"torre_vigia", "Torre de Vigia do Reino Antigo", POIData.POIType.OUTPOST, false, NenSystem.Tecnica.TEN, "Posto avançado de observação das planícies do norte.", Vector2(120 * 16, 80 * 16)))
	cfg.pois.append(_criar_poi(&"arvore_milenar", "Árvore Milenar dos Espíritos", POIData.POIType.TRAINER_SHRINE, false, NenSystem.Tecnica.TEN, "Árvore colossal no centro da floresta emanando energia vital.", Vector2(280 * 16, 240 * 16)))
	cfg.pois.append(_criar_poi(&"acampamento_abandonado", "Acampamento dos Caçadores Perdidos", POIData.POIType.OUTPOST, false, NenSystem.Tecnica.TEN, "Vestígios de uma expedição passada com suprimentos intactos.", Vector2(260 * 16, 360 * 16)))
	cfg.pois.append(_criar_poi(&"caverna_ermitao", "Caverna Oculta do Ermitão", POIData.POIType.SECRET_CAVE, true, NenSystem.Tecnica.KO, "Entrada selada por uma rocha maciça quebrável com KO.", Vector2(230 * 16, 70 * 16)))
	cfg.pois.append(_criar_poi(&"ravina_miasma", "Desfiladeiro da Névoa Tóxica", POIData.POIType.NEN_PUZZLE, false, NenSystem.Tecnica.TEN, "Zona de perigo extremo com miasma corrosivo ativo.", Vector2(400 * 16, 420 * 16)))
	cfg.pois.append(_criar_poi(&"ninho_predadores", "Ninho das Feras das Sombras", POIData.POIType.BOSS_ARENA, false, NenSystem.Tecnica.ZETSU, "Corredor de sentinelas predadoras contornável com ZETSU.", Vector2(360 * 16, 460 * 16)))
	cfg.pois.append(_criar_poi(&"portal_dungeon", "Pórtico das Ruínas de Zaban", POIData.POIType.DUNGEON_ENTRANCE, false, NenSystem.Tecnica.TEN, "Entrada monumental da dungeon nas ruínas ancestrais.", Vector2(430 * 16, 90 * 16)))
	cfg.pois.append(_criar_poi(&"altar_sagrado", "Altar da Chama de Nen", POIData.POIType.NEN_PUZZLE, true, NenSystem.Tecnica.REN, "Totem ancestral reativo a emissões de REN no topo das ruínas.", Vector2(470 * 16, 60 * 16)))
	cfg.pois.append(_criar_poi(&"portao_atalho", "Portão de Ferro das Ruínas", POIData.POIType.SHORTCUT, true, NenSystem.Tecnica.TEN, "Mecanismo interno que abre atalho direto de volta à estrada.", Vector2(400 * 16, 120 * 16)))

	# 2. Sub-Zonas de Densidade (6 Zonas)
	cfg.sub_zones.clear()
	cfg.sub_zones.append(_criar_zona(&"vila_padokia", "Vila de Padokia (Zona Segura)", ZoneData.DensityLevel.ALTA, 1, 0.0, 0.0))
	cfg.sub_zones.append(_criar_zona(&"estrada_real", "Estrada Real de Padokia", ZoneData.DensityLevel.BAIXA, 1, 0.5, 0.1))
	cfg.sub_zones.append(_criar_zona(&"planicies_rio", "Planícies do Grande Rio", ZoneData.DensityLevel.BAIXA, 1, 0.8, 0.2))
	cfg.sub_zones.append(_criar_zona(&"floresta_vestigios", "Floresta dos Vestígios", ZoneData.DensityLevel.MEDIA, 1, 1.0, 0.35))
	cfg.sub_zones.append(_criar_zona(&"ravina_perigo", "Ravina da Névoa Corrosiva (Zona de Perigo)", ZoneData.DensityLevel.EXTREMA, 2, 2.5, 0.6))
	cfg.sub_zones.append(_criar_zona(&"ruinas_dungeon", "Ruínas do Santuário de Zaban (Dungeon)", ZoneData.DensityLevel.EXTREMA, 2, 2.0, 0.5))

	return cfg


static func _criar_poi(id: StringName, nome: String, tipo: POIData.POIType, secreto: bool, tecnica: NenSystem.Tecnica, desc: String, pos: Vector2) -> POIData:
	var p = POIData.new()
	p.poi_id = id
	p.poi_name = nome
	p.type = tipo
	p.is_secret = secreto
	p.requires_nen = tecnica
	p.description = desc
	p.world_position = pos
	return p


static func _criar_zona(id: StringName, nome: String, densidade: ZoneData.DensityLevel, tier: int, danger_mult: float, enc_chance: float) -> ZoneData:
	var z = ZoneData.new()
	z.zone_id = id
	z.zone_name = nome
	z.density = densidade
	z.recommended_tier = tier
	z.danger_multiplier = danger_mult
	z.procedural_encounter_chance = enc_chance
	return z
