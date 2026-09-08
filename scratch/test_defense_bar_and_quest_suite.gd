extends Node2D

var _total: int = 0
var _passados: int = 0

func _ready() -> void:
	print("\n============================================================")
	print("🛡️ SUÍTE DE TESTES: BARRA DE DEFESA, GUARD BREAK & FLORESTA")
	print("============================================================")

	_teste_1_quebra_por_golpes_fortes()
	_teste_2_quebra_por_sequencia_de_fracos()
	_teste_3_dano_amplificado_vulneravel()
	_teste_4_regeneracao_fora_de_combate()
	_teste_5_boss_bar_hud_com_defesa()
	_teste_6_povoamento_floresta_e_quests()

	print("\n============================================================")
	print("🏆 RESULTADO FINAL: %d / %d TESTES APROVADOS" % [_passados, _total])
	if _passados == _total:
		print("   STATUS: 100% SUCESSO! BARRA DE DEFESA E CONTEÚDO VALIDADOS!")
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
# TESTE 1: QUEBRA POR GOLPES FORTES (2 ACERTOS)
# ------------------------------------------------------------------------------
func _teste_1_quebra_por_golpes_fortes() -> void:
	print("\n[TESTE 1/6] Testando Quebra de Defesa por Golpes Fortes (2 Heavy Hits)...")
	var enemy_scn = load("res://scripts/systems/EnemySystem/Enemy.tscn") as PackedScene
	_assinalar(enemy_scn != null, "Enemy.tscn carregado", "Falha ao carregar Enemy.tscn")
	if enemy_scn == null: return

	var enemy = enemy_scn.instantiate()
	add_child(enemy)
	var es = enemy.get_node_or_null("EnemySystem") as EnemySystem
	_assinalar(es != null, "Inimigo possui EnemySystem", "EnemySystem ausente")

	if es:
		es.defesa_barra_max = 100.0
		es.defesa_barra_atual = 100.0
		es.em_defesa_quebrada = false

		# Golpe Forte 1 (Drena 50%)
		es.aplicar_dano_defesa(50.0, true)
		_assinalar(es.defesa_barra_atual == 50.0, "Primeiro golpe forte drena 50%% da defesa", "Valor inesperado: %f" % es.defesa_barra_atual)
		_assinalar(es.em_defesa_quebrada == false, "Defesa ainda sustentada apos 1 golpe", "Quebrou prematuramente")

		# Golpe Forte 2 (Drena 50% -> Quebra!)
		es.aplicar_dano_defesa(50.0, true)
		_assinalar(es.defesa_barra_atual == 0.0, "Segundo golpe forte zera a barra de defesa", "Valor inesperado: %f" % es.defesa_barra_atual)
		_assinalar(es.em_defesa_quebrada == true, "Estado em_defesa_quebrada ativado com sucesso!", "Nao ativou defesa quebrada")
		_assinalar(es.em_stagger == true, "Inimigo entra em stagger fisico simultaneo", "Stagger nao ativado")
		_assinalar(es.tempo_timer_quebrada == 3.5, "Timer de vulnerabilidade configurado para 3.5s", "Timer incorreto: %f" % es.tempo_timer_quebrada)

	enemy.queue_free()

# ------------------------------------------------------------------------------
# TESTE 2: QUEBRA POR SEQUÊNCIA DE FRACOS (COMBO DE 4-5 HITS)
# ------------------------------------------------------------------------------
func _teste_2_quebra_por_sequencia_de_fracos() -> void:
	print("\n[TESTE 2/6] Testando Quebra por Sequência de Golpes Fracos...")
	var enemy_scn = load("res://scripts/systems/EnemySystem/Enemy.tscn") as PackedScene
	var enemy = enemy_scn.instantiate()
	add_child(enemy)
	var es = enemy.get_node_or_null("EnemySystem") as EnemySystem

	if es:
		es.defesa_barra_max = 100.0
		es.defesa_barra_atual = 100.0
		es.em_defesa_quebrada = false

		# Sequência: 15% -> 20% -> 30% -> 15% -> 20% = 100%
		es.aplicar_dano_defesa(15.0, false) # Hit 1 (85 left)
		_assinalar(es.defesa_barra_atual == 85.0, "Sequência Hit 1 drena 15%% (restam 85%%)", "Hit 1 falhou")

		es.aplicar_dano_defesa(20.0, false) # Hit 2 (65 left)
		_assinalar(es.defesa_barra_atual == 65.0, "Sequência Hit 2 drena 20%% (restam 65%%)", "Hit 2 falhou")

		es.aplicar_dano_defesa(30.0, false) # Hit 3 (35 left)
		_assinalar(es.defesa_barra_atual == 35.0, "Sequência Hit 3 drena 30%% (restam 35%%)", "Hit 3 falhou")

		es.aplicar_dano_defesa(15.0, false) # Hit 4 (20 left)
		_assinalar(es.defesa_barra_atual == 20.0, "Sequência Hit 4 drena 15%% (restam 20%%)", "Hit 4 falhou")

		es.aplicar_dano_defesa(20.0, false) # Hit 5 (0 left -> BREAK!)
		_assinalar(es.em_defesa_quebrada == true, "Sequência de 5 golpes leves quebrou a defesa!", "Falha ao quebrar por combo")

	enemy.queue_free()

# ------------------------------------------------------------------------------
# TESTE 3: DANO AMPLIFICADO DURANTE VULNERABILIDADE (+80%)
# ------------------------------------------------------------------------------
func _teste_3_dano_amplificado_vulneravel() -> void:
	print("\n[TESTE 3/6] Testando Dano Amplificado (+80%) com Defesa Quebrada...")
	var enemy_scn = load("res://scripts/systems/EnemySystem/Enemy.tscn") as PackedScene
	
	# Inimigo A: Guarda Normal
	var enemy_a = enemy_scn.instantiate()
	add_child(enemy_a)
	var es_a = enemy_a.get_node_or_null("EnemySystem") as EnemySystem
	es_a.max_health = 1000
	es_a.health = 1000
	es_a.defense = 0
	es_a.em_defesa_quebrada = false
	es_a.em_stagger = false
	es_a.take_damage(100)
	var dano_normal = 1000 - es_a.health

	# Inimigo B: Guarda Quebrada
	var enemy_b = enemy_scn.instantiate()
	add_child(enemy_b)
	var es_b = enemy_b.get_node_or_null("EnemySystem") as EnemySystem
	es_b.max_health = 1000
	es_b.health = 1000
	es_b.defense = 0
	es_b.em_defesa_quebrada = true
	es_b.em_stagger = true
	es_b.take_damage(100)
	var dano_quebrado = 1000 - es_b.health

	_assinalar(dano_normal == 100, "Dano normal base = 100", "Dano normal: %d" % dano_normal)
	_assinalar(dano_quebrado == 180, "Dano com defesa quebrada amplificado em +80%% (180)", "Dano quebrado: %d" % dano_quebrado)

	enemy_a.queue_free()
	enemy_b.queue_free()

# ------------------------------------------------------------------------------
# TESTE 4: REGENERAÇÃO FORA DE COMBATE
# ------------------------------------------------------------------------------
func _teste_4_regeneracao_fora_de_combate() -> void:
	print("\n[TESTE 4/6] Testando Regeneração da Barra de Defesa...")
	var enemy_scn = load("res://scripts/systems/EnemySystem/Enemy.tscn") as PackedScene
	var enemy = enemy_scn.instantiate()
	add_child(enemy)
	var es = enemy.get_node_or_null("EnemySystem") as EnemySystem

	if es:
		es.defesa_barra_max = 100.0
		es.defesa_barra_atual = 60.0
		es.em_defesa_quebrada = false
		es.tempo_sem_receber_dano = 0.0

		# 1s sem tomar dano -> ainda nao regenera (delay é 2.5s)
		es._physics_process(1.0)
		_assinalar(es.defesa_barra_atual == 60.0, "Defesa não regenera antes de 2.5s sem ataques", "Regenerou antes da hora")

		# Mais 1.6s -> total 2.6s (passou de 2.5s)
		es._physics_process(1.6)
		_assinalar(es.defesa_barra_atual > 60.0, "Defesa começa a se regenerar após 2.5s fora de combate (%f)" % es.defesa_barra_atual, "Nao regenerou")

	enemy.queue_free()

# ------------------------------------------------------------------------------
# TESTE 5: BOSS BAR NO PLAYERHUD COM BARRA DE DEFESA
# ------------------------------------------------------------------------------
func _teste_5_boss_bar_hud_com_defesa() -> void:
	print("\n[TESTE 5/6] Testando Boss Bar com Barra de Defesa no PlayerHUD...")
	var hud_scn = load("res://ui/HUD/HUD.tscn") as PackedScene
	_assinalar(hud_scn != null, "HUD.tscn carregado", "HUD.tscn ausente")
	if hud_scn == null: return

	var hud = hud_scn.instantiate()
	add_child(hud)

	var enemy_scn = load("res://scripts/systems/EnemySystem/Enemy.tscn") as PackedScene
	var boss = enemy_scn.instantiate()
	add_child(boss)
	var es = boss.get_node_or_null("EnemySystem") as EnemySystem

	if es:
		es.enemy_name = "Guardião Ancestral"
		es.max_health = 600
		es.health = 600
		es.defesa_barra_max = 280.0
		es.defesa_barra_atual = 280.0
		es.em_defesa_quebrada = false

		hud.registrar_boss(es)
		_assinalar(hud.boss_bar_panel.visible == true, "Boss bar ativada no HUD", "Boss bar oculta")
		_assinalar(hud.boss_def_bar != null, "ProgressBar de Defesa do Chefe criada", "Barra de defesa ausente")
		_assinalar(hud.boss_def_bar.value == 280.0, "Valor inicial de defesa do Chefe sincronizado (280.0)", "Defesa dessincronizada")

		# Drenar para quebrar defesa
		es.aplicar_dano_defesa(280.0, true)
		_assinalar(hud.lbl_boss_def.text == "💥 DEFESA QUEBRADA! (VULNERÁVEL)", 
			"HUD exibe aviso de DEFESA QUEBRADA em tempo real", 
			"Texto inesperado no HUD: %s" % hud.lbl_boss_def.text)

	boss.queue_free()
	hud.queue_free()

# ------------------------------------------------------------------------------
# TESTE 6: POVOAMENTO DA FLORESTA DOS VESTÍGIOS & NPCS
# ------------------------------------------------------------------------------
func _teste_6_povoamento_floresta_e_quests() -> void:
	print("\n[TESTE 6/6] Testando Povoamento da Floresta dos Vestígios e NPCs...")
	var scn = load("res://world/maps/floresta_vestigios.tscn") as PackedScene
	_assinalar(scn != null, "floresta_vestigios.tscn carregada", "floresta_vestigios ausente")
	if scn:
		var mapa = scn.instantiate()
		add_child(mapa)

		# 1. Herbalista NPC
		var herb = mapa.get_node_or_null("HerbalistaFloresta")
		_assinalar(herb != null, "Herbalista da Floresta presente no mapa", "Herbalista ausente")
		if herb:
			var inter = herb.get_node_or_null("InteractionComponent")
			_assinalar(inter != null, "Herbalista possui componente de interação [E]", "InteractionComponent ausente")

		# 2. Bestas de Sombra com Barras de Defesa
		var f1 = mapa.get_node_or_null("FeraSombra1")
		var f2 = mapa.get_node_or_null("FeraSombra2")
		var f3 = mapa.get_node_or_null("FeraSombra3")
		var f4 = mapa.get_node_or_null("FeraSombra4")
		var sent = mapa.get_node_or_null("SentinelaRuinasEntrada")

		_assinalar(f1 != null and f2 != null and f3 != null and f4 != null, 
			"Todas as 4 Bestas de Sombra instanciadas no mapa", 
			"Faltando bestas de sombra")
		_assinalar(sent != null, "Sentinela de Pedra Ancestral guardando a entrada da dungeon", "Sentinela ausente")

		if f1:
			var es1 = f1.get_node_or_null("EnemySystem")
			_assinalar(es1 != null and es1.defesa_barra_max == 100.0, "Besta de Sombra configurada com Barra de Defesa ativa (100.0)", "Defesa ausente")
		if sent:
			var es_s = sent.get_node_or_null("EnemySystem")
			_assinalar(es_s != null and es_s.defesa_barra_max == 140.0, "Sentinela Ancestral configurada com Barra de Defesa reforçada (140.0)", "Defesa sentinela incorreta")

		mapa.queue_free()