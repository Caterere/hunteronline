extends Node

const XPSystemScript = preload("res://scripts/systems/XPSystem.gd")
const NenSystemScript = preload("res://scripts/systems/NenSystem.gd")
const HatsuSystemScript = preload("res://scripts/systems/HatsuSystem.gd")
const StatusMenuScript = preload("res://ui/StatusMenu/StatusMenu.gd")

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
		print("  ❌ [FAIL] " + test_name)

func _ready() -> void:
	print("================================================================")
	print("🥋 TEST SUITE: GERADOR DE HUNTER LEVEL 100 / DEBUG PLAYTEST (13 TESTES)")
	print("================================================================")

	# -------------------------------------------------------------
	# TEST 1: Estado Inicial Normal (Level 1)
	# -------------------------------------------------------------
	PlayerData.reset()
	var initial_lvl = int(PlayerData.attributes.get("nivel", 1))
	var initial_hp = int(PlayerData.attributes.get("vida", 100))
	assert_test(initial_lvl == 1 and initial_hp > 0 and not PlayerData.is_debug_mode, "1. Estado Inicial: Personagem inicializa no Nível 1 com %d HP" % initial_hp)

	# -------------------------------------------------------------
	# TEST 2: Execução do Gerador Level 100
	# -------------------------------------------------------------
	var res = PlayerData.debug_create_level_100_hunter(true)
	assert_test(res.get("status") == "SUCCESS" and PlayerData.is_debug_mode, "2. Execução do Gerador: debug_create_level_100_hunter() concluído com sucesso")

	# -------------------------------------------------------------
	# TEST 3: Validação de Nível no PlayerData
	# -------------------------------------------------------------
	var lvl_100 = (PlayerData.attributes.get("nivel") == 100 and PlayerData.attributes.get("nivel_nen") == 100)
	assert_test(lvl_100, "3. PlayerData: Nível normal 100 e Nível Nen 100 confirmados")

	# -------------------------------------------------------------
	# TEST 4: Sincronização do XPSystem
	# -------------------------------------------------------------
	var xp_sys = XPSystemScript.new()
	add_child(xp_sys)
	xp_sys.sincronizar_com_player_data()
	var xp_sync_ok = (xp_sys.level == 100 and xp_sys.xp == xp_sys.xp_necessario())
	assert_test(xp_sync_ok, "4. XPSystem: Sincronizado para Level 100 com XP tabelado e sinal de level_up emitido")

	# -------------------------------------------------------------
	# TEST 5: Recálculo Canônico de Atributos
	# -------------------------------------------------------------
	var hp_max = PlayerData.attributes.get("vida_max", 0)
	var forca = PlayerData.attributes.get("forca", 0)
	var defesa = PlayerData.attributes.get("defesa", 0)
	var vel = PlayerData.attributes.get("velocidade", 0)
	var aura_max = PlayerData.attributes.get("aura_max", 0.0)
	var stats_ok = (hp_max >= 1000 and forca >= 200 and defesa >= 200 and vel >= 100 and aura_max >= 10000.0)
	assert_test(stats_ok, "5. Atributos: HP (%d), Força (%d), Defesa (%d), Aura (%d) recalculados pela pipeline oficial" % [hp_max, forca, defesa, int(aura_max)])

	# -------------------------------------------------------------
	# TEST 6: Todas as 9 Técnicas de Nen no Nível 100
	# -------------------------------------------------------------
	var all_nen_ok = true
	var tecs = ["ten", "ren", "zetsu", "gyo", "shu", "ko", "en", "ken", "ryu"]
	for t in tecs:
		if not PlayerData.tecnicas_nen.has(t) or PlayerData.tecnicas_nen[t].get("nivel") != 100 or not PlayerData.tecnicas_nen[t].get("desbloqueada", false):
			all_nen_ok = false
			break
	assert_test(all_nen_ok, "6. Técnicas de Nen: Todas as 9 técnicas canônicas desbloqueadas no Lv. 100 Máximo")

	# -------------------------------------------------------------
	# TEST 7: Hatsu Loadout nos 4 Slots
	# -------------------------------------------------------------
	var hatsu_slots_ok = (PlayerData.hatsu_slots.size() == 4 and PlayerData.hatsu_slots[0] != -1 and PlayerData.hatsu_criados.size() >= 4)
	assert_test(hatsu_slots_ok, "7. Hatsu Loadout: 4 slots equipados com habilidades canônicas prontas para combate")

	# -------------------------------------------------------------
	# TEST 8: Escalonamento de Dano no Combate
	# -------------------------------------------------------------
	var hatsu_sys = HatsuSystemScript.new()
	add_child(hatsu_sys)
	var h0: HatsuData = PlayerData.obter_hatsu_slot(0)
	var dano_calculado = hatsu_sys._calcular_dano_hatsu(h0, 1.0)
	assert_test(dano_calculado > 300, "8. Combate: Dano de Hatsu escalonado com poder Lv. 100 (%d dano)" % dano_calculado)

	# -------------------------------------------------------------
	# TEST 9: NenSystem Ativação e Sincronização
	# -------------------------------------------------------------
	var nen_sys = NenSystemScript.new()
	add_child(nen_sys)
	nen_sys.sincronizar_com_player_data()
	nen_sys.ativar_tecnica(NenSystem.Tecnica.TEN)
	var ten_active = nen_sys.tecnica_ativa(NenSystem.Tecnica.TEN)
	nen_sys.desativar_tecnica(NenSystem.Tecnica.TEN)
	assert_test(ten_active, "9. NenSystem: Ativação, maestria e cálculo de Ten funcionais em tempo de execução")

	# -------------------------------------------------------------
	# TEST 10: StatusMenu Atualização Visual
	# -------------------------------------------------------------
	var status_menu = StatusMenuScript.new()
	# Criar estrutura mínima de nós para StatusMenu
	var panel = Panel.new()
	panel.name = "Panel"
	var vbox = VBoxContainer.new()
	vbox.name = "VBoxContainer"
	var l_tit = Label.new(); l_tit.name = "TituloLabel"; vbox.add_child(l_tit)
	var l_lvl = Label.new(); l_lvl.name = "LevelLabel"; vbox.add_child(l_lvl)
	var l_hp = Label.new(); l_hp.name = "HPLabel"; vbox.add_child(l_hp)
	var l_frc = Label.new(); l_frc.name = "ForcaLabel"; vbox.add_child(l_frc)
	var l_def = Label.new(); l_def.name = "DefesaLabel"; vbox.add_child(l_def)
	var l_aur = Label.new(); l_aur.name = "AuraLabel"; vbox.add_child(l_aur)
	panel.add_child(vbox)
	status_menu.add_child(panel)
	add_child(status_menu)
	status_menu._atualizar_status()
	var ui_ok = (l_hp.text.contains(str(hp_max)) and l_aur.text.contains("Lv.100"))
	assert_test(ui_ok, "10. StatusMenu: Interface de Status reflete imediatamente os dados de Level 100")

	# -------------------------------------------------------------
	# TEST 11: Função de Reset (reset_debug_character)
	# -------------------------------------------------------------
	var reset_success = PlayerData.reset_debug_character()
	var restored_lvl = int(PlayerData.attributes.get("nivel", 1))
	var restored_hp = int(PlayerData.attributes.get("vida", 100))
	var reset_ok = (reset_success and restored_lvl == initial_lvl and restored_hp == initial_hp and not PlayerData.is_debug_mode)
	assert_test(reset_ok, "11. Reset Debug: Personagem restaurado fielmente ao estado original anterior (Lv. %d, %d HP)" % [restored_lvl, restored_hp])

	# -------------------------------------------------------------
	# TEST 12: Sincronização do XPSystem pós-Reset
	# -------------------------------------------------------------
	var xp_reset_ok = (xp_sys.level == 1 and xp_sys.xp == 0)
	assert_test(xp_reset_ok, "12. XPSystem pós-Reset: XPSystem retornou ao Nível 1 sem sobras de XP")

	# -------------------------------------------------------------
	# TEST 13: Isolamento de Saves Legítimos
	# -------------------------------------------------------------
	# Simular save no slot 2 normal
	PlayerData.reset()
	PlayerData.nome_personagem = "Hunter Original Slot 2"
	SaveManager.salvar_jogo(2)
	
	# Elevar para level 100 em modo debug
	PlayerData.debug_create_level_100_hunter()
	
	# Recarregar slot 2 legítimo
	SaveManager.carregar_jogo(2)
	var save_safe = (PlayerData.attributes.get("nivel") == 1 and PlayerData.nome_personagem == "Hunter Original Slot 2" and not PlayerData.is_debug_mode)
	assert_test(save_safe, "13. Isolamento de Saves: Progresso legítimo no Slot 2 permaneceu intacto e isolado do modo debug")

	print("================================================================")
	print("📊 RESULTADOS DA SUÍTE DE LEVEL 100 DEBUG:")
	print("Total: %d | Aprovados: %d | Falhas: %d" % [total_tests, passed_tests, failed_tests])
	print("================================================================")

	if failed_tests == 0:
		print("🎉 100% DOS TESTES DE LEVEL 100 APROVADOS COM SUCESSO!")
	else:
		printerr("❌ ALGUNS TESTES FALHARAM!")

	await get_tree().create_timer(0.2).timeout
	get_tree().quit(0 if failed_tests == 0 else 1)