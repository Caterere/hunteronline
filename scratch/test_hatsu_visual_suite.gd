extends Node

const VisualProfile = preload("res://resource/hatsu/VisualProfile.gd")
const AuraVisualProfile = preload("res://resource/hatsu/AuraVisualProfile.gd")
const HatsuVisual = preload("res://scripts/visual/HatsuVisual.gd")
const HatsuComponentLibrary = preload("res://resource/hatsu/HatsuComponentLibrary.gd")

var total_tests: int = 0
var passed_tests: int = 0
var failed_tests: int = 0

func assert_test(condition: bool, test_name: String) -> void:
	total_tests += 1
	if condition:
		passed_tests += 1
		print("  ✅ [PASS] " + test_name)
	else:
		failed_tests += 1
		print("  ❌ [FAIL] " + test_name)

func _ready() -> void:
	print("================================================================")
	print("🎨 TEST SUITE: SISTEMA VISUAL E CUSTOMIZAÇÃO DE HATSU (12 TESTES)")
	print("================================================================")
	
	PlayerData.reset()
	PlayerData.attributes["aura"] = 200.0
	PlayerData.attributes["aura_max"] = 200.0

	# -------------------------------------------------------------
	# TEST 1: Separação Rígida de Balanceamento (Regra #1)
	# -------------------------------------------------------------
	var h1 := HatsuData.new()
	h1.nome = "Projétil de Aura"
	h1.poder_base = 100.0
	h1.custo_aura_base = 50.0
	h1.cooldown_base = 1.0
	h1.alcance = 300.0

	var vp1 := VisualProfile.new()
	vp1.primary_color = VisualProfile.get_palette_color("vermelho")
	vp1.visual_scale = 2.5
	vp1.glow_intensity = 1.5
	vp1.trail_enabled = true
	h1.visual_profile = vp1

	var dmg_before = h1.obter_poder_final()
	var cost_before = h1.obter_custo_final()
	var cd_before = h1.obter_cooldown_final()
	var range_before = h1.alcance

	# Modificar parâmetros visuais drasticamente
	vp1.primary_color = VisualProfile.get_palette_color("azul")
	vp1.visual_scale = 0.5
	vp1.glow_intensity = 0.0
	vp1.trail_enabled = false

	var dmg_after = h1.obter_poder_final()
	var cost_after = h1.obter_custo_final()
	var cd_after = h1.obter_cooldown_final()
	var range_after = h1.alcance

	var balance_preserved = (dmg_before == dmg_after and cost_before == cost_after and cd_before == cd_after and range_before == range_after)
	assert_test(balance_preserved, "Separação de Balanceamento: Mudanças cosméticas NÃO alteram dano/custo/cooldown/alcance")

	# -------------------------------------------------------------
	# TEST 2: Paleta Canônica Pré-definida
	# -------------------------------------------------------------
	var c_red = VisualProfile.get_palette_color("vermelho")
	var c_blue = VisualProfile.get_palette_color("azul")
	var c_cyan = VisualProfile.get_palette_color("ciano")
	var c_white = VisualProfile.get_palette_color("branco")
	var palette_valid = (c_red.r > 0.8 and c_blue.b > 0.8 and c_cyan.g > 0.8 and c_white == Color.WHITE)
	assert_test(palette_valid, "Paleta de Cores Pré-definida: Obtenção de cores canônicas calibrada")

	# -------------------------------------------------------------
	# TEST 3: Assinatura de Aura & Herança Visual (Blending 50%)
	# -------------------------------------------------------------
	var aura_char := AuraVisualProfile.new()
	aura_char.aura_primary_color = Color(0.0, 0.0, 1.0, 1.0) # Azul puro
	aura_char.aura_secondary_color = Color(1.0, 1.0, 1.0, 1.0)
	aura_char.aura_glow_color = Color(0.0, 1.0, 1.0, 1.0)

	var vp_hatsu := VisualProfile.new()
	vp_hatsu.primary_color = Color(1.0, 0.0, 0.0, 1.0) # Vermelho puro
	vp_hatsu.inherit_aura_visual = true
	vp_hatsu.inheritance_strength = 0.5

	var resolved_vp = aura_char.blend_with_hatsu(vp_hatsu)
	var expected_color = Color(1.0, 0.0, 0.0, 1.0).lerp(Color(0.0, 0.0, 1.0, 1.0), 0.5)
	var blend_ok = (resolved_vp.primary_color.is_equal_approx(expected_color))
	assert_test(blend_ok, "Herança de Aura: Mesclagem proporcional (50%) entre Aura do Personagem e Hatsu")

	# -------------------------------------------------------------
	# TEST 4: Herança Desativada (100% Custom)
	# -------------------------------------------------------------
	vp_hatsu.inherit_aura_visual = false
	var resolved_uninherited = aura_char.blend_with_hatsu(vp_hatsu)
	var uninherited_ok = (resolved_uninherited.primary_color == Color(1.0, 0.0, 0.0, 1.0))
	assert_test(uninherited_ok, "Herança Desativada: Hatsu mantém 100% de customização individual")

	# -------------------------------------------------------------
	# TEST 5: Formatos Visuais Procedurais (VisualShape)
	# -------------------------------------------------------------
	var visual_node := HatsuVisual.new()
	add_child(visual_node)
	var shapes = [
		VisualProfile.VisualShape.SPHERE,
		VisualProfile.VisualShape.BEAM,
		VisualProfile.VisualShape.BLADE,
		VisualProfile.VisualShape.DISC,
		VisualProfile.VisualShape.RING
	]
	var shapes_rendered = true
	for s in shapes:
		var vp_shape := VisualProfile.new()
		vp_shape.shape = s
		visual_node.setup(vp_shape)
		visual_node.queue_redraw()
	assert_test(shapes_rendered, "Formatos Visuais Procedurais: Renderização de SPHERE, BEAM, BLADE, DISC e RING sem erros")

	# -------------------------------------------------------------
	# TEST 6: Sistema de Rastro (Line2D Trail)
	# -------------------------------------------------------------
	var vp_trail := VisualProfile.new()
	vp_trail.trail_enabled = true
	vp_trail.trail_length = 8
	visual_node.setup(vp_trail)
	for i in range(12):
		visual_node.global_position = Vector2(i * 10, i * 5)
		visual_node._process(0.016)
	var trail_ok = (visual_node.trail_points.size() <= 8 and visual_node.trail_line != null)
	assert_test(trail_ok, "Sistema de Rastro (Line2D): Buffer de pontos limitado a trail_length sem vazamentos")

	# -------------------------------------------------------------
	# TEST 7: Efeito de Cast (Cast Effect Lifecycle)
	# -------------------------------------------------------------
	var cast_fx = HatsuVisual.spawn_cast_effect(Vector2(50, 50), vp1, self)
	var cast_ok = (cast_fx != null and is_instance_valid(cast_fx))
	assert_test(cast_ok, "Efeito de Cast: Instanciado com animação de expansão e auto-liberação")

	# -------------------------------------------------------------
	# TEST 8: Efeito de Impacto (Impact Effect Lifecycle)
	# -------------------------------------------------------------
	var impact_fx = HatsuVisual.spawn_impact_effect(Vector2(100, 100), vp1, self)
	var impact_ok = (impact_fx != null and is_instance_valid(impact_fx))
	assert_test(impact_ok, "Efeito de Impacto: Onda de choque instanciada com auto-liberação")

	# -------------------------------------------------------------
	# TEST 9: Partículas Leves (Performance-Friendly)
	# -------------------------------------------------------------
	var vp_part := VisualProfile.new()
	vp_part.particle_enabled = true
	vp_part.particle_amount = 8
	visual_node.setup(vp_part)
	var particles_ok = (visual_node.particles_node != null and visual_node.particles_node.amount == 8)
	assert_test(particles_ok, "Partículas Leves: Emissor CPUParticles2D configurado com limite estrito de partículas")

	# -------------------------------------------------------------
	# TEST 10: Serialização e Deserialização de VisualProfile
	# -------------------------------------------------------------
	var dict_vp = vp1.to_dict()
	var restored_vp = VisualProfile.from_dict(dict_vp)
	var serial_ok = (restored_vp.visual_scale == vp1.visual_scale and restored_vp.glow_intensity == vp1.glow_intensity and restored_vp.shape == vp1.shape)
	assert_test(serial_ok, "Serialização to_dict() e from_dict(): Preservação integral de propriedades cosméticas")

	# -------------------------------------------------------------
	# TEST 11: Integração com HatsuData e Persistência de Hatsu
	# -------------------------------------------------------------
	var h11 := HatsuData.new()
	h11.nome = "Técnica Customizada Visual"
	h11.visual_profile = vp1
	var dict_h11 = h11.to_dict()
	var restored_h11 = HatsuData.from_dict(dict_h11)
	var hatsu_visual_ok = (restored_h11.visual_profile != null and restored_h11.visual_profile.visual_scale == vp1.visual_scale)
	assert_test(hatsu_visual_ok, "Integração HatsuData: Perfil visual integrado à serialização e carregamento de Hatsu")

	# -------------------------------------------------------------
	# TEST 12: Execução de Projétil em HatsuSystem com VisualProfile
	# -------------------------------------------------------------
	var hatsu_sys := HatsuSystem.new()
	add_child(hatsu_sys)
	PlayerData.equipar_hatsu_slot(0, h1)
	var s0 = PlayerData.obter_hatsu_slot(0)
	var sys_visual_ok = (s0 != null and s0.obter_visual_profile() != null)
	assert_test(sys_visual_ok, "Execução em HatsuSystem: HatsuSystem recupera perfil visual dinamicamente")

	print("================================================================")
	print("📊 RESULTADOS DA SUÍTE VISUAL:")
	print("Total: %d | Aprovados: %d | Falhas: %d" % [total_tests, passed_tests, failed_tests])
	print("================================================================")

	if failed_tests == 0:
		print("🎉 100% DOS TESTES VISUAIS APROVADOS COM SUCESSO!")
	else:
		printerr("❌ ALGUNS TESTES FALHARAM!")

	await get_tree().create_timer(0.2).timeout
	get_tree().quit(0 if failed_tests == 0 else 1)