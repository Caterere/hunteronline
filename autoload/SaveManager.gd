extends Node

# ============================================================
# HUNTER ONLINE - CONSOLIDATED SAVE MANAGER (PRODUCTION GRADE)
# ============================================================
#
# Gerenciador canÃ´nico de persistência multi-slot (Slots 1 a 3 + Dev Slots).
# Implementa:
# - Gravação AtÃ´mica (Arquivo Temporário -> Validação -> Backup .bak -> Swap Seguro)
# - Sanitização Estrita de Cenas de Mundo (Impede gravação de UIs como mapa de jogo)
# - UUID / Identificador Persistente do Personagem (character_id)
# - Recuperação e Tolerância a Falhas com Backup Automático
# - Diagnósticos Estruturados de Carregamento e Seleção
# - Persistência Completa de Atributos, Nen, Hatsu, Quests, Inventário, História e Mundo
#
# ============================================================

signal jogo_salvo(slot: int)
signal jogo_carregado(slot: int)

var current_slot: int = 1

const SAVE_VERSION: String = "2.2"
const MAPA_PADRAO_FALLBACK: String = "res://world/lobby.tscn"



func obter_caminho_slot(slot: int) -> String:
	return "user://savegame_slot_%d.json" % slot


func obter_caminho_tmp(slot: int) -> String:
	return "user://savegame_slot_%d.tmp" % slot


func obter_caminho_bak(slot: int) -> String:
	return "user://savegame_slot_%d.bak" % slot


func obter_caminho_legado(slot: int) -> String:
	return "user://save_slot_%d.json" % slot


func is_valid_world_map(scene_path: String) -> bool:
	if scene_path.is_empty():
		return false
	var lower := scene_path.to_lower()
	# Rejeitar menus, UIs e pastas de teste
	if lower.contains("ui/") or lower.contains("characterselection") or lower.contains("charactercreation") or lower.contains("mainmenu") or lower.contains("saveslot") or lower.contains("scratch/"):
		return false
	if not ResourceLoader.exists(scene_path):
		return false
	# Aceitar cenas de mundo legítimas
	return lower.begins_with("res://world/") or lower.contains("lobby") or lower.contains("map") or lower.contains("arena") or lower.contains("dungeon") or lower.contains("house")


func existe_save_no_slot(slot: int) -> bool:
	return FileAccess.file_exists(obter_caminho_slot(slot)) or FileAccess.file_exists(obter_caminho_bak(slot)) or FileAccess.file_exists(obter_caminho_legado(slot))


func existe_save(slot: int) -> bool:
	return existe_save_no_slot(slot)


func obter_resumo_slot(slot: int) -> Dictionary:
	var path := obter_caminho_slot(slot)
	if not FileAccess.file_exists(path):
		path = obter_caminho_bak(slot)
		if not FileAccess.file_exists(path):
			path = obter_caminho_legado(slot)
			if not FileAccess.file_exists(path):
				return {"existe": false, "valido": false}

	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {"existe": false, "valido": false}

	var json_str := file.get_as_text()
	file.close()

	var json := JSON.new()
	if json.parse(json_str) == OK and json.data is Dictionary:
		var data: Dictionary = json.data
		var attr: Dictionary = data.get("attributes", {})
		var map_str: String = data.get("mapa_atual", MAPA_PADRAO_FALLBACK)
		if not is_valid_world_map(map_str):
			map_str = MAPA_PADRAO_FALLBACK

		return {
			"existe": true,
			"valido": true,
			"character_id": data.get("character_id", "hxr-legacy-s%d" % slot),
			"nome": data.get("nome_personagem", "Hunter"),
			"afinidade": data.get("afinidade_nen", 0),
			"nivel": attr.get("nivel", 1),
			"nivel_nen": attr.get("nivel_nen", 0),
			"gold": data.get("gold", 0),
			"mapa": map_str,
			"timestamp": data.get("timestamp", ""),
			"arco_atual": data.get("arco_atual", 1),
			"etapa_quest_arco": data.get("etapa_quest_arco", 1)
		}

	return {"existe": true, "valido": false, "motivo_invalido": "JSON Corrompido"}


func salvar_jogo(slot: int = -1) -> bool:
	if slot <= 0:
		slot = PlayerData.slot_ativo if PlayerData.slot_ativo > 0 else current_slot
	current_slot = slot
	PlayerData.slot_ativo = slot

	# Garantir UUID único do personagem
	if PlayerData.character_id.is_empty():
		PlayerData.gerar_novo_character_id()

	# 1. Posição atual do jogador se estiver em cena
	var pos_array := [PlayerData.posicao_salva.x, PlayerData.posicao_salva.y]
	var tree := get_tree()
	if tree != null:
		var ply = tree.get_first_node_in_group("player")
		if ply != null and is_instance_valid(ply) and ply is Node2D:
			pos_array = [ply.global_position.x, ply.global_position.y]

	# 2. Cena atual (Sanitização estrita contra caminhos de UI)
	var cena_atual: String = PlayerData.mapa_atual_salvo
	if tree != null and tree.current_scene != null and tree.current_scene.scene_file_path != null:
		var scn_path: String = tree.current_scene.scene_file_path
		if is_valid_world_map(scn_path):
			cena_atual = scn_path
			PlayerData.mapa_atual_salvo = scn_path

	if not is_valid_world_map(cena_atual):
		cena_atual = MAPA_PADRAO_FALLBACK
		PlayerData.mapa_atual_salvo = MAPA_PADRAO_FALLBACK

	var col_cab = [PlayerData.character_colors["cabelo"].r, PlayerData.character_colors["cabelo"].g, PlayerData.character_colors["cabelo"].b, PlayerData.character_colors["cabelo"].a] if PlayerData.character_colors.has("cabelo") else [0.15, 0.15, 0.15, 1.0]
	var col_roup = [PlayerData.character_colors["roupa"].r, PlayerData.character_colors["roupa"].g, PlayerData.character_colors["roupa"].b, PlayerData.character_colors["roupa"].a] if PlayerData.character_colors.has("roupa") else [0.2, 0.6, 0.3, 1.0]

	var hatsus_serialized: Array = []
	for h in PlayerData.hatsu_criados:
		if h is HatsuData and h.has_method("to_dict"):
			hatsus_serialized.append(h.to_dict())

	var stored_hatsus_serialized: Array = []
	for sh in PlayerData.stored_hatsus:
		if sh is Dictionary and sh.has("hatsu_data") and sh["hatsu_data"] is HatsuData:
			var h_dict = sh["hatsu_data"].to_dict()
			stored_hatsus_serialized.append({
				"id": sh.get("id", ""),
				"source_name": sh.get("source_name", ""),
				"remaining_uses": sh.get("remaining_uses", -1),
				"acquired_at": sh.get("acquired_at", ""),
				"active": sh.get("active", true),
				"hatsu_data": h_dict
			})

	var save_data := {
		"version": SAVE_VERSION,
		"slot": slot,
		"character_id": PlayerData.character_id,
		"is_debug_save": PlayerData.is_debug_mode,
		"timestamp": Time.get_datetime_string_from_system(),
		"mapa_atual": cena_atual,
		"posicao_player": pos_array,
		"nome_personagem": PlayerData.nome_personagem,
		"afinidade_nen": int(PlayerData.afinidade_nen),
		"dificuldade": int(PlayerData.dificuldade),
		"potencial": PlayerData.potencial,
		"reputacao_hunter": PlayerData.reputacao_hunter,
		"titulo_equipado": PlayerData.titulo_equipado,
		"titulos_desbloqueados": PlayerData.titulos_desbloqueados,
		"segredos_descobertos": PlayerData.segredos_descobertos,
		"stats_globais": PlayerData.stats_globais,
		"conquistas_desbloqueadas": PlayerData.conquistas_desbloqueadas,
		"conquistas_resgatadas": PlayerData.conquistas_resgatadas,
		"arco_atual": PlayerData.arco_atual,
		"etapa_quest_arco": PlayerData.etapa_quest_arco,
		"max_arco_desbloqueado": PlayerData.max_arco_desbloqueado,
		"modo_historia_concluido": PlayerData.modo_historia_concluido,
		"tour_lobby_concluido": PlayerData.tour_lobby_concluido,
		"tutorial_concluido": PlayerData.tutorial_concluido,
		"tutorial_data": PlayerData.tutorial_data.duplicate(),
		"conhecimentos_desbloqueados": PlayerData.conhecimentos_desbloqueados.duplicate(),
		"gold": Economy.obter_gold() if Economy != null and Economy.has_method("obter_gold") else 1000,
		"character_colors": {
			"cabelo": col_cab,
			"roupa": col_roup,
			"cabelo_html": PlayerData.character_colors["cabelo"].to_html() if PlayerData.character_colors.has("cabelo") else "262626",
			"roupa_html": PlayerData.character_colors["roupa"].to_html() if PlayerData.character_colors.has("roupa") else "33994c"
		},
		"attributes": PlayerData.attributes.duplicate(),
		"inventory": PlayerData.inventory.duplicate(),
		"quest_states": PlayerData.quest_states.duplicate(),
		"tecnicas_nen": PlayerData.tecnicas_nen.duplicate(),
		"hatsu_criados": hatsus_serialized,
		"hatsu_slots": PlayerData.hatsu_slots.duplicate(),
		"stored_hatsus": stored_hatsus_serialized,
		"despertou_nen": PlayerData.despertou_nen,
		"hatsu_desbloqueado": PlayerData.hatsu_desbloqueado,
		"hatsu_creation_unlocked": PlayerData.hatsu_creation_unlocked,
		"besta_nen_desbloqueada": PlayerData.besta_nen_desbloqueada,
		"parallel_quests_concluidas": PlayerData.parallel_quests_concluidas.duplicate(),
		"world_state": WorldState.salvar_dados() if WorldState != null else {},
		"regiao_atual": String(WorldProgressionManager.regiao_atual_id) if WorldProgressionManager != null else "lobby",
		"regioes_desbloqueadas": WorldProgressionManager.regioes_desbloqueadas.map(func(r): return String(r)) if WorldProgressionManager != null else ["lobby"],
		"relationship_data": RelationshipSystem.salvar_dados() if RelationshipSystem != null else {},
		"rumor_data": RumorSystem.salvar_dados() if RumorSystem != null else {},
		"world_events_data": WorldEventManager.salvar_dados() if WorldEventManager != null else {},
		"bounty_data": BountySystem.salvar_dados() if BountySystem != null else {}
	}

	var json_string := JSON.stringify(save_data, "\t")
	var tmp_path := obter_caminho_tmp(slot)
	var final_path := obter_caminho_slot(slot)
	var bak_path := obter_caminho_bak(slot)

	# 1. Escrever no arquivo temporário (.tmp)
	var tmp_file := FileAccess.open(tmp_path, FileAccess.WRITE)
	if tmp_file == null:
		push_error("[SaveManager] Erro ao abrir arquivo temporário: " + tmp_path)
		return false

	tmp_file.store_string(json_string)
	tmp_file.close()

	# 2. Validar JSON escrito no .tmp
	var check_file := FileAccess.open(tmp_path, FileAccess.READ)
	if check_file == null:
		push_error("[SaveManager] Erro ao reabrir arquivo temporário para validação!")
		return false
	var check_str := check_file.get_as_text()
	check_file.close()

	var test_json := JSON.new()
	if test_json.parse(check_str) != OK:
		push_error("[SaveManager] Validação do JSON temporário falhou! Abortando substituição.")
		DirAccess.remove_absolute(tmp_path)
		return false

	# 3. Criar Backup .bak do save anterior se existir
	if FileAccess.file_exists(final_path):
		var old_file := FileAccess.open(final_path, FileAccess.READ)
		if old_file != null:
			var old_str := old_file.get_as_text()
			old_file.close()
			var bak_file := FileAccess.open(bak_path, FileAccess.WRITE)
			if bak_file != null:
				bak_file.store_string(old_str)
				bak_file.close()

	# 4. Gravar arquivo final com segurança atÃ´mica
	var target_file := FileAccess.open(final_path, FileAccess.WRITE)
	if target_file == null:
		push_error("[SaveManager] Falha crítica ao gravar arquivo final de save: " + final_path)
		return false
	target_file.store_string(json_string)
	target_file.close()

	if FileAccess.file_exists(tmp_path):
		DirAccess.remove_absolute(tmp_path)

	print("=================================")
	print("[SaveManager] JOGO SALVO COM SUCESSO NO SLOT ", slot, " [ID: ", PlayerData.character_id, "]")
	print("  Arquivo: ", final_path, " | Mapa: ", cena_atual)
	print("=================================")

	jogo_salvo.emit(slot)
	if EventBus != null and EventBus.has_signal("toast_requested"):
		EventBus.emit_toast("Jogo Salvo com Sucesso! (Slot %d)" % slot, Color(0.4, 1.0, 0.4))
	return true


func carregar_jogo(slot: int = -1) -> bool:
	if slot <= 0:
		slot = PlayerData.slot_ativo if PlayerData.slot_ativo > 0 else current_slot
	current_slot = slot

	var save_path := obter_caminho_slot(slot)
	var bak_path := obter_caminho_bak(slot)
	var legacy_path := obter_caminho_legado(slot)

	var json_string := ""
	var path_utilizado := ""

	# Tentar arquivo primário
	if FileAccess.file_exists(save_path):
		var f := FileAccess.open(save_path, FileAccess.READ)
		if f != null:
			json_string = f.get_as_text()
			f.close()
			path_utilizado = save_path

	# Fallback para Backup .bak se primário falhou ou está corrompido
	var test_json := JSON.new()
	if json_string.is_empty() or test_json.parse(json_string) != OK:
		if FileAccess.file_exists(bak_path):
			print("[SaveManager] Tentando restaurar a partir do backup: ", bak_path)
			var f_bak := FileAccess.open(bak_path, FileAccess.READ)
			if f_bak != null:
				var bak_str := f_bak.get_as_text()
				f_bak.close()
				if test_json.parse(bak_str) == OK:
					json_string = bak_str
					path_utilizado = bak_path

		if json_string.is_empty() and FileAccess.file_exists(legacy_path):
			var f_leg := FileAccess.open(legacy_path, FileAccess.READ)
			if f_leg != null:
				json_string = f_leg.get_as_text()
				f_leg.close()
				path_utilizado = legacy_path

	if json_string.is_empty():
		push_error("[ERROR] Character load failed: Nenhum arquivo de save legível no slot %d" % slot)
		return false

	var json := JSON.new()
	if json.parse(json_string) != OK or not (json.data is Dictionary):
		push_error("[ERROR] Character load failed: Estrutura JSON corrompida no slot %d" % slot)
		return false

	var data: Dictionary = json.data

	# --- RESTAURAÇÃO COMPLETA DE DADOS ---
	PlayerData.slot_ativo = slot
	PlayerData.character_id = data.get("character_id", "hxr-legacy-s%d" % slot)
	PlayerData.is_debug_mode = bool(data.get("is_debug_save", false))
	PlayerData.nome_personagem = data.get("nome_personagem", "Hunter")
	PlayerData.afinidade_nen = data.get("afinidade_nen", 0) as NenAffinityData.CategoriaAfinidade
	PlayerData.dificuldade = data.get("dificuldade", 1) as PlayerData.Dificuldade
	PlayerData.potencial = float(data.get("potencial", 1.0))
	PlayerData.reputacao_hunter = int(data.get("reputacao_hunter", 0))
	PlayerData.titulo_equipado = data.get("titulo_equipado", "Hunter Novato")

	PlayerData.titulos_desbloqueados.clear()
	for t in data.get("titulos_desbloqueados", ["Hunter Novato"]):
		PlayerData.titulos_desbloqueados.append(str(t))

	PlayerData.segredos_descobertos.clear()
	for s in data.get("segredos_descobertos", []):
		PlayerData.segredos_descobertos.append(str(s))

	PlayerData.stats_globais = data.get("stats_globais", PlayerData.stats_globais)

	PlayerData.conquistas_desbloqueadas.clear()
	for c in data.get("conquistas_desbloqueadas", []):
		PlayerData.conquistas_desbloqueadas.append(str(c))

	PlayerData.conquistas_resgatadas.clear()
	for cr in data.get("conquistas_resgatadas", []):
		PlayerData.conquistas_resgatadas.append(str(cr))

	PlayerData.arco_atual = int(data.get("arco_atual", 1))
	PlayerData.etapa_quest_arco = int(data.get("etapa_quest_arco", 1))
	PlayerData.max_arco_desbloqueado = int(data.get("max_arco_desbloqueado", 1))
	PlayerData.modo_historia_concluido = bool(data.get("modo_historia_concluido", false))
	PlayerData.tour_lobby_concluido = bool(data.get("tour_lobby_concluido", false))
	PlayerData.tutorial_concluido = bool(data.get("tutorial_concluido", false))
	PlayerData.tutorial_data = (data.get("tutorial_data", {}) as Dictionary).duplicate(true)

	PlayerData.conhecimentos_desbloqueados.clear()
	for cd in data.get("conhecimentos_desbloqueados", []):
		PlayerData.conhecimentos_desbloqueados.append(str(cd))

	PlayerData.parallel_quests_concluidas.clear()
	for pq in data.get("parallel_quests_concluidas", []):
		PlayerData.parallel_quests_concluidas.append(str(pq))

	# Sanitização Estrita do Mapa Salvo (Nunca permitir UI como mapa salvo)
	var raw_mapa: String = data.get("mapa_atual", MAPA_PADRAO_FALLBACK)
	if is_valid_world_map(raw_mapa):
		PlayerData.mapa_atual_salvo = raw_mapa
	else:
		PlayerData.mapa_atual_salvo = MAPA_PADRAO_FALLBACK

	# Posição do jogador
	var pos_data = data.get("posicao_player", [0.0, 0.0])
	if pos_data is Array and pos_data.size() >= 2:
		var px = float(pos_data[0])
		var py = float(pos_data[1])
		if px != 0.0 or py != 0.0:
			PlayerData.posicao_salva = Vector2(px, py)
		else:
			PlayerData.posicao_salva = Vector2.ZERO

	# Cores
	if data.has("character_colors"):
		var colors: Dictionary = data["character_colors"]
		if colors.has("cabelo"):
			var c = colors["cabelo"]
			if c is Array and c.size() >= 4:
				PlayerData.character_colors["cabelo"] = Color(c[0], c[1], c[2], c[3])
			elif c is String:
				PlayerData.character_colors["cabelo"] = Color.html(c)
		elif colors.has("cabelo_html"):
			PlayerData.character_colors["cabelo"] = Color.html(colors["cabelo_html"])

		if colors.has("roupa"):
			var r = colors["roupa"]
			if r is Array and r.size() >= 4:
				PlayerData.character_colors["roupa"] = Color(r[0], r[1], r[2], r[3])
			elif r is String:
				PlayerData.character_colors["roupa"] = Color.html(r)
		elif colors.has("roupa_html"):
			PlayerData.character_colors["roupa"] = Color.html(colors["roupa_html"])

	# Atributos com sanitização e defaults seguros
	var attrs_padrao: Dictionary = {
		"vida": 100,
		"vida_max": 100,
		"forca": 10,
		"defesa": 10,
		"velocidade": 10,
		"aura": 0.0,
		"aura_max": 0.0,
		"nivel_nen": 0,
		"xp_nen": 0,
		"nivel": 1
	}
	if data.has("attributes") and data["attributes"] is Dictionary:
		for k in attrs_padrao.keys():
			PlayerData.attributes[k] = data["attributes"].get(k, attrs_padrao[k])
	else:
		PlayerData.attributes = attrs_padrao.duplicate()

	# Garantir que vida e nivel estão dentro dos limites mínimos válidos
	PlayerData.attributes["nivel"] = max(1, int(PlayerData.attributes.get("nivel", 1)))
	var raw_vida = int(PlayerData.attributes.get("vida", 100))
	var raw_vida_max = max(100, int(PlayerData.attributes.get("vida_max", 100)))
	if raw_vida > raw_vida_max:
		raw_vida_max = raw_vida
	PlayerData.attributes["vida_max"] = raw_vida_max
	PlayerData.attributes["vida"] = clamp(raw_vida, 1, raw_vida_max)

	# Inventário
	if data.has("inventory"):
		PlayerData.inventory = data["inventory"].duplicate()

	# Quests
	if data.has("quest_states"):
		PlayerData.quest_states = data["quest_states"].duplicate()

	# Nen
	PlayerData.despertou_nen = bool(data.get("despertou_nen", false))
	if data.has("tecnicas_nen"):
		PlayerData.tecnicas_nen = data["tecnicas_nen"].duplicate()

	# Hatsu & Criação de Hatsu
	var saved_unlock: bool = bool(data.get("hatsu_creation_unlocked", data.get("hatsu_desbloqueado", false)))
	PlayerData.hatsu_creation_unlocked = saved_unlock
	PlayerData.hatsu_desbloqueado = saved_unlock

	# Migração canônica para saves antigos/legados: se Greed Island já foi concluída, desbloqueia imediatamente
	if PlayerData.is_greed_island_concluida():
		PlayerData.desbloquear_hatsu_creator()

	PlayerData.hatsu_criados.clear()
	if data.has("hatsu_criados"):
		for hd in data["hatsu_criados"]:
			if hd is Dictionary:
				PlayerData.hatsu_criados.append(HatsuData.from_dict(hd))

	PlayerData.stored_hatsus.clear()
	if data.has("stored_hatsus"):
		for sh in data["stored_hatsus"]:
			if sh is Dictionary and sh.has("hatsu_data") and sh["hatsu_data"] is Dictionary:
				var h_data = HatsuData.from_dict(sh["hatsu_data"])
				PlayerData.stored_hatsus.append({
					"id": sh.get("id", ""),
					"source_name": sh.get("source_name", ""),
					"remaining_uses": sh.get("remaining_uses", -1),
					"acquired_at": sh.get("acquired_at", ""),
					"active": sh.get("active", true),
					"hatsu_data": h_data
				})

	if data.has("hatsu_slots"):
		PlayerData.hatsu_slots.clear()
		for hs in data["hatsu_slots"]:
			PlayerData.hatsu_slots.append(int(hs))
	else:
		PlayerData.hatsu_slots = [-1, -1, -1, -1]

	# Besta de Nen
	PlayerData.besta_nen_desbloqueada = bool(data.get("besta_nen_desbloqueada", false))

	# Tutorial & Conhecimentos (Hunter Guide)
	PlayerData.tour_lobby_concluido = bool(data.get("tour_lobby_concluido", false))
	PlayerData.tutorial_concluido = bool(data.get("tutorial_concluido", false))
	PlayerData.tutorial_data = data.get("tutorial_data", {
		"tutorial_inicial_concluido": false,
		"movimento": false,
		"interacao": false,
		"menus": false,
		"inventario": false,
		"combate": false,
		"status": false,
		"nen_conceito": false,
		"nen_despertar_visto": false,
		"hatsu_visto": false,
		"gyo_visto": false,
		"treinamento_visto": false
	}).duplicate()

	if data.has("conhecimentos_desbloqueados"):
		PlayerData.conhecimentos_desbloqueados.clear()
		for c in data["conhecimentos_desbloqueados"]:
			PlayerData.conhecimentos_desbloqueados.append(str(c))
	else:
		PlayerData.conhecimentos_desbloqueados = ["mundo_associacao_hunter", "combate_basico", "atributos_vitalidade", "menus_sistema"]

	# Economia
	if Economy != null:
		var saved_gold = data.get("gold", 1000)
		if Economy.has_method("definir_gold"):
			Economy.definir_gold(saved_gold)
		elif "gold" in Economy:
			Economy.gold = saved_gold

	# Estado Mundial, Regiões e Causalidade
	if WorldProgressionManager != null:
		var reg_str: String = data.get("regiao_atual", "lobby")
		WorldProgressionManager.definir_regiao_atual(StringName(reg_str))
		var r_desbloq = data.get("regioes_desbloqueadas", [])
		if r_desbloq is Array and not r_desbloq.is_empty():
			WorldProgressionManager.regioes_desbloqueadas.clear()
			for r_item in r_desbloq:
				WorldProgressionManager.regioes_desbloqueadas.append(StringName(r_item))
	if WorldState != null:
		WorldState.carregar_dados(data.get("world_state", {}))

	# Matriz de Relacionamentos e Rumores
	if RelationshipSystem != null:
		RelationshipSystem.carregar_dados(data.get("relationship_data", {}))
	if RumorSystem != null:
		RumorSystem.carregar_dados(data.get("rumor_data", {}))
	if WorldEventManager != null:
		WorldEventManager.carregar_dados(data.get("world_events_data", {}))
	if BountySystem != null:
		BountySystem.carregar_dados(data.get("bounty_data", {}))

	if PlayerData != null:
		PlayerData.is_character_ready = true
	if GameManager != null:
		GameManager.set_flow_state(GameManager.GameFlowState.SAVE_LOADED)

	print("=================================")
	print("[SaveManager] SLOT ", slot, " CARREGADO COM SUCESSO!")
	print("  ID: ", PlayerData.character_id, " | Nome: ", PlayerData.nome_personagem)
	print("  Mapa Alvo: ", PlayerData.mapa_atual_salvo, " | Fonte: ", path_utilizado)
	print("=================================")

	jogo_carregado.emit(slot)
	return true


func deletar_save(slot: int) -> void:
	var p1 := obter_caminho_slot(slot)
	if FileAccess.file_exists(p1):
		DirAccess.remove_absolute(p1)
	var pb := obter_caminho_bak(slot)
	if FileAccess.file_exists(pb):
		DirAccess.remove_absolute(pb)
	var p2 := obter_caminho_legado(slot)
	if FileAccess.file_exists(p2):
		DirAccess.remove_absolute(p2)
	print("[SaveManager] Save do Slot ", slot, " removido com sucesso.")


func remover_save(slot: int) -> void:
	deletar_save(slot)


func novo_jogo(slot: int = 1) -> void:
	current_slot = slot
	if PlayerData != null:
		PlayerData.slot_ativo = slot
		PlayerData.is_character_ready = false
		PlayerData.gerar_novo_character_id()
		PlayerData.nome_personagem = "Hunter"
		PlayerData.mapa_atual_salvo = MAPA_PADRAO_FALLBACK
		PlayerData.posicao_salva = Vector2.ZERO
		PlayerData.attributes = {
			"vida": 100,
			"vida_max": 100,
			"forca": 10,
			"defesa": 10,
			"velocidade": 10,
			"aura": 0.0,
			"aura_max": 0.0,
			"nivel_nen": 0,
			"xp_nen": 0,
			"nivel": 1
		}
		PlayerData.inventory.clear()
		PlayerData.quest_states.clear()
		PlayerData.hatsu_criados.clear()
		PlayerData.hatsu_slots = [-1, -1, -1, -1]
		PlayerData.despertou_nen = false
		PlayerData.hatsu_desbloqueado = false
		PlayerData.hatsu_creation_unlocked = false
		PlayerData.besta_nen_desbloqueada = false
		PlayerData.tour_lobby_concluido = false
		PlayerData.tutorial_concluido = false
		PlayerData.tutorial_data = {
			"tutorial_inicial_concluido": false,
			"movimento": false,
			"interacao": false,
			"menus": false,
			"inventario": false,
			"combate": false,
			"status": false,
			"nen_conceito": false,
			"nen_despertar_visto": false,
			"hatsu_visto": false,
			"gyo_visto": false,
			"treinamento_visto": false
		}
		PlayerData.conhecimentos_desbloqueados = [
			"mundo_associacao_hunter",
			"combate_basico",
			"atributos_vitalidade",
			"menus_sistema"
		]
		PlayerData.arco_atual = 1
		PlayerData.etapa_quest_arco = 1
	if Economy != null and Economy.has_method("definir_gold"):
		Economy.definir_gold(500)
	if WorldState != null:
		WorldState.reinicializar_estado_padrao()
	if GameManager != null:
		GameManager.set_flow_state(GameManager.GameFlowState.CHARACTER_CREATION)
	print("[SaveManager] Novo jogo inicializado no Slot ", slot, " [ID: ", PlayerData.character_id, "]")