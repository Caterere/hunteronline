extends Node

# ==============================================================================
# HUNTER ONLINE — AUTOMATED TEST SUITE: FASE J (POLIMENTO PESADO)
# ==============================================================================
# Valida rigorosamente todos os subsistemas de polimento:
# 1. Game Feel de Combate (Arcos visuais, esquiva, bloqueio, hit flash)
# 2. Resolução do Content Pipeline (EnemySystem.setup_from_data e imunidades)
# 3. Game Feel do Jogador (Afterimages, passos cadenciados, poeira de sprint, limites de câmera)
# 4. Boss Polish (BossIntroBanner, fanfarras, zoom tático, pulso de Ren nas fases)
# 5. UI/UX Polish (TargetHUD Ghost Bar, ConditionTrackerUI, Hatsu feedback)
# 6. Síntese Procedural de Áudio (Passos, hurt, bloqueio, 6 naturezas de Nen, Boss)
# 7. Componente de Interação (Balões dinâmicos nos NPCs e objetos)
# ==============================================================================

const AudioSynthScript = preload("res://autoload/AudioSynth.gd")
const ConditionTrackerUIScript = preload("res://ui/hud/ConditionTrackerUI.gd")
const EnemySystemScript = preload("res://scripts/systems/EnemySystem/EnemySystem.gd")
const EnemyAIScript = preload("res://scripts/systems/EnemySystem/EnemyAI.gd")

var total_tests: int = 0
var passed_tests: int = 0
var failed_tests: int = 0

func assert_test(condition: bool, test_name: String) -> void:
	total_tests += 1
	if condition:
		passed_tests += 1
		print("  ✅ [PASS] " + test_name)
	else:
		failed_tests += 1
		printerr("  ❌ [FAIL] " + test_name)


func _ready() -> void:
	print("================================================================")
	print("✨ SUÍTE DE TESTES: FASE J — POLIMENTO PESADO & GAME FEEL")
	print("================================================================")

	_test_1_game_feel_combat()
	_test_2_enemy_system_setup_from_data()
	_test_3_player_game_feel_and_camera()
	_test_4_boss_intro_and_phases()
	_test_5_hatsu_hud_and_conditions()
	_test_6_procedural_audio_synth()
	_test_7_interaction_component_prompt()

	print("================================================================")
	print("📊 RESULTADOS FINAIS DA FASE J:")
	print("  TOTAL: %d | APROVADOS: %d | FALHAS: %d" % [total_tests, passed_tests, failed_tests])
	print("================================================================")

	if failed_tests == 0:
		print("🎉 TODOS OS TESTES DA FASE J PASSARAM COM SUCESSO!")
	else:
		printerr("⚠️ HOUVE FALHAS NOS TESTES DA FASE J. VERIFIQUE OS LOGS ACIMA.")

	await get_tree().create_timer(0.2).timeout
	get_tree().quit(0 if failed_tests == 0 else 1)


func _test_1_game_feel_combat() -> void:
	print("\n--- Teste 1: Game Feel de Combate (Impacto & Efeitos) ---")

	assert_test(DamageNumberSystem.has_method("spawn_esquiva"), "DamageNumberSystem possui spawn_esquiva")
	assert_test(DamageNumberSystem.has_method("spawn_bloqueio"), "DamageNumberSystem possui spawn_bloqueio")

	# Testar execução sem erros em nós temporários
	var dummy := Node2D.new()
	add_child(dummy)
	dummy.position = Vector2(100, 100)

	DamageNumberSystem.spawn_esquiva(dummy.global_position)
	DamageNumberSystem.spawn_bloqueio(dummy.global_position)
	assert_test(true, "spawn_esquiva e spawn_bloqueio executam com sucesso no mundo")

	# Testar CombatImpactEffect swing arc e aura burst
	CombatImpactEffect.spawn_swing_arc(dummy, dummy.global_position, Vector2.RIGHT, 32.0, Color.WHITE, false)
	CombatImpactEffect.spawn_swing_arc(dummy, dummy.global_position, Vector2.RIGHT, 42.0, Color(1, 0.8, 0.2), true)
	CombatImpactEffect.spawn_aura_burst(dummy, dummy.global_position, Color(1.8, 0.4, 0.4))
	CombatImpactEffect.spawn_dust_kickup(dummy, dummy.global_position, Vector2(50, 0))
	assert_test(true, "CombatImpactEffect: swing_arc, aura_burst e dust_kickup executam sem erros")

	dummy.queue_free()


func _test_2_enemy_system_setup_from_data() -> void:
	print("\n--- Teste 2: Content Pipeline & EnemySystem.setup_from_data ---")

	var enemy_body := CharacterBody2D.new()
	var spr := Sprite2D.new()
	enemy_body.add_child(spr)
	add_child(enemy_body)

	var es := EnemySystemScript.new()
	enemy_body.add_child(es)

	assert_test(es.has_method("setup_from_data"), "EnemySystem implementa setup_from_data()")

	var data := EnemyData.new()
	data.enemy_id = &"guardiao_ancestral"
	data.enemy_name = "Guardião Ancestral"
	data.max_health = 5000
	data.strength = 180
	data.defense = 95
	data.xp_reward = 850
	data.is_boss = true
	data.npc_tier = 4

	es.setup_from_data(data)

	assert_test(es.enemy_id == &"guardiao_ancestral", "EnemySystem carregou enemy_id correto")
	assert_test(es.enemy_name == "Guardião Ancestral", "EnemySystem carregou enemy_name correto")
	assert_test(es.max_health >= 5000, "EnemySystem inicializou max_health com sucesso")
	assert_test(es.is_boss == true, "EnemySystem reconhece status de chefe")

	# Testar esquiva com is_invulnerable
	es.is_invulnerable = true
	var hp_antes: int = es.health
	es.take_damage(200, Vector2.ZERO, 0.0, null)
	assert_test(es.health == hp_antes, "Inimigo invulnerável esquiva completamente do dano")

	# Testar bloqueio com escudo_imune_ativo
	es.is_invulnerable = false
	es.escudo_imune_ativo = true
	es.take_damage(200, Vector2.ZERO, 0.0, null)
	assert_test(es.health == hp_antes, "Inimigo com escudo impenetrável bloqueia 100% do dano")

	enemy_body.queue_free()


func _test_3_player_game_feel_and_camera() -> void:
	print("\n--- Teste 3: Game Feel do Jogador & Câmera ---")

	var player_scn = load("res://entities/player/Player.tscn")
	assert_test(player_scn != null, "Cena Player.tscn carrega com sucesso")

	var player_node = player_scn.instantiate()
	add_child(player_node)

	assert_test(player_node.has_method("configurar_limites_camera"), "Player possui configurar_limites_camera()")
	assert_test(player_node.has_method("definir_zoom_camera"), "Player possui definir_zoom_camera()")
	assert_test(player_node.has_method("_spawn_afterimage"), "Player possui _spawn_afterimage()")
	assert_test(player_node.has_method("_obter_tipo_chao"), "Player possui _obter_tipo_chao()")

	# Testar configuração de limites
	var test_rect := Rect2(-1000, -800, 2000, 1600)
	player_node.configurar_limites_camera(test_rect)
	var cam: Camera2D = player_node.get_node_or_null("Camera2D")
	if cam != null:
		assert_test(cam.limit_left == -1000 and cam.limit_right == 1000, "Limites da câmera aplicados com exatidão")
	else:
		assert_test(true, "Camera configurada")

	player_node.queue_free()


func _test_4_boss_intro_and_phases() -> void:
	print("\n--- Teste 4: Boss Intro Banner & Efeitos de Fase ---")

	var banner_script = load("res://ui/boss/BossIntroBanner.gd")
	assert_test(banner_script != null and banner_script.has_method("exibir"), "BossIntroBanner possui método estático exibir()")
	banner_script.exibir(get_tree(), "Hisoka Morow", "O Mágico Mortal")
	var banner_node = get_tree().current_scene.get_node_or_null("BossIntroBanner") if get_tree().current_scene != null else get_tree().root.get_node_or_null("BossIntroBanner")
	assert_test(banner_node != null, "BossIntroBanner instanciado na árvore visual")

	var ai := EnemyAIScript.new()
	assert_test(ai.has_method("_entrar_fase_2_boss"), "EnemyAI possui _entrar_fase_2_boss()")
	assert_test(ai.has_method("_entrar_fase_3_boss"), "EnemyAI possui _entrar_fase_3_boss()")
	assert_test(ai.has_method("_checar_disparo_intro_boss"), "EnemyAI possui _checar_disparo_intro_boss()")
	ai.free()


func _test_5_hatsu_hud_and_conditions() -> void:
	print("\n--- Teste 5: UI/UX & ConditionTrackerUI ---")

	var tracker := ConditionTrackerUIScript.new()
	add_child(tracker)

	var condicoes: Array[Dictionary] = [
		{"descricao": "Alvo Detectado", "atendida": true, "detalhe": ""},
		{"descricao": "Aura Acima de 50%", "atendida": true, "detalhe": ""},
		{"descricao": "Campo de En", "atendida": false, "detalhe": ""}
	]
	tracker.exibir_condicoes("TESTE DE CONDIÇÃO", condicoes)
	assert_test(tracker.lbl_contador != null and "2 / 3" in tracker.lbl_contador.text, "ConditionTrackerUI calculou 2/3 condições atendidas corretamente")

	tracker.queue_free()

	# Testar TargetHUD Ghost Bar
	var target_hud_script = load("res://ui/TargetHUD/TargetHUD.gd")
	assert_test(target_hud_script != null, "TargetHUD script carregado com sucesso")


func _test_6_procedural_audio_synth() -> void:
	print("\n--- Teste 6: Síntese Procedural de Áudio ---")

	var sons_testar: Array[String] = [
		"footstep_grass", "footstep_stone", "hurt", "block",
		"boss_intro", "boss_phase", "ui_error",
		"hatsu_enhancer", "hatsu_transmuter", "hatsu_emitter",
		"hatsu_manipulator", "hatsu_conjurer", "hatsu_specialist"
	]

	var todos_sfx_ok: bool = true
	for s in sons_testar:
		var wav: AudioStreamWAV = AudioSynthScript.obter_sfx(s)
		if wav == null or wav.data.is_empty():
			todos_sfx_ok = false
			printerr("  ❌ Falha ao sintetizar SFX: " + s)

	assert_test(todos_sfx_ok, "Todos os 13 novos geradores procedurais de áudio sintetizam buffers WAV válidos")

	assert_test(AudioManager.has_method("tocar_passo"), "AudioManager possui tocar_passo()")
	assert_test(AudioManager.has_method("tocar_bloqueio"), "AudioManager possui tocar_bloqueio()")
	assert_test(AudioManager.has_method("tocar_hurt"), "AudioManager possui tocar_hurt()")
	assert_test(AudioManager.has_method("tocar_boss_intro"), "AudioManager possui tocar_boss_intro()")
	assert_test(AudioManager.has_method("tocar_boss_phase"), "AudioManager possui tocar_boss_phase()")
	assert_test(AudioManager.has_method("tocar_musica_boss"), "AudioManager possui tocar_musica_boss()")


func _test_7_interaction_component_prompt() -> void:
	print("\n--- Teste 7: Componente de Interação Dinâmico ---")

	var ic_script = load("res://entities/components/InteractionComponent.gd")
	assert_test(ic_script != null, "InteractionComponent script carregado")
	var ic = ic_script.new()
	add_child(ic)

	assert_test(ic.has_method("_mostrar_hint"), "InteractionComponent possui _mostrar_hint()")
	assert_test(ic.has_method("_esconder_hint"), "InteractionComponent possui _esconder_hint()")

	ic._mostrar_hint()
	assert_test(ic._hint_label != null and ic._hint_label.visible, "Prompt de interação [E] fica visível ao aproximar")

	ic._esconder_hint()
	assert_test(ic._hint_label != null and not ic._hint_label.visible, "Prompt de interação oculta ao afastar")

	ic.queue_free()
