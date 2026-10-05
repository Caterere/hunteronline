extends Node

# ============================================================
# HUNTER ONLINE — Steam Polish Pass Suite (bugs G5 + pilares)
# ============================================================
# Chat focus · frame clamp · cluster identity · schedules · sinks · áudio
# ============================================================

var _passed: int = 0
var _total: int = 0
var _failures: PackedStringArray = []


func _ready() -> void:
	print("\n================================================================================")
	print("🧪 STEAM POLISH PASS SUITE")
	print("================================================================================")
	await get_tree().process_frame
	_test_chat_focus_defaults()
	_test_enemy_frame_clamp()
	_test_skill_cluster_identity()
	_test_living_badge_ambient()
	_test_estrada_schedules()
	_test_economy_sinks()
	_test_audio_apis()
	_test_floresta_deferred()
	print("\n================================================================================")
	print("🏆 RESULTADO: %d / %d" % [_passed, _total])
	if not _failures.is_empty():
		for f in _failures:
			print("   ❌ ", f)
	print("================================================================================\n")
	get_tree().quit(0 if _passed == _total else 1)


func _ok(cond: bool, label: String) -> void:
	_total += 1
	if cond:
		_passed += 1
		print("  ✅ ", label)
	else:
		_failures.append(label)
		print("  ❌ ", label)


func _test_chat_focus_defaults() -> void:
	print("\n[1] MultiplayerChatHUD focus...")
	var src := FileAccess.get_file_as_string("res://ui/chat/MultiplayerChatHUD.gd")
	_ok("MOUSE_FILTER_IGNORE" in src, "chat fecha com mouse_filter IGNORE")
	_ok("_aplicar_filtro_mouse_chat" in src, "helper filtro mouse chat")
	_ok("FOCUS_NONE" in src, "LineEdit FOCUS_NONE quando fechado")


func _test_enemy_frame_clamp() -> void:
	print("\n[2] Enemy sprite frame clamp...")
	var es := FileAccess.get_file_as_string("res://scripts/systems/EnemySystem/EnemySystem.gd")
	_ok("clampi(enemy_sprite.frame" in es or "enemy_sprite.frame = clampi" in es, "EnemySystem clamp no swap folha")
	var ai := FileAccess.get_file_as_string("res://scripts/systems/EnemySystem/EnemyAI.gd")
	_ok("clampi(dir_frame" in ai or "max_frame" in ai, "EnemyAI clamp direção/frame")


func _test_skill_cluster_identity() -> void:
	print("\n[3] SkillTree cluster identity...")
	var db = SkillTreeDatabase.get_instance()
	_ok(db != null and db.nodes.size() > 100, "database carrega")
	var identity_count := 0
	var sample_ok := false
	for nid in db.nodes.keys():
		var n: SkillTreeNodeData = db.nodes[nid]
		if n.tags.has("cluster_identity"):
			identity_count += 1
			if "Identidade" in n.description or "Marco" in n.description:
				sample_ok = true
	_ok(identity_count >= 10, "≥10 nós com tag cluster_identity (got %d)" % identity_count)
	_ok(sample_ok, "descrições de identidade (não só +stat)")


func _test_living_badge_ambient() -> void:
	print("\n[4] LivingNPC ambient badge...")
	var src := FileAccess.get_file_as_string("res://entities/npc/LivingNPCBehavior.gd")
	_ok('"ambient":' in src or "\"ambient\"" in src, "match ambient badge")
	_ok("badge_proximity_only" in src, "badge_proximity_only export")
	_ok("_atualizar_badge_proximidade" in src, "proximidade atualiza badge")


func _test_estrada_schedules() -> void:
	print("\n[5] Estrada schedules + facção...")
	var src := FileAccess.get_file_as_string("res://world/maps/EstradaPadokiaMap.gd")
	_ok("NPCScheduleData" in src or "schedule_data" in src, "Estrada atribui schedule_data")
	_ok("AgenteAssociacaoEstrada" in src and "ObservadorMafiaEstrada" in src, "evento facção Associação×Máfia")
	_ok("badge_proximity_only" in src, "walkers Estrada proximity badges")


func _test_economy_sinks() -> void:
	print("\n[6] Economy sinks...")
	_ok(Economy.has_method("aplicar_multa"), "aplicar_multa")
	_ok(Economy.custo_sink_hatsu() == 5000, "Hatsu sink 5k")
	var n: int = Economy.ITEM_CATALOGO.size()
	_ok(n >= 30 and n <= 80, "catálogo 30–80 IDs (got %d)" % n)
	_ok(not Economy.ITEM_CATALOGO.has("pocao_vida"), "sem poção clássica")


func _test_audio_apis() -> void:
	print("\n[7] Áudio stinger/bark/crossfade...")
	_ok(AudioManager.has_method("tocar_stinger_reward"), "tocar_stinger_reward")
	_ok(AudioManager.has_method("tocar_bark_mentor"), "tocar_bark_mentor")
	_ok(AudioManager.has_method("crossfade_story_gate"), "crossfade_story_gate")
	AudioManager.tocar_stinger_reward("chest")
	AudioManager.tocar_bark_mentor("elena")
	_ok(true, "stinger+bark invocáveis sem crash")


func _test_floresta_deferred() -> void:
	print("\n[8] Floresta densify deferred...")
	var src := FileAccess.get_file_as_string("res://world/maps/FlorestaVestigiosMap.gd")
	_ok('call_deferred("_densificar_steam_early_floresta")' in src, "densify call_deferred")
