extends Node

# ============================================================
# Skill tree cluster identity + Vale Training Wing respiro
# ============================================================

var _ok_n: int = 0
var _fail_n: int = 0


func _ready() -> void:
	print("================================================================================")
	print("🧪 SUÍTE: Skill Tree Identity + Training Wing Vale")
	print("================================================================================")
	await _run_identity()
	_run_vale_training()
	print("--------------------------------------------------------------------------------")
	print("RESULTADO: %d ok / %d fail" % [_ok_n, _fail_n])
	print("================================================================================")
	await get_tree().process_frame
	get_tree().quit(0 if _fail_n == 0 else 1)


func _assert(cond: bool, msg: String) -> void:
	if cond:
		_ok_n += 1
		print("  ✅ %s" % msg)
	else:
		_fail_n += 1
		print("  ❌ %s" % msg)


func _run_identity() -> void:
	_assert(SkillTreeDatabase.obter_identidade_cluster(&"warrior") == "Lutador de Frente", "identity warrior")
	_assert(SkillTreeDatabase.obter_nome_cluster(&"body") == "Fortaleza Corpórea", "nome body")
	_assert(SkillTreeDatabase.REGIONS[&"hatsu"].has("identity"), "REGIONS.hatsu.identity")

	var tree_script = load("res://scripts/systems/NenSkillTree.gd")
	_assert(tree_script != null, "NenSkillTree carregável")
	if PlayerData != null:
		PlayerData.despertou_nen = true
		PlayerData.nen_skill_points = 20
		PlayerData.nen_skill_tree_progress = {}
		PlayerData.nen_ryu_caminho = ""
	var tree: NenSkillTree = tree_script.new()
	add_child(tree)
	await get_tree().process_frame
	if PlayerData != null:
		PlayerData.nen_skill_points = 20

	# Cadeia: gateway → war_str_01… (nexus_center já começa rank 1)
	var chain: Array[String] = ["warrior_gateway", "war_str_01", "war_str_02", "war_str_03", "war_str_04"]
	var invested := 0
	for nid in chain:
		if tree.investir_ponto(nid):
			invested += 1
		else:
			print("    (falha invest %s | SP=%d)" % [nid, PlayerData.nen_skill_points if PlayerData else -1])
	_assert(invested >= 4, "investiu ≥4 nós warrior chain (%d)" % invested)

	var dom: Dictionary = tree.obter_identidade_dominante()
	_assert(str(dom.get("region_id", "")) == "warrior", "cluster dominante = warrior")
	_assert(str(dom.get("identity", "")) == "Lutador de Frente", "identidade Lutador de Frente")
	_assert(bool(dom.get("committed", false)), "build committed após margem")


func _run_vale_training() -> void:
	var src := FileAccess.get_file_as_string("res://world/maps/RegiaoValePadokiaMap.gd")
	_assert(src.contains("_garantir_training_wing_respiro_vale"), "Vale tem Training Wing respiro")
	_assert(src.contains("TrainingWingRespiro"), "nó TrainingWingRespiro no Vale")
	var early_ok := FileAccess.get_file_as_string("res://autoload/DataManager.gd")
	_assert(early_ok.contains('"hp": 90') and early_ok.contains("slime"), "slime early HP retuned")
	_assert(early_ok.contains('"hp": 1100') and early_ok.contains("guardiao_ancestral"), "boss Guardião HP retuned")
