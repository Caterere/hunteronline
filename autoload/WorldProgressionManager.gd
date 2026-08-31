class_name WorldProgressionManagerScript
extends Node

# ============================================================
# HUNTER ONLINE - WORLD PROGRESSION & SPAWN MANAGER (AUTOLOAD)
# ============================================================
#
# Gerencia a progressão física e imersiva pelo mundo de Hunter x Hunter:
# - Definição estruturada de Regiões e Sagas conectadas
# - Registro dinâmico e posicionamento preciso de SpawnPoints por mapa
# - Gestão de Checkpoints e Respawn
# - Suporte a travessia contínua de rotas e portais de saga
#
# ============================================================

signal regiao_alterada(regiao_id: String, regiao_nome: String)
signal checkpoint_ativado(checkpoint_id: String, posicao: Vector2)
signal spawn_executado(posicao: Vector2, spawn_id: StringName)

# Registro de Spawns da Cena Atual
var registered_spawns: Dictionary = {} # { StringName(id): SpawnPoint }
var default_spawn_node: SpawnPoint = null

# Parâmetros de Transição Pendente
var target_spawn_id: StringName = &"default"
var target_spawn_position: Vector2 = Vector2.ZERO
var checkpoint_ativo_posicao: Vector2 = Vector2.ZERO
var checkpoint_ativo_mapa: String = ""

# Catálogo Estruturado de Regiões do Mundo
const REGIOES: Dictionary = {
	"lobby": {
		"id": "lobby",
		"nome": "Capital dos Caçadores",
		"subtitulo": "Hunter Plaza — Hub Central",
		"cena": "res://world/lobby.tscn",
		"saga": 0,
		"default_spawn": &"default"
	},
	"exame_hunter": {
		"id": "exame_hunter",
		"nome": "287º Exame Hunter",
		"subtitulo": "Arco 1 — Túnel Subterrâneo & Pantanal Numere",
		"cena": "res://world/maps/exame_maratona.tscn",
		"saga": 1,
		"default_spawn": &"default"
	},
	"montanha_kukuroo": {
		"id": "montanha_kukuroo",
		"nome": "Montanha Kukuroo",
		"subtitulo": "Arco 2 — Propriedade da Família Zoldyck",
		"cena": "res://world/maps/montanha_kukuroo.tscn",
		"saga": 2,
		"default_spawn": &"default"
	},
	"arena_celestial": {
		"id": "arena_celestial",
		"nome": "Arena Celestial",
		"subtitulo": "Arco 3 — O Palco dos Mestres de Nen",
		"cena": "res://world/maps/arena_celestial.tscn",
		"saga": 3,
		"default_spawn": &"default"
	},
	"yorknew_city": {
		"id": "yorknew_city",
		"nome": "Yorknew City",
		"subtitulo": "Arco 4 — Leilão Subterrâneo & Trupe Fantasma",
		"cena": "res://world/maps/yorknew_city.tscn",
		"saga": 4,
		"default_spawn": &"default"
	},
	"greed_island": {
		"id": "greed_island",
		"nome": "Greed Island",
		"subtitulo": "Arco 5 — O Mundo Mágico dos Feitiços e Cartas",
		"cena": "res://world/maps/greed_island.tscn",
		"saga": 5,
		"default_spawn": &"default"
	},
	"ngl_formigas": {
		"id": "ngl_formigas",
		"nome": "NGL — Ninho das Formigas",
		"subtitulo": "Arco 6 — Expedição de Extermínio & Palácio Real",
		"cena": "res://world/maps/ngl_formigas.tscn",
		"saga": 6,
		"default_spawn": &"default"
	},
	"associacao_hunter": {
		"id": "associacao_hunter",
		"nome": "Sede da Associação Hunter",
		"subtitulo": "Arco 7 — A 13ª Eleição do Presidente Hunter",
		"cena": "res://world/maps/associacao_hunter.tscn",
		"saga": 7,
		"default_spawn": &"default"
	},
	"continente_negro": {
		"id": "continente_negro",
		"nome": "O Continente Negro",
		"subtitulo": "Arco 8 — Território Inexplorado das 5 Calamidades",
		"cena": "res://world/maps/continente_negro.tscn",
		"saga": 8,
		"default_spawn": &"default"
	},
	"black_whale_1": {
		"id": "black_whale_1",
		"nome": "Navio Black Whale 1",
		"subtitulo": "Arco 9 — Guerra de Sucessão dos Príncipes",
		"cena": "res://world/maps/black_whale_1.tscn",
		"saga": 9,
		"default_spawn": &"default"
	},
	"vale_padokia": {
		"id": "vale_padokia",
		"nome": "Vale de Padokia",
		"subtitulo": "Região Semiaberta — Território de Exploração",
		"cena": "res://world/maps/regiao_vale_padokia.tscn",
		"saga": 1,
		"default_spawn": &"default"
	},
	"casa_jogador": {
		"id": "casa_jogador",
		"nome": "Residência Pessoal do Caçador",
		"subtitulo": "Distrito Residencial — Hunter Plaza",
		"cena": "res://world/maps/PlayerHouse.tscn",
		"saga": 0,
		"default_spawn": &"default"
	}
}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	print("=================================")
	print("[WorldProgressionManager] GERENCIADOR DE MUNDO E SPAWNS ATIVO")
	print("=================================")


# ============================================================
# 1. GESTÃO DE SPAWN POINTS
# ============================================================

func registrar_spawn_point(spawn: SpawnPoint) -> void:
	if spawn == null or not is_instance_valid(spawn):
		return
	
	registered_spawns[spawn.spawn_id] = spawn
	if spawn.is_default_spawn or default_spawn_node == null:
		default_spawn_node = spawn
	
	print("[WorldProgressionManager] SpawnPoint registrado: '%s' em %s" % [spawn.spawn_id, spawn.global_position])


func limpar_spawn_points() -> void:
	registered_spawns.clear()
	default_spawn_node = null


func definir_destino_spawn(spawn_id: StringName = &"default", pos_exata: Vector2 = Vector2.ZERO) -> void:
	target_spawn_id = spawn_id
	target_spawn_position = pos_exata


func posicionar_player_no_spawn(player: Node2D) -> bool:
	if player == null or not is_instance_valid(player):
		return false

	# 1. Se houver uma posição exata de transição (ex: retorno por portal)
	if target_spawn_position != Vector2.ZERO:
		player.global_position = target_spawn_position
		var pos_usada = target_spawn_position
		target_spawn_position = Vector2.ZERO
		spawn_executado.emit(pos_usada, target_spawn_id)
		return true

	# 2. Se houver SpawnPoint com o ID solicitado registrado no mapa
	if registered_spawns.has(target_spawn_id):
		var sp: SpawnPoint = registered_spawns[target_spawn_id]
		if sp != null and is_instance_valid(sp):
			player.global_position = sp.global_position
			var pos_usada = sp.global_position
			target_spawn_id = &"default"
			spawn_executado.emit(pos_usada, sp.spawn_id)
			return true

	# 3. Fallback para o SpawnPoint default do mapa
	if default_spawn_node != null and is_instance_valid(default_spawn_node):
		player.global_position = default_spawn_node.global_position
		var pos_usada = default_spawn_node.global_position
		target_spawn_id = &"default"
		spawn_executado.emit(pos_usada, default_spawn_node.spawn_id)
		return true

	# 4. Fallback para o primeiro nó de spawn no grupo se não tiver sido registrado ainda
	var tree = get_tree()
	if tree != null:
		var spawns_no_grupo = tree.get_nodes_in_group("spawn_point")
		for sp_node in spawns_no_grupo:
			if sp_node is SpawnPoint and sp_node.spawn_id == target_spawn_id:
				player.global_position = sp_node.global_position
				target_spawn_id = &"default"
				spawn_executado.emit(sp_node.global_position, sp_node.spawn_id)
				return true
		if not spawns_no_grupo.is_empty() and spawns_no_grupo[0] is Node2D:
			player.global_position = spawns_no_grupo[0].global_position
			target_spawn_id = &"default"
			spawn_executado.emit(spawns_no_grupo[0].global_position, &"default")
			return true

	return false


# ============================================================
# 2. CHECKPOINTS & RESPAWN
# ============================================================

func registrar_checkpoint(checkpoint_id: String, posicao: Vector2, cena_mapa: String = "") -> void:
	checkpoint_ativo_posicao = posicao
	checkpoint_ativo_mapa = cena_mapa if not cena_mapa.is_empty() else (get_tree().current_scene.scene_file_path if get_tree().current_scene else "")
	checkpoint_ativado.emit(checkpoint_id, posicao)
	print("[WorldProgressionManager] 🚩 Checkpoint ativado: '%s' em %s (Mapa: %s)" % [checkpoint_id, posicao, checkpoint_ativo_mapa])
	
	if EventBus != null:
		EventBus.emit_toast("🚩 Ponto de Controle Salvo!", Color(0.3, 0.9, 1.0))


func obter_posicao_respawn() -> Vector2:
	if checkpoint_ativo_posicao != Vector2.ZERO:
		return checkpoint_ativo_posicao
	if default_spawn_node != null and is_instance_valid(default_spawn_node):
		return default_spawn_node.global_position
	return Vector2.ZERO


# ============================================================
# 3. INFORMAÇÕES DE REGIÕES
# ============================================================

func obter_info_regiao(regiao_id: String) -> Dictionary:
	return REGIOES.get(regiao_id, {})


func obter_info_regiao_por_cena(caminho_cena: String) -> Dictionary:
	for r_id in REGIOES.keys():
		var r_data: Dictionary = REGIOES[r_id]
		if r_data.get("cena", "") == caminho_cena:
			return r_data
	return {}
