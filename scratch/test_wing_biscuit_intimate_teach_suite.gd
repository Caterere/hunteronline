extends Node
## Source-assert: aulas íntimas Wing + Biscuit (cutscenes + Primer combate/votos).
## godot --headless --path . res://scratch/test_wing_biscuit_intimate_teach_suite.tscn


var _passed := 0
var _total := 0


func _ready() -> void:
	print("\n🧪 WING + BISCUIT INTIMATE TEACH")
	await get_tree().process_frame
	_test_wing_cutscene()
	_test_biscuit_ko_and_forja()
	_test_npc_wiring()
	_test_primer_topics()
	print("🏆 RESULTADO: %d / %d" % [_passed, _total])
	get_tree().quit(0 if _passed == _total else 1)


func _ok(c: bool, label: String) -> void:
	_total += 1
	if c:
		_passed += 1
		print("  ✅ ", label)
	else:
		print("  ❌ ", label)


func _test_wing_cutscene() -> void:
	var scm := FileAccess.get_file_as_string("res://scripts/cutscenes/StoryCutsceneManager.gd")
	_ok(not scm.is_empty(), "StoryCutsceneManager legível")
	_ok(scm.find("executar_wing_principios_nen") >= 0, "cutscene Wing princípios existe")
	_ok(scm.find("cutscene_wing_principios") >= 0, "flag cutscene_wing_principios")
	_ok(scm.find("Essa aura é sua") >= 0 or scm.find("essa aura é sua") >= 0, "Wing: olhar íntimo / afinidade")
	_ok(scm.find("[Z]") >= 0 and scm.find("[G]") >= 0 and scm.find("[X]") >= 0, "Wing: teclas Z/G/X")
	_ok(scm.find("finisher") >= 0, "Wing: combo finisher")
	_ok(scm.find("Perfect Dodge") >= 0 or scm.find("perfect dodge") >= 0, "Wing: Perfect Dodge")
	_ok(scm.find("wing_foco_treino") >= 0, "Wing: escolha íntima wing_foco_treino")
	_ok(scm.find("Eu fico de olho") >= 0, "Wing: resposta emocional pós-escolha")
	_ok(scm.find("não te abandono") >= 0 or scm.find("nao te abandono") >= 0, "Wing: fecho íntimo 200º")


func _test_biscuit_ko_and_forja() -> void:
	var scm := FileAccess.get_file_as_string("res://scripts/cutscenes/StoryCutsceneManager.gd")
	_ok(scm.find("executar_biscuit_pressao_ko") >= 0, "cutscene Biscuit Ko existe")
	_ok(scm.find("cutscene_biscuit_ko") >= 0, "flag cutscene_biscuit_ko")
	_ok(scm.find("coragem, não fraqueza") >= 0 or scm.find("coragem — não fraqueza") >= 0, "Ko: coragem íntima")
	_ok(scm.find("Cem por cento") >= 0 or scm.find("100%") >= 0 or scm.find("cem por cento") >= 0, "Ko: concentração num ponto")
	_ok(scm.find("biscuit_foco_gi") >= 0, "Ko: escolha biscuit_foco_gi")
	_ok(scm.find("executar_biscuit_forja_hatsu") >= 0, "cutscene forja Hatsu existe")
	_ok(scm.find("cutscene_biscuit_forja_hatsu") >= 0, "flag cutscene_biscuit_forja_hatsu")
	_ok(scm.find("Slot [1]") >= 0 or scm.find("Slot 1") >= 0, "Forja: Slot 1")
	_ok(scm.find("Votos") >= 0 or scm.find("votos") >= 0, "Forja: votos/juramentos")
	_ok(scm.find("Não copie o Gon") >= 0 or scm.find("não copie o Gon") >= 0, "Forja: não copie Gon")
	_ok(scm.find("Canalize") >= 0 or scm.find("canalize") >= 0, "Forja: canalize→impacto→residual")


func _test_npc_wiring() -> void:
	var wing := FileAccess.get_file_as_string("res://entities/npc/wing/Wing.gd")
	_ok(wing.find("executar_wing_principios_nen") >= 0, "Wing dispara cutscene princípios")
	_ok(wing.find("Agora olha pra mim") >= 0, "Wing handoff íntimo pós-água")
	_ok(wing.find("Sinto sua aura ainda escapando") >= 0, "Wing etapa 12 íntima")
	_ok(wing.find("Guia:") >= 0, "Wing menu guia presente")
	_ok(wing.find("ProgressionSystemsPrimerScript.abrir_menu_guia") >= 0, "Wing abre Primer")
	_ok(wing.find("combate") >= 0 and wing.find("votos") >= 0, "Wing menciona combate/votos no menu")

	var bisc := FileAccess.get_file_as_string("res://entities/npc/biscuit/Biscuit.gd")
	_ok(bisc.find("executar_biscuit_forja_hatsu") >= 0, "Biscuit unlock → forja cutscene")
	_ok(bisc.find("executar_biscuit_pressao_ko") >= 0, "Biscuit etapa 7 → Ko cutscene")
	_ok(bisc.find("topicos_biscuit") >= 0, "Biscuit Conversar usa topicos_biscuit")
	_ok(bisc.find("ProgressionSystemsPrimerScript.abrir_menu_guia") >= 0, "Biscuit abre Primer")


func _test_primer_topics() -> void:
	var primer := FileAccess.get_file_as_string("res://scripts/story/ProgressionSystemsPrimer.gd")
	_ok(primer.find("falas_combate") >= 0, "Primer falas_combate")
	_ok(primer.find("falas_votos") >= 0, "Primer falas_votos")
	_ok(primer.find("topicos_biscuit") >= 0, "Primer topicos_biscuit")
	_ok(primer.find("\"id\": \"combate\"") >= 0 or primer.find('"id": "combate"') >= 0, "tópico combate em topicos()")
	_ok(primer.find("\"id\": \"votos\"") >= 0 or primer.find('"id": "votos"') >= 0, "tópico votos em topicos()")
	_ok(primer.find("lista_topicos") >= 0, "abrir_menu_guia aceita lista_topicos")
	_ok(primer.find("Perfect Dodge") >= 0, "combate menciona Perfect Dodge")
	_ok(primer.find("tradeoff") >= 0, "votos menciona tradeoff HUD")
