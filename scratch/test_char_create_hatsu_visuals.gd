extends SceneTree

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var failed := 0
	print("=== TEST: Character Create + Hatsu Visuals ===")

	var pd = root.get_node_or_null("PlayerData")
	if pd == null:
		push_error("PlayerData autoload missing"); quit(1); return

	pd.character_colors["cabelo"] = Color(0.1, 0.8, 0.2)
	pd.character_colors["roupa"] = Color(0.2, 0.3, 0.9)
	pd.character_colors["olhos"] = Color(0.9, 0.1, 0.2)
	pd.character_colors["hair_id"] = "hair_kurapika_01"
	if str(pd.character_colors.get("hair_id")) != "hair_kurapika_01":
		push_error("hair_id persist fail"); failed += 1
	else:
		print("OK PlayerData hair_id/olhos")

	var db = load("res://entities/character_creator/CharacterAssetDatabase.gd")
	var styles = db.HAIR_STYLES
	if styles.size() < 5:
		push_error("HAIR_STYLES too small"); failed += 1
	else:
		print("OK HAIR_STYLES count=", styles.size())

	var overlay_scr = load("res://entities/character_creator/HairStyleOverlay.gd")
	var ov = overlay_scr.new()
	ov.configurar("hair_gon_01", Color.BLACK, Color.BLUE, true)
	print("OK HairStyleOverlay")

	var catalog = load("res://resource/hatsu/CanonHatsuVisualCatalog.gd")
	var ids := [
		"gon_jajanken_pedra", "gon_jajanken_tesoura", "gon_jajanken_papel",
		"killua_kanmuru", "killua_narukami", "kurapika_chain_jail",
		"hisoka_bungee_gum", "feitan_pain_packer", "illumi_needle_people"
	]
	for id in ids:
		var vp = catalog.obter_perfil(id)
		if vp == null:
			push_error("Missing visual for " + id); failed += 1
		else:
			print("OK visual ", id, " shape=", vp.shape)

	var hm = root.get_node_or_null("HatsuManager")
	if hm == null:
		push_error("HatsuManager missing"); failed += 1
	else:
		var h = hm.obter_hatsu_canonico("gon_jajanken_pedra")
		if h == null or h.visual_profile == null:
			push_error("HatsuManager did not attach visual_profile"); failed += 1
		else:
			print("OK HatsuManager visual_profile shape=", h.visual_profile.shape)

	var shader = load("res://assets/shaders/character_color_customizer.gdshader")
	if shader == null:
		push_error("shader missing"); failed += 1
	else:
		print("OK shader loaded")

	var ui_scr = load("res://ui/CharacterSelection/CharacterSelectionUI.gd")
	if ui_scr == null:
		push_error("CharacterSelectionUI failed to load"); failed += 1
	else:
		print("OK CharacterSelectionUI script")

	print("=== RESULT failed=", failed, " ===")
	quit(1 if failed > 0 else 0)
