class_name HatsuVisualResolver
extends RefCounted

## Resolve VisualProfile a partir de estilo/forma/elemento/objetivo/efeitos.
## Cosmético apenas — não altera balanceamento.

const VisualProfileScript = preload("res://resource/hatsu/VisualProfile.gd")


## Sugere estilo visual a partir do elemento/forma (presets e auto-wire).
static func suggest_estilo(
	elemento: HatsuData.Elemento,
	forma: HatsuData.Forma = HatsuData.Forma.PROJETIL,
	objetivo: HatsuData.ObjetivoPrincipal = HatsuData.ObjetivoPrincipal.DANO
) -> HatsuData.EstiloVisual:
	match elemento:
		HatsuData.Elemento.FOGO:
			return HatsuData.EstiloVisual.CHAMAS_FOGO
		HatsuData.Elemento.ELETRICIDADE:
			return HatsuData.EstiloVisual.RELAMPAGOS_ELETRICOS
		HatsuData.Elemento.SOMBRA, HatsuData.Elemento.VENENO:
			return HatsuData.EstiloVisual.NEVOA_SOMBRIAS
		HatsuData.Elemento.LUZ:
			return HatsuData.EstiloVisual.ANEIS_IMPACTO
		HatsuData.Elemento.SOM:
			return HatsuData.EstiloVisual.SHURIKEN_GIRATORIO
		HatsuData.Elemento.GELO:
			return HatsuData.EstiloVisual.PURO_PULSANTE
		_:
			pass
	if forma == HatsuData.Forma.TOQUE and objetivo == HatsuData.ObjetivoPrincipal.DANO:
		return HatsuData.EstiloVisual.ANEIS_IMPACTO
	if forma == HatsuData.Forma.AREA or forma == HatsuData.Forma.ZONA:
		return HatsuData.EstiloVisual.ANEIS_IMPACTO
	if objetivo == HatsuData.ObjetivoPrincipal.CONTROLE:
		return HatsuData.EstiloVisual.NEVOA_SOMBRIAS
	return HatsuData.EstiloVisual.PURO_PULSANTE


static func build_for_hatsu(hatsu: HatsuData) -> VisualProfile:
	var vp: VisualProfile = VisualProfileScript.new()
	if hatsu == null:
		return vp

	# Cores com sentido de efeito:
	# 1) Elemento (fogo/choque/gelo…) quando não é Nen puro
	# 2) Estilo visual (chamas/lâmina/névoa…)
	# 3) cor_aura do jogador só reforça Nen puro / override explícito
	var primary := _color_for_style(hatsu.estilo_visual)
	if hatsu.elemento != HatsuData.Elemento.NEN_PURO:
		primary = _color_for_element(hatsu.elemento)
	elif hatsu.cor_aura != Color(0.2, 0.6, 1.0, 1.0):
		primary = hatsu.cor_aura

	primary = _tint_for_objective(hatsu.objetivo, primary)

	var secondary := hatsu.cor_aura_secundaria
	if (
		secondary.a <= 0.01
		or secondary.is_equal_approx(Color(1.0, 1.0, 1.0, 0.8))
		or secondary.is_equal_approx(Color(1.0, 1.0, 1.0, 0.9))
	):
		secondary = _secondary_for_element(hatsu.elemento)
		if hatsu.elemento == HatsuData.Elemento.NEN_PURO:
			secondary = _secondary_for_style(hatsu.estilo_visual)

	vp.primary_color = primary
	vp.secondary_color = secondary
	vp.core_color = _core_for_objective(hatsu.objetivo, primary)
	vp.glow_color = Color(primary.r, primary.g, primary.b, 0.85)
	vp.trail_color = Color(primary.r, primary.g, primary.b, 0.55)
	vp.shape = _shape_for(hatsu.estilo_visual, hatsu.forma, hatsu.objetivo, hatsu.categoria)
	vp.visual_scale = _scale_for(hatsu.forma, hatsu.objetivo)
	vp.glow_intensity = _glow_for(hatsu.elemento, hatsu.estilo_visual)
	vp.trail_enabled = _trail_for(hatsu.forma, hatsu.estilo_visual)
	vp.trail_length = 14 if vp.trail_enabled else 0
	vp.trail_width = 3.0 if hatsu.estilo_visual == HatsuData.EstiloVisual.LAMINA_CORTE else 5.0
	vp.particle_enabled = _particles_for(hatsu.estilo_visual, hatsu.elemento)
	vp.particle_amount = 12 if vp.particle_enabled else 0
	vp.particle_size = 2.2
	vp.particle_speed = 40.0 if hatsu.elemento == HatsuData.Elemento.ELETRICIDADE else 28.0
	vp.particle_lifetime = 0.35
	vp.cast_effect = _cast_effect_for(hatsu)
	vp.impact_effect = _impact_effect_for(hatsu)
	vp.inherit_aura_visual = false
	vp.inheritance_strength = 0.0

	_apply_effect_modules(vp, hatsu)
	return vp


static func apply_to_hatsu(hatsu: HatsuData) -> VisualProfile:
	if hatsu == null:
		return null
	var vp := build_for_hatsu(hatsu)
	hatsu.visual_profile = vp
	hatsu.cor_aura = vp.primary_color
	hatsu.cor_aura_secundaria = vp.secondary_color
	return vp


static func _color_for_element(el: HatsuData.Elemento) -> Color:
	match el:
		HatsuData.Elemento.ELETRICIDADE:
			return VisualProfileScript.get_palette_color("ciano")
		HatsuData.Elemento.FOGO:
			return VisualProfileScript.get_palette_color("laranja")
		HatsuData.Elemento.GELO:
			return Color(0.55, 0.85, 1.0, 1.0)
		HatsuData.Elemento.VENENO:
			return VisualProfileScript.get_palette_color("roxo")
		HatsuData.Elemento.SOM:
			return VisualProfileScript.get_palette_color("amarelo")
		HatsuData.Elemento.LUZ:
			return VisualProfileScript.get_palette_color("branco")
		HatsuData.Elemento.SOMBRA:
			return VisualProfileScript.get_palette_color("preto")
		_:
			return VisualProfileScript.get_palette_color("azul")


static func _secondary_for_element(el: HatsuData.Elemento) -> Color:
	match el:
		HatsuData.Elemento.FOGO:
			return VisualProfileScript.get_palette_color("amarelo")
		HatsuData.Elemento.ELETRICIDADE:
			return VisualProfileScript.get_palette_color("branco")
		HatsuData.Elemento.GELO:
			return Color(0.85, 0.95, 1.0, 0.95)
		HatsuData.Elemento.VENENO:
			return VisualProfileScript.get_palette_color("verde")
		HatsuData.Elemento.SOMBRA:
			return VisualProfileScript.get_palette_color("roxo")
		HatsuData.Elemento.LUZ:
			return VisualProfileScript.get_palette_color("amarelo")
		_:
			return Color(1.0, 1.0, 1.0, 0.9)


static func _color_for_style(estilo: HatsuData.EstiloVisual) -> Color:
	match estilo:
		HatsuData.EstiloVisual.CHAMAS_FOGO:
			return Color(1.0, 0.3, 0.1, 1.0)
		HatsuData.EstiloVisual.RELAMPAGOS_ELETRICOS:
			return Color(0.2, 0.9, 1.0, 1.0)
		HatsuData.EstiloVisual.LAMINA_CORTE:
			return Color(0.8, 0.9, 1.0, 1.0)
		HatsuData.EstiloVisual.SHURIKEN_GIRATORIO:
			return Color(0.9, 0.8, 0.2, 1.0)
		HatsuData.EstiloVisual.ANEIS_IMPACTO:
			return Color(0.9, 0.5, 0.2, 1.0)
		HatsuData.EstiloVisual.NEVOA_SOMBRIAS:
			return Color(0.4, 0.1, 0.5, 1.0)
		HatsuData.EstiloVisual.DRAGAO_SERPENTE:
			return Color(1.0, 0.8, 0.2, 1.0)
		_:
			return Color(0.3, 0.7, 1.0, 1.0)


static func _secondary_for_style(estilo: HatsuData.EstiloVisual) -> Color:
	match estilo:
		HatsuData.EstiloVisual.CHAMAS_FOGO:
			return VisualProfileScript.get_palette_color("amarelo")
		HatsuData.EstiloVisual.RELAMPAGOS_ELETRICOS:
			return VisualProfileScript.get_palette_color("branco")
		HatsuData.EstiloVisual.NEVOA_SOMBRIAS:
			return VisualProfileScript.get_palette_color("roxo")
		HatsuData.EstiloVisual.DRAGAO_SERPENTE:
			return VisualProfileScript.get_palette_color("laranja")
		_:
			return Color(1.0, 1.0, 1.0, 0.9)


static func _tint_for_objective(obj: HatsuData.ObjetivoPrincipal, primary: Color) -> Color:
	match obj:
		HatsuData.ObjetivoPrincipal.CURA:
			return primary.lerp(VisualProfileScript.get_palette_color("verde_claro"), 0.55)
		HatsuData.ObjetivoPrincipal.CONTROLE:
			return primary.lerp(VisualProfileScript.get_palette_color("magenta"), 0.4)
		HatsuData.ObjetivoPrincipal.DEFESA:
			return primary.lerp(VisualProfileScript.get_palette_color("branco"), 0.35)
		HatsuData.ObjetivoPrincipal.MOBILIDADE:
			return primary.lerp(VisualProfileScript.get_palette_color("ciano"), 0.3)
		_:
			return primary


static func _core_for_objective(obj: HatsuData.ObjetivoPrincipal, primary: Color) -> Color:
	match obj:
		HatsuData.ObjetivoPrincipal.CURA:
			return VisualProfileScript.get_palette_color("verde_claro")
		HatsuData.ObjetivoPrincipal.DEFESA:
			return VisualProfileScript.get_palette_color("branco")
		HatsuData.ObjetivoPrincipal.CONTROLE:
			return VisualProfileScript.get_palette_color("magenta")
		HatsuData.ObjetivoPrincipal.MOBILIDADE:
			return VisualProfileScript.get_palette_color("ciano")
		_:
			return Color(1.0, 1.0, 1.0, 1.0).lerp(primary, 0.25)


static func _shape_for(
	estilo: HatsuData.EstiloVisual,
	forma: HatsuData.Forma,
	obj: HatsuData.ObjetivoPrincipal,
	cat: HatsuData.Categoria
) -> int:
	match estilo:
		HatsuData.EstiloVisual.CHAMAS_FOGO:
			return VisualProfileScript.VisualShape.AURA
		HatsuData.EstiloVisual.RELAMPAGOS_ELETRICOS:
			return VisualProfileScript.VisualShape.RAY
		HatsuData.EstiloVisual.LAMINA_CORTE:
			return VisualProfileScript.VisualShape.BLADE
		HatsuData.EstiloVisual.SHURIKEN_GIRATORIO:
			return VisualProfileScript.VisualShape.DISC
		HatsuData.EstiloVisual.ANEIS_IMPACTO:
			return VisualProfileScript.VisualShape.RING
		HatsuData.EstiloVisual.NEVOA_SOMBRIAS:
			return VisualProfileScript.VisualShape.SMOKE
		HatsuData.EstiloVisual.DRAGAO_SERPENTE:
			return VisualProfileScript.VisualShape.DRAGON
		_:
			pass

	match forma:
		HatsuData.Forma.PROJETIL:
			return VisualProfileScript.VisualShape.SPHERE
		HatsuData.Forma.AREA, HatsuData.Forma.ZONA:
			return VisualProfileScript.VisualShape.RING
		HatsuData.Forma.TOQUE:
			if obj == HatsuData.ObjetivoPrincipal.DANO:
				return VisualProfileScript.VisualShape.FIST
			if obj == HatsuData.ObjetivoPrincipal.CONTROLE:
				return VisualProfileScript.VisualShape.CHAIN
			if obj == HatsuData.ObjetivoPrincipal.CURA:
				return VisualProfileScript.VisualShape.AURA
			return VisualProfileScript.VisualShape.BLADE
		HatsuData.Forma.PESSOAL:
			if cat == HatsuData.Categoria.CONJURACAO:
				return VisualProfileScript.VisualShape.BOOK
			if obj == HatsuData.ObjetivoPrincipal.MOBILIDADE:
				return VisualProfileScript.VisualShape.BEAM
			return VisualProfileScript.VisualShape.AURA
		_:
			return VisualProfileScript.VisualShape.SPHERE


static func _scale_for(forma: HatsuData.Forma, obj: HatsuData.ObjetivoPrincipal) -> float:
	var s := 1.0
	if forma == HatsuData.Forma.AREA or forma == HatsuData.Forma.ZONA:
		s = 1.35
	elif forma == HatsuData.Forma.TOQUE:
		s = 0.95
	if obj == HatsuData.ObjetivoPrincipal.CURA:
		s *= 1.1
	return s


static func _glow_for(el: HatsuData.Elemento, estilo: HatsuData.EstiloVisual) -> float:
	if el == HatsuData.Elemento.ELETRICIDADE or estilo == HatsuData.EstiloVisual.RELAMPAGOS_ELETRICOS:
		return 1.25
	if el == HatsuData.Elemento.LUZ:
		return 1.15
	if el == HatsuData.Elemento.SOMBRA or estilo == HatsuData.EstiloVisual.NEVOA_SOMBRIAS:
		return 0.55
	return 0.85


static func _trail_for(forma: HatsuData.Forma, estilo: HatsuData.EstiloVisual) -> bool:
	if forma == HatsuData.Forma.PROJETIL:
		return true
	if (
		estilo == HatsuData.EstiloVisual.LAMINA_CORTE
		or estilo == HatsuData.EstiloVisual.SHURIKEN_GIRATORIO
		or estilo == HatsuData.EstiloVisual.DRAGAO_SERPENTE
		or estilo == HatsuData.EstiloVisual.RELAMPAGOS_ELETRICOS
	):
		return true
	return false



static func _particles_for(estilo: HatsuData.EstiloVisual, el: HatsuData.Elemento) -> bool:
	if (
		estilo == HatsuData.EstiloVisual.CHAMAS_FOGO
		or estilo == HatsuData.EstiloVisual.NEVOA_SOMBRIAS
		or estilo == HatsuData.EstiloVisual.RELAMPAGOS_ELETRICOS
	):
		return true
	return (
		el == HatsuData.Elemento.FOGO
		or el == HatsuData.Elemento.VENENO
		or el == HatsuData.Elemento.ELETRICIDADE
	)



static func _cast_effect_for(hatsu: HatsuData) -> String:
	match hatsu.objetivo:
		HatsuData.ObjetivoPrincipal.CURA:
			return "heal_pulse"
		HatsuData.ObjetivoPrincipal.DEFESA:
			return "aura_flash"
		HatsuData.ObjetivoPrincipal.MOBILIDADE:
			return "spark_burst"
		_:
			pass
	match hatsu.estilo_visual:
		HatsuData.EstiloVisual.CHAMAS_FOGO, HatsuData.EstiloVisual.RELAMPAGOS_ELETRICOS:
			return "spark_burst"
		HatsuData.EstiloVisual.LAMINA_CORTE, HatsuData.EstiloVisual.SHURIKEN_GIRATORIO:
			return "spark_burst"
		HatsuData.EstiloVisual.NEVOA_SOMBRIAS:
			return "smoke"
		HatsuData.EstiloVisual.ANEIS_IMPACTO, HatsuData.EstiloVisual.DRAGAO_SERPENTE:
			return "aura_flash"
		_:
			pass
	match hatsu.elemento:
		HatsuData.Elemento.FOGO, HatsuData.Elemento.ELETRICIDADE, HatsuData.Elemento.SOM:
			return "spark_burst"
		HatsuData.Elemento.SOMBRA, HatsuData.Elemento.VENENO:
			return "smoke"
		HatsuData.Elemento.GELO:
			return "ice_flash"
		HatsuData.Elemento.LUZ:
			return "aura_flash"
		_:
			return "aura_flash"


static func _impact_effect_for(hatsu: HatsuData) -> String:
	match hatsu.objetivo:
		HatsuData.ObjetivoPrincipal.CURA:
			return "heal_pulse"
		HatsuData.ObjetivoPrincipal.CONTROLE:
			return "bind_flash"
		HatsuData.ObjetivoPrincipal.DEFESA:
			return "shockwave"
		_:
			pass
	match hatsu.estilo_visual:
		HatsuData.EstiloVisual.CHAMAS_FOGO, HatsuData.EstiloVisual.RELAMPAGOS_ELETRICOS:
			return "spark_burst"
		HatsuData.EstiloVisual.NEVOA_SOMBRIAS:
			return "smoke"
		HatsuData.EstiloVisual.ANEIS_IMPACTO, HatsuData.EstiloVisual.DRAGAO_SERPENTE:
			return "shockwave"
		HatsuData.EstiloVisual.LAMINA_CORTE, HatsuData.EstiloVisual.SHURIKEN_GIRATORIO:
			return "slash_flash"
		_:
			pass
	match hatsu.elemento:
		HatsuData.Elemento.FOGO, HatsuData.Elemento.ELETRICIDADE:
			return "spark_burst"
		HatsuData.Elemento.GELO:
			return "ice_shatter"
		HatsuData.Elemento.VENENO, HatsuData.Elemento.SOMBRA:
			return "smoke"
		_:
			return "shockwave"


static func _apply_effect_modules(vp: VisualProfile, hatsu: HatsuData) -> void:
	if hatsu.effect_modules.is_empty():
		return
	for mod in hatsu.effect_modules:
		var t: int = -1
		if mod is Dictionary:
			t = int(mod.get("type", mod.get("effect_type", -1)))
		elif typeof(mod) == TYPE_INT:
			t = int(mod)
		# HatsuComponentLibrary.EffectType: KNOCKBACK=6, STUN=7, AURA_DRAIN=9
		match t:
			6:
				vp.impact_effect = "shockwave"
				vp.visual_scale = maxf(vp.visual_scale, 1.2)
			7:
				vp.cast_effect = "spark_burst"
				vp.impact_effect = "bind_flash"
			9:
				vp.primary_color = vp.primary_color.lerp(VisualProfileScript.get_palette_color("roxo"), 0.35)
				vp.particle_enabled = true
			_:
				pass
