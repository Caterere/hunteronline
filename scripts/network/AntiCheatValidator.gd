class_name AntiCheatValidator
extends RefCounted

# ============================================================
# HUNTER ONLINE — ANTI-CHEAT & INTEGRITY VALIDATOR
# ============================================================
#
# Validador de integridade server-side que rejeita anomalias físicas,
# cadências impossíveis de ataque e tentativas de injeção numérica.
# ============================================================

var _ultimos_ataques: Dictionary = {} # peer_id -> int (ms)
var _logs_suspeitos: Array[String] = []
const MAX_LOGS: int = 50


func validar_movimento(peer_id: int, pos_antiga: Vector2, pos_nova: Vector2, delta_tempo: float, vel_base: float, bonus_nen: float = 0.0) -> bool:
	if delta_tempo <= 0.001:
		return true

	var dist_percorrida: float = pos_antiga.distance_to(pos_nova)
	var vel_max_permitida: float = (vel_base + bonus_nen) * 1.35 # Tolerância de 35% para compensação de jitter/latência
	var dist_max_teorica: float = vel_max_permitida * delta_tempo + 8.0 # Offset mínimo de tolerância de frame

	if dist_percorrida > dist_max_teorica and dist_percorrida > 30.0:
		registrar_alerta(peer_id, "Deslocamento anômalo: %.1f px em %.3f s (Max: %.1f px)" % [dist_percorrida, delta_tempo, dist_max_teorica])
		return false

	return true


func validar_taxa_ataque(peer_id: int, cd_nominal: float) -> bool:
	var agora: int = Time.get_ticks_msec()
	var ultimo: int = int(_ultimos_ataques.get(peer_id, 0))
	var delta_ms: int = agora - ultimo
	var cd_min_ms: int = int(cd_nominal * 1000.0 * 0.70) # 30% tolerância para envio de comandos antecipados

	if delta_ms < cd_min_ms:
		registrar_alerta(peer_id, "Ataque rápido suspeito: intervalo de %d ms (Mínimo: %d ms)" % [delta_ms, cd_min_ms])
		return false

	_ultimos_ataques[peer_id] = agora
	return true


func validar_custo_hatsu(peer_id: int, aura_atual: float, custo_nominal: float) -> bool:
	if aura_atual < custo_nominal:
		registrar_alerta(peer_id, "Cast de Hatsu sem aura: disponível %.1f, custo %.1f" % [aura_atual, custo_nominal])
		return false
	return true


func validar_dano_maximo(peer_id: int, dano_declarado: int, forca_base: int) -> int:
	var teto_teorico: int = max(50, forca_base * 6)
	if dano_declarado > teto_teorico:
		registrar_alerta(peer_id, "Dano excessivo interceptado: %d (Teto matemático: %d)" % [dano_declarado, teto_teorico])
		return teto_teorico
	return dano_declarado


func registrar_alerta(peer_id: int, motivo: String) -> void:
	var log_entry := "[ANTI-CHEAT] Peer %d: %s (Hora: %d)" % [peer_id, motivo, Time.get_ticks_msec()]
	_logs_suspeitos.append(log_entry)
	if _logs_suspeitos.size() > MAX_LOGS:
		_logs_suspeitos.pop_front()
	print(log_entry)


func obter_logs_suspeitos() -> Array[String]:
	return _logs_suspeitos.duplicate()


func limpar_peer(peer_id: int) -> void:
	if _ultimos_ataques.has(peer_id):
		_ultimos_ataques.erase(peer_id)
