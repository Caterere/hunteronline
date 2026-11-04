extends Node
## Source-assert: Trilha G — percepção de aura + cast vivo.
## godot --headless --path . res://scratch/test_aura_cast_fidelity_suite.tscn


var _passed := 0
var _total := 0


func _ready() -> void:
	print("\n🧪 AURA CAST FIDELITY (Trilha G)")
	await get_tree().process_frame
	_test_ken_passive()
	_test_gyo_inspect()
	_test_enemy_search_pack_hatsus()
	_test_cast_vivo()
	print("🏆 RESULTADO: %d / %d" % [_passed, _total])
	get_tree().quit(0 if _passed == _total else 1)


func _ok(c: bool, label: String) -> void:
	_total += 1
	if c:
		_passed += 1
		print("  ✅ ", label)
	else:
		print("  ❌ ", label)


func _test_ken_passive() -> void:
	var nen := FileAccess.get_file_as_string("res://scripts/systems/NenSystem.gd")
	var passive := FileAccess.get_file_as_string("res://scripts/systems/nen/PassiveNenController.gd")
	var primer := FileAccess.get_file_as_string("res://scripts/story/ProgressionSystemsPrimer.gd")
	_ok(nen.find("aplicar_ken_no_dano") >= 0, "aplicar_ken_no_dano existe")
	_ok(nen.find("tecnica_ativa(Tecnica.KEN)") < 0 or nen.find("Ken é passivo") >= 0, "Ken não exige técnica ativa no mitigar")
	_ok(nen.find("obter_nivel_tecnica(Tecnica.KEN)") >= 0, "Ken escala por nível")
	_ok(passive.find("obter_multiplicador_ken_dano") >= 0, "PassiveNenController Ken")
	_ok(primer.find("Ken é blindagem passiva") >= 0 or primer.find("Ken é blindagem") >= 0, "Primer menciona Ken passivo")


func _test_gyo_inspect() -> void:
	var kit := FileAccess.get_file_as_string("res://scripts/systems/EnemySystem/EnemyNenKit.gd")
	var es := FileAccess.get_file_as_string("res://scripts/systems/EnemySystem/EnemySystem.gd")
	_ok(kit.find("inspect_summary") >= 0, "EnemyNenKit.inspect_summary")
	_ok(kit.find("Fraco contra:") >= 0, "fraqueza PT-BR")
	_ok(es.find("inspect_summary") >= 0, "EnemySystem sincroniza inspect")
	_ok(es.find("obter_dados_inspecao_gyo") >= 0, "obter_dados_inspecao_gyo")
	# Runtime smoke
	var NenKit = load("res://scripts/systems/EnemySystem/EnemyNenKit.gd")
	var data := EnemyData.new()
	data.enemy_id = &"formiga_lider"
	data.enemy_name = "Formiga Líder"
	data.role = "bruiser"
	NenKit.enrich(data)
	var summary: Dictionary = NenKit.inspect_summary(data)
	_ok(str(summary.get("categoria_nen", "")).length() > 3, "summary categoria preenchida")
	var frag := str(summary.get("fraqueza", ""))
	_ok(frag.find("Fraco contra:") >= 0 or frag.find("Hatsu:") >= 0, "summary fraqueza do kit (não placeholder)")


func _test_enemy_search_pack_hatsus() -> void:
	var ai := FileAccess.get_file_as_string("res://scripts/systems/EnemySystem/EnemyAI.gd")
	_ok(ai.find("SEARCH") >= 0, "State.SEARCH")
	_ok(ai.find("_entrar_search") >= 0 and ai.find("func _search") >= 0, "SEARCH handlers")
	_ok(ai.find("alertar_matilha") >= 0, "alertar_matilha")
	_ok(ai.find("PACK_ALERT_RADIUS") >= 0, "raio pack ~200")
	_ok(ai.find("_hatsu_comando_matilha") >= 0, "Comando de Matilha")
	_ok(ai.find("Rising Sun") >= 0 and ai.find("hp_ratio <= 0.50") >= 0, "Feitan gate HP 50%")
	_ok(ai.find("nobunaga_en_until") >= 0, "Nobunaga En persistente")
	_ok(ai.find("genthru_bomb_until") >= 0 or ai.find("LITTLE FLOWER — contagem") >= 0, "Genthru countdown")


func _test_cast_vivo() -> void:
	var gon := FileAccess.get_file_as_string("res://entities/npc/gon/Gon.gd")
	var killua := FileAccess.get_file_as_string("res://entities/npc/killua/Killua.gd")
	var leorio := FileAccess.get_file_as_string("res://entities/npc/leorio/Leorio.gd")
	var hisoka := FileAccess.get_file_as_string("res://entities/npc/hisoka/Hisoka.gd")
	var kura := FileAccess.get_file_as_string("res://entities/npc/kurapika/Kurapika.gd")
	var living := FileAccess.get_file_as_string("res://entities/npc/LivingNPCBehavior.gd")
	var chatter := FileAccess.get_file_as_string("res://scripts/story/CompanionChatter.gd")
	_ok(gon.find("_falas_para") >= 0 and gon.find("exibir_sequencia_falas") >= 0, "Gon etapa + VisualDialogue")
	_ok(killua.find("_falas_para") >= 0 and killua.find("ORDEM:") < 0, "Killua íntimo sem ORDEM")
	_ok(leorio.find("_falas_para") >= 0, "Leorio etapa beats")
	_ok(hisoka.find("ORDEM:") < 0, "Hisoka sem ORDEM falado")
	_ok(kura.find("_falas_yorknew") >= 0, "Kurapika Yorknew beats")
	_ok(living.find("\"gon\"") >= 0 or living.find("gon\" in n_lower") >= 0, "LivingNPC Gon STORY")
	_ok(living.find("hisoka") >= 0 and living.find("chrollo") >= 0, "LivingNPC Hisoka/Chrollo STORY")
	_ok(chatter.find("Hit1→finisher") < 0 and chatter.find("Hit1") < 0, "Chatter sem tutorial Hit1")
	_ok(chatter.find("Mike escuta presença") >= 0 or chatter.find("portão…") >= 0 or chatter.find("Esse portão") >= 0, "Chatter voz HxH")
