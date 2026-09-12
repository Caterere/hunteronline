class_name NetworkProtocol
extends RefCounted

# ============================================================
# HUNTER ONLINE - NETWORK PROTOCOL (MMORPG FOUNDATION)
# ============================================================
#
# Estrutura base de pacotes de rede e serialização para MMORPG:
# - Definição de Opcodes padronizados
# - Empacotamento Dictionary (legado) + PackedByteArray compacto (PREREQ-1)
# - Sincronização de posição, combate, Nen e chat
#
# Binary world snapshot v1 (magic HOS1):
#   u32 magic | u8 ver | u8 flags | u32 tick | u32 ts_ms
#   u16 player_count | players... | u16 enemy_count | enemies...
#   u16 rem_players | ids... | u16 rem_enemies | ids...
#
# ============================================================

const SNAPSHOT_MAGIC: int = 0x484F5331 # "HOS1"
const SNAPSHOT_VERSION: int = 1
const FIXED_POINT_SCALE: float = 10.0 # 0.1 world units
const FLAG_FULL: int = 1 << 0

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
	WORLD_SNAPSHOT = 0x24,

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


# ------------------------------------------------------------
# LEGACY DICT SERIALIZATION (compat)
# ------------------------------------------------------------

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


# ------------------------------------------------------------
# PREREQ-1 — BINARY PACKING HELPERS
# ------------------------------------------------------------

static func _to_fixed(v: float) -> int:
	return int(round(v * FIXED_POINT_SCALE))


static func _from_fixed(v: int) -> float:
	return float(v) / FIXED_POINT_SCALE


static func _clamp_i16(v: int) -> int:
	return clampi(v, -32768, 32767)


static func _encode_facing(facing: Vector2) -> int:
	# 8-way facing packed in 3 bits
	if facing.length_squared() < 0.01:
		return 2 # down
	var a := atan2(facing.x, -facing.y) # 0 = up
	var sector := int(round(a / (TAU / 8.0))) & 7
	return sector


static func _decode_facing(code: int) -> Vector2:
	var a := float(code & 7) * (TAU / 8.0)
	return Vector2(sin(a), -cos(a))


## Pacote binário de estado de 1 jogador (Opcode.PLAYER_STATE_SYNC).
## Layout: u8 op | u32 seq | u32 net_id | i32 x|y | i16 vx|vy | u8 facing | u16 hp | u16 aura*10 | utf8 nen
static func pack_player_state_binary(
	net_id: int,
	pos: Vector2,
	vel: Vector2,
	facing: Vector2,
	hp: int,
	aura: float,
	nen_tech: String
) -> PackedByteArray:
	var sp := StreamPeerBuffer.new()
	sp.put_u8(Opcode.PLAYER_STATE_SYNC)
	sp.put_u32(Time.get_ticks_msec())
	sp.put_u32(net_id)
	sp.put_32(_to_fixed(pos.x))
	sp.put_32(_to_fixed(pos.y))
	sp.put_16(_clamp_i16(_to_fixed(vel.x)))
	sp.put_16(_clamp_i16(_to_fixed(vel.y)))
	sp.put_u8(_encode_facing(facing))
	sp.put_u16(clampi(hp, 0, 65535))
	sp.put_u16(clampi(_to_fixed(aura), 0, 65535))
	sp.put_utf8_string(nen_tech if not nen_tech.is_empty() else "NONE")
	return sp.data_array


static func unpack_player_state_binary(bytes: PackedByteArray) -> Dictionary:
	var out := {}
	if bytes.size() < 20:
		return out
	var sp := StreamPeerBuffer.new()
	sp.data_array = bytes
	var op := sp.get_u8()
	if op != Opcode.PLAYER_STATE_SYNC:
		return out
	out["seq"] = int(sp.get_u32())
	out["id"] = int(sp.get_u32())
	out["px"] = _from_fixed(sp.get_32())
	out["py"] = _from_fixed(sp.get_32())
	out["vx"] = _from_fixed(sp.get_16())
	out["vy"] = _from_fixed(sp.get_16())
	var face := _decode_facing(sp.get_u8())
	out["fx"] = face.x
	out["fy"] = face.y
	out["hp"] = int(sp.get_u16())
	out["aura"] = _from_fixed(sp.get_u16())
	out["nen"] = sp.get_utf8_string()
	out["dead"] = false
	return out


static func _pack_player_entry(sp: StreamPeerBuffer, p: Dictionary) -> void:
	sp.put_u32(int(p.get("id", 0)))
	sp.put_32(_to_fixed(float(p.get("px", 0.0))))
	sp.put_32(_to_fixed(float(p.get("py", 0.0))))
	sp.put_16(_clamp_i16(_to_fixed(float(p.get("vx", 0.0)))))
	sp.put_16(_clamp_i16(_to_fixed(float(p.get("vy", 0.0)))))
	sp.put_u8(_encode_facing(Vector2(float(p.get("fx", 0.0)), float(p.get("fy", 1.0)))))
	sp.put_u16(clampi(int(p.get("hp", 0)), 0, 65535))
	sp.put_u16(clampi(int(p.get("hp_max", 100)), 0, 65535))
	sp.put_u16(clampi(_to_fixed(float(p.get("aura", 0.0))), 0, 65535))
	var flags := 0
	if bool(p.get("dead", false)):
		flags |= 1
	sp.put_u8(flags)
	sp.put_utf8_string(str(p.get("nen", "")))


static func _unpack_player_entry(sp: StreamPeerBuffer) -> Dictionary:
	var id := int(sp.get_u32())
	var px := _from_fixed(sp.get_32())
	var py := _from_fixed(sp.get_32())
	var vx := _from_fixed(sp.get_16())
	var vy := _from_fixed(sp.get_16())
	var face := _decode_facing(sp.get_u8())
	var hp := int(sp.get_u16())
	var hp_max := int(sp.get_u16())
	var aura := _from_fixed(sp.get_u16())
	var flags := int(sp.get_u8())
	var nen := sp.get_utf8_string()
	return {
		"id": id,
		"px": px,
		"py": py,
		"vx": vx,
		"vy": vy,
		"fx": face.x,
		"fy": face.y,
		"hp": hp,
		"hp_max": hp_max,
		"aura": aura,
		"nen": nen,
		"dead": (flags & 1) != 0
	}


static func _pack_enemy_entry(sp: StreamPeerBuffer, e: Dictionary) -> void:
	sp.put_u32(int(e.get("id", 0)))
	sp.put_32(_to_fixed(float(e.get("px", 0.0))))
	sp.put_32(_to_fixed(float(e.get("py", 0.0))))
	sp.put_16(_clamp_i16(_to_fixed(float(e.get("vx", 0.0)))))
	sp.put_16(_clamp_i16(_to_fixed(float(e.get("vy", 0.0)))))
	sp.put_u16(clampi(int(e.get("hp", 0)), 0, 65535))
	sp.put_u16(clampi(int(e.get("hp_max", 100)), 0, 65535))
	var flags := 0
	if bool(e.get("boss", false)):
		flags |= 1
	sp.put_u8(flags)
	sp.put_utf8_string(str(e.get("enemy_id", "")))
	sp.put_utf8_string(str(e.get("name", "")))
	sp.put_utf8_string(str(e.get("state", "")))


static func _unpack_enemy_entry(sp: StreamPeerBuffer) -> Dictionary:
	var id := int(sp.get_u32())
	var px := _from_fixed(sp.get_32())
	var py := _from_fixed(sp.get_32())
	var vx := _from_fixed(sp.get_16())
	var vy := _from_fixed(sp.get_16())
	var hp := int(sp.get_u16())
	var hp_max := int(sp.get_u16())
	var flags := int(sp.get_u8())
	var enemy_id := sp.get_utf8_string()
	var name := sp.get_utf8_string()
	var state := sp.get_utf8_string()
	return {
		"id": id,
		"enemy_id": enemy_id,
		"name": name,
		"px": px,
		"py": py,
		"vx": vx,
		"vy": vy,
		"hp": hp,
		"hp_max": hp_max,
		"state": state,
		"boss": (flags & 1) != 0
	}


## Empacota snapshot de mundo (formato do ServerWorldCoordinator) em binário compacto.
static func pack_world_snapshot(snapshot: Dictionary) -> PackedByteArray:
	var sp := StreamPeerBuffer.new()
	sp.put_u32(SNAPSHOT_MAGIC)
	sp.put_u8(SNAPSHOT_VERSION)
	var flags := 0
	if bool(snapshot.get("full", true)):
		flags |= FLAG_FULL
	sp.put_u8(flags)
	sp.put_u32(int(snapshot.get("tick", 0)))
	sp.put_u32(int(snapshot.get("ts", Time.get_ticks_msec())))

	var players: Array = snapshot.get("players", [])
	sp.put_u16(clampi(players.size(), 0, 65535))
	for p in players:
		if p is Dictionary:
			_pack_player_entry(sp, p)

	var enemies: Array = snapshot.get("enemies", [])
	sp.put_u16(clampi(enemies.size(), 0, 65535))
	for e in enemies:
		if e is Dictionary:
			_pack_enemy_entry(sp, e)

	var rem_p: Array = snapshot.get("removed_players", [])
	sp.put_u16(clampi(rem_p.size(), 0, 65535))
	for pid in rem_p:
		sp.put_u32(int(pid))

	var rem_e: Array = snapshot.get("removed_enemies", [])
	sp.put_u16(clampi(rem_e.size(), 0, 65535))
	for eid in rem_e:
		sp.put_u32(int(eid))

	return sp.data_array


static func unpack_world_snapshot(bytes: PackedByteArray) -> Dictionary:
	var out := {}
	if bytes.size() < 12:
		return out
	var sp := StreamPeerBuffer.new()
	sp.data_array = bytes
	var magic := int(sp.get_u32())
	if magic != SNAPSHOT_MAGIC:
		return out
	var ver := int(sp.get_u8())
	if ver != SNAPSHOT_VERSION:
		push_warning("[NetworkProtocol] Snapshot version unsupported: %d" % ver)
		return out
	var flags := int(sp.get_u8())
	out["full"] = (flags & FLAG_FULL) != 0
	out["tick"] = int(sp.get_u32())
	out["ts"] = int(sp.get_u32())

	var p_count := int(sp.get_u16())
	var players: Array = []
	for _i in range(p_count):
		players.append(_unpack_player_entry(sp))
	out["players"] = players

	var e_count := int(sp.get_u16())
	var enemies: Array = []
	for _i in range(e_count):
		enemies.append(_unpack_enemy_entry(sp))
	out["enemies"] = enemies

	var rp_count := int(sp.get_u16())
	var rem_p: Array = []
	for _i in range(rp_count):
		rem_p.append(int(sp.get_u32()))
	out["removed_players"] = rem_p

	var re_count := int(sp.get_u16())
	var rem_e: Array = []
	for _i in range(re_count):
		rem_e.append(int(sp.get_u32()))
	out["removed_enemies"] = rem_e

	return out


static func is_world_snapshot_binary(bytes: PackedByteArray) -> bool:
	if bytes.size() < 4:
		return false
	var sp := StreamPeerBuffer.new()
	sp.data_array = bytes
	return int(sp.get_u32()) == SNAPSHOT_MAGIC


## Compara tamanho dict(var_to_bytes) vs binário compacto.
static func measure_snapshot_sizes(snapshot: Dictionary) -> Dictionary:
	var dict_bytes: PackedByteArray = var_to_bytes(snapshot)
	var bin_bytes: PackedByteArray = pack_world_snapshot(snapshot)
	var ratio := 0.0
	if dict_bytes.size() > 0:
		ratio = float(bin_bytes.size()) / float(dict_bytes.size())
	return {
		"dict_size": dict_bytes.size(),
		"binary_size": bin_bytes.size(),
		"ratio": ratio,
		"saved_bytes": dict_bytes.size() - bin_bytes.size()
	}
