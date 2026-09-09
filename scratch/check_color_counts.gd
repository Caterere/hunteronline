@tool
extends SceneTree

func _init() -> void:
	var npcs = [
		"npc_gon", "npc_killua", "npc_kurapika", "npc_leorio",
		"npc_hisoka", "npc_chrollo", "npc_netero", "npc_biscuit",
		"npc_tonpa", "npc_ging", "npc_hanzo", "npc_pokkle",
		"npc_ponzu", "npc_buhara", "npc_menchi", "npc_gittarackur",
		"npc_bodoro", "npc_nicol",
		"enemy_candidato_exame", "enemy_criatura_pantanal", "enemy_mordomo_zoldyck",
		"enemy_lutador_arena", "enemy_mafioso_yorknew", "enemy_bomber_greed",
		"enemy_formiga_soldado", "enemy_formiga_lider", "enemy_guarda_real",
		"enemy_boss_razor", "enemy_boss_meruem"
	]
	
	for name in npcs:
		var p = "res://assets/sprites/characters/" + name + "_8dir.png"
		var img = Image.load_from_file(ProjectSettings.globalize_path(p))
		if img == null: continue
		var max_colors = 0
		var bad_frames = []
		for c in range(8):
			var colors = {}
			for y in range(48):
				for x in range(48):
					var col = img.get_pixel(c * 48 + x, y)
					if col.a >= 0.5:
						colors[col.to_html(false)] = true
			max_colors = maxi(max_colors, colors.size())
			if colors.size() > 14:
				bad_frames.append([c, colors.size()])
		if bad_frames.size() > 0:
			print("[-] %s: max=%d > 14! Bad frames: %s" % [name, max_colors, bad_frames])
		else:
			print("[+] %s: OK (max=%d <= 14)" % [name, max_colors])
	quit(0)
