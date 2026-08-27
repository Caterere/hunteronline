extends Node2D

var total_testes: int = 0
var testes_passaram: int = 0
var testes_falharam: int = 0

func _ready() -> void:
	print("============================================================")
	print("TEST SUITE: EXPANSÃO DO MUNDO & SISTEMA DE EXPLORAÇÃO NEN")
	print("============================================================")

	_executar_todos_testes()

	print("============================================================")
	print("RESULTADO FINAL: %d/%d TESTES PASSARAM (%d FALHAS)" % [testes_passaram, total_testes, testes_falharam])
	print("============================================================")

	if testes_falharam == 0:
		print("🎉 TODOS OS SISTEMAS DE MUNDO E EXPLORAÇÃO FORAM VALIDADOS COM SUCESSO!")
	else:
		push_error("❌ ALGUNS TESTES FALHARAM!")

	get_tree().quit(0 if testes_falharam == 0 else 1)


func assert_true(condicao: bool, mensagem: String) -> void:
	total_testes += 1
	if condicao:
		testes_passaram += 1
		print("  ✅ [PASSOU] ", mensagem)
	else:
		testes_falharam += 1
		print("  ❌ [FALHOU] ", mensagem)


func _executar_todos_testes() -> void:
	_testar_data_driven_resources()
	_testar_ko_obstacle()
	_testar_ten_hazard_zone()
	_testar_ren_beacon()
	_testar_zetsu_sensor_zone()
	_testar_shortcut_door()
	_testar_world_chunk_loader()


func _testar_data_driven_resources() -> void:
	print("\n--- [TESTE 1: RECURSOS DATA-DRIVEN DO MUNDO] ---")
	
	var poi = POIData.new()
	poi.poi_id = &"vila_padokia"
	poi.poi_name = "Vila de Padokia"
	poi.type = POIData.POIType.TOWN
	assert_true(poi.poi_name == "Vila de Padokia", "POIData instanciado com sucesso")

	var zone = ZoneData.new()
	zone.zone_id = &"floresta_vestigios"
	zone.density = ZoneData.DensityLevel.MEDIA
	assert_true(zone.density == ZoneData.DensityLevel.MEDIA, "ZoneData gerencia nível de densidade MEDIA")

	var regiao = RegionData.new()
	regiao.region_id = &"vale_padokia"
	regiao.region_name = "Vale de Padokia"
	regiao.pois.append(poi)
	regiao.sub_zones.append(zone)
	assert_true(regiao.pois.size() == 1 and regiao.sub_zones.size() == 1, "RegionData conecta POIs e Sub-Zonas")


func _testar_ko_obstacle() -> void:
	print("\n--- [TESTE 2: OBSTÁCULO QUEBRÁVEL COM KO] ---")

	var player_scn = load("res://entities/Player/Player.tscn").instantiate()
	add_child(player_scn)
	var nen_sys: NenSystem = player_scn.get_node_or_null("NenSystem") as NenSystem

	PlayerData.despertou_nen = true
	PlayerData.attributes["nivel_nen"] = 5
	PlayerData.attributes["aura"] = 250.0
	PlayerData.attributes["aura_max"] = 250.0

	var ko_obs = KoObstacle.new()
	add_child(ko_obs)

	# 1. Dano sem KO não deve quebrar
	ko_obs.receber_dano(50, Vector2.ZERO, 0.0, player_scn)
	assert_true(not ko_obs.foi_destruido, "Obstáculo resiste a dano convencional sem técnica KO")

	# 2. Dano com KO ativa destruição
	nen_sys.ativar_tecnica(NenSystem.Tecnica.KO)
	ko_obs.receber_dano(50, Vector2.ZERO, 0.0, player_scn)
	assert_true(ko_obs.foi_destruido, "Obstáculo foi destruído com sucesso com KO ativo")
	nen_sys.desativar_tecnica(NenSystem.Tecnica.KO)

	player_scn.queue_free()
	ko_obs.queue_free()


func _testar_ten_hazard_zone() -> void:
	print("\n--- [TESTE 3: ZONA DE NÉVOA CORROSIVA (TEN HAZARD)] ---")

	var player_scn = load("res://entities/Player/Player.tscn").instantiate()
	add_child(player_scn)
	var nen_sys: NenSystem = player_scn.get_node_or_null("NenSystem") as NenSystem

	PlayerData.despertou_nen = true
	PlayerData.attributes["nivel_nen"] = 5
	PlayerData.attributes["aura"] = 250.0
	PlayerData.attributes["aura_max"] = 250.0
	PlayerData.attributes["vida"] = 100
	PlayerData.attributes["vida_max"] = 100

	var hazard = TenHazardZone.new()
	hazard.dano_por_tick = 10
	add_child(hazard)

	hazard._on_body_entered(player_scn)
	assert_true(hazard.jogador_na_zona == player_scn, "Jogador detectado ao entrar na zona de perigo")

	# 1. Sem TEN -> Sofre dano
	hazard._processar_dano_ambiental()
	assert_true(PlayerData.attributes["vida"] < 100, "Jogador sem TEN sofreu dano ambiental do miasma")

	# 2. Com TEN -> Protegido
	var hp_antes = PlayerData.attributes["vida"]
	nen_sys.ativar_tecnica(NenSystem.Tecnica.TEN)
	hazard._processar_dano_ambiental()
	assert_true(PlayerData.attributes["vida"] == hp_antes, "Película de TEN protegeu o jogador contra o dano contínuo")
	nen_sys.desativar_tecnica(NenSystem.Tecnica.TEN)

	player_scn.queue_free()
	hazard.queue_free()


func _testar_ren_beacon() -> void:
	print("\n--- [TESTE 4: TOTEM ANCESTRAL COM REN] ---")

	var player_scn = load("res://entities/Player/Player.tscn").instantiate()
	add_child(player_scn)
	var nen_sys: NenSystem = player_scn.get_node_or_null("NenSystem") as NenSystem

	PlayerData.despertou_nen = true
	PlayerData.attributes["nivel_nen"] = 5
	PlayerData.attributes["aura"] = 250.0
	PlayerData.attributes["aura_max"] = 250.0

	var beacon = RenBeacon.new()
	add_child(beacon)

	beacon._on_body_entered(player_scn)
	assert_true(not beacon.foi_ativado, "Beacon permanece inativo sem emanação de REN")

	nen_sys.ativar_tecnica(NenSystem.Tecnica.REN)
	beacon._process(0.1)
	assert_true(beacon.foi_ativado, "Beacon foi energizado e ativado com a presença de REN")
	nen_sys.desativar_tecnica(NenSystem.Tecnica.REN)

	player_scn.queue_free()
	beacon.queue_free()


func _testar_zetsu_sensor_zone() -> void:
	print("\n--- [TESTE 5: SENSOR DE AURA & TRAVESSIA COM ZETSU] ---")

	var player_scn = load("res://entities/Player/Player.tscn").instantiate()
	add_child(player_scn)
	var nen_sys: NenSystem = player_scn.get_node_or_null("NenSystem") as NenSystem

	PlayerData.despertou_nen = true
	PlayerData.attributes["nivel_nen"] = 5
	PlayerData.attributes["aura"] = 250.0
	PlayerData.attributes["aura_max"] = 250.0

	var sensor = ZetsuSensorZone.new()
	sensor.zone_id = &"sensor_teste"
	add_child(sensor)

	# 1. Sem Zetsu -> Falha no stealth / Alarme dispara
	sensor._on_body_entered(player_scn)
	assert_true(sensor.falhou_stealth == true, "Alarme disparado ao entrar na zona sem ZETSU")
	sensor._on_body_exited(player_scn)

	# 2. Com Zetsu -> Sucesso no stealth
	nen_sys.ativar_tecnica(NenSystem.Tecnica.ZETSU)
	sensor._on_body_entered(player_scn)
	assert_true(sensor.falhou_stealth == false, "Jogador em ZETSU passa indetectável pelas sentinelas")
	sensor._on_body_exited(player_scn)
	nen_sys.desativar_tecnica(NenSystem.Tecnica.ZETSU)

	player_scn.queue_free()
	sensor.queue_free()


func _testar_shortcut_door() -> void:
	print("\n--- [TESTE 6: ATALHO DESBLOQUEÁVEL (BACKTRACKING)] ---")

	var door = ShortcutDoor.new()
	door.shortcut_id = &"atalho_teste_porta"
	door.door_name = "Portão de Teste"
	add_child(door)

	assert_true(door.esta_aberto == false, "Portão inicia trancado")

	door.abrir()
	assert_true(door.esta_aberto == true, "Portão foi destrancado pelo mecanismo interno")
	assert_true(PlayerData.quest_states.get("atalho_atalho_teste_porta", false) == true, "Estado do atalho salvo permanentemente no PlayerData")

	door.queue_free()


func _testar_world_chunk_loader() -> void:
	print("\n--- [TESTE 7: STREAMING DE CHUNKS & PERFORMANCE] ---")

	var player_scn = load("res://entities/Player/Player.tscn").instantiate()
	add_child(player_scn)
	player_scn.global_position = Vector2(0, 0)

	var loader = WorldChunkLoader.new()
	loader.raio_ativo = 500.0
	add_child(loader)

	var chunk_perto = Node2D.new()
	chunk_perto.name = "ChunkPerto"
	chunk_perto.global_position = Vector2(100, 0)
	loader.add_child(chunk_perto)

	var chunk_longe = Node2D.new()
	chunk_longe.name = "ChunkLonge"
	chunk_longe.global_position = Vector2(2000, 0)
	loader.add_child(chunk_longe)

	loader._coletar_chunks()
	loader.jogador = player_scn
	loader.atualizar_chunks()

	assert_true(chunk_perto.process_mode == Node.PROCESS_MODE_INHERIT and chunk_perto.visible == true, "Chunk próximo (<500px) ativo e visível")
	assert_true(chunk_longe.process_mode == Node.PROCESS_MODE_DISABLED and chunk_longe.visible == false, "Chunk distante (>2000px) pausado e ocultado para economia de recursos")

	player_scn.queue_free()
	loader.queue_free()
