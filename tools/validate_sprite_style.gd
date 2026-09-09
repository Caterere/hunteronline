extends SceneTree

# ==============================================================================
# HUNTER ONLINE — SPRITE STYLE LOCK VALIDATOR
# Baseado no Style Anchor Canônico: player(3).png / player.png
# ==============================================================================

const EXPECTED_FRAME_W = 48
const EXPECTED_FRAME_H = 48
const TARGET_FEET_Y = 42
const TOLERANCE_FEET_Y = 2
const MAX_IDLE_WIDTH = 18
const MAX_IDLE_HEIGHT = 25
const MIN_TOP_PADDING = 18
const MIN_BOTTOM_PADDING = 3
const MAX_COLORS_PER_FRAME = 14
const MAX_COLORS_TOTAL_SHEET = 22

func validate_sprite(path: String) -> bool:
	var real_path = ProjectSettings.globalize_path(path) if path.begins_with("res://") else path
	var img = Image.load_from_file(real_path)
	if not img:
		print("[FAIL] Não foi possível carregar a imagem: %s" % path)
		return false

	var total_w = img.get_width()
	var total_h = img.get_height()
	print("\n" + "=".repeat(70))
	print(" AUDITORIA DE ESTILO: %s" % path.get_file())
	print("=".repeat(70))
	print(" Dimensões totais: %dx%d px" % [total_w, total_h])

	var pass_all = true
	var errors = []
	var warnings = []

	# 1. Canvas 48x48
	if total_w % EXPECTED_FRAME_W != 0 or total_h % EXPECTED_FRAME_H != 0:
		errors.append("Dimensões não são múltiplos de 48x48 (Frame não canônico).")
		pass_all = false

	var cols = maxi(1, total_w / EXPECTED_FRAME_W)
	var rows = maxi(1, total_h / EXPECTED_FRAME_H)
	print(" Grid de frames: %d colunas x %d linhas (%d frames de 48x48)" % [cols, rows, cols * rows])

	# 2. Transparência suave / anti-aliasing no corpo do sprite
	var body_partial_alpha_count = 0
	var all_sheet_colors = {}
	for y in range(total_h):
		var local_y = y % EXPECTED_FRAME_H
		for x in range(total_w):
			var c = img.get_pixel(x, y)
			var is_shadow = (local_y >= 38 and abs(c.a - 0.5) < 0.1)
			if not is_shadow and c.a > 0.05 and c.a < 0.95:
				body_partial_alpha_count += 1
			if c.a >= 0.1:
				all_sheet_colors[c.to_html(false)] = true

	if body_partial_alpha_count > 0:
		errors.append("Detectados %d pixels com transparência suave no corpo (anti-aliasing/soft brush). O sprite deve ter contornos rígidos e alpha binário." % body_partial_alpha_count)
		pass_all = false

	# 3. Análise frame a frame
	var max_frame_w = 0
	var max_frame_h = 0
	var max_frame_colors = 0

	for r in range(rows):
		for c in range(cols):
			var frame_rect = Rect2i(c * EXPECTED_FRAME_W, r * EXPECTED_FRAME_H, EXPECTED_FRAME_W, EXPECTED_FRAME_H)
			var frame_img = img.get_region(frame_rect)
			var min_x = EXPECTED_FRAME_W; var max_x = -1
			var min_y = EXPECTED_FRAME_H; var max_y = -1
			var frame_colors = {}
			var opaque_count = 0

			for y in range(EXPECTED_FRAME_H):
				for x in range(EXPECTED_FRAME_W):
					var p = frame_img.get_pixel(x, y)
					if p.a >= 0.5:
						opaque_count += 1
						frame_colors[p.to_html(false)] = true
						if x < min_x: min_x = x
						if x > max_x: max_x = x
						if y < min_y: min_y = y
						if y > max_y: max_y = y

			if opaque_count > 0:
				var fw = max_x - min_x + 1
				var fh = max_y - min_y + 1
				max_frame_w = maxi(max_frame_w, fw)
				max_frame_h = maxi(max_frame_h, fh)
				max_frame_colors = maxi(max_frame_colors, frame_colors.size())

				# Verificar padding e proporção para frames de repouso/andar
				if fw > MAX_IDLE_WIDTH:
					errors.append("Frame [r=%d, c=%d]: Largura do personagem (%d px) excede o limite de %d px." % [r, c, fw, MAX_IDLE_WIDTH])
					pass_all = false
				if fh > MAX_IDLE_HEIGHT:
					errors.append("Frame [r=%d, c=%d]: Altura do personagem (%d px) excede o limite de %d px." % [r, c, fh, MAX_IDLE_HEIGHT])
					pass_all = false
				if min_y < MIN_TOP_PADDING:
					errors.append("Frame [r=%d, c=%d]: Top padding insuficiente (%d px < %d px requeridos). Personagem gigante/esticado." % [r, c, min_y, MIN_TOP_PADDING])
					pass_all = false
				if abs(max_y - TARGET_FEET_Y) > TOLERANCE_FEET_Y:
					errors.append("Frame [r=%d, c=%d]: Baseline dos pés em Y=%d (esperado Y=%d ± %d)." % [r, c, max_y, TARGET_FEET_Y, TOLERANCE_FEET_Y])
					pass_all = false
				if frame_colors.size() > MAX_COLORS_PER_FRAME:
					errors.append("Frame [r=%d, c=%d]: Densidade de cores excessiva (%d cores > %d permitidas). Ilustração reduzida ou shading complexo demais." % [r, c, frame_colors.size(), MAX_COLORS_PER_FRAME])
					pass_all = false

	# 4. Total de cores da folha
	if all_sheet_colors.size() > MAX_COLORS_TOTAL_SHEET:
		warnings.append("Paleta total da folha possui %d cores únicas (limite ideal: %d). Verifique se há variações parasitas de cor." % [all_sheet_colors.size(), MAX_COLORS_TOTAL_SHEET])

	# Relatório
	print(" Bounding Box máxima observada: %dx%d px" % [max_frame_w, max_frame_h])
	print(" Máximo de cores em um único frame: %d cores" % max_frame_colors)
	print(" Total de cores únicas na folha: %d cores" % all_sheet_colors.size())

	if errors.is_empty():
		print("\n >>> [STATUS: APROVADO] Sprite cumpre rigorosamente todos os critérios do Style Lock! <<<")
	else:
		print("\n >>> [STATUS: REPROVADO] Violações de Style Lock encontradas: <<<")
		for err in errors.slice(0, 10):
			print("   ✖ %s" % err)
		if errors.size() > 10:
			print("   ... e mais %d violações omitidas." % [errors.size() - 10])

	if not warnings.is_empty():
		print("\n [AVISOS]:")
		for w in warnings:
			print("   ⚠ %s" % w)

	return pass_all

func _init():
	# Se caminhos forem passados via CLI (após `--`), valida apenas eles.
	var cli_args := OS.get_cmdline_user_args()
	if cli_args.size() > 0:
		var ok := true
		var passed := 0
		for p in cli_args:
			if validate_sprite(p):
				passed += 1
			else:
				ok = false
		print("\n" + "=".repeat(70))
		print(" RESULTADO (CLI): %d/%d aprovados." % [passed, cli_args.size()])
		print("=".repeat(70))
		quit(0 if ok else 1)
		return
	var npcs = [
		"res://assets/sprites/characters/npc_discipulo_zushi_8dir.png",
		"res://assets/sprites/characters/npc_instrutor_combate_8dir.png",
		"res://assets/sprites/characters/npc_examinador_oficial_8dir.png",
		"res://assets/sprites/characters/npc_ferreiro_mestre_8dir.png",
		"res://assets/sprites/characters/npc_vendedor_mercador_8dir.png",
		"res://assets/sprites/characters/npc_guarda_fronteira_8dir.png",
		"res://assets/sprites/characters/npc_recepcionista_elena_8dir.png",
		"res://assets/sprites/characters/npc_viajante_scout_8dir.png",
		"res://assets/sprites/characters/npc_gon_8dir.png",
		"res://assets/sprites/characters/npc_killua_8dir.png",
		"res://assets/sprites/characters/npc_kurapika_8dir.png",
		"res://assets/sprites/characters/npc_leorio_8dir.png",
		"res://assets/sprites/characters/npc_hisoka_8dir.png",
		"res://assets/sprites/characters/npc_chrollo_8dir.png",
		"res://assets/sprites/characters/npc_netero_8dir.png",
		"res://assets/sprites/characters/npc_biscuit_8dir.png",
		"res://assets/sprites/characters/npc_tonpa_8dir.png",
		"res://assets/sprites/characters/npc_ging_8dir.png",
		"res://assets/sprites/characters/npc_hanzo_8dir.png",
		"res://assets/sprites/characters/npc_pokkle_8dir.png",
		"res://assets/sprites/characters/npc_ponzu_8dir.png",
		"res://assets/sprites/characters/npc_buhara_8dir.png",
		"res://assets/sprites/characters/npc_menchi_8dir.png",
		"res://assets/sprites/characters/npc_gittarackur_8dir.png",
		"res://assets/sprites/characters/npc_bodoro_8dir.png",
		"res://assets/sprites/characters/npc_nicol_8dir.png",
		"res://assets/sprites/characters/enemy_candidato_exame_8dir.png",
		"res://assets/sprites/characters/enemy_criatura_pantanal_8dir.png",
		"res://assets/sprites/characters/enemy_mordomo_zoldyck_8dir.png",
		"res://assets/sprites/characters/enemy_lutador_arena_8dir.png",
		"res://assets/sprites/characters/enemy_mafioso_yorknew_8dir.png",
		"res://assets/sprites/characters/enemy_bomber_greed_8dir.png",
		"res://assets/sprites/characters/enemy_formiga_soldado_8dir.png",
		"res://assets/sprites/characters/enemy_formiga_lider_8dir.png",
		"res://assets/sprites/characters/enemy_guarda_real_8dir.png",
		"res://assets/sprites/characters/enemy_boss_razor_8dir.png",
		"res://assets/sprites/characters/enemy_boss_meruem_8dir.png",
		"res://assets/sprites/characters/npc_melody_8dir.png",
		"res://assets/sprites/characters/npc_battera_8dir.png",
		"res://assets/sprites/characters/npc_tsezguerra_8dir.png",
		"res://assets/sprites/characters/enemy_sentinela_pedra_8dir.png",
		"res://assets/sprites/characters/npc_mordoma_canary_8dir.png",
		"res://assets/sprites/characters/npc_mordomo_gotoh_8dir.png",
		"res://assets/sprites/characters/npc_silva_zoldyck_8dir.png",
	]

	var all_passed = true
	var pass_count = 0
	for p in npcs:
		if validate_sprite(p):
			pass_count += 1
		else:
			all_passed = false

	print("\n" + "=".repeat(70))
	if all_passed:
		print(" RESULTADO FINAL: TODOS OS %d ASSETS (NPCS + INIMIGOS) FORAM 100%% APROVADOS NO STYLE LOCK!" % npcs.size())
	else:
		print(" RESULTADO FINAL: FALHAS DETECTADAS (%d/%d APROVADOS)." % [pass_count, npcs.size()])
	print("=".repeat(70))
	quit(0 if all_passed else 1)
