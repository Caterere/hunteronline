extends SceneTree

## Combat Density Pass — asserts estáticos + smoke de API
## godot --headless -s res://scratch/test_combat_density_pass_suite.gd

var _passed: int = 0
var _failed: int = 0


func _assert(cond: bool, msg: String) -> void:
	if cond:
		_passed += 1
		print("  ✅ PASS: ", msg)
	else:
		_failed += 1
		print("  ❌ FAIL: ", msg)


func _read(path: String) -> String:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return ""
	return f.get_as_text()


func _initialize() -> void:
	print("\n=== COMBAT DENSITY PASS SUITE ===\n")

	var combat := _read("res://scripts/combat/CombatSystem.gd")
	var ai := _read("res://scripts/systems/EnemySystem/EnemyAI.gd")
	var esys := _read("res://scripts/systems/EnemySystem/EnemySystem.gd")
	var floresta := _read("res://world/maps/FlorestaVestigiosMap.gd")
	var ruinas := _read("res://world/maps/DungeonRuinasZabanMap.gd")

	# 1. Perfect Dodge por telegraph + janela curta de counter
	_assert("func _tentar_perfect_dodge_por_telegraph" in combat, "PD por leitura de telegraph")
	_assert("CONTRA_ATAQUE_JANELA" in combat, "janela de counter constante")
	_assert("0.85" in combat, "counter ~0.85s (skill window)")
	_assert("forcar_whiff_por_perfect_dodge" in combat, "whiff no inimigo após PD")
	_assert("PUNISH" in combat, "bônus em recovery do inimigo")
	_assert("_pressao_combate_timer" in combat, "dash mais caro em combate aberto")

	# 2. EnemyAI: telegraph, guarda, roles
	_assert("func esta_telegrafando" in ai, "API esta_telegrafando")
	_assert("func esta_em_recovery" in ai, "API esta_em_recovery")
	_assert("func esta_em_guarda" in ai, "API esta_em_guarda")
	_assert("func forcar_whiff_por_perfect_dodge" in ai, "API whiff PD")
	_assert("func _iniciar_guarda" in ai, "estado de guarda ativa")
	_assert("GUARD" in ai, "enum State.GUARD")
	_assert("_criar_telegraph_slash_direcional" in ai, "cone/slash de telegraph")
	_assert("RETALIAÇÃO" in ai or "CONTRA!" in ai, "retaliação a spam de leves")

	# 3. EnemySystem: guarda mitiga leve / heavy quebra
	_assert("em_guarda_ativa" in esys, "flag em_guarda_ativa")
	_assert("func entrar_guarda_ativa" in esys, "entrar_guarda_ativa")
	_assert("func sair_guarda_ativa" in esys, "sair_guarda_ativa")
	_assert("0.12" in esys or "0.18" in esys, "leve quase não drena guarda")
	_assert("1.35" in esys, "heavy pressiona guarda ativa")

	# 4. Encontros mistos floresta (bruiser + ranged)
	_assert("\"role\": \"ranged\"" in floresta or '"role": "ranged"' in floresta, "floresta tem ranged")
	_assert("\"role\": \"bruiser\"" in floresta or '"role": "bruiser"' in floresta, "floresta tem bruiser")
	_assert("Fera Alada Atiradora" in floresta, "pack clareira com atiradora")
	_assert("FeraFloresta2" in floresta, "FeraFloresta2 preservada (GPS/quests)")
	_assert("aoe_circle" in floresta, "telegraph aoe no pack")
	_assert("AlfaNinhoElite" in floresta, "elite Nen puzzle floresta")
	_assert("alfa_ninho_elite" in floresta or "Uivo de Aura" in floresta, "elite com Hatsu")

	# 5. Ruínas com roles mistos
	_assert('"tank"' in ruinas and '"ranged"' in ruinas, "ruínas misturam tank+ranged")
	_assert("role: String = \"bruiser\"" in ruinas or 'role: String = "bruiser"' in ruinas, "_instanciar_mob aceita role")
	_assert("guardiao_elite" in ruinas, "elite ruínas usa guardiao_elite")
	_assert("Muralha de Pedra" in ruinas or "hatsu_name" in ruinas, "elite ruínas com Hatsu")

	# 6. Smoke runtime: CombatSystem instancia e tem APIs
	var CombatScript = load("res://scripts/combat/CombatSystem.gd")
	_assert(CombatScript != null, "CombatSystem carrega")
	if CombatScript != null:
		var cs = CombatScript.new()
		root.add_child(cs)
		_assert(cs.has_method("_tentar_perfect_dodge_por_telegraph"), "método PD telegraph no runtime")
		_assert(cs.has_method("_executar_perfect_dodge"), "método PD execution runtime")
		# Const CONTRA_ATAQUE_JANELA lida via source (0.85) — já assertada acima
		cs.queue_free()

	var AIScript = load("res://scripts/systems/EnemySystem/EnemyAI.gd")
	_assert(AIScript != null, "EnemyAI carrega")
	if AIScript != null:
		var ai_node = AIScript.new()
		root.add_child(ai_node)
		_assert(ai_node.has_method("esta_telegrafando"), "esta_telegrafando runtime")
		_assert(ai_node.has_method("forcar_whiff_por_perfect_dodge"), "whiff runtime")
		_assert(ai_node.has_method("registrar_golpe_leve_recebido"), "pressão de leves runtime")
		_assert(not ai_node.esta_telegrafando(), "idle não telegrafa")
		ai_node.queue_free()

	print("\n=== RESULTADO: %d passed, %d failed ===\n" % [_passed, _failed])
	quit(0 if _failed == 0 else 1)
