class_name MissionGPSIndicator
extends Node2D

# ============================================================
# HUNTER ONLINE - GPS DE MISSÕES & NAVEGAÇÃO DE MUNDO ABERTO
# ============================================================
#
# Sistema de navegação inteligente estilo RPG de Mundo Aberto:
# 1. Identifica em tempo real o próximo objetivo pendente da missão ativa.
# 2. Se o alvo (NPC, Inimigo, Item) estiver no mapa atual:
#    - Aponta a bússola/seta diretamente para suas coordenadas exatas.
# 3. Se o alvo estiver em outra região do mundo contínuo:
#    - Localiza o portão físico / MapTransitionArea mais apropriado na cena atual
#      que conecta em direção ao destino e aponta para ele.
# 4. No Hub Central (Lobby):
#    - Passo 1: Recepcionista Elena.
#    - Passo 2: Portão Sul de Saída para o Mundo Exterior (PortaoMundoExterior).
# 5. Exibe plaqueta dinâmica com tipo de ação, nome do alvo e distância em metros.
# 6. Efeito de anel pulsante verde ao aproximar-se do objetivo (< 35px).
#
# ============================================================

var player_ref: CharacterBody2D = null
var current_target_node: Node2D = null
var current_target_pos: Vector2 = Vector2.ZERO
var current_target_name: String = ""
var current_target_type: String = "" # "npc", "enemy", "portal", "loot", "gate"
var target_found: bool = false
var distance_to_target: float = 0.0

var pulse_time: float = 0.0
var smooth_angle: float = 0.0

# UI Overlay (CanvasLayer para textos e plaqueta inferior)
var canvas_layer: CanvasLayer = null
var screen_edge_indicator: Control = null
var lbl_target_info: Label = null

const ORBIT_RADIUS: float = 30.0
const ARRIVAL_DISTANCE: float = 35.0


func _ready() -> void:
	z_index = 50
	_criar_overlay_tela()


func _criar_overlay_tela() -> void:
	canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 15
	add_child(canvas_layer)

	screen_edge_indicator = Control.new()
	screen_edge_indicator.set_anchors_preset(Control.PRESET_FULL_RECT)
	screen_edge_indicator.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas_layer.add_child(screen_edge_indicator)

	# Plaqueta Flutuante de GPS (Centralizada na parte inferior da tela)
	var panel := PanelContainer.new()
	panel.name = "GPSBottomPanel"
	panel.position = Vector2(160 - 85, 160)
	panel.custom_minimum_size = Vector2(170, 15)
	
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.04, 0.06, 0.10, 0.85)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.border_color = Color(1.0, 0.8, 0.2, 0.9)
	style.corner_radius_top_left = 3
	style.corner_radius_top_right = 3
	style.corner_radius_bottom_right = 3
	style.corner_radius_bottom_left = 3
	panel.add_theme_stylebox_override("panel", style)
	screen_edge_indicator.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 4)
	margin.add_theme_constant_override("margin_right", 4)
	panel.add_child(margin)

	lbl_target_info = Label.new()
	lbl_target_info.text = "🧭 GPS: Localizando rota..."
	lbl_target_info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_target_info.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl_target_info.add_theme_font_size_override("font_size", 3)
	lbl_target_info.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3, 1.0))
	margin.add_child(lbl_target_info)


func _process(delta: float) -> void:
	pulse_time += delta
	_localizar_player()
	
	if player_ref == null or not is_instance_valid(player_ref):
		visible = false
		if screen_edge_indicator: screen_edge_indicator.visible = false
		return

	global_position = player_ref.global_position
	visible = true
	if screen_edge_indicator: screen_edge_indicator.visible = true

	_atualizar_alvo_ativo()
	queue_redraw()


func _localizar_player() -> void:
	if player_ref != null and is_instance_valid(player_ref):
		return
	var players = get_tree().get_nodes_in_group("player")
	if not players.is_empty() and players[0] is CharacterBody2D:
		player_ref = players[0] as CharacterBody2D


func _atualizar_alvo_ativo() -> void:
	target_found = false
	current_target_node = null

	var tree := get_tree()
	if tree == null:
		return

	var cur_scn := tree.current_scene
	if cur_scn == null:
		return

	var cena_atual: String = cur_scn.scene_file_path.to_lower() if cur_scn.scene_file_path != null else ""
	var is_lobby: bool = ("lobby" in cena_atual or cur_scn.name == "Lobby")

	# =========================================================
	# CONTEXTO 1: HUB CENTRAL / CIDADE DE PADOKIA (LOBBY)
	# =========================================================
	if is_lobby:
		if not PlayerData.tour_lobby_concluido:
			current_target_type = "npc"
			current_target_name = "Recepcionista Elena"
			var elena = cur_scn.get_node_or_null("RecepcionistaElena")
			if elena != null and elena is Node2D:
				current_target_node = elena
				current_target_pos = elena.global_position
				target_found = true
			if lbl_target_info and not target_found:
				lbl_target_info.text = "👉 Passo 1/2: Fale com a Recepcionista Elena na Praça Central"
				lbl_target_info.add_theme_color_override("font_color", Color(0.3, 0.9, 1.0, 1.0))
		else:
			# No novo mundo aberto contínuo, a saída para o mundo exterior é o Portão Sul
			current_target_type = "portal"
			current_target_name = "Portão Sul (Mundo Exterior — 287º Exame Hunter)"
			var portao_sul = cur_scn.get_node_or_null("PortaoMundoExterior")
			if portao_sul != null and portao_sul is Node2D:
				current_target_node = portao_sul
				current_target_pos = portao_sul.global_position
				target_found = true
			else:
				# Fallback se houver algum MapTransitionArea no mapa
				var transicoes: Array = []
				_coletar_areas_transicao(cur_scn, transicoes)
				if not transicoes.is_empty():
					var t = transicoes[0] as Node2D
					current_target_node = t
					current_target_pos = t.global_position
					target_found = true

			if lbl_target_info and not target_found:
				lbl_target_info.text = "👉 Passo 2/2: Siga pelo Portão Sul para iniciar a jornada no Mundo Aberto!"
				lbl_target_info.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3, 1.0))

		if target_found and player_ref != null:
			var passo_lobby: int = 0 if not PlayerData.tour_lobby_concluido else 1
			_atualizar_render_gps(passo_lobby, 2, 1)
		return

	# =========================================================
	# CONTEXTO 2: MAPAS DO MUNDO ABERTO & MISSÕES DE SAGA
	# =========================================================
	if QuestSystem == null:
		return

	if QuestSystem.active_quests.is_empty():
		QuestSystem.garantir_quest_do_arco(PlayerData.arco_atual)

	if QuestSystem.active_quests.is_empty():
		if lbl_target_info:
			lbl_target_info.text = "📜 Carregando missão da saga..."
			lbl_target_info.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8, 1.0))
		return

	var quest: Quest = QuestSystem.active_quests[0]
	if quest == null or quest.objectives.is_empty():
		return

	var obj_pendente: QuestObjective = null
	var pendente_idx: int = 0
	var total_objetivos: int = quest.objectives.size()

	for i in range(total_objetivos):
		var obj = quest.objectives[i]
		var prog = PlayerData.get_quest_objective_progress(quest, i)
		if prog < obj.required_amount:
			obj_pendente = obj
			pendente_idx = i
			break

	# Se todos os objetivos da etapa atual foram concluídos, apontar para o Portão de Saída / Avanço
	if obj_pendente == null:
		var transicoes: Array = []
		_coletar_areas_transicao(get_tree().current_scene, transicoes)
		var portal_avanco: Node2D = null

		# 1º: Priorizar portal com story_gate ativo que abre o próximo arco/etapa
		for t in transicoes:
			if t is MapTransitionArea and t.story_gate != null:
				portal_avanco = t
				break

		# 2º: Priorizar portal que avança para fora e não é de retorno ao Lobby ou interior de casa
		if portal_avanco == null:
			for t in transicoes:
				if t is MapTransitionArea:
					var t_name = t.name.to_lower()
					var target_p = t.target_scene_path.to_lower()
					if not "retorno" in t_name and not "lobby" in target_p and not "interior" in target_p and not "casa" in target_p:
						portal_avanco = t
						break

		if portal_avanco == null and not transicoes.is_empty():
			portal_avanco = transicoes[0] as Node2D

		if portal_avanco != null:
			current_target_node = portal_avanco
			current_target_pos = portal_avanco.global_position
			if portal_avanco is MapTransitionArea and not portal_avanco.portal_name.is_empty():
				current_target_name = portal_avanco.portal_name
			else:
				current_target_name = "Portão de Avanço da História"
			current_target_type = "portal"
			target_found = true
			_atualizar_render_gps(total_objetivos - 1, total_objetivos, 0)
			return

		if lbl_target_info:
			lbl_target_info.text = "✨ TODOS OS OBJETIVOS CONCLUÍDOS! Siga para a próxima área..."
			lbl_target_info.add_theme_color_override("font_color", Color(0.3, 1.0, 0.5, 1.0))
		return

	var prog_atual = PlayerData.get_quest_objective_progress(quest, pendente_idx)
	var req_total = obj_pendente.required_amount
	var faltam = max(1, req_total - prog_atual)

	# 1. Tentar localizar o alvo localmente na cena atual
	match obj_pendente.type:
		QuestObjective.Type.VISIT, QuestObjective.Type.PERSUASION:
			current_target_type = "npc"
			var target_id_str = str(obj_pendente.target_npc_id).to_lower()
			var target_name_str = obj_pendente.target_npc_name.to_lower()
			current_target_name = obj_pendente.target_npc_name if not obj_pendente.target_npc_name.is_empty() else "NPC de Missão"

			# Procurar nós no grupo npc
			var npcs = get_tree().get_nodes_in_group("npc")
			var best_npc: Node2D = null
			var best_dist: float = 999999.0

			for n in npcs:
				if n is Node2D and is_instance_valid(n) and not n.is_queued_for_deletion():
					var n_name = n.name.to_lower()
					var custom_name = ""
					if "npc_name" in n and n.npc_name != null:
						custom_name = str(n.npc_name).to_lower()
					
					var bate: bool = (
						target_id_str == n_name
						or target_id_str in n_name
						or n_name in target_id_str
						or target_name_str in n_name
						or (!custom_name.is_empty() and (target_id_str == custom_name or target_id_str in custom_name or custom_name in target_id_str or target_name_str in custom_name))
					)
					if bate:
						var d = player_ref.global_position.distance_to(n.global_position)
						if d < best_dist:
							best_dist = d
							best_npc = n

			if best_npc != null:
				current_target_node = best_npc
				current_target_pos = best_npc.global_position
				target_found = true
			else:
				# Busca recursiva por nome na cena atual
				var root_scene = get_tree().current_scene
				if root_scene != null:
					var found_node = _buscar_no_recursivo_por_nome(root_scene, target_id_str, target_name_str)
					if found_node != null and not found_node.is_queued_for_deletion():
						current_target_node = found_node
						current_target_pos = found_node.global_position
						target_found = true

		QuestObjective.Type.KILL:
			current_target_type = "enemy"
			var enemy_type_str = str(obj_pendente.enemy_type).to_lower()
			current_target_name = "Inimigo de Missão" if enemy_type_str.is_empty() else enemy_type_str.replace("_", " ").capitalize()
			
			var all_enemies: Array[Node2D] = []
			var grupos = ["enemies", "enemy"]
			for g in grupos:
				for n in get_tree().get_nodes_in_group(g):
					if n is Node2D and is_instance_valid(n) and not n.is_queued_for_deletion() and not all_enemies.has(n):
						all_enemies.append(n)

			if all_enemies.is_empty() and get_tree().current_scene != null:
				_coletar_inimigos_recursivo(get_tree().current_scene, all_enemies)

			# Filtrar apenas inimigos vivos
			var living_enemies: Array[Node2D] = []
			for e in all_enemies:
				if not is_instance_valid(e) or e.is_queued_for_deletion():
					continue
				var esys = e.get_node_or_null("EnemySystem")
				if esys != null and ("is_dead" in esys and esys.is_dead):
					continue
				living_enemies.append(e)

			var matching_enemies: Array[Node2D] = []
			var keywords = enemy_type_str.split("_")

			for e in living_enemies:
				var e_sys = e.get_node_or_null("EnemySystem")
				var e_id = str(e_sys.enemy_id).to_lower() if e_sys != null and "enemy_id" in e_sys else ""
				var e_nome = str(e_sys.enemy_name).to_lower() if e_sys != null and "enemy_name" in e_sys else ""
				var n_name = e.name.to_lower()

				var bate: bool = false
				if enemy_type_str.is_empty() or enemy_type_str == "any" or enemy_type_str == "monstro" or enemy_type_str in e_id or e_id in enemy_type_str or enemy_type_str in n_name or enemy_type_str in e_nome:
					bate = true
				else:
					for kw in keywords:
						if kw.length() >= 4 and (kw in e_id or kw in n_name or kw in e_nome):
							bate = true
							break

				if bate:
					matching_enemies.append(e)

			var candidatos = matching_enemies if not matching_enemies.is_empty() else living_enemies
			var menor_dist: float = 999999.0
			for e in candidatos:
				var d = player_ref.global_position.distance_to(e.global_position)
				if d < menor_dist:
					menor_dist = d
					current_target_node = e
					current_target_pos = e.global_position
					target_found = true
					var esys = e.get_node_or_null("EnemySystem")
					if esys != null and "enemy_name" in esys and not str(esys.enemy_name).is_empty():
						current_target_name = str(esys.enemy_name)

		QuestObjective.Type.COLLECT:
			current_target_type = "loot"
			current_target_name = str(obj_pendente.item_id).replace("_", " ").capitalize()
			var loots = get_tree().get_nodes_in_group("loot")
			for l in loots:
				if l is Node2D and is_instance_valid(l) and not l.is_queued_for_deletion():
					current_target_node = l
					current_target_pos = l.global_position
					target_found = true
					break

		QuestObjective.Type.INVESTIGATE:
			current_target_type = "clue"
			var clue_str = str(obj_pendente.target_clue_id).to_lower()
			current_target_name = "Pista de Aura [GYO]" if clue_str.is_empty() else clue_str.replace("_", " ").capitalize()
			var clues = get_tree().get_nodes_in_group("gyo_inspectable")
			var best_clue: Node2D = null
			var best_dist: float = 999999.0
			for c in clues:
				if c is Node2D and is_instance_valid(c) and not c.is_queued_for_deletion():
					var c_id = str(c.clue_id).to_lower() if "clue_id" in c else ""
					if clue_str.is_empty() or clue_str in c_id or c_id in clue_str or clue_str in c.name.to_lower():
						var d = player_ref.global_position.distance_to(c.global_position)
						if d < best_dist:
							best_dist = d
							best_clue = c
			if best_clue != null:
				current_target_node = best_clue
				current_target_pos = best_clue.global_position
				target_found = true

		QuestObjective.Type.STEALTH_PASS:
			current_target_type = "stealth"
			var zone_str = str(obj_pendente.target_zone_id).to_lower()
			current_target_name = "Zona Furtiva [ZETSU]" if zone_str.is_empty() else zone_str.replace("_", " ").capitalize()
			var zones = get_tree().get_nodes_in_group("zetsu_sensor_zone")
			var best_zone: Node2D = null
			var best_dist: float = 999999.0
			for z in zones:
				if z is Node2D and is_instance_valid(z) and not z.is_queued_for_deletion():
					var z_id = str(z.zone_id).to_lower() if "zone_id" in z else ""
					if zone_str.is_empty() or zone_str in z_id or z_id in zone_str or zone_str in z.name.to_lower():
						var d = player_ref.global_position.distance_to(z.global_position)
						if d < best_dist:
							best_dist = d
							best_zone = z
			if best_zone != null:
				current_target_node = best_zone
				current_target_pos = best_zone.global_position
				target_found = true

	# 2. ROTEAMENTO INTER-MAPAS: Se o alvo NÃO foi encontrado no mapa atual,
	# encontrar o portão/transição que conecta em direção à região da missão
	if not target_found:
		var transicoes: Array = []
		_coletar_areas_transicao(get_tree().current_scene, transicoes)
		
		var destino_mapa_esperado: String = _obter_mapa_esperado_da_quest(quest)
		var transicao_candidata: Node2D = null

		# 1º: Procura primeiro a transição cujo target_scene_path bate com o mapa esperado
		for t in transicoes:
			if t is MapTransitionArea and not destino_mapa_esperado.is_empty():
				if t.target_scene_path == destino_mapa_esperado or destino_mapa_esperado in t.target_scene_path:
					transicao_candidata = t
					break

		# 2º: Procura portal com StoryGate que autoriza o avanço
		if transicao_candidata == null:
			for t in transicoes:
				if t is MapTransitionArea and t.story_gate != null:
					transicao_candidata = t
					break

		# 3º: Procura transição de mapa que não seja interior de residência nem retorno
		if transicao_candidata == null:
			for t in transicoes:
				if t is MapTransitionArea:
					var target_p = t.target_scene_path.to_lower()
					var t_name = t.name.to_lower()
					if not "interior" in target_p and not "casa" in target_p and not "retorno" in t_name:
						transicao_candidata = t
						break

		# Fallback geral
		if transicao_candidata == null and not transicoes.is_empty():
			transicao_candidata = transicoes[0] as Node2D

		if transicao_candidata != null:
			current_target_node = transicao_candidata
			current_target_pos = transicao_candidata.global_position
			current_target_type = "portal"
			if transicao_candidata is MapTransitionArea and not transicao_candidata.portal_name.is_empty():
				current_target_name = transicao_candidata.portal_name
			else:
				current_target_name = "Portão de Viagem"
			target_found = true

	# Atualizar Distância e UI do GPS
	if target_found and player_ref != null:
		_atualizar_render_gps(pendente_idx, total_objetivos, faltam)
	else:
		if lbl_target_info:
			var prefixo_passo = "👉 Passo %d/%d" % [pendente_idx + 1, total_objetivos]
			lbl_target_info.text = "%s: %s (%d/%d)" % [prefixo_passo, obj_pendente.describe(), prog_atual, req_total]
			lbl_target_info.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9, 1.0))


func _obter_mapa_esperado_da_quest(quest: Quest) -> String:
	if quest == null:
		return ""
	var q_name = quest.quest_name.to_lower()
	if "padokia" in q_name or "wing" in q_name or "guardião" in q_name:
		if "guardião" in q_name or "ruínas" in q_name or "dungeon" in q_name:
			return "res://world/maps/dungeon_ruinas_zaban.tscn"
		return "res://world/maps/regiao_vale_padokia.tscn"

	var arco: int = PlayerData.arco_atual
	match arco:
		1: return "res://world/maps/exame_maratona.tscn"
		2: return "res://world/maps/montanha_kukuroo.tscn"
		3: return "res://world/maps/arena_celestial.tscn"
		4: return "res://world/maps/yorknew_city.tscn"
		5: return "res://world/maps/greed_island.tscn"
		6: return "res://world/maps/ngl_formigas.tscn"
		7: return "res://world/maps/associacao_hunter.tscn"
		8: return "res://world/maps/continente_negro.tscn"
		9: return "res://world/maps/black_whale_1.tscn"
	return ""


func _atualizar_render_gps(pendente_idx: int, total_objetivos: int, faltam: int = 1) -> void:
	if not target_found or player_ref == null:
		return

	distance_to_target = player_ref.global_position.distance_to(current_target_pos)
	var dir_vec = (current_target_pos - player_ref.global_position).normalized()
	var target_angle = dir_vec.angle()
	smooth_angle = lerp_angle(smooth_angle, target_angle, 0.25)
	
	var metros = max(1, int(distance_to_target / 10.0))
	var prefixo_passo = "👉 Passo %d/%d" % [pendente_idx + 1, total_objetivos]
	
	if distance_to_target <= ARRIVAL_DISTANCE:
		match current_target_type:
			"npc":
				lbl_target_info.text = "💬 [E] Fale com [%s] agora!" % current_target_name
				lbl_target_info.add_theme_color_override("font_color", Color(0.2, 1.0, 0.4, 1.0))
			"enemy":
				lbl_target_info.text = "⚔️ [Ataque] Derrote [%s]! (Faltam %d)" % [current_target_name, faltam]
				lbl_target_info.add_theme_color_override("font_color", Color(1.0, 0.35, 0.35, 1.0))
			"loot":
				lbl_target_info.text = "🎒 [E] Colete [%s] no chão!" % current_target_name
				lbl_target_info.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3, 1.0))
			"clue":
				lbl_target_info.text = "🔍 [GYO] Examine [%s] com técnica GYO!" % current_target_name
				lbl_target_info.add_theme_color_override("font_color", Color(0.2, 0.9, 1.0, 1.0))
			"stealth":
				lbl_target_info.text = "🥷 [ZETSU] Atravesse [%s] em modo ZETSU!" % current_target_name
				lbl_target_info.add_theme_color_override("font_color", Color(0.4, 1.0, 0.7, 1.0))
			"portal":
				lbl_target_info.text = "⛩️ [E] Entre no [%s] para prosseguir!" % current_target_name
				lbl_target_info.add_theme_color_override("font_color", Color(1.0, 0.9, 0.2, 1.0))
			_:
				lbl_target_info.text = "🎯 Chegou ao Alvo: [%s]" % current_target_name
				lbl_target_info.add_theme_color_override("font_color", Color(1.0, 0.9, 0.2, 1.0))
	else:
		var seta_char = _obter_icone_seta(smooth_angle)
		match current_target_type:
			"npc":
				lbl_target_info.text = "%s: Fale com [%s] ➔ %s (%dm)" % [prefixo_passo, current_target_name, seta_char, metros]
				lbl_target_info.add_theme_color_override("font_color", Color(0.3, 0.9, 1.0, 1.0))
			"enemy":
				lbl_target_info.text = "%s: Derrote [%s] (Faltam %d) ➔ %s (%dm)" % [prefixo_passo, current_target_name, faltam, seta_char, metros]
				lbl_target_info.add_theme_color_override("font_color", Color(1.0, 0.4, 0.4, 1.0))
			"loot":
				lbl_target_info.text = "%s: Colete [%s] (Faltam %d) ➔ %s (%dm)" % [prefixo_passo, current_target_name, faltam, seta_char, metros]
				lbl_target_info.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3, 1.0))
			"clue":
				lbl_target_info.text = "%s: Investigue [%s] com GYO ➔ %s (%dm)" % [prefixo_passo, current_target_name, seta_char, metros]
				lbl_target_info.add_theme_color_override("font_color", Color(0.2, 0.9, 1.0, 1.0))
			"stealth":
				lbl_target_info.text = "%s: Atravesse [%s] com ZETSU ➔ %s (%dm)" % [prefixo_passo, current_target_name, seta_char, metros]
				lbl_target_info.add_theme_color_override("font_color", Color(0.4, 1.0, 0.7, 1.0))
			"portal":
				lbl_target_info.text = "%s: Siga pelo [%s] ➔ %s (%dm)" % [prefixo_passo, current_target_name, seta_char, metros]
				lbl_target_info.add_theme_color_override("font_color", Color(1.0, 0.8, 0.2, 1.0))
			_:
				lbl_target_info.text = "%s: Siga a rota ➔ %s (%dm)" % [prefixo_passo, seta_char, metros]
				lbl_target_info.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3, 1.0))


func _draw() -> void:
	if not target_found or player_ref == null:
		return

	var bobbing = sin(pulse_time * 5.0) * 3.0
	var radius = ORBIT_RADIUS + bobbing

	var dir = Vector2.from_angle(smooth_angle)
	var arrow_center = dir * radius

	# Cores da Seta
	var cor_principal := Color(1.0, 0.85, 0.2, 0.95) # Ouro / Dourado
	var cor_borda := Color(0.1, 0.1, 0.1, 0.9)

	match current_target_type:
		"npc":
			cor_principal = Color(0.3, 0.9, 1.0, 0.95) # Ciano Celeste
		"enemy":
			cor_principal = Color(1.0, 0.3, 0.3, 0.95) # Vermelho Carmesim
		"loot":
			cor_principal = Color(0.4, 1.0, 0.4, 0.95) # Verde Esmeralda
		"portal":
			cor_principal = Color(1.0, 0.9, 0.2, 0.95) # Ouro Radiante

	if distance_to_target <= ARRIVAL_DISTANCE:
		# Efeito de anel pulsante quando próximo ao objetivo
		var pulse_radius = 12.0 + sin(pulse_time * 8.0) * 4.0
		draw_arc(Vector2.ZERO, pulse_radius, 0, TAU, 24, Color(cor_principal.r, cor_principal.g, cor_principal.b, 0.6), 1.5, true)

	# Desenhar triângulo estilizado apontando na direção do alvo
	var angle = smooth_angle
	var p_tip = arrow_center + Vector2.from_angle(angle) * 7.0
	var p_left = arrow_center + Vector2.from_angle(angle + 2.5) * 5.0
	var p_right = arrow_center + Vector2.from_angle(angle - 2.5) * 5.0

	var pontos = PackedVector2Array([p_tip, p_left, p_right])
	draw_colored_polygon(pontos, cor_principal)
	draw_polyline(PackedVector2Array([p_tip, p_left, p_right, p_tip]), cor_borda, 1.0, true)


func _obter_icone_seta(rad_angle: float) -> String:
	var deg = rad_to_deg(rad_angle)
	if deg >= -22.5 and deg < 22.5: return "➡ Leste"
	elif deg >= 22.5 and deg < 67.5: return "↘ Sudeste"
	elif deg >= 67.5 and deg < 112.5: return "⬇ Sul"
	elif deg >= 112.5 and deg < 157.5: return "↙ Sudoeste"
	elif deg >= -67.5 and deg < -22.5: return "↗ Nordeste"
	elif deg >= -112.5 and deg < -67.5: return "⬆ Norte"
	elif deg >= -157.5 and deg < -112.5: return "↖ Noroeste"
	else: return "⬅ Oeste"


func _buscar_no_recursivo_por_nome(parent: Node, target_id: String, target_name: String) -> Node2D:
	if parent == null:
		return null
	if parent is Node2D:
		var p_name: String = parent.name.to_lower() if parent.name != null else ""
		if target_id in p_name or p_name in target_id or target_name in p_name:
			return parent
		if "npc_name" in parent and parent.npc_name != null and str(parent.npc_name).to_lower() in target_name:
			return parent
			
	for child in parent.get_children():
		if child != null:
			var res = _buscar_no_recursivo_por_nome(child, target_id, target_name)
			if res != null:
				return res
	return null


func _coletar_areas_transicao(node: Node, out_list: Array) -> void:
	if node == null or not is_instance_valid(node) or node.is_queued_for_deletion():
		return
	var n_name: String = node.name.to_lower() if node.name != null else ""
	if (node is MapTransitionArea or n_name.begins_with("portal") or n_name.begins_with("portao") or node.is_in_group("portal") or node.is_in_group("transition")) and not (node is MissionGPSIndicator):
		if node is Node2D:
			out_list.append(node)
	for child in node.get_children():
		if child != null:
			_coletar_areas_transicao(child, out_list)


func _coletar_inimigos_recursivo(parent: Node, out_list: Array[Node2D]) -> void:
	if parent == null or not is_instance_valid(parent) or parent.is_queued_for_deletion():
		return
	if parent is CharacterBody2D and (parent.get_node_or_null("EnemySystem") != null or parent.name.to_lower().begins_with("inimigo") or parent.name.to_lower().begins_with("monstro")):
		if not out_list.has(parent):
			out_list.append(parent)
	for child in parent.get_children():
		if child != null:
			_coletar_inimigos_recursivo(child, out_list)
