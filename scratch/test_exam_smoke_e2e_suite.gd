extends Node

# Smoke ponta a ponta do Arco 1 (Exame) — headless-safe.
# godot --headless --path . res://scratch/test_exam_smoke_e2e_suite.tscn

const MissionObjectiveResolverScript = preload("res://scripts/missions/MissionObjectiveResolver.gd")
const StoryGateScript = preload("res://world/components/StoryGate.gd")

var _pass := 0
var _fail := 0


func _ok(cond: bool, msg: String) -> void:
	if cond:
		_pass += 1
		print("  ✅ ", msg)
	else:
		_fail += 1
		print("  ❌ ", msg)


func _ready() -> void:
	print("\n========== EXAM SMOKE E2E ==========")
	_test_exame_assets()
	_test_mission_resolver_and_gps_api()
	_test_nen_gyo_zetsu_en()
	_test_story_gate_helpers()
	await _test_exame_map_boot()
	print("========== RESULTADO: %d ok / %d fail ==========" % [_pass, _fail])
	await get_tree().create_timer(0.05).timeout
	get_tree().quit(1 if _fail > 0 else 0)


func _test_exame_assets() -> void:
	print("-- exame map/script --")
	var packed = load("res://world/maps/exame_maratona.tscn")
	_ok(packed != null, "exame_maratona.tscn carrega")
	var map_script = load("res://world/maps/ExameMaratonaMap.gd")
	_ok(map_script != null, "ExameMaratonaMap.gd carrega")
	var src := FileAccess.get_file_as_string("res://world/maps/ExameMaratonaMap.gd")
	_ok("_popular_sensores_nen_exame" in src, "ExameMaratonaMap densifica sensores Nen")


func _test_mission_resolver_and_gps_api() -> void:
	print("-- MissionObjectiveResolver / GPS --")
	_ok(MissionObjectiveResolverScript != null, "MissionObjectiveResolver preload")
	var _probe_path := MissionObjectiveResolverScript.get_expected_map_path(null)
	_ok(_probe_path is String, "get_expected_map_path retorna String")
	var gps_script = load("res://ui/hud/MissionGPSIndicator.gd")
	_ok(gps_script != null, "MissionGPSIndicator carrega")
	var gps := MissionGPSIndicator.new()
	_ok(gps.has_method("_atualizar_alvo_ativo"), "GPS _atualizar_alvo_ativo")
	gps.free()

	var q1 = CanonQuestCatalog.obter_quest_da_etapa(1, 1)
	if q1 != null:
		var path := MissionObjectiveResolverScript.get_expected_map_path(q1)
		_ok("exame_maratona" in path, "mapa esperado etapa 1 contém exame_maratona (%s)" % path)
	else:
		_ok(false, "CanonQuestCatalog etapa 1/1")


func _test_nen_gyo_zetsu_en() -> void:
	print("-- Nen Gyo / Zetsu / En --")
	_ok(InputMap.has_action("nen_gyo"), "InputMap nen_gyo")
	_ok(InputMap.has_action("nen_zetsu"), "InputMap nen_zetsu")
	_ok(InputMap.has_action("nen_en"), "InputMap nen_en")
	var nen := NenSystem.new()
	_ok(nen.has_method("esta_em_gyo") and nen.has_method("esta_em_zetsu"), "NenSystem API Gyo/Zetsu")
	_ok(nen.has_method("esta_em_en"), "NenSystem esta_em_en")
	nen.free()
	var synth_src := FileAccess.get_file_as_string("res://autoload/AudioSynth.gd")
	_ok("\"gyo_detect\"" in synth_src, "AudioSynth define gyo_detect")


func _test_story_gate_helpers() -> void:
	print("-- StoryGate --")
	var gate := StoryGateScript.new(1, 24, true)
	_ok(gate != null, "StoryGate instancia")
	var pend: Array = gate.get_unmet_requirements()
	_ok(pend is Array, "get_unmet_requirements retorna Array")
	var dlg: Array = gate.get_formatted_rejection_dialogue()
	_ok(dlg.size() >= 1, "get_formatted_rejection_dialogue não vazio")
	_ok(typeof(gate.can_advance()) == TYPE_BOOL, "can_advance retorna bool")


func _test_exame_map_boot() -> void:
	print("-- exame map runtime --")
	var packed = load("res://world/maps/exame_maratona.tscn")
	if packed == null:
		_ok(false, "boot mapa (tscn ausente)")
		return
	var mapa: Node2D = packed.instantiate()
	add_child(mapa)
	await get_tree().process_frame
	await get_tree().process_frame
	if mapa.has_method("_alinhar_atores_ao_corredor"):
		mapa._alinhar_atores_ao_corredor()
	_ok(mapa.get_node_or_null("SpawnDefault") != null, "SpawnDefault após _ready")
	_ok(mapa.get_node_or_null("GyoPistaFarsaMacaco") != null or mapa.get_node_or_null("GyoPistaMarcaSabotador") != null,
		"pista Gyo no Exame (farsa ou marca sabotador)")
	var portal = mapa.get_node_or_null("PortalMontanhaKukuroo")
	if portal != null and "story_gate" in portal and portal.story_gate != null:
		var sg = portal.story_gate
		_ok(sg.get_unmet_requirements() is Array, "StoryGate do portal não explode")
	else:
		_ok(portal != null, "PortalMontanhaKukuroo presente")
	mapa.queue_free()
