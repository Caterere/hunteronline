extends Node2D

const PassiveNenControllerScript = preload("res://scripts/systems/nen/PassiveNenController.gd")

# ============================================================
# HUNTER ONLINE — DEFINITIVE GAMEPLAY VISION VERIFICATION SUITE
# ============================================================
#
# Validação exaustiva e sem atalhos dos requisitos do Master Document:
# 1. Zetsu Stealth Real (Detecção escalonada e quebra em combate)
# 2. En Detecção + Intimidação (Cúpula e redução de defesa)
# 3. Gyo Percepção Multi-Tier (Tiers 1 a 5, sem "highlight everything")
# 4. Matriz Canônica de Conflitos de Técnicas Ativas
# 5. Os 5 Passivos (Ten, Ren, Shu, Ko, Ryu) e 2 Pilares de Combate
# 6. Save/Reload Roundtrip com Maestrias, Facções e Hub World
# ============================================================

var _total: int = 0
var _passados: int = 0


func _ready() -> void:
	print("\n============================================================")
	print("🥋 INICIANDO SUÍTE DEFINITIVA: NEN, COMBAT & WORLD VISION")
	print("============================================================")

	_teste_1_zetsu_stealth_e_deteccao()
	_teste_2_en_intimidacao_e_raio()
	_teste_3_gyo_percepcao_multi_tier()
	_teste_4_matriz_conflitos_ativos()
	_teste_5_cinco_passivos_e_combate()
	_teste_6_save_load_roundtrip_definitivo()

	print("\n============================================================")
	print("🏆 RESULTADO FINAL: %d / %d TESTES APROVADOS" % [_passados, _total])
	if _passados == _total:
		print("   STATUS: 100% EM CONFORMIDADE COM A DEFINITIVE GAMEPLAY VISION!")
	else:
		printerr("   ALERTA: %d testes falharam!" % (_total - _passados))
	print("============================================================\n")


func _assinalar(condicao: bool, msg_ok: String, msg_erro: String) -> void:
	_total += 1
	if condicao:
		_passados += 1
		print("  ✅ [PASS] " + msg_ok)
	else:
		printerr("  ❌ [FAIL] " + msg_erro)


# ------------------------------------------------------------------------------
# TESTE 1: ZETSU STEALTH & DETECÇÃO REAL (Seção 53)
# ------------------------------------------------------------------------------
func _teste_1_zetsu_stealth_e_deteccao() -> void:
	print("\n[TESTE 1/6] Testando Zetsu Stealth Real e Fórmulas de Detecção...")
	PlayerData.reset()
	PlayerData.despertou_nen = true

	# Criar jogador com NenSystem
	var player = CharacterBody2D.new()
	player.name = "Player"
	player.add_to_group("player")
	var nen_sys = NenSystem.new()
	nen_sys.name = "NenSystem"
	player.add_child(nen_sys)
	add_child(player)

	# Criar inimigo com EnemyAI
	var enemy = CharacterBody2D.new()
	enemy.name = "Enemy"
	enemy.add_to_group("enemies")
	var enemy_sys = EnemySystem.new()
	var enemy_ai = EnemyAI.new()
	enemy.add_child(enemy_sys)
	enemy.add_child(enemy_ai)
	add_child(enemy)

	enemy.global_position = Vector2.ZERO
	enemy_ai.detection_range = 260.0
	enemy_ai.player = player

	# Cenário A: Zetsu OFF, jogador a 230px (dentro dos 260px)
	player.global_position = Vector2(230, 0)
	var detectado_sem_zetsu: bool = enemy_ai.is_player_detected()

	# Cenário B: Zetsu ON (Base Lv 1 = 20% stealth -> Raio efetivo = 208px)
	nen_sys.ativar_tecnica(NenSystem.Tecnica.ZETSU)
	var detectado_com_zetsu_lv1: bool = enemy_ai.is_player_detected()

	# Cenário C: Upgrade de Zetsu via Skill Tree (Lv 5 = +60% stealth -> 80% total -> Raio efetivo = 52px)
	PlayerData.adicionar_modificador(StatModifier.new(&"test_zetsu", &"zetsu_stealth", StatModifier.Type.PERCENTAGE, 0.60))
	player.global_position = Vector2(80, 0) # A 80px do inimigo
	var detectado_com_zetsu_lv5: bool = enemy_ai.is_player_detected()

	# Cenário D: Quebra de Zetsu ao sofrer/desferir dano em combate
	CombatEngine.calcular_dano(enemy, player, null)
	var zetsu_quebrou_em_combate: bool = not nen_sys.esta_em_zetsu()

	player.queue_free()
	enemy.queue_free()

	_assinalar(detectado_sem_zetsu and not detectado_com_zetsu_lv1 and not detectado_com_zetsu_lv5 and zetsu_quebrou_em_combate,
		"Zetsu reduz efetivamente o raio de detecção conforme maestria e quebra em combate.",
		"Falha na fórmula de detecção de Zetsu ou na quebra de combate!")


# ------------------------------------------------------------------------------
# TESTE 2: EN DETECÇÃO + INTIMIDAÇÃO (Seção 54)
# ------------------------------------------------------------------------------
func _teste_2_en_intimidacao_e_raio() -> void:
	print("\n[TESTE 2/6] Testando En com Cúpula de Detecção e Intimidação em Área...")
	PlayerData.reset()
	PlayerData.despertou_nen = true

	var player = CharacterBody2D.new()
	var nen_sys = NenSystem.new()
	nen_sys.name = "NenSystem"
	player.add_child(nen_sys)
	add_child(player)

	var enemy = CharacterBody2D.new()
	enemy.add_to_group("enemies")
	var enemy_sys = EnemySystem.new()
	enemy_sys.defense = 50
	var enemy_ai = EnemyAI.new()
	enemy.add_child(enemy_sys)
	enemy.add_child(enemy_ai)
	add_child(enemy)

	enemy.global_position = Vector2(80, 0)
	player.global_position = Vector2.ZERO

	# Ligar En
	nen_sys.ativar_tecnica(NenSystem.Tecnica.EN)
	var en_ativo_ok: bool = nen_sys.esta_em_en()

	# Processar pulso de En
	nen_sys.active_controller.processar_pulso_en(0.6, Vector2.ZERO, get_tree())
	var def_intimidada_lv1: float = enemy_ai.obter_defesa_efetiva()
	var teve_reducao_lv1: bool = def_intimidada_lv1 < 50.0

	# Upgrade de En (Lv 5: Raio +330px, Intimidação -30%)
	PlayerData.adicionar_modificador(StatModifier.new(&"test_en_r", &"en_range", StatModifier.Type.FLAT, 330.0))
	PlayerData.adicionar_modificador(StatModifier.new(&"test_en_int", &"en_intimidation_defense_reduction", StatModifier.Type.PERCENTAGE, 0.25))
	var raio_expandido: float = nen_sys.obter_raio_en() >= 450.0

	nen_sys.active_controller.processar_pulso_en(0.6, Vector2.ZERO, get_tree())
	var def_intimidada_lv5: float = enemy_ai.obter_defesa_efetiva()
	var reducao_maior_lv5: bool = def_intimidada_lv5 <= 35.0

	player.queue_free()
	enemy.queue_free()

	_assinalar(en_ativo_ok and teve_reducao_lv1 and raio_expandido and reducao_maior_lv5,
		"En expande cúpula de aura e aplica debuff de intimidação proporcional à maestria.",
		"Falha na mecânica de cúpula de En ou na redução de defesa por intimidação!")


# ------------------------------------------------------------------------------
# TESTE 3: GYO PERCEPÇÃO MULTI-TIER (Seção 55)
# ------------------------------------------------------------------------------
func _teste_3_gyo_percepcao_multi_tier() -> void:
	print("\n[TESTE 3/6] Testando Gyo Percepção Multi-Tier (Sem highlight everything)...")
	PlayerData.reset()
	PlayerData.despertou_nen = true

	var player = CharacterBody2D.new()
	var nen_sys = NenSystem.new()
	nen_sys.name = "NenSystem"
	player.add_child(nen_sys)
	add_child(player)

	# Criar Pista Tier 1 (Fácil) e Pista Tier 3 (Avançada)
	var pista_t1 = GyoInspectable.new()
	pista_t1.nivel_gyo_minimo = 1
	add_child(pista_t1)

	var pista_t3 = GyoInspectable.new()
	pista_t3.nivel_gyo_minimo = 3
	add_child(pista_t3)

	# Gyo OFF: ambas invisíveis
	nen_sys.desativar_tecnica(NenSystem.Tecnica.GYO)
	var gyo_off_ok: bool = not pista_t1.gyo_ativo_no_jogador and not pista_t3.gyo_ativo_no_jogador

	# Gyo ON com Percepção Nível 1: Revela Tier 1, mas NÃO Tier 3!
	nen_sys.ativar_tecnica(NenSystem.Tecnica.GYO)
	var t1_revelada: bool = pista_t1.gyo_ativo_no_jogador
	var t3_ainda_oculta: bool = not pista_t3.gyo_ativo_no_jogador

	# Upgrade de Gyo para Nível 3
	PlayerData.adicionar_modificador(StatModifier.new(&"test_gyo", &"gyo_perception_level", StatModifier.Type.FLAT, 2.0))
	nen_sys.ativar_tecnica(NenSystem.Tecnica.GYO)
	var t3_revelada: bool = pista_t3.gyo_ativo_no_jogador

	player.queue_free()
	pista_t1.queue_free()
	pista_t3.queue_free()

	_assinalar(gyo_off_ok and t1_revelada and t3_ainda_oculta and t3_revelada,
		"Gyo revela segredos estritamente conforme o tier de percepção da Skill Tree.",
		"Falha no sistema de níveis de percepção de Gyo!")


# ------------------------------------------------------------------------------
# TESTE 4: MATRIZ CANÔNICA DE CONFLITOS DE ATIVOS (Seção 56)
# ------------------------------------------------------------------------------
func _teste_4_matriz_conflitos_ativos() -> void:
	print("\n[TESTE 4/6] Testando Matriz de Conflitos e Exclusão Mútua de Ativos...")
	PlayerData.reset()
	PlayerData.despertou_nen = true

	var nen_sys = NenSystem.new()
	add_child(nen_sys)

	# 1. Zetsu ON -> En ON deve desativar Zetsu
	nen_sys.ativar_tecnica(NenSystem.Tecnica.ZETSU)
	var z1: bool = nen_sys.esta_em_zetsu()
	nen_sys.ativar_tecnica(NenSystem.Tecnica.EN)
	var en1: bool = nen_sys.esta_em_en()
	var z_desligou_por_en: bool = not nen_sys.esta_em_zetsu()

	# 2. En ON -> Zetsu ON deve desativar En
	nen_sys.ativar_tecnica(NenSystem.Tecnica.ZETSU)
	var en_desligou_por_zetsu: bool = not nen_sys.esta_em_en()
	var z2: bool = nen_sys.esta_em_zetsu()

	# 3. Zetsu ON -> Gyo ON deve desativar Zetsu
	nen_sys.ativar_tecnica(NenSystem.Tecnica.GYO)
	var z_desligou_por_gyo: bool = not nen_sys.esta_em_zetsu()
	var gyo1: bool = nen_sys.esta_em_gyo()

	# 4. En + Gyo podem coexistir
	nen_sys.ativar_tecnica(NenSystem.Tecnica.EN)
	var en_com_gyo: bool = nen_sys.esta_em_en() and nen_sys.esta_em_gyo()

	# 5. Ativar Zetsu desliga ambos En e Gyo
	nen_sys.ativar_tecnica(NenSystem.Tecnica.ZETSU)
	var z_limpou_ambos: bool = nen_sys.esta_em_zetsu() and not nen_sys.esta_em_en() and not nen_sys.esta_em_gyo()

	nen_sys.queue_free()

	_assinalar(z1 and en1 and z_desligou_por_en and en_desligou_por_zetsu and z2 and z_desligou_por_gyo and gyo1 and en_com_gyo and z_limpou_ambos,
		"Matriz de conflitos preserva regras canônicas: Zetsu extingue En/Gyo e En+Gyo coexistem.",
		"Falha na resolução de conflito mútuo entre técnicas ativas!")


# ------------------------------------------------------------------------------
# TESTE 5: OS 5 PASSIVOS E COMBATE (Seções 10-14, 51)
# ------------------------------------------------------------------------------
func _teste_5_cinco_passivos_e_combate() -> void:
	print("\n[TESTE 5/6] Testando as 5 Técnicas Passivas (Ten, Ren, Shu, Ko, Ryu)...")
	PlayerData.reset()
	PlayerData.despertou_nen = true
	PlayerData.attributes["aura_max"] = 100.0

	var passive = PassiveNenControllerScript.new()

	# 1. Ten (Mitigação)
	var mit_ten: float = passive.obter_mitigacao_ten()
	var ten_ok: bool = mit_ten >= 8.0

	# 2. Ren (Multiplicador de dano físico)
	var mult_ren: float = passive.obter_multiplicador_ren_dano()
	var ren_ok: bool = mult_ren >= 1.15

	# 3. Shu (Equipamentos)
	PlayerData.adicionar_modificador(StatModifier.new(&"test_shu", &"dano_arma", StatModifier.Type.PERCENTAGE, 0.20))
	var shu_ok: bool = passive.obter_bonus_shu_equipamento() > 0.0

	# 4. Ko (Burst Finalizador)
	var ko_burst: float = passive.obter_bonus_ko_finalizador()
	var ko_ok: bool = ko_burst >= 0.50

	# 5. Ryu (Alocação dinâmica)
	var ryu_mod: Dictionary = passive.obter_modificador_ryu()
	var ryu_ok: bool = ryu_mod.has("ataque") and ryu_mod.has("defesa")

	_assinalar(ten_ok and ren_ok and shu_ok and ko_ok and ryu_ok,
		"As 5 técnicas passivas fornecem modificadores contínuos sem botões manuais.",
		"Falha nos cálculos do PassiveNenController!")


# ------------------------------------------------------------------------------
# TESTE 6: SAVE & RELOAD ROUNDTRIP (Seção 57)
# ------------------------------------------------------------------------------
func _teste_6_save_load_roundtrip_definitivo() -> void:
	print("\n[TESTE 6/6] Testando Save/Reload com Maestrias, Reputação e Hub World...")
	PlayerData.reset()
	PlayerData.nome_personagem = "Killua Zoldyck"
	PlayerData.despertou_nen = true
	PlayerData.nen_skill_points = 3
	PlayerData.mapa_atual_salvo = "res://world/maps/montanha_kukuroo.tscn"

	StoryManager.iniciar_saga(2)
	StoryManager.definir_checkpoint(&"montanha_kukuroo_portao")
	ReputationSystem.alterar_reputacao(ReputationSystem.Faccao.ASSOCIACAO_HUNTER, 450, "Treino Hunter")

	# Salvar no slot 96
	var salvou: bool = SaveManager.salvar_jogo(96)

	# Resetar memória
	PlayerData.reset()
	StoryManager.current_saga = 1

	# Carregar jogo
	var carregou: bool = SaveManager.carregar_jogo(96)

	var hub_world_ok: bool = PlayerData.mapa_atual_salvo == "res://world/lobby.tscn"
	var checkpoint_ok: bool = StoryManager.current_story_checkpoint == &"montanha_kukuroo_portao"
	var rep_ok: bool = ReputationSystem.obter_reputacao(ReputationSystem.Faccao.ASSOCIACAO_HUNTER) >= 450
	var nome_ok: bool = PlayerData.nome_personagem == "Killua Zoldyck"

	_assinalar(salvou and carregou and hub_world_ok and checkpoint_ok and rep_ok and nome_ok,
		"Save/Reload restaura checkpoints, reputação e respeita o Hub World Mandate.",
		"Falha na integridade do Save/Load roundtrip definitivo!")
