class_name NetworkSession
extends RefCounted

# ============================================================
# HUNTER ONLINE — NETWORK SESSION STATE
# ============================================================
#
# Estrutura em memória que rastreia a sessão de caçada ativa:
# - Identificação da sala/sessão
# - Limite de caçadores (padrão: 4, expansível até 8 para raids)
# - Dicionário de peers conectados e métricas de conectividade
# ============================================================

var session_id: String = ""
var room_name: String = "Lobby de Caçada"
var max_players: int = 4
var current_map_path: String = "res://world/lobby.tscn"
var is_locked: bool = false

# int (peer_id) -> Dictionary
var connected_peers: Dictionary = {}


func _init() -> void:
	session_id = "hunt-%x" % [Time.get_ticks_msec()]


func adicionar_peer(peer_id: int, info: Dictionary = {}) -> void:
	connected_peers[peer_id] = {
		"peer_id": peer_id,
		"name": info.get("name", "Hunter_%d" % peer_id),
		"level": info.get("level", 1),
		"affinity": info.get("affinity", "Intensificação"),
		"hp": info.get("hp", 100),
		"hp_max": info.get("hp_max", 100),
		"aura": info.get("aura", 100.0),
		"aura_max": info.get("aura_max", 100.0),
		"ping_ms": 0,
		"last_seen_ms": Time.get_ticks_msec()
	}


func remover_peer(peer_id: int) -> void:
	if connected_peers.has(peer_id):
		connected_peers.erase(peer_id)


func obter_peer_info(peer_id: int) -> Dictionary:
	return connected_peers.get(peer_id, {})


func atualizar_latencia(peer_id: int, ping: int) -> void:
	if connected_peers.has(peer_id):
		connected_peers[peer_id]["ping_ms"] = ping
		connected_peers[peer_id]["last_seen_ms"] = Time.get_ticks_msec()


func obter_quantidade_jogadores() -> int:
	return connected_peers.size()


func pode_adicionar_jogador() -> bool:
	return (not is_locked) and (connected_peers.size() < max_players)


func limpar() -> void:
	connected_peers.clear()
	is_locked = false
