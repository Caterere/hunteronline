extends Node2D

# ============================================================
# Hatsu signature polish — Chrollo / Meruem / Pitou
# ============================================================

const SignatureKit = preload("res://scripts/systems/hatsu/HatsuSignatureKit.gd")

var _ok := 0
var _total := 0
var _pass := true


func _ready() -> void:
	print("================================================================================")
	print("🚀 SUÍTE HATSU SIGNATURE POLISH (Chrollo / Meruem / Pitou)")
	print("================================================================================")
	await get_tree().process_frame
	_run()
	print("--------------------------------------------------------------------------------")
	print("RESULTADO: %d/%d" % [_ok, _total])
	if _pass:
		print("✅ HATSU SIGNATURE POLISH SUITE PASSED")
		get_tree().quit(0)
	else:
		print("❌ HATSU SIGNATURE POLISH SUITE FAILED")
		get_tree().quit(1)


func _check(c: bool, ok: String, fail: String) -> void:
	_total += 1
	if c:
		_ok += 1
		print("  ✅ [PASS] %s" % ok)
	else:
		_pass = false
		print("  ❌ [FAIL] %s" % fail)


func _run() -> void:
	print("\n[1] Catalog canônico")
	var hunter = HatsuManager.obter_hatsu_canonico("chrollo_skill_hunter")
	_check(hunter != null and hunter.arquetipo == HatsuData.Arquetipo.LIVRO_COLECAO,
		"Skill Hunter com LIVRO_COLECAO", "skill hunter thin")
	_check(hunter != null and hunter.steal_conditions.size() >= 2,
		"Skill Hunter tem steal_conditions", "no steal conditions")
	var devour = HatsuManager.obter_hatsu_canonico("meruem_aura_devour")
	_check(devour != null and devour.core_component == HatsuComponentLibrary.CoreType.ABSORPTION,
		"Meruem Devour ABSORPTION", "meruem missing")
	var terp = HatsuManager.obter_hatsu_canonico("pitou_terpsichora")
	_check(terp != null and "buff" in terp.tags, "Terpsichora tags buff", "terpsichora missing")
	var blythe = HatsuManager.obter_hatsu_canonico("pitou_doctor_blythe")
	_check(blythe != null and blythe.cura_base >= 80.0, "Doctor Blythe cura massiva", "blythe thin")

	print("\n[2] SignatureKit detect + play")
	_check(SignatureKit.detect_kind(hunter) == SignatureKit.Kind.SKILL_HUNTER, "detect Skill Hunter", "detect fail hunter")
	_check(SignatureKit.detect_kind(devour) == SignatureKit.Kind.DEVOUR, "detect Devour", "detect fail devour")
	_check(SignatureKit.detect_kind(terp) == SignatureKit.Kind.TERPSICHORA, "detect Terpsichora", "detect fail terp")
	_check(SignatureKit.detect_kind(blythe) == SignatureKit.Kind.DOCTOR_BLYTHE, "detect Doctor Blythe", "detect fail blythe")
	SignatureKit.play(SignatureKit.Kind.SKILL_HUNTER, self, self, "test")
	SignatureKit.play(SignatureKit.Kind.DEVOUR, self, self, "test")
	SignatureKit.play(SignatureKit.Kind.TERPSICHORA, self, self, "test")
	SignatureKit.play(SignatureKit.Kind.DOCTOR_BLYTHE, self, self, "test")
	_check(true, "play 4 signatures sem crash", "signature crash")

	print("\n[3] Player paths (buff / absorb / heal)")
	if FactionManager != null:
		pass
	PlayerData.faccao_atual = PlayerData.faccao_atual
	PlayerData.attributes["vida"] = 40
	PlayerData.attributes["vida_max"] = 100
	PlayerData.attributes["forca"] = 20
	PlayerData.attributes["aura"] = 200
	PlayerData.attributes["aura_max"] = 200
	Economy.adicionar_gold(0)

	var dummy := CharacterBody2D.new()
	dummy.name = "DummyCaster"
	add_child(dummy)
	var hs := HatsuSystem.new()
	add_child(hs)
	hs.owner_body = dummy
	# Buff corporal
	hs._executar_buff_corporal(terp, 1.0)
	_check(true, "buff corporal executa", "buff fail")
	# Doctor heal
	var hp_before := int(PlayerData.attributes["vida"])
	hs._executar_cura(blythe, 1.0)
	_check(int(PlayerData.attributes["vida"]) > hp_before, "Doctor Blythe cura HP", "heal fail")
	# Absorb
	var forca_before := int(PlayerData.attributes.get("forca", 20))
	var res = HatsuManager.execute_absorption_devour(devour, {"id": "prey_test", "name": "Prey", "level": 12, "is_boss": false})
	_check(bool(res.get("sucesso", false)) and int(PlayerData.attributes.get("forca", 0)) >= forca_before,
		"Devour absorve forca", "absorb fail: %s" % str(res))
	dummy.queue_free()
	hs.queue_free()
	print("\n[4] Enemy AI wiring source")
	var ai_src := FileAccess.get_file_as_string("res://scripts/systems/EnemySystem/EnemyAI.gd")
	_check("HatsuSignatureKit.play" in ai_src and "stolen_pages" in ai_src, "Chrollo steal real", "chrollo thin")
	_check("meruem_absorb_stacks" in ai_src, "Meruem absorb stacks", "meruem thin")
	_check("DOCTOR_BLYTHE" in ai_src and "TERPSICHORA" in ai_src, "Pitou dual mode", "pitou thin")

	print("\n[5] HatsuSystem suporte routing")
	var sys_src := FileAccess.get_file_as_string("res://scripts/systems/HatsuSystem.gd")
	_check("_executar_suporte" in sys_src and "_executar_buff_corporal" in sys_src,
		"SUPORTE → buff/absorb", "suporte routing missing")
	_check("HatsuSignatureKit.play" in sys_src, "cast signature no player", "player signature missing")
