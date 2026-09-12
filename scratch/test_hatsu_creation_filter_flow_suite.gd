extends Node

# ============================================================
# SUÍTE: filtros por categoria + identidade travada do preset
# ============================================================

var passados: int = 0
var totais: int = 0


func _ready() -> void:
	print("\n============================================================")
	print("🧪 HATSU CREATION FILTER FLOW SUITE")
	print("============================================================\n")

	_run("1. Intensificação não oferece emissão/homing no catálogo", _t_intensificacao_filter)
	_run("2. Emissão não oferece cura como objetivo", _t_emissao_filter)
	_run("3. Preset trava identidade (≠ CRIAR_DO_ZERO)", _t_preset_lock)
	_run("4. Palma Curativa mantém cura/toque/aliado", _t_palma_identity)
	_run("5. garantir_selecao troca valor inválido", _t_garantir)
	_run("6. UI source: sem inspiração ampla + CenterContainer", _t_ui_source)

	print("\n============================================================")
	print("RESULTADO: %d / %d" % [passados, totais])
	print("============================================================\n")
	get_tree().quit(0 if passados == totais else 1)


func _run(nome: String, fn: Callable) -> void:
	totais += 1
	print("▶ ", nome)
	var ok: bool = fn.call()
	if ok:
		passados += 1
		print("  ✅ PASSOU\n")
	else:
		print("  ❌ FALHOU\n")


func _t_intensificacao_filter() -> bool:
	var objs: Array = HatsuCreationPolish.objetivos_permitidos(int(HatsuData.Categoria.INTENSIFICACAO))
	var formas: Array = HatsuCreationPolish.formas_permitidas(int(HatsuData.Categoria.INTENSIFICACAO))
	var efs: Array = HatsuCreationPolish.efeitos_secundarios_permitidos(int(HatsuData.Categoria.INTENSIFICACAO))
	print("  objs=", objs, " formas=", formas, " efs=", efs)
	if int(HatsuData.ObjetivoPrincipal.CURA) not in objs:
		return false
	if int(HatsuData.ObjetivoPrincipal.MOBILIDADE) in objs:
		print("  mobilidade não deveria estar em intensificação v1")
		return false
	if int(HatsuData.Forma.PROJETIL) in formas:
		print("  projétil não deveria estar em intensificação v1")
		return false
	if int(HatsuComponentLibrary.EffectType.TRACKING) in efs:
		print("  tracking/homing não deveria estar em intensificação")
		return false
	return int(HatsuData.Forma.TOQUE) in formas


func _t_emissao_filter() -> bool:
	var objs: Array = HatsuCreationPolish.objetivos_permitidos(int(HatsuData.Categoria.EMISSAO))
	var formas: Array = HatsuCreationPolish.formas_permitidas(int(HatsuData.Categoria.EMISSAO))
	print("  emissao objs=", objs, " formas=", formas)
	if int(HatsuData.ObjetivoPrincipal.CURA) in objs:
		return false
	return int(HatsuData.Forma.PROJETIL) in formas and int(HatsuData.Forma.TOQUE) not in formas


func _t_preset_lock() -> bool:
	var free_ok := not HatsuCreationPolish.preset_trava_identidade(int(HatsuPresetLibrary.PresetId.CRIAR_DO_ZERO))
	var lock_ok := HatsuCreationPolish.preset_trava_identidade(int(HatsuPresetLibrary.PresetId.PALMA_CURATIVA))
	print("  free=", free_ok, " palma_lock=", lock_ok)
	return free_ok and lock_ok


func _t_palma_identity() -> bool:
	var p: Dictionary = HatsuPresetLibrary.obter_preset(HatsuPresetLibrary.PresetId.PALMA_CURATIVA)
	print("  palma cat=", p.get("categoria"), " obj=", p.get("objetivo"), " forma=", p.get("forma"), " alvo=", p.get("alvo"))
	if p.get("categoria") != HatsuData.Categoria.INTENSIFICACAO:
		return false
	if p.get("objetivo") != HatsuData.ObjetivoPrincipal.CURA:
		return false
	if p.get("forma") != HatsuData.Forma.TOQUE:
		return false
	var alvo = p.get("alvo")
	return alvo == HatsuData.Alvo.ALIADO or alvo == HatsuData.Alvo.PROPRIO_USUARIO


func _t_garantir() -> bool:
	var permitidos: Array = [0, 1, 2]
	var g := HatsuCreationPolish.garantir_selecao_permitida(5, permitidos, 0)
	var keep := HatsuCreationPolish.garantir_selecao_permitida(1, permitidos, 0)
	print("  invalid->", g, " keep=", keep)
	return g == 0 and keep == 1


func _t_ui_source() -> bool:
	var src := FileAccess.get_file_as_string("res://ui/Hatsu/HatsuCreationUI.gd")
	if "Inspiração ampla" in src or "exceto_categoria" in src:
		print("  UI ainda lista inspiração ampla")
		return false
	if "CenterContainer" not in src:
		print("  UI sem CenterContainer")
		return false
	if "preset_trava_identidade" not in src or "filtrar_catalogo" not in src:
		print("  UI sem hooks de filtro")
		return false
	print("  filtros + centro OK")
	return true
