extends Node

# ============================================================
# HUNTER ONLINE — GUILDAS DE CAÇADORES (A6)
# ============================================================
# Orgs de jogadores (não confundir com FactionManager lore).
# Cap 20, bank compartilhado cosmético/jenny, hall id.
# ============================================================

signal guild_created(guild_id: String, name: String)
signal guild_member_joined(guild_id: String, member_id: String)
signal guild_member_left(guild_id: String, member_id: String)
signal guild_disbanded(guild_id: String)

const MAX_MEMBERS := 20
const CREATE_COST := 5000
const ATTR_KEY := "hunter_guild"

var guilds: Dictionary = {} ## guild_id → Dictionary
var _next_id: int = 1


func _ready() -> void:
	print("[HunterGuildSystem] Guildas de Caçadores ativas")


func reset_for_tests() -> void:
	guilds.clear()
	_next_id = 1
	_mirror()


func _player_id() -> String:
	if PlayerData == null:
		return "local_hunter"
	var cid := str(PlayerData.character_id).strip_edges()
	return cid if not cid.is_empty() else "local_hunter"


func _player_name() -> String:
	if PlayerData == null:
		return "Caçador"
	var n := str(PlayerData.nome_personagem).strip_edges()
	return n if not n.is_empty() else "Caçador"


func get_player_guild_id() -> String:
	var pid := _player_id()
	for gid in guilds.keys():
		var g: Dictionary = guilds[gid]
		var members: Array = g.get("members", [])
		for m in members:
			if typeof(m) == TYPE_DICTIONARY and str(m.get("id", "")) == pid:
				return str(gid)
	return ""


func get_player_guild() -> Dictionary:
	var gid := get_player_guild_id()
	if gid.is_empty() or not guilds.has(gid):
		return {}
	return (guilds[gid] as Dictionary).duplicate(true)


func create_guild(guild_name: String, tag: String = "") -> Dictionary:
	guild_name = guild_name.strip_edges()
	tag = tag.strip_edges().to_upper()
	if guild_name.is_empty():
		return {"ok": false, "error": "nome_vazio"}
	if not get_player_guild_id().is_empty():
		return {"ok": false, "error": "ja_em_guilda"}
	if Economy != null and not Economy.tem_gold(CREATE_COST):
		return {"ok": false, "error": "sem_jenny", "cost": CREATE_COST}
	if Economy != null and not Economy.remover_gold(CREATE_COST):
		return {"ok": false, "error": "pagamento_falhou"}

	var gid := "guild_%d" % _next_id
	_next_id += 1
	var leader := {
		"id": _player_id(),
		"name": _player_name(),
		"role": "leader",
		"joined_day": _day(),
	}
	guilds[gid] = {
		"id": gid,
		"name": guild_name,
		"tag": tag if not tag.is_empty() else guild_name.substr(0, mini(4, guild_name.length())).to_upper(),
		"leader_id": _player_id(),
		"members": [leader],
		"bank_jenny": 0,
		"hall_id": "hall_%s" % gid,
		"motto": "Caçadores unidos pelo Nen.",
		"created_day": _day(),
	}
	_mirror()
	guild_created.emit(gid, guild_name)
	return {"ok": true, "guild": get_player_guild(), "cost": CREATE_COST}


func invite_member(member_id: String, member_name: String = "") -> Dictionary:
	var gid := get_player_guild_id()
	if gid.is_empty():
		return {"ok": false, "error": "sem_guilda"}
	var g: Dictionary = guilds[gid]
	if str(g.get("leader_id", "")) != _player_id():
		return {"ok": false, "error": "nao_lider"}
	var members: Array = g.get("members", [])
	if members.size() >= MAX_MEMBERS:
		return {"ok": false, "error": "cheia"}
	for m in members:
		if typeof(m) == TYPE_DICTIONARY and str(m.get("id", "")) == member_id:
			return {"ok": false, "error": "ja_membro"}
	members.append({
		"id": member_id,
		"name": member_name if not member_name.is_empty() else member_id,
		"role": "member",
		"joined_day": _day(),
	})
	g["members"] = members
	guilds[gid] = g
	_mirror()
	guild_member_joined.emit(gid, member_id)
	return {"ok": true, "members": members.size()}


func kick_member(member_id: String) -> Dictionary:
	var gid := get_player_guild_id()
	if gid.is_empty():
		return {"ok": false, "error": "sem_guilda"}
	var g: Dictionary = guilds[gid]
	if str(g.get("leader_id", "")) != _player_id():
		return {"ok": false, "error": "nao_lider"}
	if member_id == _player_id():
		return {"ok": false, "error": "nao_pode_kickar_lider"}
	var members: Array = []
	var removed := false
	for m in g.get("members", []):
		if typeof(m) == TYPE_DICTIONARY and str(m.get("id", "")) == member_id:
			removed = true
			continue
		members.append(m)
	if not removed:
		return {"ok": false, "error": "nao_encontrado"}
	g["members"] = members
	guilds[gid] = g
	_mirror()
	guild_member_left.emit(gid, member_id)
	return {"ok": true, "members": members.size()}


func leave_guild() -> Dictionary:
	var gid := get_player_guild_id()
	if gid.is_empty():
		return {"ok": false, "error": "sem_guilda"}
	var g: Dictionary = guilds[gid]
	var pid := _player_id()
	if str(g.get("leader_id", "")) == pid:
		# Líder saindo dissolve se sozinho; senão promove o mais antigo membro
		var members: Array = g.get("members", [])
		if members.size() <= 1:
			guilds.erase(gid)
			_mirror()
			guild_disbanded.emit(gid)
			return {"ok": true, "disbanded": true}
		var next_leader := ""
		var next_members: Array = []
		for m in members:
			if typeof(m) != TYPE_DICTIONARY:
				continue
			if str(m.get("id", "")) == pid:
				continue
			if next_leader.is_empty():
				next_leader = str(m.get("id", ""))
				m["role"] = "leader"
			next_members.append(m)
		g["leader_id"] = next_leader
		g["members"] = next_members
		guilds[gid] = g
	else:
		var kept: Array = []
		for m in g.get("members", []):
			if typeof(m) == TYPE_DICTIONARY and str(m.get("id", "")) != pid:
				kept.append(m)
		g["members"] = kept
		guilds[gid] = g
	_mirror()
	guild_member_left.emit(gid, pid)
	return {"ok": true, "disbanded": false}


func deposit_bank(amount: int) -> Dictionary:
	amount = maxi(0, amount)
	var gid := get_player_guild_id()
	if gid.is_empty():
		return {"ok": false, "error": "sem_guilda"}
	if amount <= 0:
		return {"ok": false, "error": "valor_invalido"}
	if Economy == null or not Economy.tem_gold(amount):
		return {"ok": false, "error": "sem_jenny"}
	if not Economy.remover_gold(amount):
		return {"ok": false, "error": "falha"}
	var g: Dictionary = guilds[gid]
	g["bank_jenny"] = int(g.get("bank_jenny", 0)) + amount
	guilds[gid] = g
	_mirror()
	return {"ok": true, "bank": int(g["bank_jenny"])}


func withdraw_bank(amount: int) -> Dictionary:
	amount = maxi(0, amount)
	var gid := get_player_guild_id()
	if gid.is_empty():
		return {"ok": false, "error": "sem_guilda"}
	var g: Dictionary = guilds[gid]
	if str(g.get("leader_id", "")) != _player_id():
		return {"ok": false, "error": "nao_lider"}
	var bank := int(g.get("bank_jenny", 0))
	if amount <= 0 or amount > bank:
		return {"ok": false, "error": "saldo"}
	g["bank_jenny"] = bank - amount
	guilds[gid] = g
	if Economy != null:
		Economy.adicionar_gold(amount)
	_mirror()
	return {"ok": true, "bank": int(g["bank_jenny"]), "withdrawn": amount}


func summary_text() -> String:
	var g := get_player_guild()
	if g.is_empty():
		return "Sem guilda · criar custa %d Jenny · cap %d" % [CREATE_COST, MAX_MEMBERS]
	return "[%s] %s · %d/%d membros · bank %d Jenny" % [
		str(g.get("tag", "????")),
		str(g.get("name", "?")),
		(g.get("members", []) as Array).size(),
		MAX_MEMBERS,
		int(g.get("bank_jenny", 0)),
	]


func _day() -> int:
	if TimeManager != null:
		return maxi(1, int(TimeManager.current_day))
	return 1


func _mirror() -> void:
	if PlayerData != null:
		PlayerData.attributes[ATTR_KEY] = salvar_dados()


func salvar_dados() -> Dictionary:
	return {"guilds": guilds.duplicate(true), "next_id": _next_id}


func carregar_dados(dados: Dictionary) -> void:
	if dados.is_empty():
		guilds.clear()
		_next_id = 1
		return
	var raw = dados.get("guilds", {})
	guilds = raw.duplicate(true) if typeof(raw) == TYPE_DICTIONARY else {}
	_next_id = maxi(1, int(dados.get("next_id", 1)))
