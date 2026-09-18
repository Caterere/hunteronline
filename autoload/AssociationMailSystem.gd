extends Node

# ============================================================
# HUNTER ONLINE — B9 CORREIO DA ASSOCIAÇÃO
# ============================================================
# Mailbox estilo WoW/FFXIV: mensagens da Associação, jogadores e
# anexos leves (Jenny / itens). Persistido no SaveManager.
# ============================================================

signal mail_received(mail_id: String)
signal mail_opened(mail_id: String)
signal mail_deleted(mail_id: String)
signal inbox_changed()

const ATTR_KEY := "association_mail"
const MAX_INBOX := 40

var inbox: Array = [] # Array[Dictionary]
var _next_id: int = 1


func _ready() -> void:
	if inbox.is_empty():
		enviar_aviso_associacao(
			"Boas-vindas, Caçador",
			"O Correio da Associação está ativo. Use-o para receber contratos, recompensas e mensagens de outros caçadores.",
			{"jenny": 0}
		)


func gerar_id() -> String:
	var id := "mail_%d_%d" % [_next_id, Time.get_unix_time_from_system()]
	_next_id += 1
	return id


func enviar_aviso_associacao(assunto: String, corpo: String, anexos: Dictionary = {}) -> String:
	return _entregar({
		"from": "Associação Hunter",
		"from_id": "association",
		"subject": assunto,
		"body": corpo,
		"attachments": anexos.duplicate(true),
		"system": true,
	})


func enviar_de_jogador(from_id: String, from_name: String, to_id: String, assunto: String, corpo: String, anexos: Dictionary = {}) -> String:
	# Local/single-player: entrega na inbox do jogador atual se to_id for o próprio.
	var meu_id := "local_player"
	if PlayerData != null and str(PlayerData.character_id) != "":
		meu_id = str(PlayerData.character_id)
	if to_id != meu_id and to_id != "player" and to_id != "self":
		# Stub multiplayer: ainda entrega localmente para testes / offline first.
		pass
	return _entregar({
		"from": from_name if not from_name.is_empty() else from_id,
		"from_id": from_id,
		"to_id": to_id,
		"subject": assunto,
		"body": corpo,
		"attachments": anexos.duplicate(true),
		"system": false,
	})


func _entregar(payload: Dictionary) -> String:
	var mail := {
		"id": gerar_id(),
		"from": str(payload.get("from", "Desconhecido")),
		"from_id": str(payload.get("from_id", "")),
		"to_id": str(payload.get("to_id", "player")),
		"subject": str(payload.get("subject", "(sem assunto)")),
		"body": str(payload.get("body", "")),
		"attachments": payload.get("attachments", {}),
		"system": bool(payload.get("system", false)),
		"read": false,
		"claimed": false,
		"timestamp": Time.get_unix_time_from_system(),
	}
	inbox.push_front(mail)
	while inbox.size() > MAX_INBOX:
		inbox.pop_back()
	mail_received.emit(mail["id"])
	inbox_changed.emit()
	return mail["id"]


func listar_inbox() -> Array:
	return inbox.duplicate(true)


func obter_mail(mail_id: String) -> Dictionary:
	for m in inbox:
		if str(m.get("id", "")) == mail_id:
			return m
	return {}


func marcar_lido(mail_id: String) -> bool:
	for i in range(inbox.size()):
		if str(inbox[i].get("id", "")) == mail_id:
			inbox[i]["read"] = true
			mail_opened.emit(mail_id)
			inbox_changed.emit()
			return true
	return false


func contar_nao_lidos() -> int:
	var n := 0
	for m in inbox:
		if not bool(m.get("read", false)):
			n += 1
	return n


func reivindicar_anexos(mail_id: String) -> Dictionary:
	var mail := obter_mail(mail_id)
	if mail.is_empty():
		return {"ok": false, "reason": "NOT_FOUND"}
	if bool(mail.get("claimed", false)):
		return {"ok": false, "reason": "ALREADY_CLAIMED"}
	var anexos: Dictionary = mail.get("attachments", {})
	var jenny: int = int(anexos.get("jenny", 0))
	if jenny > 0 and Economy != null and Economy.has_method("adicionar_gold"):
		Economy.adicionar_gold(jenny)
	var item_id := str(anexos.get("item_id", ""))
	var item_qty := int(anexos.get("item_qty", 0))
	if not item_id.is_empty() and item_qty > 0 and PlayerData != null and PlayerData.has_method("adicionar_item"):
		PlayerData.adicionar_item(StringName(item_id), item_qty)
	for i in range(inbox.size()):
		if str(inbox[i].get("id", "")) == mail_id:
			inbox[i]["claimed"] = true
			inbox[i]["read"] = true
			break
	inbox_changed.emit()
	return {"ok": true, "attachments": anexos.duplicate(true)}


func deletar_mail(mail_id: String) -> bool:
	for i in range(inbox.size()):
		if str(inbox[i].get("id", "")) == mail_id:
			inbox.remove_at(i)
			mail_deleted.emit(mail_id)
			inbox_changed.emit()
			return true
	return false


func salvar_dados() -> Dictionary:
	return {
		"inbox": inbox.duplicate(true),
		"next_id": _next_id,
	}


func carregar_dados(dados: Dictionary) -> void:
	if dados.is_empty():
		return
	inbox = dados.get("inbox", []).duplicate(true)
	_next_id = int(dados.get("next_id", _next_id))
	inbox_changed.emit()
