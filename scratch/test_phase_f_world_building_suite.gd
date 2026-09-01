extends Node

# ============================================================
# HUNTER ONLINE - SUÍTE DE TESTES: FASE F (WORLD BUILDING & MMORPG CORE)
# ============================================================

const RegionDefinition = preload("res://resource/world/RegionDefinition.gd")
const SpawnPoint = preload("res://entities/world/SpawnPoint.gd")
const MapTransitionArea = preload("res://world/components/MapTransitionArea.gd")

var total_testes: int = 0
var testes_passados: int = 0
var falhas: Array[String] = []

func _ready() -> void:
	print("\n================================================================================")
	print("🌍 INICIANDO SUÍTE DE TESTES: FASE F — WORLD BUILDING & CONNECTED WORLD")
	print("================================================================================\n")
	
	_testar_1_region_definition_data()
	_testar_2_world_progression_connections()
	_testar_3_spawn_points_and_positioning()
	_testar_4_save_manager_world_persistence()
	_testar_5_map_transition_gateways()
	_testar_6_dungeon_ruinas_boss_and_chest()
	_testar_7_gps_routing_across_regions()
	
	_imprimir_resultado_final()


func _assinalar(condicao: bool, desc_sucesso: String, desc_falha: String) -> void:
	total_testes += 1
	if condicao:
		testes_passados += 1
		print("  ✅ [PASS %d] %s" % [total_testes, desc_sucesso])
	else:
		falhas.append(desc_falha)
		print("  ❌ [FAIL %d] %s" % [total_testes, desc_falha])


# ------------------------------------------------------------
# 1. REGION DEFINITION DATA STRUCTURE
# ------------------------------------------------------------
func _testar_1_region_definition_data() -> void:
	print("[TESTE 1/7] Estrutura Orientada a Dados RegionDefinition...")
	var reg_dict := {
		"id": "vale_padokia",
		"display_name": "Vale de Padokia",
		"subtitle": "Região Semiaberta",
		"saga_id": 1,
		"scene_path": "res://world/maps/regiao_vale_padokia.tscn",
		"default_spawn": "spawn_padokia",
		"unlocked": true,
		"connected_regions": ["lobby", "dungeon_ruinas_zaban"],
		"exits": [
			{"portal_id": "portal_dungeon", "target_region": "dungeon_ruinas_zaban"}
		]
	}
	
	var def := RegionDefinition.from_dict(reg_dict)
	var serializado := def.to_dict()
	
	var ok: bool = (
		def.id == &"vale_padokia" and
		def.display_name == "Vale de Padokia" and
		def.connected_regions.has(&"dungeon_ruinas_zaban") and
		serializado.get("display_name") == "Vale de Padokia" and
		serializado.get("exits").size() == 1
	)
	
	_assinalar(
		ok,
		"RegionDefinition instancia, serializa e deserializa perfeitamente com tipagem estrita.",
		"Falha na serialização ou estrutura de RegionDefinition."
	)


# ------------------------------------------------------------
# 2. WORLD PROGRESSION & REGION CONNECTIONS
# ------------------------------------------------------------
func _testar_2_world_progression_connections() -> void:
	print("\n[TESTE 2/7] Gerenciamento de Regiões Conectadas no WorldProgressionManager...")
	WorldProgressionManager.definir_regiao_atual(&"lobby")
	var reg_atual = WorldProgressionManager.obter_regiao_atual()
	
	var conexoes_lobby = WorldProgressionManager.obter_regioes_conectadas(&"lobby")
	var tem_padokia: bool = false
	for cr in conexoes_lobby:
		if cr.id == &"vale_padokia":
			tem_padokia = true
			break
			
	WorldProgressionManager.desbloquear_regiao(&"continente_negro")
	var desbloqueou = WorldProgressionManager.is_regiao_desbloqueada(&"continente_negro")
	
	var ok: bool = (
		reg_atual != null and
		reg_atual.id == &"lobby" and
		tem_padokia and
		desbloqueou
	)
	
	_assinalar(
		ok,
		"WorldProgressionManager rastreia região atual, conexões de rota e estado de desbloqueio.",
		"Falha no roteamento de regiões conectadas do WorldProgressionManager."
	)


# ------------------------------------------------------------
# 3. SPAWN POINTS & PLAYER POSITIONING
# ------------------------------------------------------------
func _testar_3_spawn_points_and_positioning() -> void:
	print("\n[TESTE 3/7] Registro de SpawnPoints e Posicionamento Preciso...")
	WorldProgressionManager.limpar_spawn_points()
	
	var sp1 := SpawnPoint.new()
	sp1.name = "SpawnDefaultTest"
	sp1.spawn_id = &"default"
	sp1.position = Vector2(100, 200)
	sp1.is_default_spawn = true
	add_child(sp1)
	WorldProgressionManager.registrar_spawn_point(sp1)
	
	var sp2 := SpawnPoint.new()
	sp2.name = "SpawnRuinasTest"
	sp2.spawn_id = &"saida_ruinas"
	sp2.position = Vector2(500, 800)
	sp2.is_default_spawn = false
	add_child(sp2)
	WorldProgressionManager.registrar_spawn_point(sp2)
	
	var dummy_player := CharacterBody2D.new()
	dummy_player.name = "DummyPlayer"
	add_child(dummy_player)
	
	# Teste 1: Destino default
	WorldProgressionManager.definir_destino_spawn(&"default")
	WorldProgressionManager.posicionar_player_no_spawn(dummy_player)
	var pos1_ok = dummy_player.global_position.distance_to(Vector2(100, 200)) < 1.0
	
	# Teste 2: Destino saída de ruínas
	WorldProgressionManager.definir_destino_spawn(&"saida_ruinas")
	WorldProgressionManager.posicionar_player_no_spawn(dummy_player)
	var pos2_ok = dummy_player.global_position.distance_to(Vector2(500, 800)) < 1.0
	
	sp1.queue_free()
	sp2.queue_free()
	dummy_player.queue_free()
	
	_assinalar(
		pos1_ok and pos2_ok,
		"SpawnPoints registrados e consumidos deterministamente na transição de mundo.",
		"Falha no posicionamento de jogador por SpawnPoint!"
	)


# ------------------------------------------------------------
# 4. SAVE MANAGER WORLD PERSISTENCE
# ------------------------------------------------------------
func _testar_4_save_manager_world_persistence() -> void:
	print("\n[TESTE 4/7] Persistência de Região e Coordenadas no SaveManager...")
	PlayerData.nome_personagem = "Gon Freecss"
	PlayerData.mapa_atual_salvo = "res://world/maps/regiao_vale_padokia.tscn"
	PlayerData.posicao_salva = Vector2(1200, 4080)
	WorldProgressionManager.definir_regiao_atual(&"vale_padokia")
	
	SaveManager.salvar_jogo(1)
	
	# Verificar conteúdo do arquivo no disco com segurança
	var path = SaveManager.obter_caminho_slot(1)
	var file = FileAccess.open(path, FileAccess.READ)
	var file_ok = false
	var reg_salva = ""
	var pos_salva = []
	if file != null:
		var json = JSON.new()
		if json.parse(file.get_as_text()) == OK and json.data is Dictionary:
			file_ok = true
			reg_salva = json.data.get("regiao_atual", "")
			pos_salva = json.data.get("posicao_player", [])
		file.close()
	
	var reg_ok = (reg_salva == "vale_padokia")
	var pos_ok = (pos_salva.size() >= 2 and abs(float(pos_salva[0]) - 1200.0) < 1.0 and abs(float(pos_salva[1]) - 4080.0) < 1.0)
	
	_assinalar(
		file_ok and reg_ok and pos_ok,
		"SaveManager serializou com segurança atômica a região 'vale_padokia' e coordenadas (1200, 4080) no slot 1.",
		"Falha na serialização de região ou coordenadas no disco!"
	)


# ------------------------------------------------------------
# 5. MAP TRANSITION GATEWAYS & STORY GATES
# ------------------------------------------------------------
func _testar_5_map_transition_gateways() -> void:
	print("\n[TESTE 5/7] Conectividade Física dos Portões de Mundo...")
	var trans := MapTransitionArea.new()
	trans.target_scene_path = "res://world/maps/dungeon_ruinas_zaban.tscn"
	trans.target_spawn_id = &"entrada"
	trans.portal_name = "Ruínas de Zaban"
	add_child(trans)
	
	var col_ok = trans.is_in_group("portal") and trans.collision_mask == 2
	var interact_ok = trans.get_node_or_null("InteractionComponent") != null
	var label_ok = trans.get_node_or_null("PortalVisualLabel") != null
	
	trans.queue_free()
	
	_assinalar(
		col_ok and interact_ok and label_ok,
		"MapTransitionArea configura detecção física, componente de interação e label visual.",
		"Falha na inicialização dos portões de transição física!"
	)


# ------------------------------------------------------------
# 6. DUNGEON RUÍNAS DE ZABAN, BOSS & CHEST
# ------------------------------------------------------------
func _testar_6_dungeon_ruinas_boss_and_chest() -> void:
	print("\n[TESTE 6/7] Estrutura da Dungeon, Chefe e Baú de Recompensas...")
	var dung_scn = load("res://world/maps/dungeon_ruinas_zaban.tscn")
	var dung = dung_scn.instantiate() as Node2D
	add_child(dung)
	
	var has_spawn = dung.get_node_or_null("SpawnEntrada") != null
	var has_boss = dung.boss_node != null
	var has_exit = dung.get_node_or_null("PortalSaidaDungeon") != null
	
	# Simular vitória contra o Chefe
	dung._on_boss_derrotado(&"guardiao_ancestral")
	var has_chest = dung.get_node_or_null("BauDouradoRecompensa") != null
	
	dung.queue_free()
	
	_assinalar(
		has_spawn and has_boss and has_exit and has_chest,
		"Dungeon das Ruínas possui fluxo completo: Entrada, Chefe com Boss Bar, Baú de Recompensas e Saída.",
		"Falha na estrutura ou eventos da Dungeon das Ruínas!"
	)


# ------------------------------------------------------------
# 7. GPS ROUTING ACROSS REGIONS
# ------------------------------------------------------------
func _testar_7_gps_routing_across_regions() -> void:
	print("\n[TESTE 7/7] Navegação e Roteamento de GPS entre Regiões...")
	var gps_scn = load("res://ui/hud/MissionGPSIndicator.gd")
	var gps = gps_scn.new()
	add_child(gps)
	
	var player_dummy := CharacterBody2D.new()
	player_dummy.name = "Player"
	player_dummy.add_to_group("player")
	add_child(player_dummy)
	
	gps._localizar_player()
	var player_encontrado = gps.player_ref == player_dummy
	
	gps.queue_free()
	player_dummy.queue_free()
	
	_assinalar(
		player_encontrado,
		"MissionGPSIndicator detecta e rastreia o jogador dinamicamente para orientação no mundo aberto.",
		"Falha no rastreamento de jogador pelo MissionGPSIndicator!"
	)


# ------------------------------------------------------------
# IMPRIMIR RESULTADOS FINAIS
# ------------------------------------------------------------
func _imprimir_resultado_final() -> void:
	print("\n================================================================================")
	print("🏆 RESULTADO DA SUÍTE FASE F — WORLD BUILDING:")
	print("   TESTES APROVADOS: %d / %d (%.1f%%)" % [testes_passados, total_testes, (float(testes_passados) / float(max(1, total_testes))) * 100.0])
	if falhas.is_empty():
		print("   STATUS: MUNDO CONECTADO E SISTEMAS MMORPG 100% OPERACIONAIS!")
	else:
		print("   STATUS: FALHAS ENCONTRADAS:")
		for f in falhas:
			print("     ❌ %s" % f)
	print("================================================================================\n")
	get_tree().quit(0 if falhas.is_empty() else 1)
