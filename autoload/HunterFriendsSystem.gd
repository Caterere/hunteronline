extends Node

# ============================================================
# HUNTER ONLINE — B9 LISTA DE CAÇADORES (FRIENDS)
# ============================================================
# Lista de amigos / caçadores conhecidos (FFXIV Friend List lite).
# Pedidos, aceitar/recusar, remoção. Online = stub local/party.
# ============================================================

signal friend_added(hunter_id: String)
signal friend_removed(hunter_id: String)
signal request_received(from_id: String)
signal request_resolved(from_id: String, accepted: bool)
signal friends_changed()

const ATTR_KEY := "hunter_friends"
const MAX_FRIENDS := 50

var friends: Dictionary = {} # id -> {id, name, note, since}
var incoming_requests: Dictionary = {} # id -> {id, name, at}
var outgoing_requests: Dictionary = {} # id -> {id, name, at}


func listar_amigos() -> Array:
	var out: Array = []
	for id in friends.keys():
		out.append(friends[id].duplicate(true))
	out.sort_custom(func(a, b): return str(a.get("name", "")) < str(b.get("name", "")))
	return out


func eh_amigo(hunter_id: String) -> bool:
	return friends.has(hunter_id)


func enviar_pedido(hunter_id: String, hunter_name: String = "") -> Dictionary:
	hunter_id = hunter_id.strip_edges()
	if hunter_id.is_empty():
		return {"ok": false, "reason": "EMPTY_ID"}
	if friends.has(hunter_id):
		return {"ok": false, "reason": "ALREADY_FRIEND"}
	if friends.size() >= MAX_FRIENDS:
		return {"ok": false, "reason": "FRIENDS_FULL"}
	if outgoing_requests.has(hunter_id):
		return {"ok": false, "reason": "ALREADY_PENDING"}
	# Auto-aceita pedidos espelhados (offline / same client simulation)
	if incoming_requests.has(hunter_id):
		return aceitar_pedido(hunter_id)
	outgoing_requests[hunter_id] = {
		"id": hunter_id,
		"name": hunter_name if not hunter_name.is_empty() else hunter_id,
		"at": Time.get_unix_time_from_system(),
	}
	friends_changed.emit()
	return {"ok": true, "reason": "SENT"}


func receber_pedido(from_id: String, from_name: String = "") -> Dictionary:
	from_id = from_id.strip_edges()
	if from_id.is_empty():
		return {"ok": false, "reason": "EMPTY_ID"}
	if friends.has(from_id):
		return {"ok": false, "reason": "ALREADY_FRIEND"}
	incoming_requests[from_id] = {
		"id": from_id,
		"name": from_name if not from_name.is_empty() else from_id,
		"at": Time.get_unix_time_from_system(),
	}
	request_received.emit(from_id)
	friends_changed.emit()
	return {"ok": true}


func aceitar_pedido(from_id: String) -> Dictionary:
	if not incoming_requests.has(from_id) and not outgoing_requests.has(from_id):
		return {"ok": false, "reason": "NO_REQUEST"}
	var meta: Dictionary = incoming_requests.get(from_id, outgoing_requests.get(from_id, {}))
	incoming_requests.erase(from_id)
	outgoing_requests.erase(from_id)
	friends[from_id] = {
		"id": from_id,
		"name": str(meta.get("name", from_id)),
		"note": "",
		"since": Time.get_unix_time_from_system(),
	}
	friend_added.emit(from_id)
	request_resolved.emit(from_id, true)
	friends_changed.emit()
	if AssociationMailSystem != null:
		AssociationMailSystem.enviar_aviso_associacao(
			"Novo contato de caçador",
			"Você e %s agora estão na Lista de Caçadores." % str(meta.get("name", from_id))
		)
	return {"ok": true}


func recusar_pedido(from_id: String) -> Dictionary:
	if not incoming_requests.has(from_id):
		return {"ok": false, "reason": "NO_REQUEST"}
	incoming_requests.erase(from_id)
	request_resolved.emit(from_id, false)
	friends_changed.emit()
	return {"ok": true}


func remover_amigo(hunter_id: String) -> bool:
	if not friends.has(hunter_id):
		return false
	friends.erase(hunter_id)
	friend_removed.emit(hunter_id)
	friends_changed.emit()
	return true


func definir_nota(hunter_id: String, nota: String) -> bool:
	if not friends.has(hunter_id):
		return false
	friends[hunter_id]["note"] = nota
	friends_changed.emit()
	return true


func esta_online_stub(hunter_id: String) -> bool:
	# Stub: amigos na party local contam como online.
	if typeof(PartyManager) != TYPE_NIL and PartyManager != null and PartyManager.has_method("obter_membros"):
		for m in PartyManager.obter_membros():
			if str(m.get("id", "")) == hunter_id or str(m.get("name", "")) == hunter_id:
				return true
	return friends.has(hunter_id) and int(friends[hunter_id].get("since", 0)) % 2 == 0


func salvar_dados() -> Dictionary:
	return {
		"friends": friends.duplicate(true),
		"incoming_requests": incoming_requests.duplicate(true),
		"outgoing_requests": outgoing_requests.duplicate(true),
	}


func carregar_dados(dados: Dictionary) -> void:
	if dados.is_empty():
		return
	friends = dados.get("friends", {}).duplicate(true)
	incoming_requests = dados.get("incoming_requests", {}).duplicate(true)
	outgoing_requests = dados.get("outgoing_requests", {}).duplicate(true)
	friends_changed.emit()
