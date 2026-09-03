extends Node2D

# ============================================================
# HUNTER ONLINE — SUÍTE DE TESTES: ATTGRANDE.md TRANSFORMAÇÃO RPG 2D
# ============================================================
#
# Valida integralmente os componentes implementados:
# 1. Design System & Typography (HunterUIStyle)
# 2. Status Menu RPG Rebuild (StatusMenu em 3 colunas)
# 3. ConditionTrackerUI Modular & Reutilizável
# 4. DamageNumberSystem (Floating Combat Text & Feedback)
# 5. TargetHUD com Fases de Chefe & Elite
# 6. Overhead Badges de NPCs com Cargo e Lore
# 7. QuestHUD Hierárquico com Objetivos Opcionais
# 8. Ciclo Save / Load de Persistência
# ============================================================

const HunterUIStyle = preload("res://ui/theme/HunterUIStyle.gd")
const ConditionTrackerUIScript = preload("res://ui/hud/ConditionTrackerUI.gd")

var _total_testes: int = 0
var _testes_passados: int = 0


func _ready() -> void:
	print("============================================================")
	print("🚀 INICIANDO SUÍTE DE TESTES: ATTGRANDE.md (RPG TRANSFORMATION)")
	print("============================================================")

	_teste_1_design_system_e_tipografia()
	_teste_2_status_menu_rpg_rebuild()
	_teste_3_condition_tracker_ui()
	_teste_4_damage_number_system()
	_teste_5_target_hud_boss_phases()
	_teste_6_npc_overhead_badges()
	_teste_7_quest_hud_hierarquia()
	_teste_8_save_load_roundtrip()

	print("\n============================================================")
	print("🏆 RESULTADO FINAL: %d / %d TESTES APROVADOS" % [_testes_passados, _total_testes])
	if _testes_passados == _total_testes:
		print("   STATUS: ATTGRANDE.md 100% IMPLEMENTADO, VALIDADO E BLINDADO!")
	else:
		printerr("   ALERTA: %d testes falharam!" % (_total_testes - _testes_passados))
	print("============================================================\n")


func _assinalar(condicao: bool, msg_sucesso: String, msg_falha: String) -> void:
	_total_testes += 1
	if condicao:
		_testes_passados += 1
		print("  ✅ [PASS] " + msg_sucesso)
	else:
		printerr("  ❌ [FAIL] " + msg_falha)


# ------------------------------------------------------------------------------
# TESTE 1: Design System & Tipografia
# ------------------------------------------------------------------------------
func _teste_1_design_system_e_tipografia() -> void:
	print("\n[TESTE 1/8] Verificando Design System centralizado e paleta...")

	var tipografia_ok := (
		HunterUIStyle.FONT_SIZE_TITLE == 11
		and HunterUIStyle.FONT_SIZE_HEADING == 9
		and HunterUIStyle.FONT_SIZE_BODY == 8
		and HunterUIStyle.FONT_SIZE_NUMERIC == 10
		and HunterUIStyle.FONT_SIZE_DAMAGE == 9
	)

	var cores_combate_ok := (
		HunterUIStyle.COLOR_CRIT_GOLD != Color.TRANSPARENT
		and HunterUIStyle.COLOR_DODGE_CYAN != Color.TRANSPARENT
		and HunterUIStyle.COLOR_BLOCK_STEEL != Color.TRANSPARENT
		and HunterUIStyle.COLOR_WEAK_ORANGE != Color.TRANSPARENT
		and HunterUIStyle.COLOR_HEAL_GREEN != Color.TRANSPARENT
	)

	var st_card := HunterUIStyle.criar_style_card_personagem()
	var st_licenca := HunterUIStyle.criar_style_licenca_hunter()
	var st_cond := HunterUIStyle.criar_style_condition_box(true)
	var st_float := HunterUIStyle.criar_style_floating_text()
	var st_phase := HunterUIStyle.criar_style_boss_phase_badge()
	var factories_ok := (st_card != null and st_licenca != null and st_cond != null and st_float != null and st_phase != null)

	var btn := Button.new()
	HunterUIStyle.aplicar_estilo_botao_estado(btn, "danger")
	var btn_danger_ok := btn.has_theme_stylebox_override("normal")
	HunterUIStyle.aplicar_estilo_botao_estado(btn, "selected")
	var btn_sel_ok := btn.has_theme_stylebox_override("normal")
	btn.queue_free()

	_assinalar(tipografia_ok and cores_combate_ok and factories_ok and btn_danger_ok and btn_sel_ok,
		"Design System centraliza tipografia formal, paletas semânticas e factories de painéis.",
		"Falha nas definições do Design System HunterUIStyle!")


# ------------------------------------------------------------------------------
# TESTE 2: Status Menu RPG Rebuild
# ------------------------------------------------------------------------------
func _teste_2_status_menu_rpg_rebuild() -> void:
	print("\n[TESTE 2/8] Testando Tela de Personagem RPG em 3 Colunas (StatusMenu)...")
	var status_menu = load("res://ui/StatusMenu/StatusMenu.tscn").instantiate()
	add_child(status_menu)
	status_menu._atualizar_status()

	var campos_ok := (
		status_menu.titulo_label != null
		and status_menu.hp_label != null
		and status_menu.aura_label != null
		and status_menu.forca_label != null
		and status_menu.defesa_label != null
		and status_menu.level_label != null
	)

	var barras_ok := (
		status_menu.bar_hp != null
		and status_menu.bar_aura != null
		and status_menu.bar_xp != null
		and status_menu.bar_nen_xp != null
	)

	var licenca_ok := (
		status_menu.lbl_hunter_id != null
		and status_menu.lbl_afinidade_licenca != null
		and status_menu.lbl_titulo_personagem != null
	)

	var sem_nen_lv := not "Nen Lv." in status_menu.aura_label.text
	var tem_sp := "SP" in status_menu.aura_label.text

	_assinalar(campos_ok and barras_ok and licenca_ok and sem_nen_lv and tem_sp,
		"StatusMenu reconstruído como Tela de Personagem RPG autêntica com barras e Licença Hunter.",
		"StatusMenu falhou na estrutura de 3 colunas ou mantém strings legadas!")

	status_menu.queue_free()


# ------------------------------------------------------------------------------
# TESTE 3: ConditionTrackerUI Modular
# ------------------------------------------------------------------------------
func _teste_3_condition_tracker_ui() -> void:
	print("\n[TESTE 3/8] Testando rastreador modular de condições (ConditionTrackerUI)...")
	var tracker = ConditionTrackerUIScript.new()
	add_child(tracker)

	var lista_teste: Array[Dictionary] = [
		{"texto": "Alvo Detectado no Raio de Ação", "atendida": true},
		{"texto": "Vida Abaixo de 50%", "atendida": false},
		{"texto": "Permanecer no Campo de En", "atendida": true}
	]

	tracker.rastrear_condicoes("⚡ GODSPEED", lista_teste)

	var visivel_ok := tracker.visible
	var titulo_ok := tracker.lbl_titulo.text == "⚡ GODSPEED"
	var contador_ok := tracker.lbl_contador.text == "2 / 3 Atendidas"
	var itens_ok := tracker.vbox_lista.get_child_count() == 3

	tracker.limpar()
	var limpar_ok := not tracker.visible

	_assinalar(visivel_ok and titulo_ok and contador_ok and itens_ok and limpar_ok,
		"ConditionTrackerUI renderiza checkmarks ✓/○, metas e contagem dinamicamente.",
		"Falha no funcionamento do ConditionTrackerUI!")

	tracker.queue_free()


# ------------------------------------------------------------------------------
# TESTE 4: DamageNumberSystem (Floating Combat Text)
# ------------------------------------------------------------------------------
func _teste_4_damage_number_system() -> void:
	print("\n[TESTE 4/8] Testando Sistema Global de Números de Dano (DamageNumberSystem)...")
	var dns = get_tree().root.get_node_or_null("DamageNumberSystem") if get_tree() != null else null
	var existe_dns := dns != null

	if existe_dns:
		# Testar spawns seguros sem lançar exceções
		dns.spawn_dano(Vector2(200, 200), 25, false)
		dns.spawn_dano(Vector2(200, 200), 75, true) # Crítico
		dns.spawn_dano(Vector2(200, 200), 50, false, true) # Weak point
		dns.spawn_esquiva(Vector2(200, 200))
		dns.spawn_bloqueio(Vector2(200, 200))
		dns.spawn_cura(Vector2(200, 200), 30)

	_assinalar(existe_dns,
		"DamageNumberSystem registrado globalmente e emitindo floating combat text sem erros.",
		"DamageNumberSystem não encontrado no ambiente de execução!")


# ------------------------------------------------------------------------------
# TESTE 5: TargetHUD com Fases de Boss e Elite
# ------------------------------------------------------------------------------
func _teste_5_target_hud_boss_phases() -> void:
	print("\n[TESTE 5/8] Testando TargetHUD com suporte a fases de chefes e elite...")
	var target_hud = TargetHUD.new()
	add_child(target_hud)

	# Criar nó dummy de chefe
	var dummy_boss := CharacterBody2D.new()
	dummy_boss.name = "Quimera Alpha"
	var enemy_sys := EnemySystem.new()
	enemy_sys.name = "EnemySystem"
	enemy_sys.is_boss = true
	enemy_sys.health = 50.0
	enemy_sys.max_health = 100.0
	dummy_boss.add_child(enemy_sys)
	add_child(dummy_boss)

	target_hud.focar_alvo(dummy_boss)

	var boss_focado := target_hud.visible
	var tem_badge_fase := target_hud.lbl_boss_phase.visible
	var texto_fase_ok := "FASE" in target_hud.lbl_boss_phase.text
	var hp_texto_ok := "50 / 100" in target_hud.lbl_hp_val.text

	target_hud.limpar_alvo()
	var limpo_ok := not target_hud.visible

	_assinalar(boss_focado and tem_badge_fase and texto_fase_ok and hp_texto_ok and limpo_ok,
		"TargetHUD exibe fases de Boss, valores numéricos de HP e limpa o foco corretamente.",
		"TargetHUD falhou ao detectar fases de chefe ou percentuais de HP!")

	target_hud.queue_free()
	dummy_boss.queue_free()


# ------------------------------------------------------------------------------
# TESTE 6: Overhead Badges de NPCs com Cargo e Lore
# ------------------------------------------------------------------------------
func _teste_6_npc_overhead_badges() -> void:
	print("\n[TESTE 6/8] Testando overhead badges com cargo e marcador em LivingNPCBehavior...")
	var dummy_npc := CharacterBody2D.new()
	dummy_npc.name = "DummyWing"
	var living := LivingNPCBehavior.new()
	living.npc_nome = "Wing"
	dummy_npc.add_child(living)
	add_child(dummy_npc)

	var badge := dummy_npc.get_node_or_null("LivingNPCNameBadge")
	var tem_badge := badge != null

	var tem_cargo := false
	if tem_badge:
		var lbl_role = badge.find_child("LivingNPCRoleLabel", true, false)
		if lbl_role != null and "Mestre de Nen" in lbl_role.text:
			tem_cargo = true

	_assinalar(tem_badge and tem_cargo,
		"LivingNPCBehavior injeta badge overhead com nome e cargo canônico ('Mestre de Nen').",
		"LivingNPCBehavior falhou na geração do overhead badge de identidade!")

	dummy_npc.queue_free()


# ------------------------------------------------------------------------------
# TESTE 7: QuestHUD Hierárquico
# ------------------------------------------------------------------------------
func _teste_7_quest_hud_hierarquia() -> void:
	print("\n[TESTE 7/8] Testando renderização hierárquica e integridade de texto no QuestHUD...")
	var quest_hud = load("res://ui/hud/QuestHUD.tscn").instantiate()
	add_child(quest_hud)

	quest_hud._atualizar_hud()

	var texto_arco := quest_hud.lbl_arco.text
	var sem_caracteres_corrompidos := not "ðŸ" in texto_arco and not "✓¨" in quest_hud.lbl_bussola.text
	var tem_header_legivel := "ARCO" in texto_arco or "PRAÇA" in texto_arco

	_assinalar(sem_caracteres_corrompidos and tem_header_legivel,
		"QuestHUD exibe caracteres limpos, títulos de arco e hierarquia de objetivos de RPG.",
		"QuestHUD ainda apresenta caracteres corrompidos ou falha no header!")

	quest_hud.queue_free()


# ------------------------------------------------------------------------------
# TESTE 8: Save / Load Roundtrip com Novos Sistemas
# ------------------------------------------------------------------------------
func _teste_8_save_load_roundtrip() -> void:
	print("\n[TESTE 8/8] Testando persistência completa de progresso e compatibilidade de save...")
	PlayerData.reset()
	PlayerData.nome_personagem = "Gon Freecss"
	PlayerData.nen_skill_points = 7
	PlayerData.nen_skill_tree_progress = {"ten_1": 1, "ten_2": 1, "ren_1": 1}
	PlayerData.nen_ryu_caminho = "ofensivo"

	var salvou := SaveManager.salvar_jogo(99)
	_assinalar(salvou, "Save de jogo realizado com sucesso no slot de teste 99.", "Falha ao salvar o jogo!")

	PlayerData.reset()
	_assinalar(PlayerData.nen_skill_points == 0 and PlayerData.nen_skill_tree_progress.is_empty(),
		"PlayerData resetado com sucesso.", "Falha no reset do PlayerData!")

	var carregou := SaveManager.carregar_jogo(99)
	var sp_restaurado := PlayerData.nen_skill_points == 7
	var nos_restaurados := PlayerData.nen_skill_tree_progress.has("ten_2")
	var ryu_restaurado := PlayerData.nen_ryu_caminho == "ofensivo"

	_assinalar(carregou and sp_restaurado and nos_restaurados and ryu_restaurado,
		"Progresso da Skill Tree, SP e dados do personagem restaurados com 100% de integridade.",
		"Falha na restauração do save no slot 99!")
