extends Node2D

var _total: int = 0
var _passados: int = 0

func _ready() -> void:
	print("\n============================================================")
	print("🏛️ SUÍTE DE TESTES: INSTANCIAÇÃO DO LOBBY E PROPORÇÕES DE NPCS")
	print("============================================================")

	_teste_1_lobby_script_e_instanciacao()
	_teste_2_npcs_presentes_no_lobby()
	_teste_3_proporcoes_e_alturas_dos_sprites()
	_teste_4_alinhamento_do_chao_pes()

	print("\n============================================================")
	print("🏆 RESULTADO: %d / %d TESTES APROVADOS" % [_passados, _total])
	if _passados == _total:
		print("   STATUS: 100% SUCESSO! LOBBY E NPCS VALIDADOS E PROPORCIONAIS!")
	else:
		printerr("   ALERTA: %d testes falharam!" % (_total - _passados))
	print("============================================================\n")
	get_tree().quit(0 if _passados == _total else 1)

func _assinalar(condicao: bool, msg_ok: String, msg_erro: String) -> void:
	_total += 1
	if condicao:
		_passados += 1
		print("  ✅ [PASS] " + msg_ok)
	else:
		printerr("  ❌ [FAIL] " + msg_erro)

# ------------------------------------------------------------------------------
# TESTE 1: LOBBY SCRIPT & INSTANCIAÇÃO
# ------------------------------------------------------------------------------
func _teste_1_lobby_script_e_instanciacao() -> void:
	print("\n[TESTE 1/4] Validando anexação do script Lobby.gd em world/lobby.tscn...")
	var lobby_scn = load("res://world/lobby.tscn") as PackedScene
	_assinalar(lobby_scn != null, "world/lobby.tscn carregado com sucesso", "Falha ao carregar world/lobby.tscn")
	if lobby_scn == null: return

	var lobby = lobby_scn.instantiate()
	_assinalar(lobby.get_script() != null, "Nó raiz Lobby possui script anexado", "Nó raiz Lobby NÃO tem script anexado!")
	_assinalar(lobby is Lobby, "Nó raiz é uma instância da classe Lobby", "Script anexado não é Lobby")
	
	add_child(lobby)
	_assinalar(lobby.get_child_count() >= 25, 
		"Lobby gerou %d nós filhos em _ready() (esperado >= 25)" % lobby.get_child_count(),
		"Poucos nós filhos gerados (%d)" % lobby.get_child_count())
	lobby.queue_free()

# ------------------------------------------------------------------------------
# TESTE 2: NPCS E LANDMARKS PRESENTES NO LOBBY
# ------------------------------------------------------------------------------
func _teste_2_npcs_presentes_no_lobby() -> void:
	print("\n[TESTE 2/4] Validando presença dos NPCs e Landmarks no Lobby...")
	var lobby_scn = load("res://world/lobby.tscn") as PackedScene
	var lobby = lobby_scn.instantiate()
	add_child(lobby)

	var npcs_esperados = [
		"RecepcionistaElena",
		"InstrutorCombate",
		"StoryGatewayNPC",
		"EstatuaNetero",
		"QuadroBounties",
		"Wing",
		"Zushi",
		"BonecoTreinoDojo",
		"Biscuit",
		"TrocaCategoriaNenNPC",
		"ForjaFerreiroWorkshop",
		"Ferreiro",
		"TendaMercadorStall",
		"Vendedor",
		"StoryGatewayNPC",
		"ParallelQuestNPC",
		"CuradorBestasNen",
		"PortaCasaJogador",
		"PortalTorreCelestial",
		"PortaoMundoExterior"
	]

	for npc_name in npcs_esperados:
		var node = lobby.get_node_or_null(npc_name)
		_assinalar(node != null, "Lobby contém nó '%s'" % npc_name, "Nó '%s' ausente no Lobby!" % npc_name)

	lobby.queue_free()

# ------------------------------------------------------------------------------
# TESTE 3: PROPORÇÕES E ALTURAS DOS SPRITES (VS PLAYER)
# ------------------------------------------------------------------------------
func _teste_3_proporcoes_e_alturas_dos_sprites() -> void:
	print("\n[TESTE 3/4] Validando escala e altura dos sprites dos NPCs vs Player.tscn...")
	# 1. Altura do Player: 21 px (base de comparação)
	var player_h = 21.0
	print("  -> Altura canônica do Player: %.1f px" % player_h)

	# 2. Verificar Ferreiro.tscn
	var scn_fe = load("res://entities/npc/ferreiro/Ferreiro.tscn") as PackedScene
	if scn_fe:
		var fe = scn_fe.instantiate()
		var spr = fe.get_node_or_null("Sprite2D") as Sprite2D
		_assinalar(spr != null, "Ferreiro possui Sprite2D", "Sprite2D ausente no Ferreiro")
		if spr:
			var visual_h = 48.0 * spr.scale.y
			_assinalar(visual_h >= 20.0 and visual_h <= 24.0,
				"Ferreiro altura visual proporcional (%.1f px, scale=%.2f)" % [visual_h, spr.scale.y],
				"Ferreiro altura fora do padrão: %.1f px" % visual_h)
		fe.queue_free()

	# 3. Verificar Vendedor.tscn
	var scn_ve = load("res://entities/npc/vendedor/Vendedor.tscn") as PackedScene
	if scn_ve:
		var ve = scn_ve.instantiate()
		var spr = ve.get_node_or_null("Sprite2D") as Sprite2D
		_assinalar(spr != null, "Vendedor possui Sprite2D", "Sprite2D ausente no Vendedor")
		if spr:
			var visual_h = 49.0 * spr.scale.y
			_assinalar(visual_h >= 20.0 and visual_h <= 24.0,
				"Vendedor altura visual proporcional (%.1f px, scale=%.2f)" % [visual_h, spr.scale.y],
				"Vendedor altura fora do padrão: %.1f px" % visual_h)
		ve.queue_free()

	# 4. Verificar Elena, Instrutor, Examinador e Zushi instanciados no Lobby
	var lobby_scn = load("res://world/lobby.tscn") as PackedScene
	var lobby = lobby_scn.instantiate()
	add_child(lobby)

	var npcs_verificar = {
		"RecepcionistaElena": 48.0,
		"InstrutorCombate": 48.0,
		"StoryGatewayNPC": 53.0,
		"Zushi": 50.0
	}

	for n_name in npcs_verificar.keys():
		var node = lobby.get_node_or_null(n_name)
		if node:
			var spr = node.get_node_or_null("Sprite2D") as Sprite2D
			if spr:
				var unscaled_h = npcs_verificar[n_name]
				var visual_h = unscaled_h * spr.scale.y
				_assinalar(visual_h >= 19.0 and visual_h <= 25.0,
					"%s altura visual proporcional (%.1f px, scale=%.2f)" % [n_name, visual_h, spr.scale.y],
					"%s altura desproporcional: %.1f px" % [n_name, visual_h])

	# 5. Verificar Guarda e Batedor na Estrada Real
	var estrada_scn = load("res://world/maps/estrada_padokia.tscn") as PackedScene
	if estrada_scn:
		var estrada = estrada_scn.instantiate()
		add_child(estrada)
		var guarda = estrada.get_node_or_null("GuardaPatrulha")
		if guarda:
			var spr = guarda.get_node_or_null("Sprite2D") as Sprite2D
			if spr:
				var visual_h = 51.0 * spr.scale.y
				_assinalar(visual_h >= 20.0 and visual_h <= 24.5,
					"GuardaPatrulha altura visual proporcional (%.1f px, scale=%.2f)" % [visual_h, spr.scale.y],
					"Guarda altura desproporcional: %.1f px" % visual_h)
		var batedor = estrada.get_node_or_null("BatedorViajante")
		if batedor:
			var spr = batedor.get_node_or_null("Sprite2D") as Sprite2D
			if spr:
				var visual_h = 49.0 * spr.scale.y
				_assinalar(visual_h >= 20.0 and visual_h <= 24.0,
					"BatedorViajante altura visual proporcional (%.1f px, scale=%.2f)" % [visual_h, spr.scale.y],
					"Batedor altura desproporcional: %.1f px" % visual_h)
		estrada.queue_free()

	lobby.queue_free()

# ------------------------------------------------------------------------------
# TESTE 4: ALINHAMENTO DO CHÃO / PÉS DOS PERSONAGENS
# ------------------------------------------------------------------------------
func _teste_4_alinhamento_do_chao_pes() -> void:
	print("\n[TESTE 4/4] Validando alinhamento dos pés com o piso do mundo...")
	# Player tem pés em Y = +1 (posição -17 + 18)
	var player_feet_y = 1.0
	print("  -> Linha de solo canônica do Player: Y = +%.1f" % player_feet_y)

	var scn_fe = load("res://entities/npc/ferreiro/Ferreiro.tscn") as PackedScene
	if scn_fe:
		var fe = scn_fe.instantiate()
		var spr = fe.get_node_or_null("Sprite2D") as Sprite2D
		if spr:
			# Frame 68x68, centro 34, pés em 57 -> offset = 23
			var feet_y = spr.position.y + 23.0 * spr.scale.y
			_assinalar(abs(feet_y - player_feet_y) <= 1.0,
				"Ferreiro pés alinhados ao solo (Y = %.2f)" % feet_y,
				"Ferreiro pés desalinhados: Y = %.2f" % feet_y)
		fe.queue_free()

	var scn_pq = load("res://entities/npc/parallel_quest/ParallelQuestNPC.tscn") as PackedScene
	if scn_pq:
		var pq = scn_pq.instantiate()
		var spr = pq.get_node_or_null("Sprite2D") as Sprite2D
		if spr:
			# Frame 48x48, centro 24, pés em 42 -> offset = 18
			var feet_y = spr.position.y + 18.0 * spr.scale.y
			_assinalar(abs(feet_y - player_feet_y) <= 1.0,
				"ParallelQuestNPC pés alinhados ao solo (Y = %.2f)" % feet_y,
				"ParallelQuestNPC pés desalinhados: Y = %.2f" % feet_y)
		pq.queue_free()
