class_name NetworkProtocol
extends RefCounted

# ============================================================
# HUNTER ONLINE - NETWORK PROTOCOL (MMORPG FOUNDATION)
# ============================================================
#
# Estrutura base de pacotes de rede e serialização para MMORPG:
# - Definição de Opcodes padronizados
# - Empacotamento e desempacotamento de estados autoritativos
# - Sincronização de posição, combate, Nen e chat
#
# ============================================================

enum Opcode {
	# Handshake & Conexão
	PING = 0x01,
	PONG = 0x02,
	AUTH_LOGIN = 0x10,
	AUTH_RESPONSE = 0x11,
	
	# Sincronização de Entidades
	PLAYER_STATE_SYNC = 0x20,
	PLAYER_ACTION = 0x21,
	ENTITY_SPAWN = 0x22,
	ENTITY_DESPAWN = 0x23,
	
	# Combate & Nen
	COMBAT_DAMAGE_EVENT = 0x30,
	NEN_STATE_SYNC = 0x31,
	HATSU_CAST_EVENT = 0x32,
	
	# Mundo & Eventos
	WORLD_EVENT_SYNC = 0x40,
	TIME_SYNC = 0x41,
	
	# Social & Chat
	CHAT_MESSAGE = 0x50,
	PARTY_INVITE = 0x51
}


# Empacota um dicionário de dados com cabeçalho padrão
static func create_packet(opcode: int, payload: Dictionary) -> Dictionary:
	return {
		"op": opcode,
		"seq": Time.get_ticks_msec(),
		"data": payload
	}


# Valida a integridade básica de um pacote recebido
static func validate_packet(packet: Dictionary) -> bool:
	return packet.has("op") and packet.has("data") and typeof(packet["op"]) == TYPE_INT


# Serialização de estado do jogador para replicação no servidor
static func serialize_player_state(player_id: String, pos: Vector2, vel: Vector2, facing: Vector2, hp: int, aura: float, nen_tech: String) -> Dictionary:
	return {
		"pid": player_id,
		"x": snappedf(pos.x, 0.1),
		"y": snappedf(pos.y, 0.1),
		"vx": snappedf(vel.x, 0.1),
		"vy": snappedf(vel.y, 0.1),
		"fx": snappedf(facing.x, 0.1),
		"fy": snappedf(facing.y, 0.1),
		"hp": hp,
		"aura": snappedf(aura, 0.1),
		"nen": nen_tech
	}


# Deserialização de estado do jogador
static func deserialize_player_state(data: Dictionary) -> Dictionary:
	return {
		"player_id": data.get("pid", ""),
		"position": Vector2(data.get("x", 0.0), data.get("y", 0.0)),
		"velocity": Vector2(data.get("vx", 0.0), data.get("vy", 0.0)),
		"facing": Vector2(data.get("fx", 0.0), data.get("fy", 0.0)),
		"hp": data.get("hp", 100),
		"aura": data.get("aura", 0.0),
		"active_nen": data.get("nen", "NONE")
	}
