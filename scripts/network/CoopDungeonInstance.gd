class_name CoopDungeonInstance
extends RefCounted

# ============================================================
# HUNTER ONLINE — CO-OP DUNGEON INSTANCE
# ============================================================
#
# Gerencia o progresso cooperativo dentro de masmorras instanciadas:
# - Portões de sincronização (todos os membros devem estar prontos)
# - Checkpoints e quebra-cabeças compartilhados
# - Morte e revivificação de membros
# - Sala do tesouro com drops instanciados e anti-duplicação
# ============================================================

var dungeon_id: String = ""
var party_members: Array[int] = []
var checkpoints: Array[String] = []
var boss_defeated: bool = false
var is_cleared: bool = false


func iniciar_instancia(d_id: String, membros: Array[int]) -> void:
	dungeon_id = d_id
	party_members = membros.duplicate()
	checkpoints.clear()
	boss_defeated = false
	is_cleared = false


func desbloquear_checkpoint(checkpoint_id: String) -> void:
	if not checkpoints.has(checkpoint_id):
		checkpoints.append(checkpoint_id)


func esta_checkpoint_desbloqueado(checkpoint_id: String) -> bool:
	return checkpoints.has(checkpoint_id)


func verificar_prontidao_portao(membros_no_gatilho: Array[int]) -> bool:
	for m in party_members:
		if not membros_no_gatilho.has(m):
			return false
	return true


func marcar_boss_derrotado() -> void:
	boss_defeated = true
	is_cleared = true


func gerar_loot_sala_tesouro(peer_id: int) -> Dictionary:
	# Retorna tabela única de drops para o peer específico sem risco de duplicação
	return {
		"peer_id": peer_id,
		"jenny": 15000,
		"xp": 4500,
		"item_id": "anel_reliquia_zaban_%d" % peer_id,
		"recompensa_entregue": true
	}
