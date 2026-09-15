extends SceneTree
## Suite: Hatsu charge/explain + feel por tipo Nen
## Run: godot --headless -s scratch/test_hatsu_charge_explain_suite.gd

var _passed := 0
var _failed := 0


func _init() -> void:
	print("=== Hatsu Charge / Explain / Feel-por-tipo Suite ===")
	_check_explain()
	_check_feel_modes()
	_check_charge_math()
	_check_factory()
	_check_wiring()
	_check_tutorials()
	print("=== RESULT: %d passed, %d failed ===" % [_passed, _failed])
	quit(0 if _failed == 0 else 1)


func _assert(cond: bool, label: String) -> void:
	if cond:
		_passed += 1
		print("  OK  ", label)
	else:
		_failed += 1
		print("  FAIL", label)


func _read(path: String) -> String:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return ""
	return f.get_as_text()


func _check_explain() -> void:
	print("-- Explain --")
	var h := HatsuData.new()
	h.nome = "Pedra Teste"
	h.categoria = HatsuData.Categoria.INTENSIFICACAO
	h.objetivo = HatsuData.ObjetivoPrincipal.DANO
	h.forma = HatsuData.Forma.TOQUE
	var d := HatsuExplainKit.garantir_descricao(h)
	_assert(not d.is_empty(), "gera descricao")
	_assert("Intensificação" in d or "aprimoramento" in d.to_lower() or "poder" in d.to_lower(), "menciona intensificacao/poder")
	_assert(h.descricao == d, "persiste em descricao")

	var he := HatsuData.new()
	he.nome = "Disparo"
	he.categoria = HatsuData.Categoria.EMISSAO
	he.objetivo = HatsuData.ObjetivoPrincipal.DANO
	he.forma = HatsuData.Forma.PROJETIL
	var de := HatsuExplainKit.garantir_descricao(he)
	_assert("alcance" in de.to_lower() or "mirar" in de.to_lower() or "Emissão" in de, "emissao explica mira/alcance")

	var ht := HatsuData.new()
	ht.nome = "Godspeed Lite"
	ht.categoria = HatsuData.Categoria.TRANSFORMACAO
	ht.objetivo = HatsuData.ObjetivoPrincipal.SUPORTE
	ht.forma = HatsuData.Forma.PESSOAL
	ht.duracao = 6.0
	var dt := HatsuExplainKit.garantir_descricao(ht)
	_assert("duração" in dt.to_lower() or "Transformação" in dt, "transformacao explica duracao")


func _check_feel_modes() -> void:
	print("-- Feel modes --")
	var cases := [
		[HatsuData.Categoria.INTENSIFICACAO, HatsuData.ObjetivoPrincipal.DANO, HatsuData.Forma.TOQUE, HatsuData.FeelMode.POWER, "PWR"],
		[HatsuData.Categoria.EMISSAO, HatsuData.ObjetivoPrincipal.DANO, HatsuData.Forma.PROJETIL, HatsuData.FeelMode.RANGE_AIM, "ALC"],
		[HatsuData.Categoria.TRANSFORMACAO, HatsuData.ObjetivoPrincipal.SUPORTE, HatsuData.Forma.PESSOAL, HatsuData.FeelMode.DURATION, "DUR"],
		[HatsuData.Categoria.CONJURACAO, HatsuData.ObjetivoPrincipal.DANO, HatsuData.Forma.AREA, HatsuData.FeelMode.MATERIALIZE, "MAT"],
		[HatsuData.Categoria.MANIPULACAO, HatsuData.ObjetivoPrincipal.CONTROLE, HatsuData.Forma.ZONA, HatsuData.FeelMode.CONTROL, "CTRL"],
		[HatsuData.Categoria.ESPECIALIZACAO, HatsuData.ObjetivoPrincipal.SUPORTE, HatsuData.Forma.PESSOAL, HatsuData.FeelMode.RISK, "RISK"],
	]
	for c in cases:
		var h := HatsuData.new()
		h.categoria = c[0]
		h.objetivo = c[1]
		h.forma = c[2]
		_assert(h.obter_feel_modo() == c[3], "modo %s" % str(c[4]))
		_assert(h.eh_canalizavel_feel(), "canalizavel %s" % str(c[4]))
		_assert(h.obter_rotulo_feel() == c[4], "rotulo %s" % str(c[4]))
		var m0 := h.obter_multiplicador_feel(0.0)
		var m1 := h.obter_multiplicador_feel(1.0)
		_assert(m1 > m0, "feel escala %s (%.2f→%.2f)" % [str(c[4]), m0, m1])

	var h_def := HatsuData.new()
	h_def.categoria = HatsuData.Categoria.INTENSIFICACAO
	h_def.objetivo = HatsuData.ObjetivoPrincipal.DEFESA
	_assert(not h_def.eh_canalizavel_feel(), "intensificacao defesa nao canalizavel")
	_assert(h_def.obter_feel_modo() == HatsuData.FeelMode.NONE, "defesa = NONE")

	var h_risk := HatsuData.new()
	h_risk.categoria = HatsuData.Categoria.ESPECIALIZACAO
	h_risk.objetivo = HatsuData.ObjetivoPrincipal.DANO
	_assert(h_risk.obter_custo_feel_mult(1.0) > h_risk.obter_custo_feel_mult(0.0), "risk escala aura")


func _check_charge_math() -> void:
	print("-- Charge math --")
	var h := HatsuData.new()
	h.categoria = HatsuData.Categoria.INTENSIFICACAO
	h.objetivo = HatsuData.ObjetivoPrincipal.DANO
	_assert(h.eh_carregavel_aprimoramento(), "intensificacao carregavel")
	_assert(h.eh_canalizavel_feel(), "intensificacao canalizavel")

	h.categoria = HatsuData.Categoria.EMISSAO
	_assert(not h.eh_carregavel_aprimoramento(), "emissao nao aprimoramento")
	_assert(h.eh_canalizavel_feel(), "emissao canalizavel")
	_assert(h.obter_feel_modo() == HatsuData.FeelMode.RANGE_AIM, "emissao = RANGE_AIM")

	h.categoria = HatsuData.Categoria.INTENSIFICACAO
	var m0 := h.obter_multiplicador_carga(0.0)
	var m1 := h.obter_multiplicador_carga(1.0)
	_assert(m0 < 0.5, "carga 0%% fraca (%.2f)" % m0)
	_assert(m1 > 1.4, "carga 100%% forte (%.2f)" % m1)
	_assert(m1 > m0, "carga escala")


func _check_factory() -> void:
	print("-- Factory --")
	var hm = Engine.get_main_loop().root.get_node_or_null("HatsuManager")
	if hm != null and hm.has_method("criar_hatsu"):
		var forged: HatsuData = hm.criar_hatsu(
			"Teste Pedra", HatsuData.Categoria.INTENSIFICACAO, HatsuData.Forma.TOQUE, [],
			HatsuData.ObjetivoPrincipal.DANO
		)
		_assert(forged.activation_type == HatsuData.ActivationType.CHARGED, "factory CHARGED intens")
		_assert(forged.tempo_conjuracao_base >= 1.0, "tempo conjuracao >= 1s (%.2f)" % forged.tempo_conjuracao_base)
		_assert(not forged.descricao.is_empty(), "factory gera descricao")
		_assert(forged.eh_carregavel_aprimoramento(), "forjado carregavel")

		var fe: HatsuData = hm.criar_hatsu(
			"Teste Disparo", HatsuData.Categoria.EMISSAO, HatsuData.Forma.PROJETIL, [],
			HatsuData.ObjetivoPrincipal.DANO
		)
		_assert(fe.activation_type == HatsuData.ActivationType.CHARGED, "factory CHARGED emissao")
		_assert(fe.obter_feel_modo() == HatsuData.FeelMode.RANGE_AIM, "factory emissao RANGE_AIM")
		_assert("alcance" in fe.descricao.to_lower() or "mirar" in fe.descricao.to_lower() or "Emissão" in fe.descricao, "factory emissao desc")

		var ft: HatsuData = hm.criar_hatsu(
			"Teste Buff", HatsuData.Categoria.TRANSFORMACAO, HatsuData.Forma.PESSOAL, [],
			HatsuData.ObjetivoPrincipal.SUPORTE
		)
		_assert(ft.obter_feel_modo() == HatsuData.FeelMode.DURATION, "factory transform DURATION")
		_assert(ft.activation_type == HatsuData.ActivationType.CHARGED, "factory transform CHARGED suporte")
		_assert(ft.tempo_conjuracao_base >= 0.85, "factory transform tempo conj")
	else:
		var src := _read("res://autoload/HatsuManager.gd")
		_assert("activation_type = HatsuData.ActivationType.CHARGED" in src, "factory CHARGED (src)")
		_assert("FeelMode.RANGE_AIM" in src or "tempo_conjuracao_base = clampf" in src, "factory emissao/tempo (src)")
		_assert("HatsuExplainKit.garantir_descricao" in src, "factory gera descricao (src)")
		_assert("DURATION" in src or "duracao_buff" in src, "factory transform feel (src)")


func _check_wiring() -> void:
	print("-- Wiring --")
	var sys := _read("res://scripts/systems/HatsuSystem.gd")
	_assert("_iniciar_carga_hatsu" in sys, "iniciar carga")
	_assert("_liberar_carga_hatsu" in sys, "liberar carga")
	_assert("_executar_feel_canalizado" in sys, "executar feel canalizado")
	_assert("_atualizar_mira_feel" in sys, "mira emissao")
	_assert("hatsu_carga_atualizada" in sys, "signal carga")
	_assert("eh_canalizavel_feel" in sys, "input usa canalizavel")
	_assert("FeelMode.RANGE_AIM" in sys, "RANGE_AIM no system")
	_assert("FeelMode.DURATION" in sys, "DURATION no system")
	var hud := _read("res://ui/hud/PlayerHUD.gd")
	_assert("_on_hatsu_carga" in hud, "HUD charge handler")
	_assert("obter_rotulo_feel" in hud, "HUD rotulo por tipo")
	var eq := _read("res://ui/Hatsu/HatsuEquipUI.gd")
	_assert("HatsuExplainKit.garantir_descricao" in eq, "equip mostra explicacao")
	_assert("obter_dica_feel" in eq, "equip dica feel")
	var cr := _read("res://ui/Hatsu/HatsuCreationUI.gd")
	_assert("hatsu_criacao" in cr or "hatsu_explicacao" in cr, "creation tutorials")
	var bis := _read("res://entities/npc/biscuit/Biscuit.gd")
	_assert("hatsu_desbloqueio" in bis, "biscuit tutorial")
	var data := _read("res://resource/hatsu/HatsuData.gd")
	_assert("enum FeelMode" in data, "FeelMode enum")
	_assert("obter_feel_modo" in data, "obter_feel_modo")


func _check_tutorials() -> void:
	print("-- Tutorials --")
	var tm := _read("res://autoload/TutorialManager.gd")
	_assert('"hatsu_conceito"' in tm, "guia hatsu_conceito")
	_assert('"hatsu_aprimoramento_carga"' in tm, "guia carga")
	_assert('"hatsu_feel_por_tipo"' in tm, "guia feel por tipo")
	_assert('"categoria": "Hatsu"' in tm, "categoria Hatsu no guia")
	_assert("hatsu_feel_emissao" in tm, "contextual emissao")
	_assert("hatsu_feel_transformacao" in tm, "contextual transformacao")
	_assert("once_map" in tm, "once-gate")
	var kit := _read("res://scripts/systems/hatsu/HatsuExplainKit.gd")
	_assert("hatsu_feel_por_tipo" in kit, "explain kit artigo feel")
