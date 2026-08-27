class_name WorldDensityHeatmap
extends Node2D

# ============================================================
# HUNTER ONLINE - WORLD DENSITY HEATMAP
# ============================================================
#
# Modo visual de depuração de densidade do mundo:
# - Mapeia a região inteira (512x512 tiles) em uma grade de setores (16x16 setores)
# - Cada setor mede 32x32 tiles (512x512 pixels)
# - Calcula e renderiza densidades temáticas com transparência:
#   1. COMBINED: Calor Geral & Identificação de ZONAS MORTAS (Zero conteúdo)
#   2. NPC: Concentração de vida e habitantes urbanos (Azul)
#   3. ENEMY: Áreas de combate e perigo PvE (Vermelho)
#   4. EVENT: Zonas de eventos e encontros dinâmicos (Amarelo)
#   5. DISCOVERY: POIs, segredos, rochas de Ko e pistas de Gyo (Verde)
# - Não modifica nenhum asset nem colisão original.
# ============================================================

enum HeatmapMode {
	COMBINED,
	NPC_ONLY,
	ENEMY_ONLY,
	EVENT_ONLY,
	DISCOVERY_ONLY
}

@export var visible_on_screen: bool = false
@export var current_mode: HeatmapMode = HeatmapMode.COMBINED

const GRID_SECTORS_X: int = 16
const GRID_SECTORS_Y: int = 16
const SECTOR_SIZE_PX: float = 512.0 # 32 tiles * 16px

var sector_data: Dictionary = {} # Vector2i -> Dictionary


func _ready() -> void:
	z_index = 100
	visible = visible_on_screen
	recalculate_density_grid()


func toggle_heatmap(forced_state: Variant = null) -> bool:
	if forced_state != null and forced_state is bool:
		visible_on_screen = forced_state
	else:
		visible_on_screen = not visible_on_screen
		
	visible = visible_on_screen
	if visible_on_screen:
		recalculate_density_grid()
		queue_redraw()
	return visible_on_screen


func set_mode(mode: HeatmapMode) -> void:
	current_mode = mode
	if visible_on_screen:
		recalculate_density_grid()
		queue_redraw()


func recalculate_density_grid() -> void:
	sector_data.clear()
	
	# Inicializar setores 16x16
	for sx in range(GRID_SECTORS_X):
		for sy in range(GRID_SECTORS_Y):
			var key = Vector2i(sx, sy)
			sector_data[key] = {
				"npcs": 0,
				"enemies": 0,
				"events": 0,
				"discoveries": 0,
				"risk_level": 1,
				"total_score": 0.0
			}
			
	var director = get_tree().get_first_node_in_group("content_director") as ContentDirector
	
	# 1. Mapear NPCs
	for npc in get_tree().get_nodes_in_group("npc"):
		if npc is Node2D:
			var s = _pos_to_sector(npc.global_position)
			if sector_data.has(s):
				sector_data[s]["npcs"] += 1
				
	# 2. Mapear Inimigos
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if enemy is Node2D:
			var s = _pos_to_sector(enemy.global_position)
			if sector_data.has(s):
				sector_data[s]["enemies"] += 1
				
	# 3. Mapear Eventos e Encontros
	if director != null:
		for ev in director.active_events:
			if ev is Resource and "spawn_pos" in ev:
				var s = _pos_to_sector(ev.spawn_pos)
				if sector_data.has(s):
					sector_data[s]["events"] += 1
		for enc in director.active_encounters:
			if enc is Resource and "pos" in enc:
				var s = _pos_to_sector(enc.pos)
				if sector_data.has(s):
					sector_data[s]["events"] += 1
					
		# 4. Mapear POIs e Descobertas
		for poi in director.registered_pois:
			if poi is Dictionary and poi.has("pos"):
				var s = _pos_to_sector(poi["pos"])
				if sector_data.has(s):
					sector_data[s]["discoveries"] += 1
					
	# Mapear GyoInspectables e KoObstacles adicionais
	for gyo in get_tree().get_nodes_in_group("gyo_inspectable"):
		if gyo is Node2D:
			var s = _pos_to_sector(gyo.global_position)
			if sector_data.has(s):
				sector_data[s]["discoveries"] += 1
				
	for ko in get_tree().get_nodes_in_group("ko_obstacle"):
		if ko is Node2D:
			var s = _pos_to_sector(ko.global_position)
			if sector_data.has(s):
				sector_data[s]["discoveries"] += 1

	# Calcular score total por setor
	for key in sector_data.keys():
		var d = sector_data[key]
		d["total_score"] = (d["npcs"] * 1.5) + (d["enemies"] * 1.0) + (d["events"] * 2.0) + (d["discoveries"] * 2.5)


func _pos_to_sector(pos: Vector2) -> Vector2i:
	var sx = clampi(int(pos.x / SECTOR_SIZE_PX), 0, GRID_SECTORS_X - 1)
	var sy = clampi(int(pos.y / SECTOR_SIZE_PX), 0, GRID_SECTORS_Y - 1)
	return Vector2i(sx, sy)


func _draw() -> void:
	if not visible_on_screen:
		return
		
	for key in sector_data.keys():
		var d = sector_data[key]
		var rect = Rect2(key.x * SECTOR_SIZE_PX, key.y * SECTOR_SIZE_PX, SECTOR_SIZE_PX, SECTOR_SIZE_PX)
		
		var cor_preenchimento = Color(0, 0, 0, 0)
		var label_info = ""
		
		match current_mode:
			HeatmapMode.COMBINED:
				if d["total_score"] <= 0.0:
					# ZONA MORTA (Alerta Vermelho/Cinza)
					cor_preenchimento = Color(0.8, 0.1, 0.1, 0.22)
					label_info = "💀 VAZIO"
				elif d["total_score"] < 3.0:
					cor_preenchimento = Color(0.9, 0.6, 0.1, 0.25)
					label_info = "⚡ BAIXO (%.1f)" % d["total_score"]
				else:
					cor_preenchimento = Color(0.1, 0.8, 0.3, 0.30)
					label_info = "🔥 ATIVO (%.1f)" % d["total_score"]
					
			HeatmapMode.NPC_ONLY:
				var alpha = clampf(d["npcs"] * 0.20, 0.05, 0.55)
				cor_preenchimento = Color(0.2, 0.5, 1.0, alpha)
				label_info = "🔵 NPCs: %d" % d["npcs"]
				
			HeatmapMode.ENEMY_ONLY:
				var alpha = clampf(d["enemies"] * 0.15, 0.05, 0.55)
				cor_preenchimento = Color(1.0, 0.2, 0.2, alpha)
				label_info = "🔴 PvE: %d" % d["enemies"]
				
			HeatmapMode.EVENT_ONLY:
				var alpha = clampf(d["events"] * 0.30, 0.05, 0.60)
				cor_preenchimento = Color(1.0, 0.85, 0.1, alpha)
				label_info = "🟡 Eventos: %d" % d["events"]
				
			HeatmapMode.DISCOVERY_ONLY:
				var alpha = clampf(d["discoveries"] * 0.35, 0.05, 0.60)
				cor_preenchimento = Color(0.2, 0.9, 0.4, alpha)
				label_info = "🟢 POIs: %d" % d["discoveries"]
				
		# Desenhar Retângulo do Setor
		draw_rect(rect, cor_preenchimento, true)
		draw_rect(rect, Color(1.0, 1.0, 1.0, 0.15), false, 1.0)
		
		# Desenhar Texto Informativo do Setor
		var text_pos = rect.position + Vector2(12, 28)
		draw_string(ThemeDB.fallback_font, text_pos, "[%d,%d] %s" % [key.x, key.y, label_info], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color.WHITE)
		
		var subtext_pos = rect.position + Vector2(12, 44)
		var subtext = "NPC:%d  PvE:%d  Ev:%d  POI:%d" % [d["npcs"], d["enemies"], d["events"], d["discoveries"]]
		draw_string(ThemeDB.fallback_font, subtext_pos, subtext, HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color(0.8, 0.8, 0.8, 0.9))
