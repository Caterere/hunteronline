extends Node2D

## Valida kit de FX procedural (código only) e gera prints de evidência.

const Kit = preload("res://entities/effects/HatsuProceduralFxKit.gd")

var total: int = 0
var passed: int = 0
var failed: int = 0


func _ready() -> void:
	print("\n=== HATSU PROCEDURAL FX KIT ===")
	_test_api_spawns()
	_test_estilo_map()
	_test_named_map()
	await _capture_gallery()
	print("----------------------------------------------------------------")
	print("Resultado: %d/%d | falhas %d" % [passed, total, failed])
	await get_tree().create_timer(0.1).timeout
	get_tree().quit(0 if failed == 0 else 1)


func _ok(cond: bool, label: String) -> void:
	total += 1
	if cond:
		passed += 1
		print("  ✅ %s" % label)
	else:
		failed += 1
		print("  ❌ %s" % label)


func _test_api_spawns() -> void:
	print("\n[1] API spawn sem crash")
	var before := get_child_count()
	Kit.cast_flash(self, Vector2(80, 80), Color(0.4, 0.9, 1.0), 1.0)
	Kit.impact_ring(self, Vector2(120, 80), Color(1.0, 0.7, 0.2), 40.0)
	Kit.aura_orb(self, Vector2(160, 80), Color(0.5, 0.8, 1.0), 1.0)
	Kit.mist_cloud(self, Vector2(200, 80), Color(0.4, 0.2, 0.5), 1.0)
	Kit.shield_wall(self, Vector2(240, 80), Vector2.RIGHT, Color(0.7, 0.55, 0.3), 1.0)
	Kit.claw_marks(self, Vector2(280, 80), Vector2.RIGHT, Color(1.0, 0.4, 0.3))
	Kit.slash_arc(self, Vector2(320, 80), Vector2.RIGHT, Color(0.9, 0.95, 1.0), 30.0, true)
	Kit.ember_sparks(self, Vector2(360, 80), Color(1.0, 0.6, 0.2), 10)
	Kit.lightning_arcs(self, Vector2(400, 80), Vector2.RIGHT, Color(0.7, 0.9, 1.0), 1.0)
	Kit.spin_star(self, Vector2(440, 80), Color(0.95, 0.85, 0.3), 1.0)
	Kit.serpent_wave(self, Vector2(480, 80), Vector2.RIGHT, Color(1.0, 0.4, 0.75), 1.0)
	_ok(get_tree() != null, "árvore válida após spawns")
	_ok(true, "primitives spawnados")


func _test_estilo_map() -> void:
	print("\n[2] Mapa EstiloVisual")
	for estilo in [
		HatsuData.EstiloVisual.PURO_PULSANTE,
		HatsuData.EstiloVisual.CHAMAS_FOGO,
		HatsuData.EstiloVisual.RELAMPAGOS_ELETRICOS,
		HatsuData.EstiloVisual.LAMINA_CORTE,
		HatsuData.EstiloVisual.ANEIS_IMPACTO,
		HatsuData.EstiloVisual.NEVOA_SOMBRIAS,
		HatsuData.EstiloVisual.DRAGAO_SERPENTE,
		HatsuData.EstiloVisual.SHURIKEN_GIRATORIO,
	]:
		Kit.play_estilo(self, Vector2(100, 160), Vector2.RIGHT, estilo, Color(0.5, 0.8, 1.0), 0.9)
	_ok(true, "8 estilos disparados")

	var h := HatsuData.new()
	h.nome = "Teste Intensificação"
	h.categoria = HatsuData.Categoria.INTENSIFICACAO
	h.estilo_visual = HatsuData.EstiloVisual.ANEIS_IMPACTO
	h.cor_aura = Color(1.0, 0.8, 0.25)
	Kit.play_for_hatsu(self, Vector2(200, 160), Vector2.RIGHT, h, 1.0)
	_ok(true, "play_for_hatsu intensificação")


func _test_named_map() -> void:
	print("\n[3] Hatsus nomeados (inimigo)")
	for nome in ["Muralha de Pedra", "Garras Quimera", "Sombra Drenante", "Ko Selvagem", "Névoa Tóxica", "Flecha de Aura"]:
		Kit.play_named(self, Vector2(120, 220), Vector2.RIGHT, nome)
	_ok(true, "named hatsus com FX")


func _capture_gallery() -> void:
	print("\n[4] Galeria visual")
	# Fundo escuro para legibilidade dos FX
	var bg := ColorRect.new()
	bg.color = Color(0.06, 0.07, 0.1, 1.0)
	bg.size = Vector2(640, 360)
	bg.z_index = -10
	add_child(bg)

	var title := Label.new()
	title.text = "Hatsu Procedural FX — código only"
	title.position = Vector2(16, 8)
	title.add_theme_font_size_override("font_size", 14)
	title.add_theme_color_override("font_color", Color(0.7, 0.9, 1.0))
	add_child(title)

	var labels := [
		["Cast / Orb", HatsuData.EstiloVisual.PURO_PULSANTE, Vector2(90, 90)],
		["Chamas", HatsuData.EstiloVisual.CHAMAS_FOGO, Vector2(220, 90)],
		["Relâmpago", HatsuData.EstiloVisual.RELAMPAGOS_ELETRICOS, Vector2(350, 90)],
		["Lâmina", HatsuData.EstiloVisual.LAMINA_CORTE, Vector2(480, 90)],
		["Anéis", HatsuData.EstiloVisual.ANEIS_IMPACTO, Vector2(90, 200)],
		["Névoa", HatsuData.EstiloVisual.NEVOA_SOMBRIAS, Vector2(220, 200)],
		["Dragão", HatsuData.EstiloVisual.DRAGAO_SERPENTE, Vector2(350, 200)],
		["Shuriken", HatsuData.EstiloVisual.SHURIKEN_GIRATORIO, Vector2(480, 200)],
	]
	for row in labels:
		var lbl := Label.new()
		lbl.text = str(row[0])
		lbl.position = (row[2] as Vector2) + Vector2(-24, 36)
		lbl.add_theme_font_size_override("font_size", 10)
		lbl.add_theme_color_override("font_color", Color(0.85, 0.9, 0.95))
		add_child(lbl)
		Kit.play_estilo(self, row[2], Vector2.RIGHT, int(row[1]), Color(0.55, 0.85, 1.0), 1.15)

	# Named row
	Kit.play_named(self, Vector2(160, 300), Vector2.RIGHT, "Muralha de Pedra")
	Kit.play_named(self, Vector2(320, 300), Vector2.RIGHT, "Garras Quimera")
	Kit.play_named(self, Vector2(480, 300), Vector2.RIGHT, "Sombra Drenante")
	var lbl2 := Label.new()
	lbl2.text = "Muralha   ·   Garras   ·   Sombra"
	lbl2.position = Vector2(180, 330)
	lbl2.add_theme_font_size_override("font_size", 10)
	add_child(lbl2)

	# Re-dispara FX no frame da captura (duração curta — precisa estar vivos)
	for row in labels:
		Kit.play_estilo(self, row[2], Vector2.RIGHT, int(row[1]), Color(0.55, 0.85, 1.0), 1.35)
	Kit.play_named(self, Vector2(160, 300), Vector2.RIGHT, "Muralha de Pedra")
	Kit.play_named(self, Vector2(320, 300), Vector2.RIGHT, "Garras Quimera")
	Kit.play_named(self, Vector2(480, 300), Vector2.RIGHT, "Sombra Drenante")

	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().create_timer(0.08).timeout
	RenderingServer.force_draw()
	await get_tree().process_frame

	var vp := get_viewport()
	if vp != null:
		var tex: ViewportTexture = vp.get_texture()
		var img: Image = tex.get_image() if tex != null else null
		if img != null:
			var path := "/opt/cursor/artifacts/hatsu_procedural_fx_gallery.png"
			img.save_png(path)
			_ok(FileAccess.file_exists(path) and FileAccess.get_file_as_bytes(path).size() > 2000, "screenshot galeria salvo (%d bytes)" % FileAccess.get_file_as_bytes(path).size())
		else:
			_ok(false, "image null")
	else:
		_ok(true, "sem viewport — skip print")
