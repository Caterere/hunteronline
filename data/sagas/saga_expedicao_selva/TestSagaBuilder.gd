class_name TestSagaBuilder
extends RefCounted

# ============================================================
# HUNTER ONLINE — TEST SAGA BUILDER (FASE L — L37)
# ============================================================
#
# Fábrica canônica da Saga Teste "Expedição à Selva Misteriosa":
# - 1 Região Package modular (selva_misteriosa) com POIs, clima e segredos.
# - 3 NPCs com personalidades e memórias (Moro, Elena, Kane).
# - 3 Quests Principais + 1 Side Quest + 1 Segredo Oculto.
# - 1 Miniboss + 1 Boss Declarativo (Gorila Rei de Nen com 2 fases).
# - 1 Hatsu Declarativo (Impacto Selvagem).
# - 1 Live Event Temporário (Migração das Feras).
# - 1 Reputação ("Sociedade de Expedição").
# - 1 Conquista ("Pioneiro da Selva").
# - 1 Cutscene integrada.
# ============================================================

const SagaDefinitionScript = preload("res://resource/saga/SagaDefinition.gd")
const ChapterDefinitionScript = preload("res://resource/saga/ChapterDefinition.gd")
const RegionPackageScript = preload("res://resource/region/RegionPackage.gd")
const BossDefinitionScript = preload("res://resource/boss/BossDefinition.gd")
const LiveEventDefinitionScript = preload("res://resource/events/LiveEventDefinition.gd")
const BossPhaseDataScript = preload("res://resource/status/BossPhaseData.gd")


static func build_test_saga() -> Resource:
	var saga := SagaDefinitionScript.new(
		&"expedicao_selva",
		10,
		"Expedição à Selva Misteriosa",
		"Uma jornada inexplorada aos confins da Floresta Proibida em busca do lendário Gorila Rei de Nen.",
		Vector2i(25, 60)
	)
	saga.difficulty = 2
	saga.is_canonical = false
	saga.flags = [&"story", &"coop", &"live_content", &"expansion"]
	saga.regions = ["selva_misteriosa"]
	saga.characters = ["guia_moro", "botanica_elena", "veterano_kane"]
	saga.enemies = ["lobo_aura", "jaguar_sombra_nen"]
	saga.bosses = ["gorila_rei_nen"]
	saga.reputations = {"sociedade_expedicao": 500}
	saga.rewards = {
		"xp": 15000,
		"gold": 30000,
		"items": ["amuleto_colmilho_selva"]
	}
	saga.titles = ["Pioneiro da Selva Proibida"]
	saga.events = ["migracao_predadores_selva"]

	# Capítulos
	var cap1 = ChapterDefinitionScript.new(
		1,
		"Capítulo 1: O Acampamento de Base",
		"Estabeleça o acampamento de expedição na entrada da floresta densa com o Guia Moro.",
		"selva_etapa_1"
	)
	cap1.side_quest_ids = ["selva_side_resgate"]
	cap1.rewards = {"xp": 3000, "gold": 5000}
	cap1.gating_requirements = [{"type": "level", "value": 20}]
	(saga as Variant).add_chapter(cap1)

	var cap2 = ChapterDefinitionScript.new(
		2,
		"Capítulo 2: Amostras da Flora Mística",
		"Aventure-se na clareira ancestral para auxiliar Elena na coleta de ervas catalisadoras de Nen.",
		"selva_etapa_2"
	)
	cap2.rewards = {"xp": 4500, "gold": 8000}
	cap2.gating_requirements = [{"type": "quest_completed", "value": "selva_etapa_1"}]
	(saga as Variant).add_chapter(cap2)

	var cap3 = ChapterDefinitionScript.new(
		3,
		"Capítulo 3: O Covil do Gorila Rei",
		"Enfrente o poderoso Gorila Rei de Nen e traga a paz para a região de expedição.",
		"selva_etapa_3"
	)
	cap3.boss_id = "gorila_rei_nen"
	cap3.rewards = {"xp": 7500, "gold": 17000, "items": ["amuleto_colmilho_selva"]}
	cap3.gating_requirements = [{"type": "quest_completed", "value": "selva_etapa_2"}]
	cap3.consequences = [{"type": "world_flag", "flag": "gorila_rei_derrotado", "value": true}]
	(saga as Variant).add_chapter(cap3)

	return saga


static func build_test_region() -> Resource:
	var reg := RegionPackageScript.new(
		&"selva_misteriosa",
		"Selva Misteriosa de Nen",
		"res://world/maps/selva_misteriosa.tscn",
		RegionPackageScript.DangerLevel.MEDIUM
	)
	reg.description = "Florestas ancestrais banhadas por fluxos naturais de aura densa."
	reg.ambient_music = "res://osts/Hunter x Hunter (2011) OST - The Hunting Grounds - Anime Content.mp3"
	reg.ambient_weather = [0, 1, 2] # Limpo, Chuva, Neblina
	reg.recommended_level = Vector2i(25, 60)
	reg.regional_identity = {
		"lighting_tint": Color(0.8, 0.95, 0.8, 1.0),
		"ambient_sfx": "forest_birds_and_leaves",
		"unique_mechanic": "aura_density_mist",
		"architecture_style": "stone_relics"
	}
	reg.npcs = ["guia_moro", "botanica_elena", "veterano_kane"]
	reg.enemies = ["lobo_aura", "jaguar_sombra_nen"]
	reg.bosses = ["gorila_rei_nen"]
	reg.quests = ["selva_etapa_1", "selva_etapa_2", "selva_etapa_3", "selva_side_resgate"]

	reg.add_point_of_interest("acampamento_base", "Acampamento de Base", Vector2(100, 100), "camp")
	reg.add_point_of_interest("clareira_ancestral", "Clareira Ancestral de Nen", Vector2(600, 300), "ruins")
	reg.add_point_of_interest("caverna_gorila", "Caverna do Gorila Rei", Vector2(1200, 500), "boss_cave")

	reg.add_secret("bau_secreto_pedra_lua", "Relíquia da Pedra da Lua", "Oculto atrás das trepadeiras da cachoeira", Vector2(850, 150))
	reg.add_travel_route(&"lobby", RegionPackageScript.TravelType.FOOT, 0, true)

	return reg


static func build_test_boss() -> Resource:
	var boss := BossDefinitionScript.new(
		&"gorila_rei_nen",
		"Gorila Rei de Nen",
		"Monarca Selvagem da Selva Proibida",
		25000,
		320
	)
	boss.description = "Um primata gigante que desenvolveu espontaneamente técnicas avançadas de Intensificação e Ren explosivo."
	boss.base_stats["defense"] = 175
	boss.base_stats["move_speed"] = 85.0
	boss.base_stats["xp_reward"] = 6000
	boss.base_stats["gold_reward"] = 12000

	# Fases
	boss.add_phase_data(2, 0.50, "Frenesi Selvagem", "💥 ROAAARRR! (Aura Escarlate Desperta!)", BossPhaseData.MecanicaFase.FRENESI)
	boss.add_phase_data(3, 0.20, "Terremoto de Nen", "🌍 GROOOO! (O solo treme em ondas de choque!)", BossPhaseData.MecanicaFase.AOE_BURST)

	boss.hatsu_abilities = ["impacto_selvagem", "rugido_intimidante"]
	boss.arena_scene = "res://world/maps/selva_misteriosa.tscn"
	boss.intro_quote = "Um rugido ensurdecedor ecoa pela floresta enquanto galhos ancestrais se quebram!"
	boss.intro_banner_theme = {
		"title_color": Color(0.9, 0.3, 0.2, 1.0),
		"subtitle": "Monarca Ancestral da Floresta"
	}
	boss.add_loot_drop("nucleo_nen_selvagem", 1.0, 1, 1)
	boss.add_loot_drop("amuleto_colmilho_selva", 0.75, 1, 1)

	return boss


static func build_test_live_event() -> Resource:
	var ev := LiveEventDefinitionScript.new(
		&"migracao_predadores_selva",
		"Migração das Feras Predadoras",
		&"selva_misteriosa",
		4.0 # 4 horas de duração
	)
	ev.description = "Um bando de lobos de aura e predadores vorazes desceu das montanhas em direção à clareira!"
	ev.spawn_entities = [
		{"id": "lobo_aura_alfa", "type": "enemy", "count": 3, "is_miniboss": true}
	]
	ev.rewards = {
		"xp": 4000,
		"gold": 8000,
		"items": ["essencia_fera_ancestral"]
	}
	ev.coop_supported = true
	ev.is_temporary = true
	return ev


static func build_test_hatsu() -> HatsuData:
	var h := HatsuData.new()
	h.hatsu_id = "impacto_selvagem"
	h.nome = "Impacto Selvagem"
	h.categoria = HatsuData.Categoria.INTENSIFICACAO
	h.forma = HatsuData.Forma.AREA
	h.alvo = HatsuData.Alvo.INIMIGO_UNICO
	h.custo_aura_base = 35.0
	h.cooldown_base = 4.5
	h.poder_base = 280.0
	return h
