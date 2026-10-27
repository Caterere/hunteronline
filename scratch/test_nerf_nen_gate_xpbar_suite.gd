extends Node
var _ok := 0
var _fail := 0

func _ready() -> void:
	print("=== NERF / NEN GATE / XP BAR / ZOOM 1.75 ===")
	_zoom()
	_aura_curve()
	_damage()
	_nen_gate()
	_xp_bar()
	_exam_order_notes()
	print("Resultado: %d/%d | falhas %d" % [_ok, _ok+_fail, _fail])
	await get_tree().process_frame
	get_tree().quit(0 if _fail == 0 else 1)

func _assert(c: bool, msg: String) -> void:
	if c: _ok += 1; print("  ✅ ", msg)
	else: _fail += 1; print("  ❌ ", msg)

func _zoom() -> void:
	var src := FileAccess.get_file_as_string("res://entities/Player/Player.gd")
	_assert("1.75" in src, "zoom 1.75 no Player.gd")
	var tscn := FileAccess.get_file_as_string("res://entities/Player/Player.tscn")
	_assert("Vector2(1.75, 1.75)" in tscn, "Player.tscn zoom 1.75")

func _aura_curve() -> void:
	_assert(is_equal_approx(float(ProgressionConfig.STAT_EXPONENTS["aura_max"]), 2.05), "aura exponent 2.05")
	var a9 := ProgressionConfig.calcular_stat_base("aura_max", 9)
	_assert(a9 < 500.0, "aura lv9 < 500 (got %.0f)" % a9)
	var a1 := ProgressionConfig.calcular_stat_base("aura_max", 1)
	_assert(a1 <= 50.0, "aura lv1 base baixa")
	_assert(int(ProgressionConfig.SAGA_LEVEL_RANGES[1].y) <= 12, "soft-max exame <= 12")

func _damage() -> void:
	_assert(is_equal_approx(float(ProgressionConfig.BASE_STATS["forca"]), 4.0), "forca base 4")
	var dmg := CombatEngine.calcular_dano({"forca": 4.0, "dano_base": 2.0}, {"defesa": 2.0})
	_assert(dmg <= 8, "dano early fraco (got %d)" % dmg)
	var ce := FileAccess.get_file_as_string("res://autoload/CombatEngine.gd")
	_assert("var dano_base: float = 2.0" in ce, "dano_base 2")

func _nen_gate() -> void:
	var wing := FileAccess.get_file_as_string("res://entities/npc/wing/Wing.gd")
	_assert("arco_atual < 3" in wing, "Wing não desperta Nen no Lobby pré-Arena")
	var lobby := FileAccess.get_file_as_string("res://scripts/missions/MissionObjectiveResolver.gd")
	_assert("arco_atual >= 3" in lobby and "Desperte Nen com Mestre Wing" in lobby, "GPS Wing só arco 3+")
	_assert("Vá ao Exame" in lobby or "Guia / Portão" in lobby, "Lobby aponta Exame sem Wing")
	var exame := FileAccess.get_file_as_string("res://world/maps/ExameMaratonaMap.gd")
	_assert("requer_gyo = false" in exame, "alçapão/vela sem Gyo obrigatório")
	_assert('"hatsu_moments": []' in exame, "sem HatsuMoment no Exame")
	var zetsu := FileAccess.get_file_as_string("res://world/components/exploration/ZetsuSensorZone.gd")
	_assert("not PlayerData.despertou_nen" in zetsu, "Zetsu zone passa limpo pré-Nen")
	var cat := FileAccess.get_file_as_string("res://resource/quest/CanonQuestCatalog.gd")
	_assert("fator = 0.35" in cat, "XP exame freado 0.35")

func _xp_bar() -> void:
	var hud := FileAccess.get_file_as_string("res://ui/hud/PlayerHUD.gd")
	_assert("_criar_barra_xp_inferior" in hud, "barra XP inferior")
	_assert("XpFooterBar" in hud, "XpFooterBar nome")
	_assert("falta" in hud, "label mostra XP que falta")
	_assert('"XP"' in hud, "ícone XP no card")

func _exam_order_notes() -> void:
	# Ordem manga: túnel→pantanal→gourmet→dirigível→trick→zevil — já no catálogo
	var cat := FileAccess.get_file_as_string("res://resource/quest/CanonQuestCatalog.gd")
	var i_tunel := cat.find("Maratona dos 80km")
	var i_pant := cat.find("Pantanal Numere")
	var i_gourmet := cat.find("Floresta Biska")
	var i_dir := cat.find("Viagem Noturna no Dirigível")
	var i_trick := cat.find("Trick Tower")
	var i_zevil := cat.find("Ilha Zevil")
	_assert(
		i_tunel >= 0 and i_pant > i_tunel and i_gourmet > i_pant and i_dir > i_gourmet and i_trick > i_dir and i_zevil > i_trick,
		"ordem fases Exame alinhada ao manga"
	)
