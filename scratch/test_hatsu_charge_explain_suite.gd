extends SceneTree

var _ok := 0
var _fail := 0


func _initialize() -> void:
	print("🚀 SUÍTE HATSU CHARGE + EXPLAIN")
	_check_files()
	_check_explain()
	_check_charge_data()
	_check_wiring()
	_check_tutorials()
	print("============================================================")
	print("✅ PASSED: %d | ❌ FAILED: %d" % [_ok, _fail])
	quit(0 if _fail == 0 else 1)


func _assert(c: bool, msg: String) -> void:
	if c:
		_ok += 1
		print("  ✓ ", msg)
	else:
		_fail += 1
		print("  ✗ ", msg)


func _read(path: String) -> String:
	var f := FileAccess.open(path, FileAccess.READ)
	return f.get_as_text() if f else ""


func _check_files() -> void:
	print("-- Files --")
	_assert(ResourceLoader.exists("res://scripts/systems/hatsu/HatsuExplainKit.gd"), "ExplainKit")
	_assert("class_name HatsuExplainKit" in _read("res://scripts/systems/hatsu/HatsuExplainKit.gd"), "class_name")
	_assert("descricao" in _read("res://resource/hatsu/HatsuData.gd"), "HatsuData.descricao")
	_assert("eh_carregavel_aprimoramento" in _read("res://resource/hatsu/HatsuData.gd"), "eh_carregavel")
	_assert("obter_multiplicador_carga" in _read("res://resource/hatsu/HatsuData.gd"), "mult carga")


func _check_explain() -> void:
	print("-- Explain --")
	var h := HatsuData.new()
	h.nome = "Punho de Pedra"
	h.categoria = HatsuData.Categoria.INTENSIFICACAO
	h.objetivo = HatsuData.ObjetivoPrincipal.DANO
	h.forma = HatsuData.Forma.TOQUE
	h.poder_base = 50.0
	h.tempo_conjuracao_base = 1.5
	h.activation_type = HatsuData.ActivationType.CHARGED
	var txt := HatsuExplainKit.garantir_descricao(h)
	_assert(not txt.is_empty(), "gera explicacao")
	_assert("Intensificação" in txt or "Intensific" in txt or "aprimor" in txt.to_lower() or "canaliz" in txt.to_lower(), "fala de aprimoramento/carga")
	_assert(not h.descricao.is_empty(), "descricao persistida no resource")
	var arts: Dictionary = HatsuExplainKit.artigos_guia()
	_assert(arts.has("hatsu_conceito"), "artigo conceito")
	_assert(arts.has("hatsu_aprimoramento_carga"), "artigo carga")


func _check_charge_data() -> void:
	print("-- Charge data --")
	var h := HatsuData.new()
	h.categoria = HatsuData.Categoria.INTENSIFICACAO
	h.objetivo = HatsuData.ObjetivoPrincipal.DANO
	_assert(h.eh_carregavel_aprimoramento(), "intensificacao dano carregavel")
	h.objetivo = HatsuData.ObjetivoPrincipal.CURA
	_assert(not h.eh_carregavel_aprimoramento(), "cura nao carregavel")
	h.objetivo = HatsuData.ObjetivoPrincipal.DANO
	h.categoria = HatsuData.Categoria.EMISSAO
	_assert(not h.eh_carregavel_aprimoramento(), "emissao nao carregavel")

	h.categoria = HatsuData.Categoria.INTENSIFICACAO
	var m0 := h.obter_multiplicador_carga(0.0)
	var m1 := h.obter_multiplicador_carga(1.0)
	_assert(m0 < 0.5, "carga 0%% fraca (%.2f)" % m0)
	_assert(m1 > 1.4, "carga 100%% forte (%.2f)" % m1)
	_assert(m1 > m0, "carga escala")

	# Factory marca CHARGED + tempo longo
	var forged := HatsuManager.criar_hatsu(
		"Teste Pedra", HatsuData.Categoria.INTENSIFICACAO, HatsuData.Forma.TOQUE, [],
		HatsuData.ObjetivoPrincipal.DANO
	)
	_assert(forged.activation_type == HatsuData.ActivationType.CHARGED, "factory CHARGED")
	_assert(forged.tempo_conjuracao_base >= 1.0, "tempo conjuracao >= 1s (%.2f)" % forged.tempo_conjuracao_base)
	_assert(not forged.descricao.is_empty(), "factory gera descricao")
	_assert(forged.eh_carregavel_aprimoramento(), "forjado carregavel")


func _check_wiring() -> void:
	print("-- Wiring --")
	var sys := _read("res://scripts/systems/HatsuSystem.gd")
	_assert("_iniciar_carga_hatsu" in sys, "iniciar carga")
	_assert("_liberar_carga_hatsu" in sys, "liberar carga")
	_assert("hatsu_carga_atualizada" in sys, "signal carga")
	_assert("eh_carregavel_aprimoramento" in sys, "input usa carregavel")
	var hud := _read("res://ui/hud/PlayerHUD.gd")
	_assert("_on_hatsu_carga" in hud, "HUD charge handler")
	_assert("PWR" in hud, "HUD mostra PWR%")
	var eq := _read("res://ui/Hatsu/HatsuEquipUI.gd")
	_assert("HatsuExplainKit.garantir_descricao" in eq, "equip mostra explicacao")
	var cr := _read("res://ui/Hatsu/HatsuCreationUI.gd")
	_assert("hatsu_criacao" in cr or "hatsu_explicacao" in cr, "creation tutorials")
	var bis := _read("res://entities/npc/biscuit/Biscuit.gd")
	_assert("hatsu_desbloqueio" in bis, "biscuit tutorial")


func _check_tutorials() -> void:
	print("-- Tutorials --")
	var tm := _read("res://autoload/TutorialManager.gd")
	_assert('"hatsu_conceito"' in tm, "guia hatsu_conceito")
	_assert('"hatsu_aprimoramento_carga"' in tm, "guia carga")
	_assert('"categoria": "Hatsu"' in tm, "categoria Hatsu no guia")
	_assert("hatsu_aprimoramento" in tm, "contextual aprimoramento")
	_assert("once_map" in tm, "once-gate")
