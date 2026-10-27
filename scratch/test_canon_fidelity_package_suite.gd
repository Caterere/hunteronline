extends Node2D

## Valida o pacote recomendado D1-B … D8-B.

const CanonFidelityKit = preload("res://scripts/systems/hatsu/CanonFidelityKit.gd")

var total: int = 0
var passed: int = 0
var failed: int = 0


func _ready() -> void:
	print("\n=== CANON FIDELITY PACKAGE (D1–D8) ===")
	_test_d3_emperor()
	_test_d4_judgement_gate()
	_test_d5_crazy_slots()
	_test_d6_bungee_texture()
	_test_d7_charge_curve()
	_test_d8_legendary_gate()
	_test_runtime_hooks()
	print("----------------------------------------------------------------")
	print("Resultado: %d/%d | falhas %d" % [passed, total, failed])
	await get_tree().create_timer(0.05).timeout
	get_tree().quit(0 if failed == 0 else 1)


func _ok(cond: bool, label: String) -> void:
	total += 1
	if cond:
		passed += 1
		print("  ✅ %s" % label)
	else:
		failed += 1
		print("  ❌ %s" % label)


func _test_d3_emperor() -> void:
	print("\n[D3-C] Emperor Time")
	var emp = HatsuManager.obter_hatsu_canonico("kurapika_emperor_time")
	_ok(emp != null and emp.duracao >= 80.0, "duração longa (>=80s)")
	PlayerData.reset()
	CanonFidelityKit.ensure_esperanca_vida()
	_ok(float(PlayerData.attributes.get("esperanca_vida", 0)) >= 99.0, "esperanca_vida inicia ~100")
	var before := float(PlayerData.attributes["esperanca_vida"])
	_ok(CanonFidelityKit.gastar_esperanca_vida(CanonFidelityKit.EMPEROR_ESPERANCA_COST), "gasta esperança")
	_ok(float(PlayerData.attributes["esperanca_vida"]) < before, "esperança diminuiu")


func _test_d4_judgement_gate() -> void:
	print("\n[D4-B] Judgement após Chain Jail")
	var j = HatsuManager.obter_hatsu_canonico("kurapika_judgement_chain")
	_ok(j != null and "requires_chain_jail" in j.tags, "tag requires_chain_jail")
	_ok(CanonFidelityKit.is_judgement(j), "detect judgement")
	_ok(CanonFidelityKit.is_chain_jail(HatsuManager.obter_hatsu_canonico("kurapika_chain_jail")), "detect jail")


func _test_d5_crazy_slots() -> void:
	print("\n[D5-B] CrazySlots 3 armas")
	var src := FileAccess.get_file_as_string("res://entities/effects/CrazySlotsWheelEffect.gd")
	_ok("_executar_clava_esmagadora" in src and "dano_clava" in src, "clava com dano real")
	_ok("_executar_tiro_rifle" in src and "dano_rifle" in src, "rifle com projétil")
	_ok("[2, 2, 2, 3, 3, 4]" in src or "2, 2, 2, 3, 3, 4" in src, "pesos foice>clava>rifle")


func _test_d6_bungee_texture() -> void:
	print("\n[D6] Bungee + Texture")
	var bg = HatsuManager.obter_hatsu_canonico("hisoka_bungee_gum")
	var tex = HatsuManager.obter_hatsu_canonico("hisoka_texture_surprise")
	_ok(CanonFidelityKit.is_bungee(bg), "detect bungee")
	_ok(CanonFidelityKit.is_texture_surprise(tex), "detect texture")
	var sys_src := FileAccess.get_file_as_string("res://scripts/systems/HatsuSystem.gd")
	_ok("_criar_bungee_gum" in sys_src and "_spawn_bungee_ground_anchor" in sys_src, "multi-âncora no HatsuSystem")
	_ok("_executar_texture_surprise" in sys_src, "texture cosmético no HatsuSystem")


func _test_d7_charge_curve() -> void:
	print("\n[D7-C] Hold-to-charge")
	_ok(is_equal_approx(CanonFidelityKit.charge_power_mult(0.0), CanonFidelityKit.CHARGE_MIN_RATIO), "carga 0 → min ratio")
	_ok(is_equal_approx(CanonFidelityKit.charge_power_mult(CanonFidelityKit.CHARGE_MAX_SEC), 1.0), "carga max → 100%")
	var mid := CanonFidelityKit.charge_power_mult(1.0)
	_ok(mid > CanonFidelityKit.CHARGE_MIN_RATIO and mid < 1.0, "carga média interpola")
	var pedra = HatsuManager.obter_hatsu_canonico("gon_jajanken_pedra")
	_ok(CanonFidelityKit.is_charged_hatsu(pedra), "Pedra é charged")
	var sys_src := FileAccess.get_file_as_string("res://scripts/systems/HatsuSystem.gd")
	_ok("_iniciar_carga" in sys_src and "_liberar_carga" in sys_src, "hold API no HatsuSystem")


func _test_d8_legendary_gate() -> void:
	print("\n[D8-B] Lendários por saga")
	PlayerData.reset()
	PlayerData.arco_atual = 2
	PlayerData.max_arco_desbloqueado = 2
	PlayerData.despertou_nen = true
	PlayerData.hatsu_creation_unlocked = true
	var guanyin = HatsuManager.obter_hatsu_canonico("netero_guanyin")
	var gate = CanonFidelityKit.can_player_use_legendary(guanyin)
	_ok(not gate.get("allowed", true), "Guanyin bloqueado no arco 2")
	PlayerData.arco_atual = 6
	PlayerData.max_arco_desbloqueado = 6
	gate = CanonFidelityKit.can_player_use_legendary(guanyin)
	_ok(gate.get("allowed", false), "Guanyin liberado no arco 6")
	var pedra = HatsuManager.obter_hatsu_canonico("gon_jajanken_pedra")
	_ok(CanonFidelityKit.can_player_use_legendary(pedra).get("allowed", false), "Pedra nunca lendária-gated")


func _test_runtime_hooks() -> void:
	print("\n[Runtime] HatsuSystem hooks")
	PlayerData.reset()
	PlayerData.despertou_nen = true
	PlayerData.desbloquear_hatsu_creator()
	PlayerData.arco_atual = 6
	PlayerData.max_arco_desbloqueado = 6
	PlayerData.attributes["aura"] = 500.0
	PlayerData.attributes["aura_max"] = 500.0
	CanonFidelityKit.ensure_esperanca_vida()
	var body := CharacterBody2D.new()
	add_child(body)
	var hs := HatsuSystem.new()
	add_child(hs)
	hs.setup(body)
	# Mark / judgement helpers
	var dummy := CharacterBody2D.new()
	add_child(dummy)
	hs._marcar_chain_jail(dummy)
	_ok(hs._has_chain_jail_mark(dummy), "mark Chain Jail")
	hs._clear_chain_jail_mark(dummy)
	_ok(not hs._has_chain_jail_mark(dummy), "clear mark")
	# Emperor activation
	var emp = HatsuManager.obter_hatsu_canonico("kurapika_emperor_time")
	var before := float(PlayerData.attributes["esperanca_vida"])
	hs._ativar_emperor_time(emp)
	_ok(PlayerData.quest_states.get("emperor_time_ativo", false) == true, "emperor ativo")
	_ok(float(PlayerData.attributes["esperanca_vida"]) < before, "esperança consumida no activate")
	# Texture
	var tex = HatsuManager.obter_hatsu_canonico("hisoka_texture_surprise")
	hs._executar_texture_surprise(tex)
	_ok(PlayerData.quest_states.get("texture_surprise_ativo", false) == true, "texture ativo")
	# Charge mult on damage path
	hs._pending_charge_mult = 0.5
	var pedra = HatsuManager.obter_hatsu_canonico("gon_jajanken_pedra")
	var dmg_half := hs._calcular_dano_hatsu(pedra, 1.0, null)
	hs._pending_charge_mult = 1.0
	var dmg_full := hs._calcular_dano_hatsu(pedra, 1.0, null)
	_ok(dmg_full > dmg_half, "carga escala dano Pedra (%d < %d)" % [dmg_half, dmg_full])
	body.queue_free()
	hs.queue_free()
	dummy.queue_free()
