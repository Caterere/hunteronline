extends Node2D

## Galeria visual: estilos + elementos + objetivos com FX.
## Salva PNG em /opt/cursor/artifacts/hatsu_visual_gallery.png

const OUT_PATH := "/opt/cursor/artifacts/hatsu_visual_gallery.png"

var _saved := false


func _ready() -> void:
	RenderingServer.set_default_clear_color(Color(0.06, 0.07, 0.1, 1.0))
	_build_gallery()
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().create_timer(0.35).timeout
	_capture()


func _build_gallery() -> void:
	var title := Label.new()
	title.text = "Hatsu Visual Resolver — estilos / elementos / objetivos"
	title.position = Vector2(12, 8)
	title.add_theme_font_size_override("font_size", 14)
	add_child(title)

	var estilos := [
		HatsuData.EstiloVisual.PURO_PULSANTE,
		HatsuData.EstiloVisual.CHAMAS_FOGO,
		HatsuData.EstiloVisual.RELAMPAGOS_ELETRICOS,
		HatsuData.EstiloVisual.LAMINA_CORTE,
		HatsuData.EstiloVisual.SHURIKEN_GIRATORIO,
		HatsuData.EstiloVisual.ANEIS_IMPACTO,
		HatsuData.EstiloVisual.NEVOA_SOMBRIAS,
		HatsuData.EstiloVisual.DRAGAO_SERPENTE,
	]
	var nomes_estilo := ["Puro", "Chamas", "Raio", "Lamina", "Shuriken", "Aneis", "Nevoa", "Dragao"]
	for i in range(estilos.size()):
		var h := HatsuData.new()
		h.estilo_visual = estilos[i]
		h.elemento = HatsuData.Elemento.NEN_PURO
		h.forma = HatsuData.Forma.PROJETIL
		h.objetivo = HatsuData.ObjetivoPrincipal.DANO
		var vp := HatsuVisualResolver.build_for_hatsu(h)
		add_child(_make_cell(vp, nomes_estilo[i], Vector2(40 + i * 90, 70)))

	var elementos := [
		HatsuData.Elemento.FOGO,
		HatsuData.Elemento.ELETRICIDADE,
		HatsuData.Elemento.GELO,
		HatsuData.Elemento.VENENO,
		HatsuData.Elemento.SOMBRA,
		HatsuData.Elemento.LUZ,
		HatsuData.Elemento.SOM,
	]
	var nomes_el := ["Fogo", "Elec", "Gelo", "Veneno", "Sombra", "Luz", "Som"]
	for i in range(elementos.size()):
		var h := HatsuData.new()
		h.elemento = elementos[i]
		h.estilo_visual = HatsuVisualResolver.suggest_estilo(elementos[i])
		h.forma = HatsuData.Forma.PROJETIL
		h.objetivo = HatsuData.ObjetivoPrincipal.DANO
		var vp := HatsuVisualResolver.build_for_hatsu(h)
		var pos := Vector2(40 + i * 100, 170)
		add_child(_make_cell(vp, nomes_el[i], pos))
		HatsuVisual.spawn_cast_effect(pos + Vector2(0, 28), vp, self)

	var objetivos := [
		HatsuData.ObjetivoPrincipal.DANO,
		HatsuData.ObjetivoPrincipal.CURA,
		HatsuData.ObjetivoPrincipal.CONTROLE,
		HatsuData.ObjetivoPrincipal.DEFESA,
		HatsuData.ObjetivoPrincipal.MOBILIDADE,
	]
	var nomes_obj := ["Dano", "Cura", "Controle", "Defesa", "Mobilidade"]
	for i in range(objetivos.size()):
		var h := HatsuData.new()
		h.objetivo = objetivos[i]
		h.estilo_visual = HatsuData.EstiloVisual.PURO_PULSANTE
		h.elemento = HatsuData.Elemento.NEN_PURO
		h.forma = HatsuData.Forma.TOQUE
		var vp := HatsuVisualResolver.build_for_hatsu(h)
		var pos := Vector2(40 + i * 110, 280)
		add_child(_make_cell(vp, nomes_obj[i], pos))
		HatsuVisual.spawn_impact_effect(pos + Vector2(0, 28), vp, self)

	var legend := Label.new()
	legend.position = Vector2(12, 360)
	legend.add_theme_font_size_override("font_size", 11)
	legend.text = "Linha1=estilos  Linha2=elementos(+cast)  Linha3=objetivos(+impacto)"
	add_child(legend)


func _make_cell(vp: VisualProfile, label_text: String, pos: Vector2) -> Node2D:
	var root := Node2D.new()
	root.position = pos
	var visual := HatsuVisual.new()
	visual.setup(vp)
	root.add_child(visual)
	var lbl := Label.new()
	lbl.text = label_text
	lbl.position = Vector2(-20, 22)
	lbl.add_theme_font_size_override("font_size", 10)
	lbl.modulate = Color(0.85, 0.9, 1.0)
	root.add_child(lbl)
	return root


func _capture() -> void:
	if _saved:
		return
	_saved = true
	var img: Image = get_viewport().get_texture().get_image()
	DirAccess.make_dir_recursive_absolute("/opt/cursor/artifacts")
	var err := img.save_png(OUT_PATH)
	print("Gallery saved to ", OUT_PATH, " err=", err)
	await get_tree().create_timer(0.1).timeout
	get_tree().quit(0 if err == OK else 1)
