extends SceneTree

## Valida HatsuVisualResolver: estilos/elementos/objetivos → shape+cor+FX coerentes.

func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var failed := 0
	print("=== TEST: HatsuVisualResolver matrix ===")

	var estilo_shape := {
		HatsuData.EstiloVisual.CHAMAS_FOGO: VisualProfile.VisualShape.AURA,
		HatsuData.EstiloVisual.RELAMPAGOS_ELETRICOS: VisualProfile.VisualShape.RAY,
		HatsuData.EstiloVisual.LAMINA_CORTE: VisualProfile.VisualShape.BLADE,
		HatsuData.EstiloVisual.SHURIKEN_GIRATORIO: VisualProfile.VisualShape.DISC,
		HatsuData.EstiloVisual.ANEIS_IMPACTO: VisualProfile.VisualShape.RING,
		HatsuData.EstiloVisual.NEVOA_SOMBRIAS: VisualProfile.VisualShape.SMOKE,
		HatsuData.EstiloVisual.DRAGAO_SERPENTE: VisualProfile.VisualShape.DRAGON,
	}
	for estilo in estilo_shape.keys():
		var h := HatsuData.new()
		h.estilo_visual = estilo
		h.forma = HatsuData.Forma.PROJETIL
		h.objetivo = HatsuData.ObjetivoPrincipal.DANO
		h.elemento = HatsuData.Elemento.NEN_PURO
		var vp := HatsuVisualResolver.build_for_hatsu(h)
		if int(vp.shape) != int(estilo_shape[estilo]):
			push_error("Estilo %d shape=%d expected=%d" % [estilo, vp.shape, estilo_shape[estilo]])
			failed += 1
		else:
			print("OK estilo ", estilo, " shape=", vp.shape, " cast=", vp.cast_effect, " hit=", vp.impact_effect)

	var seen_colors: Dictionary = {}
	for el in [
		HatsuData.Elemento.FOGO,
		HatsuData.Elemento.ELETRICIDADE,
		HatsuData.Elemento.GELO,
		HatsuData.Elemento.VENENO,
		HatsuData.Elemento.SOMBRA,
		HatsuData.Elemento.LUZ,
	]:
		var h2 := HatsuData.new()
		h2.elemento = el
		h2.estilo_visual = HatsuData.EstiloVisual.PURO_PULSANTE
		h2.forma = HatsuData.Forma.PROJETIL
		h2.objetivo = HatsuData.ObjetivoPrincipal.DANO
		var vp2 := HatsuVisualResolver.build_for_hatsu(h2)
		var key := "%.2f_%.2f_%.2f" % [vp2.primary_color.r, vp2.primary_color.g, vp2.primary_color.b]
		if seen_colors.has(key):
			push_error("Element color collision el=%d with %s" % [el, str(seen_colors[key])])
			failed += 1
		else:
			seen_colors[key] = el
			print("OK elemento ", el, " color=", key, " cast=", vp2.cast_effect, " hit=", vp2.impact_effect)

	var h_cura := HatsuData.new()
	h_cura.objetivo = HatsuData.ObjetivoPrincipal.CURA
	h_cura.estilo_visual = HatsuData.EstiloVisual.PURO_PULSANTE
	h_cura.elemento = HatsuData.Elemento.NEN_PURO
	h_cura.forma = HatsuData.Forma.TOQUE
	var vp_cura := HatsuVisualResolver.build_for_hatsu(h_cura)
	if vp_cura.cast_effect != "heal_pulse" or vp_cura.impact_effect != "heal_pulse":
		push_error("CURA FX cast=%s hit=%s" % [vp_cura.cast_effect, vp_cura.impact_effect])
		failed += 1
	else:
		print("OK CURA FX")

	var h_ctrl := HatsuData.new()
	h_ctrl.objetivo = HatsuData.ObjetivoPrincipal.CONTROLE
	h_ctrl.estilo_visual = HatsuData.EstiloVisual.PURO_PULSANTE
	h_ctrl.elemento = HatsuData.Elemento.NEN_PURO
	h_ctrl.forma = HatsuData.Forma.TOQUE
	var vp_ctrl := HatsuVisualResolver.build_for_hatsu(h_ctrl)
	if vp_ctrl.impact_effect != "bind_flash":
		push_error("CONTROLE hit=%s" % vp_ctrl.impact_effect)
		failed += 1
	else:
		print("OK CONTROLE bind_flash")

	var h_def := HatsuData.new()
	h_def.objetivo = HatsuData.ObjetivoPrincipal.DEFESA
	h_def.estilo_visual = HatsuData.EstiloVisual.PURO_PULSANTE
	h_def.elemento = HatsuData.Elemento.NEN_PURO
	var vp_def := HatsuVisualResolver.build_for_hatsu(h_def)
	if vp_def.cast_effect != "aura_flash" or vp_def.impact_effect != "shockwave":
		push_error("DEFESA FX cast=%s hit=%s" % [vp_def.cast_effect, vp_def.impact_effect])
		failed += 1
	else:
		print("OK DEFESA FX")

	var h_mob := HatsuData.new()
	h_mob.objetivo = HatsuData.ObjetivoPrincipal.MOBILIDADE
	h_mob.estilo_visual = HatsuData.EstiloVisual.PURO_PULSANTE
	h_mob.elemento = HatsuData.Elemento.NEN_PURO
	var vp_mob := HatsuVisualResolver.build_for_hatsu(h_mob)
	if vp_mob.cast_effect != "spark_burst":
		push_error("MOBILIDADE cast=%s" % vp_mob.cast_effect)
		failed += 1
	else:
		print("OK MOBILIDADE spark_burst")

	var hg := HatsuData.new()
	hg.elemento = HatsuData.Elemento.GELO
	hg.objetivo = HatsuData.ObjetivoPrincipal.DANO
	hg.estilo_visual = HatsuData.EstiloVisual.PURO_PULSANTE
	hg.forma = HatsuData.Forma.PROJETIL
	var vpg := HatsuVisualResolver.build_for_hatsu(hg)
	if vpg.cast_effect != "ice_flash" or vpg.impact_effect != "ice_shatter":
		push_error("GELO FX cast=%s hit=%s" % [vpg.cast_effect, vpg.impact_effect])
		failed += 1
	else:
		print("OK gelo FX")

	var hf := HatsuData.new()
	hf.estilo_visual = HatsuData.EstiloVisual.PURO_PULSANTE
	hf.forma = HatsuData.Forma.TOQUE
	hf.objetivo = HatsuData.ObjetivoPrincipal.DANO
	var vpf := HatsuVisualResolver.build_for_hatsu(hf)
	if int(vpf.shape) != VisualProfile.VisualShape.FIST:
		push_error("TOQUE+DANO shape=%d expected FIST" % vpf.shape)
		failed += 1
	else:
		print("OK TOQUE+DANO → FIST")

	if HatsuVisualResolver.suggest_estilo(HatsuData.Elemento.FOGO) != HatsuData.EstiloVisual.CHAMAS_FOGO:
		push_error("suggest FOGO failed")
		failed += 1
	else:
		print("OK suggest FOGO→CHAMAS")
	if HatsuVisualResolver.suggest_estilo(HatsuData.Elemento.ELETRICIDADE) != HatsuData.EstiloVisual.RELAMPAGOS_ELETRICOS:
		push_error("suggest ELEC failed")
		failed += 1
	else:
		print("OK suggest ELEC→RELAMPAGOS")

	var ha := HatsuData.new()
	ha.estilo_visual = HatsuData.EstiloVisual.CHAMAS_FOGO
	ha.elemento = HatsuData.Elemento.FOGO
	ha.forma = HatsuData.Forma.PROJETIL
	ha.objetivo = HatsuData.ObjetivoPrincipal.DANO
	HatsuVisualResolver.apply_to_hatsu(ha)
	if ha.visual_profile == null:
		push_error("apply_to_hatsu null")
		failed += 1
	else:
		var root_n := Node2D.new()
		root.add_child(root_n)
		var cast_fx = HatsuVisual.spawn_cast_effect(Vector2.ZERO, ha.visual_profile, root_n)
		var hit_fx = HatsuVisual.spawn_impact_effect(Vector2(10, 10), ha.visual_profile, root_n)
		if cast_fx == null or hit_fx == null:
			push_error("FX spawn failed")
			failed += 1
		else:
			print("OK apply+spawn cast=", ha.visual_profile.cast_effect, " hit=", ha.visual_profile.impact_effect)
		root_n.queue_free()

	var hb := HatsuData.new()
	hb.poder_base = 50.0
	hb.custo_aura_base = 20.0
	var poder_antes = hb.obter_poder_final()
	HatsuVisualResolver.apply_to_hatsu(hb)
	if hb.obter_poder_final() != poder_antes:
		push_error("visual changed power")
		failed += 1
	else:
		print("OK balance preserved")

	print("=== RESULT failed=", failed, " ===")
	quit(1 if failed > 0 else 0)
