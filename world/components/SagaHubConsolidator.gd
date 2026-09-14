class_name SagaHubConsolidator
extends RefCounted

# ============================================================
# HUNTER ONLINE — SAGA HUB CONSOLIDATOR
# Densifica hubs: placas, ambient, bosses canônicos ausentes.
# Reusa Enemy.tscn + EnemySystem (sem combate paralelo).
# ============================================================

const ENEMY_SCENE := "res://scripts/systems/EnemySystem/Enemy.tscn"


static func densify_hub(mapa: Node2D, config: Dictionary) -> void:
	if mapa == null:
		return
	_spawn_placards(mapa, config.get("placards", []))
	_spawn_ambient_enemies(mapa, config.get("ambient", []))
	_ensure_bosses(mapa, config.get("bosses", []))
	if bool(config.get("sync_quests", true)) and QuestSystem != null and QuestSystem.has_method("sincronizar_inimigos_do_mapa"):
		QuestSystem.sincronizar_inimigos_do_mapa(mapa)


static func densify_zone(mapa: Node2D, zone_title: String, ambient: Array, bosses: Array = []) -> void:
	densify_hub(mapa, {
		"placards": [{"name": "PlacaZona", "pos": Vector2(80, -80), "text": "📍 %s" % zone_title}],
		"ambient": ambient,
		"bosses": bosses,
		"sync_quests": true
	})


static func _spawn_placards(mapa: Node2D, placards: Array) -> void:
	for p in placards:
		if typeof(p) != TYPE_DICTIONARY:
			continue
		var n := str(p.get("name", ""))
		if n.is_empty() or mapa.get_node_or_null(n) != null:
			continue
		var marker := Node2D.new()
		marker.name = n
		marker.position = p.get("pos", Vector2.ZERO)
		var lbl := Label.new()
		lbl.text = str(p.get("text", ""))
		lbl.position = Vector2(-90, -10)
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.add_theme_font_size_override("font_size", 5)
		lbl.add_theme_color_override("font_color", Color(0.95, 0.88, 0.45, 0.95))
		lbl.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.85))
		marker.add_child(lbl)
		mapa.add_child(marker)


static func _spawn_ambient_enemies(mapa: Node2D, ambient: Array) -> void:
	var scn = load(ENEMY_SCENE)
	if scn == null:
		return
	for f in ambient:
		if typeof(f) != TYPE_DICTIONARY:
			continue
		var n := str(f.get("name", ""))
		if n.is_empty() or mapa.get_node_or_null(n) != null:
			continue
		var mob = scn.instantiate()
		mob.name = n
		mob.position = f.get("pos", Vector2.ZERO)
		mob.add_to_group("enemy")
		mob.add_to_group("enemies")
		var es = mob.get_node_or_null("EnemySystem")
		if es != null:
			if "is_mission_enemy" in es:
				es.is_mission_enemy = false
			if "enemy_id" in es:
				es.enemy_id = StringName(str(f.get("id", "inimigo_ambient")))
			if "enemy_name" in es:
				es.enemy_name = str(f.get("label", "Inimigo Ambient"))
		mapa.add_child(mob)


static func _ensure_bosses(mapa: Node2D, bosses: Array) -> void:
	var scn = load(ENEMY_SCENE)
	if scn == null:
		return
	for b in bosses:
		if typeof(b) != TYPE_DICTIONARY:
			continue
		var n := str(b.get("name", ""))
		if n.is_empty():
			continue
		var node = mapa.get_node_or_null(n)
		if node == null:
			for a in b.get("aliases", []):
				node = mapa.get_node_or_null(str(a))
				if node != null:
					break
		if node == null:
			node = scn.instantiate()
			node.name = n
			node.position = b.get("pos", Vector2(2000, 0))
			node.add_to_group("enemy")
			node.add_to_group("enemies")
			mapa.add_child(node)
		var es = node.get_node_or_null("EnemySystem")
		if es == null:
			continue
		if "is_mission_enemy" in es:
			es.is_mission_enemy = true
		if "is_boss" in es:
			es.is_boss = true
		if "quest_arc" in es:
			es.quest_arc = int(b.get("arc", 1))
		if "quest_etapa" in es:
			es.quest_etapa = int(b.get("etapa", 1))
		if "enemy_id" in es:
			es.enemy_id = StringName(str(b.get("id", n.to_lower())))
		if "enemy_name" in es:
			es.enemy_name = str(b.get("label", n))
		if DataManager != null and DataManager.has_method("get_enemy"):
			var ed = DataManager.get_enemy(es.enemy_id)
			if ed != null and "enemy_data" in es:
				es.enemy_data = ed
		if QuestSystem != null and es.has_signal("died"):
			if not es.died.is_connected(QuestSystem.register_enemy_kill):
				es.died.connect(QuestSystem.register_enemy_kill)
			if QuestSystem.has_method("registrar_spawn_posicao_missao"):
				var pos: Vector2 = node.position
				if "global_position" in node:
					pos = node.global_position
				QuestSystem.registrar_spawn_posicao_missao(
					es.enemy_id, pos, int(b.get("arc", 1)), int(b.get("etapa", 1)), -1, null, es.enemy_name
				)


static func config_for_saga(saga_id: int) -> Dictionary:
	match saga_id:
		1:
			return {
				"placards": [
					{"name": "PlacaTunel", "pos": Vector2(200, -70), "text": "📍 Túnel Subterrâneo de Zaban"},
					{"name": "PlacaPantano", "pos": Vector2(1800, -70), "text": "📍 Pântano Numere"},
					{"name": "PlacaGourmet", "pos": Vector2(4000, -70), "text": "📍 Floresta Gourmet (Menchi)"},
					{"name": "PlacaTorre", "pos": Vector2(5200, -70), "text": "📍 Torre dos Truques / Ilha Zevil"},
				],
				"ambient": [
					{"name": "SabotadorAmbient_A", "pos": Vector2(500, 40), "id": "candidato_sabotador", "label": "Candidato Sabotador"},
					{"name": "MacacoAmbient_A", "pos": Vector2(2000, 30), "id": "macaco_pantano", "label": "Macaco do Pântano"},
					{"name": "JavaliAmbient_A", "pos": Vector2(4200, 40), "id": "javali_gourmet", "label": "Javali Gourmet"},
				],
				"bosses": [
					{"name": "HisokaExameInimigo", "pos": Vector2(5600, -40), "id": "hisoka", "label": "Hisoka Morow (Exame)", "arc": 1, "etapa": 22},
					{"name": "SedokanInimigo", "pos": Vector2(4800, 20), "id": "sedokan", "label": "Sedokan", "arc": 1, "etapa": 16},
				]
			}
		2:
			return {
				"placards": [
					{"name": "PlacaPortaoTeste", "pos": Vector2(200, -80), "text": "📍 Portão da Verificação"},
					{"name": "PlacaAlameda", "pos": Vector2(1200, -80), "text": "📍 Alameda dos Mordomos"},
					{"name": "PlacaMansao", "pos": Vector2(2400, -80), "text": "📍 Mansão Zoldyck"},
				],
				"ambient": [
					{"name": "MordomoAmbient_A", "pos": Vector2(800, 30), "id": "mordomo_zoldyck", "label": "Mordomo Zoldyck"},
					{"name": "MordomoAmbient_B", "pos": Vector2(1600, -20), "id": "mordomo_zoldyck", "label": "Mordomo de Elite"},
				],
				"bosses": [
					{"name": "CaoDeGuardaMike", "pos": Vector2(600, 40), "id": "mike_beast", "label": "Mike (Cão de Guarda)", "arc": 2, "etapa": 4},
					{"name": "CaoDeGuardaMike2", "pos": Vector2(900, 40), "id": "mike_beast", "label": "Mike — Segunda Matilha", "arc": 2, "etapa": 5},
					{"name": "GotohInimigo", "pos": Vector2(2500, -30), "id": "gotoh", "label": "Gotoh (Chefe dos Mordomos)", "arc": 2, "etapa": 14},
				]
			}
		3:
			return {
				"placards": [
					{"name": "PlacaRecepcao", "pos": Vector2(120, -80), "text": "📍 Recepção da Arena"},
					{"name": "PlacaDojo", "pos": Vector2(1100, -90), "text": "📍 Dojo Shingen-ryu (Wing)"},
					{"name": "PlacaAndar200", "pos": Vector2(2800, -90), "text": "📍 200º Andar — Floor Masters"},
				],
				"ambient": [
					{"name": "LutadorAmbient_A", "pos": Vector2(500, 30), "id": "lutador_arena", "label": "Lutador da Arena"},
					{"name": "LutadorAmbient_B", "pos": Vector2(1800, 20), "id": "lutador_arena", "label": "Aspirante Floor Master"},
				],
				"bosses": [
					{"name": "LutadorAndar200Gido", "pos": Vector2(1500, 0), "id": "gido", "label": "Gido", "arc": 3, "etapa": 18},
					{"name": "LutadorAndar200Kastro", "pos": Vector2(2200, 0), "id": "kastro", "label": "Kastro", "arc": 3, "etapa": 21},
					{"name": "MestreAndar200", "pos": Vector2(3000, -40), "id": "hisoka", "label": "Hisoka (200º Andar)", "arc": 3, "etapa": 25},
				]
			}
		4:
			return {
				"placards": [
					{"name": "PlacaLeilao", "pos": Vector2(350, -70), "text": "📍 Distrito do Leilão Underground"},
					{"name": "PlacaRuas", "pos": Vector2(1600, -90), "text": "📍 Avenida Central — Yorknew"},
					{"name": "PlacaCemiterio", "pos": Vector2(2700, -110), "text": "📍 Edifício Cemitério"},
					{"name": "PlacaTrupe", "pos": Vector2(3700, -90), "text": "📍 Zona da Trupe Fantasma"},
				],
				"ambient": [
					{"name": "MafiosoAmbient_A", "pos": Vector2(600, 40), "id": "mafioso_yorknew", "label": "Soldado da Máfia"},
					{"name": "MafiosoAmbient_B", "pos": Vector2(1500, -50), "id": "mafioso_yorknew", "label": "Capanga das Ruas"},
					{"name": "MafiosoAmbient_C", "pos": Vector2(3100, -40), "id": "mafioso_yorknew", "label": "Guarda do Cemitério"},
				],
				"bosses": [
					{"name": "UvoginInimigo", "pos": Vector2(2000, 0), "id": "uvogin", "label": "Uvogin", "arc": 4, "etapa": 10},
					{"name": "NobunagaInimigo", "pos": Vector2(2800, 0), "id": "nobunaga", "label": "Nobunaga Hazama", "arc": 4, "etapa": 20},
					{"name": "PakunodaInimiga", "pos": Vector2(3200, -20), "id": "pakunoda", "label": "Pakunoda", "arc": 4, "etapa": 24},
					{"name": "ChrolloBossInimigo", "pos": Vector2(3800, -40), "id": "chrollo", "label": "Chrollo Lucilfer", "arc": 4, "etapa": 32},
				]
			}
		5:
			return {
				"placards": [
					{"name": "PlacaAntokiba", "pos": Vector2(200, -80), "text": "📍 Antokiba — Cidade Inicial"},
					{"name": "PlacaMontanhas", "pos": Vector2(1400, -90), "text": "📍 Desfiladeiro — Treino Biscuit"},
					{"name": "PlacaSoufrabi", "pos": Vector2(2600, -90), "text": "📍 Soufrabi — Queimada de Razor"},
					{"name": "PlacaCastelo", "pos": Vector2(3700, -90), "text": "📍 Castelo de Premiação"},
				],
				"ambient": [
					{"name": "MonstroAmbient_A", "pos": Vector2(700, 30), "id": "monstro_greed", "label": "Monstro de Greed Island"},
					{"name": "GolemPedra1", "pos": Vector2(1600, 20), "id": "golem_pedra", "label": "Golem de Pedra"},
					{"name": "DemonioRazor1", "pos": Vector2(2400, 20), "id": "demonio_razor", "label": "Demônio de Nen"},
				],
				"bosses": [
					{"name": "RazorInimigo", "pos": Vector2(2800, -40), "id": "razor", "label": "Game Master Razor", "arc": 5, "etapa": 25, "aliases": ["RazorBossInimigo"]},
					{"name": "GenthruInimigo", "pos": Vector2(3400, -20), "id": "genthru", "label": "Genthru Bomber", "arc": 5, "etapa": 31},
				]
			}
		6:
			return {
				"placards": [
					{"name": "PlacaFronteira", "pos": Vector2(200, -80), "text": "📍 Fronteira Ecológica NGL"},
					{"name": "PlacaFabrica", "pos": Vector2(1400, -90), "text": "📍 Fábrica D2 / Ruínas de Gyro"},
					{"name": "PlacaPalacio", "pos": Vector2(2600, -90), "text": "📍 Palácio Real de Peijin"},
					{"name": "PlacaTumba", "pos": Vector2(3700, -90), "text": "📍 Tumba Nuclear — Netero"},
				],
				"ambient": [
					{"name": "FormigaSoldadoAmbient_A", "pos": Vector2(500, 30), "id": "formiga_soldado", "label": "Formiga Soldado"},
					{"name": "FormigaSoldadoAmbient_B", "pos": Vector2(1000, 20), "id": "formiga_oficial", "label": "Formiga Oficial"},
					{"name": "EsquadraoQuimeraAmbient", "pos": Vector2(1800, 30), "id": "guarda_peijin", "label": "Guarda de Peijin"},
				],
				"bosses": [
					{"name": "YoupiInimigo", "pos": Vector2(2400, -20), "id": "youpi", "label": "Menthuthuyoupi", "arc": 6, "etapa": 32},
					{"name": "ShaiapoufInimigo", "pos": Vector2(2700, -30), "id": "shaiapouf", "label": "Shaiapouf", "arc": 6, "etapa": 33},
					{"name": "NeferpitouInimigo", "pos": Vector2(3000, -40), "id": "neferpitou", "label": "Neferpitou", "arc": 6, "etapa": 43},
					{"name": "MeruemRei", "pos": Vector2(3600, -50), "id": "meruem", "label": "Rei Meruem", "arc": 6, "etapa": 46},
				]
			}
		7:
			return {
				"placards": [
					{"name": "PlacaAuditorio", "pos": Vector2(200, -80), "text": "📍 Auditório dos Zodíacos"},
					{"name": "PlacaHospital", "pos": Vector2(1400, -90), "text": "📍 Hospital Hunter — Gon"},
					{"name": "PlacaRodovia", "pos": Vector2(2600, -90), "text": "📍 Rodovia — Emboscada Illumi"},
					{"name": "PlacaPlenario", "pos": Vector2(3700, -90), "text": "📍 Plenário da 13ª Eleição"},
				],
				"ambient": [
					{"name": "AgenteIlicitoAmbient_A", "pos": Vector2(800, 30), "id": "mordomo_perseguidor", "label": "Mordomo Perseguidor"},
					{"name": "NeedleManAmbient_A", "pos": Vector2(2000, 20), "id": "humano_agulha", "label": "Homem-Agulha"},
					{"name": "NeedleManAmbient_B", "pos": Vector2(2300, 40), "id": "humano_agulha", "label": "Homem-Agulha Elite"},
				],
				"bosses": [
					{"name": "IllumiInimigo", "pos": Vector2(2800, -30), "id": "illumi", "label": "Illumi Zoldyck", "arc": 7, "etapa": 12},
					{"name": "HisokaEmboscadaInimigo", "pos": Vector2(3200, -20), "id": "hisoka", "label": "Hisoka (Emboscada)", "arc": 7, "etapa": 16},
				]
			}
		8:
			return {
				"placards": [
					{"name": "PlacaAcampamento", "pos": Vector2(200, -80), "text": "📍 Acampamento Beyond"},
					{"name": "PlacaBrion", "pos": Vector2(1400, -90), "text": "📍 Ruínas / Labirinto de Brion"},
					{"name": "PlacaRaizes", "pos": Vector2(2600, -90), "text": "📍 Raízes da Árvore do Mundo"},
					{"name": "PlacaTopo", "pos": Vector2(3700, -90), "text": "📍 Topo — Ninho com Ging"},
				],
				"ambient": [
					{"name": "CriaturaPrimitivaAmbient_A", "pos": Vector2(700, 30), "id": "criatura_primitiva", "label": "Criatura Primitiva"},
					{"name": "GuardaBrionAmbient_A", "pos": Vector2(1600, 20), "id": "guarda_brion", "label": "Guardião de Brion"},
				],
				"bosses": [
					{"name": "CriaturaPrimitiva2", "pos": Vector2(1800, -20), "id": "brion_boss", "label": "Calamidade Brion", "arc": 8, "etapa": 10},
					{"name": "BestaCalamidade1", "pos": Vector2(2400, -30), "id": "hellbell_boss", "label": "Hellbell", "arc": 8, "etapa": 12},
					{"name": "BestaCalamidade2", "pos": Vector2(3200, -40), "id": "ai_boss", "label": "Entidade Ai", "arc": 8, "etapa": 13},
				]
			}
		9:
			return {
				"placards": [
					{"name": "PlacaConves1", "pos": Vector2(200, -80), "text": "📍 Convés 1 — Rainha Oito / Woble"},
					{"name": "PlacaConves3", "pos": Vector2(1400, -90), "text": "📍 Convés 3 — Máfia Kakin"},
					{"name": "PlacaAposentos", "pos": Vector2(2600, -90), "text": "📍 Aposentos de Tserriednich"},
					{"name": "PlacaPorao", "pos": Vector2(3700, -90), "text": "📍 Conveses Profundos — Trupe vs Hisoka"},
				],
				"ambient": [
					{"name": "GuardaRealAmbient_A", "pos": Vector2(600, 30), "id": "besta_parasita", "label": "Besta Parasita"},
					{"name": "GuardaRealAmbient_B", "pos": Vector2(1600, 20), "id": "assassino_heilly", "label": "Assassino Heil-Ly"},
					{"name": "AssassinoMafiaAmbient", "pos": Vector2(2200, 30), "id": "assassino_mafia", "label": "Capanga da Máfia"},
				],
				"bosses": [
					{"name": "CapangaTserriednich", "pos": Vector2(2800, -20), "id": "besta_tserriednich", "label": "Besta de Tserriednich", "arc": 9, "etapa": 18},
					{"name": "BestaNenGuardiã", "pos": Vector2(3200, -40), "id": "tserriednich_boss", "label": "Príncipe Tserriednich", "arc": 9, "etapa": 19},
					{"name": "CamillaCatInimiga", "pos": Vector2(3500, -30), "id": "camilla_cat", "label": "Camilla — Gato da Ressurreição", "arc": 9, "etapa": 22},
				]
			}
		_:
			return {}
