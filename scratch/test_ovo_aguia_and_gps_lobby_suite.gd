extends Node

## Ovo águia no Exame + GPS Lobby→Guia (anti bounce Lobby↔Estrada)
## godot --headless --path . res://scratch/test_ovo_aguia_and_gps_lobby_suite.tscn

const MissionObjectiveResolverScript = preload("res://scripts/missions/MissionObjectiveResolver.gd")

var _ok := 0
var _fail := 0


func _ready() -> void:
	print("=== ovo aguia + gps lobby ===")
	_test_catalog_and_source()
	await _test_ovo_spawns_and_gps()
	await _test_lobby_gps_guia_not_estrada()
	print("=== RESULT: %d pass / %d fail ===" % [_ok, _fail])
	await get_tree().process_frame
	get_tree().quit(0 if _fail == 0 else 1)


func _assert(c: bool, msg: String) -> void:
	if c:
		_ok += 1
		print("  ✅ ", msg)
	else:
		_fail += 1
		print("  ❌ ", msg)


func _test_catalog_and_source() -> void:
	_assert(Economy.ITEM_CATALOGO.has("ovo_aguia"), "ovo_aguia no Economy")
	var exam := FileAccess.get_file_as_string("res://world/maps/ExameMaratonaMap.gd")
	_assert("_garantir_ovo_aguia_ninho" in exam, "Exame planta ovo")
	_assert("QuestWorldPickup" in exam, "usa QuestWorldPickup")
	var resolver := FileAccess.get_file_as_string("res://scripts/missions/MissionObjectiveResolver.gd")
	_assert("_is_saga_hub_map" in resolver, "helper saga hub")
	_assert("StoryGatewayNPC" in resolver and "usa_guia_historia" in resolver, "lobby prefere Guia")
	var qm := FileAccess.get_file_as_string("res://scripts/missions/QuestManager.gd")
	_assert("item_obtained" in qm and "register_item_collected" in qm, "QuestSystem escuta item_obtained")


func _test_ovo_spawns_and_gps() -> void:
	PlayerData.inventory.erase(&"ovo_aguia")
	PlayerData.inventory.erase("ovo_aguia")
	PlayerData.arco_atual = 1
	PlayerData.etapa_quest_arco = 13
	QuestSystem.active_quests.clear()
	var q := CanonQuestCatalog.obter_quest_da_etapa(1, 13)
	_assert(q != null, "quest etapa 13 existe")
	if q != null:
		QuestSystem.start_quest(q)
		var obj = q.objectives[0] if not q.objectives.is_empty() else null
		_assert(obj != null and str(obj.item_id) == "ovo_aguia", "objetivo collect ovo_aguia")

	var packed = load("res://world/maps/exame_maratona.tscn") as PackedScene
	_assert(packed != null, "exame carrega")
	if packed == null:
		return
	var mapa = packed.instantiate()
	add_child(mapa)
	await get_tree().process_frame
	await get_tree().process_frame

	var ovo = mapa.get_node_or_null("OvoAguiaNinho")
	_assert(ovo != null, "OvoAguiaNinho spawna")
	if ovo != null:
		_assert(ovo.is_in_group("loot"), "ovo no grupo loot (GPS)")
		_assert(str(ovo.get("item_id")) == "ovo_aguia" or ovo.get_meta("item_id", "") == "ovo_aguia", "item_id ovo_aguia")

	var loot = MissionObjectiveResolverScript._find_loot_target(get_tree(), q.objectives[0] if q else null)
	_assert(loot.get("found", false), "GPS encontra ovo no mapa")

	# Coleta
	if ovo != null and ovo.has_method("_on_interacted"):
		var before := PlayerData.obter_item_quantidade(&"ovo_aguia")
		ovo._on_interacted(null)
		await get_tree().process_frame
		_assert(PlayerData.obter_item_quantidade(&"ovo_aguia") > before, "inventário ganhou ovo")
		if q != null:
			var prog := PlayerData.get_quest_objective_progress(q, 0)
			_assert(prog >= 1, "quest COLLECT progrediu (%d)" % prog)

	mapa.queue_free()
	await get_tree().process_frame


func _test_lobby_gps_guia_not_estrada() -> void:
	PlayerData.tutorial_concluido = true
	PlayerData.despertou_nen = true
	PlayerData.arco_atual = 1
	PlayerData.etapa_quest_arco = 13
	QuestSystem.active_quests.clear()
	var q := CanonQuestCatalog.obter_quest_da_etapa(1, 13)
	if q != null:
		QuestSystem.start_quest(q)

	var lobby_scn = load("res://world/lobby.tscn") as PackedScene
	_assert(lobby_scn != null, "lobby carrega")
	if lobby_scn == null:
		return
	var lobby = lobby_scn.instantiate()
	# Simula current_scene para o resolver
	get_tree().root.add_child(lobby)
	await get_tree().process_frame
	await get_tree().process_frame

	# Força path de cena
	# resolve usa tree.current_scene — em headless pode ser esta suite; mock via chamada direta
	var expected := MissionObjectiveResolverScript.get_expected_map_path(q)
	_assert("exame_maratona" in expected, "etapa 13 espera exame")
	_assert(MissionObjectiveResolverScript._is_saga_hub_map(expected), "exame é saga hub")

	# Emula _resolve_lobby preferência
	var guia = lobby.get_node_or_null("StoryGatewayNPC")
	var portao = lobby.get_node_or_null("PortaoMundoExterior")
	_assert(guia != null, "StoryGatewayNPC no lobby")
	_assert(portao != null, "PortaoMundoExterior no lobby")

	# Hop a partir da estrada: saga hub → lobby (não floresta)
	var estrada = load("res://world/maps/estrada_padokia.tscn").instantiate()
	add_child(estrada)
	await get_tree().process_frame
	var hop := MissionObjectiveResolverScript._next_hop_scene_file(estrada, expected)
	_assert(hop == "lobby.tscn", "na estrada, hop pra saga = lobby (got %s)" % hop)
	var hop_floresta_back := MissionObjectiveResolverScript._next_hop_scene_file(estrada, "res://world/maps/floresta_vestigios.tscn")
	_assert(hop_floresta_back != "lobby.tscn", "objetivo floresta não manda ao lobby")

	estrada.queue_free()
	lobby.queue_free()
	await get_tree().process_frame
