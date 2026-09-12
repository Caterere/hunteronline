class_name NpcSpriteBinder
extends RefCounted

# ============================================================
# Aplica folha 8dir PixelLab sem forçar player.png / tintas.
# Style Lock v2: arte 96×96 (mais detalhe), mas escala mundana = player 48px.
# ============================================================

## Altura de frame do player (`player.png` = 48×48).
const PLAYER_FRAME_PX: float = 48.0
## Offset vertical do Sprite2D do player (pés no chão).
const PLAYER_SPRITE_Y: float = -17.0


## Redimensiona sprite (ex.: 96px) para a mesma altura visual do player.
static func aplicar_escala_mundo_player(spr: Sprite2D) -> void:
	if spr == null or spr.texture == null:
		return
	var tex_h: float = float(spr.texture.get_height())
	var frame_h: float = tex_h / float(maxi(1, spr.vframes))
	# Folha 8dir horizontal: altura da textura = altura do frame
	if spr.hframes > 1 and spr.vframes <= 1:
		frame_h = tex_h
	if frame_h <= 1.0:
		return
	var s: float = PLAYER_FRAME_PX / frame_h
	spr.scale = Vector2(s, s)
	# Com scale, o offset do player (-17) alinha os pés no mesmo chão
	spr.position = Vector2(0.0, PLAYER_SPRITE_Y)


static func aplicar(node: Node, preferred_ids: Array = []) -> void:
	if node == null:
		return
	var spr := node.get_node_or_null("Sprite2D") as Sprite2D
	if spr == null:
		return

	var ids: Array = preferred_ids.duplicate()
	var n_low := ""
	if node.get("npc_name") != null:
		n_low = str(node.get("npc_name")).to_lower()
	n_low += " " + str(node.name).to_lower()

	const ALIASES := {
		"gon": "npc_gon",
		"killua": "npc_killua",
		"kurapika": "npc_kurapika",
		"leorio": "npc_leorio",
		"hisoka": "npc_hisoka",
		"biscuit": "npc_biscuit",
		"bisky": "npc_biscuit",
		"netero": "npc_netero",
		"netero_presidente": "npc_netero",
		"chrollo": "npc_chrollo",
		"melody": "npc_melody",
		"battera": "npc_battera",
		"tsezguerra": "npc_tsezguerra",
		"zebro": "npc_guarda_fronteira",
		"canary": "npc_mordoma_canary",
		"gotoh": "npc_mordomo_gotoh",
		"silva": "npc_silva_zoldyck",
		"guia": "npc_viajante_scout",
		"ferreiro": "npc_ferreiro_mestre",
		"vendedor": "npc_vendedor_mercador",
		"wing": "npc_instrutor_combate",
		"viajante calibracao": "npc_calibration_viajante_padokia",
		"calibracao": "npc_calibration_viajante_padokia",
		"herbalista": "npc_herbalista_floresta",
		"jardineiro": "npc_mordomo_zoldyck_ambient",
		"aprendiz": "npc_mordomo_zoldyck_ambient",
		"mafioso": "npc_mafioso_yorknew_ambient",
		"lutador": "npc_lutador_arena_ambient"
	}
	for k in ALIASES.keys():
		if k in n_low:
			ids.append(ALIASES[k])

	for asset_id in ids:
		var path := "res://assets/sprites/characters/%s_8dir.png" % str(asset_id)
		if ResourceLoader.exists(path):
			spr.texture = load(path)
			spr.hframes = 8
			spr.vframes = 1
			spr.frame = 0
			spr.modulate = Color.WHITE
			aplicar_escala_mundo_player(spr)
			# Anexar animador idle/walk se folhas quality-pack existirem
			var idle_path := "res://assets/sprites/characters/%s_idle_8xN.png" % str(asset_id)
			if ResourceLoader.exists(idle_path):
				var existing := node.get_node_or_null("NpcSheetAnimator")
				if existing == null:
					var anim_script = load("res://entities/npc/NpcSheetAnimator.gd")
					if anim_script != null:
						var anim = anim_script.new()
						anim.name = "NpcSheetAnimator"
						node.add_child(anim)
						if anim.has_method("setup"):
							anim.setup(spr, str(asset_id), node)
			return

	# Já veio com folha 8dir no .tscn (ex.: Kurapika.tscn) — só corrige escala
	if spr.texture != null and spr.hframes >= 8:
		aplicar_escala_mundo_player(spr)
