extends Node

# ============================================================
# HUNTER ONLINE — B10 DUTY FINDER (FILA DE CONTEÚDO)
# ============================================================
# Fila estilo FFXIV Duty Finder: dungeon / raid / arena.
# Usa o catálogo local já existente; matchmaking real depende de PREREQ-1.
# Offline: preenche com stubs/bots para testes de fluxo.
# ============================================================

signal queue_joined(duty_id: String)
signal queue_left(duty_id: String)
signal match_found(duty_id: String, party: Array)
signal match_cancelled(duty_id: String)

enum DutyType { DUNGEON, RAID, ARENA }
enum QueueState { IDLE, QUEUED, MATCHED }

const ATTR_KEY := "duty_finder"

var catalog: Dictionary = {
	"dungeon_zaban": {"id": "dungeon_zaban", "name": "Ruínas de Zaban", "type": DutyType.DUNGEON, "min_size": 2, "max_size": 4, "level_min": 10},
	"raid_ruins_8": {"id": "raid_ruins_8", "name": "Raid das Ruínas (8)", "type": DutyType.RAID, "min_size": 4, "max_size": 8, "level_min": 40},
	"arena_1v1": {"id": "arena_1v1", "name": "Heaven's Arena 1v1", "type": DutyType.ARENA, "min_size": 2, "max_size": 2, "level_min": 5},
}

var state: QueueState = QueueState.IDLE
var queued_duty_id: String = ""
var queued_roles: Array = [] # tank/healer/dps stubs
var last_match: Dictionary = {}
var fill_with_stubs: bool = true


func listar_duties() -> Array:
	var out: Array = []
	for k in catalog.keys():
		out.append(catalog[k].duplicate(true))
	return out


func obter_duty(duty_id: String) -> Dictionary:
	return catalog.get(duty_id, {}).duplicate(true)


func entrar_fila(duty_id: String, roles: Array = ["dps"]) -> Dictionary:
	if not catalog.has(duty_id):
		return {"ok": false, "reason": "UNKNOWN_DUTY"}
	if state == QueueState.QUEUED:
		return {"ok": false, "reason": "ALREADY_QUEUED"}
	state = QueueState.QUEUED
	queued_duty_id = duty_id
	queued_roles = roles.duplicate()
	queue_joined.emit(duty_id)
	if fill_with_stubs:
		# Simula match rápido offline (Duty Finder pop)
		_simular_match()
	return {"ok": true, "duty_id": duty_id}


func sair_fila() -> Dictionary:
	if state == QueueState.IDLE:
		return {"ok": false, "reason": "NOT_IN_QUEUE"}
	var old := queued_duty_id
	state = QueueState.IDLE
	queued_duty_id = ""
	queued_roles.clear()
	last_match.clear()
	queue_left.emit(old)
	match_cancelled.emit(old)
	return {"ok": true}


func _simular_match() -> void:
	var duty := obter_duty(queued_duty_id)
	if duty.is_empty():
		return
	var size := int(duty.get("max_size", 4))
	var party: Array = [{"id": "local_player", "name": "Você", "role": str(queued_roles[0] if queued_roles.size() > 0 else "dps")}]
	var stub_names := ["Gon", "Killua", "Kurapika", "Leorio", "Biscuit", "Hisoka", "Knuckle", "Morel"]
	while party.size() < size:
		var idx := party.size() - 1
		party.append({
			"id": "stub_%d" % idx,
			"name": stub_names[idx % stub_names.size()],
			"role": ["tank", "healer", "dps"][idx % 3],
			"stub": true,
		})
	state = QueueState.MATCHED
	last_match = {"duty_id": queued_duty_id, "party": party, "at": Time.get_unix_time_from_system()}
	match_found.emit(queued_duty_id, party)


func confirmar_match() -> Dictionary:
	if state != QueueState.MATCHED:
		return {"ok": false, "reason": "NO_MATCH"}
	var result := last_match.duplicate(true)
	state = QueueState.IDLE
	queued_duty_id = ""
	return {"ok": true, "match": result}


func esta_na_fila() -> bool:
	return state == QueueState.QUEUED or state == QueueState.MATCHED


func salvar_dados() -> Dictionary:
	return {
		"state": int(state),
		"queued_duty_id": queued_duty_id,
		"queued_roles": queued_roles.duplicate(),
		"last_match": last_match.duplicate(true),
		"fill_with_stubs": fill_with_stubs,
	}


func carregar_dados(dados: Dictionary) -> void:
	if dados.is_empty():
		return
	state = int(dados.get("state", QueueState.IDLE)) as QueueState
	queued_duty_id = str(dados.get("queued_duty_id", ""))
	queued_roles = dados.get("queued_roles", []).duplicate()
	last_match = dados.get("last_match", {}).duplicate(true)
	fill_with_stubs = bool(dados.get("fill_with_stubs", true))
