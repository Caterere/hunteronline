class_name PartyManagerClass
extends Node

# ============================================================
# HUNTER ONLINE — PARTY MANAGER (HUNTING PARTY CONTROLLER)
# ============================================================
#
# Gerencia grupos cooperativos de até 4 caçadores (expansível até 8):
# - Criação, convites, liderança e expulsão
# - Broadcast contínuo de status dos membros (HP, Aura, Nível)
# - Sincronização de objetivos compartilhados de caçada
# ============================================================

signal party_criada(lider_id: int)
signal membro_entrou(peer_id: int, nome: String)
signal membro_saiu(peer_id: int)
signal party_desfeita()
signal convite_recebido(de_peer_id: int, nome_lider: String)
signal party_dados_atualizados(membros: Array)

const MAX_MEMBROS: int = 4

var party_id: String = ""
var lider_id: int = 0
var membros: Dictionary = {} # peer_id -> Dictionary


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	print("=================================")
	print("[PartyManager] SISTEMA DE PARTY ATIVO")
	print("=================================")


func esta_em_party() -> bool:
	return not party_id.is_empty() and not membros.is_empty()


func eh_lider() -> bool:
	var meu_id = 1
	var nm = get_node_or_null("/root/NetworkManager")
	if nm != null and not nm.is_offline_singleplayer():
		meu_id = nm.local_peer_id
	return esta_em_party() and lider_id == meu_id


func criar_party() -> void:
	party_id = "party-%x" % [Time.get_ticks_msec()]
	var nm = get_node_or_null("/root/NetworkManager")
	lider_id = nm.local_peer_id if nm != null and not nm.is_offline_singleplayer() else 1

	membros.clear()
	var dados_lider := _obter_dados_jogador_local()
	dados_lider["is_leader"] = true
	membros[lider_id] = dados_lider

	party_criada.emit(lider_id)
	party_dados_atualizados.emit(obter_membros())
	print("[PartyManager] 🛡️ Party criada com sucesso! Líder: Peer %d" % lider_id)


func convidar_jogador(alvo_peer_id: int) -> void:
	if not esta_em_party():
		criar_party()

	if not eh_lider():
		EventBus.emit_toast("Apenas o líder pode convidar novos membros!", Color(1.0, 0.4, 0.4))
		return

	if membros.size() >= MAX_MEMBROS:
		EventBus.emit_toast("A party atingiu o limite máximo de 4 caçadores!", Color(1.0, 0.4, 0.4))
		return

	var meu_nome = PlayerData.character_name if PlayerData != null and "character_name" in PlayerData else "Líder"
	rpc_id(alvo_peer_id, "rpc_receber_convite_party", lider_id, meu_nome)
	EventBus.emit_toast("Convite enviado ao Caçador %d!" % alvo_peer_id, Color.WHITE)


func aceitar_convite(lider_peer_id: int) -> void:
	var meus_dados := _obter_dados_jogador_local()
	rpc_id(lider_peer_id, "rpc_confirmar_entrada_party", meus_dados)
	EventBus.emit_toast("Você entrou na party de caçada!", Color(0.4, 1.0, 0.5))


func recusar_convite(_lider_peer_id: int) -> void:
	EventBus.emit_toast("Convite de party recusado.", Color(0.8, 0.8, 0.8))


func sair_da_party() -> void:
	if not esta_em_party():
		return

	var nm = get_node_or_null("/root/NetworkManager")
	var meu_id = nm.local_peer_id if nm != null and not nm.is_offline_singleplayer() else 1

	if eh_lider() and membros.size() > 1:
		# Passa liderança para o próximo
		for id in membros.keys():
			if id != meu_id:
				transferir_lideranca(id)
				break

	membros.erase(meu_id)
	if membros.is_empty():
		party_id = ""
		lider_id = 0
		party_desfeita.emit()
	else:
		_sincronizar_todos_membros()

	EventBus.emit_toast("Você saiu da party.", Color(0.8, 0.8, 0.8))
	party_dados_atualizados.emit(obter_membros())


func desfazer_party() -> void:
	party_id = ""
	lider_id = 0
	membros.clear()
	party_desfeita.emit()
	party_dados_atualizados.emit([])


func expulsar_membro(alvo_peer_id: int) -> void:
	if not eh_lider() or alvo_peer_id == lider_id:
		return

	if membros.has(alvo_peer_id):
		membros.erase(alvo_peer_id)
		var nm = get_node_or_null("/root/NetworkManager")
		if nm != null and not nm.is_offline_singleplayer() and multiplayer.has_multiplayer_peer():
			rpc_id(alvo_peer_id, "rpc_voce_foi_expulso")
		_sincronizar_todos_membros()
		EventBus.emit_toast("Caçador %d foi removido da party." % alvo_peer_id)


func transferir_lideranca(novo_lider_id: int) -> void:
	if not membros.has(novo_lider_id):
		return
	if membros.has(lider_id):
		membros[lider_id]["is_leader"] = false
	lider_id = novo_lider_id
	membros[novo_lider_id]["is_leader"] = true
	_sincronizar_todos_membros()
	EventBus.emit_toast("Liderança da party transferida para o Caçador %d." % novo_lider_id)


func atualizar_status_membro(peer_id: int, hp_val: int, hp_max_val: int, aura_val: float, aura_max_val: float) -> void:
	if membros.has(peer_id):
		membros[peer_id]["hp"] = hp_val
		membros[peer_id]["hp_max"] = hp_max_val
		membros[peer_id]["aura"] = aura_val
		membros[peer_id]["aura_max"] = aura_max_val
		party_dados_atualizados.emit(obter_membros())


func definir_membro_desmaiado(peer_id: int, desmaiado: bool) -> void:
	if not membros.has(peer_id):
		return
	membros[peer_id]["is_downed"] = desmaiado
	if desmaiado:
		membros[peer_id]["hp"] = 0
	party_dados_atualizados.emit(obter_membros())


func obter_membros() -> Array:
	var lista: Array = []
	for k in membros.keys():
		lista.append(membros[k])
	return lista


func _obter_dados_jogador_local() -> Dictionary:
	var nm = get_node_or_null("/root/NetworkManager")
	var pid: int = nm.local_peer_id if nm != null and not nm.is_offline_singleplayer() else 1
	var nome: String = PlayerData.character_name if PlayerData != null and "character_name" in PlayerData else "Hunter"
	var lvl: int = int(PlayerData.attributes.get("nivel", 1)) if PlayerData != null else 1
	var hp_v: int = int(PlayerData.attributes.get("vida", 100)) if PlayerData != null else 100
	var hp_m: int = int(PlayerData.attributes.get("vida_max", 100)) if PlayerData != null else 100
	var au_v: float = float(PlayerData.attributes.get("aura", 100.0)) if PlayerData != null else 100.0
	var au_m: float = float(PlayerData.attributes.get("aura_max", 100.0)) if PlayerData != null else 100.0

	return {
		"peer_id": pid,
		"name": nome,
		"level": lvl,
		"hp": hp_v,
		"hp_max": hp_m,
		"aura": au_v,
		"aura_max": au_m,
		"is_leader": false,
		"is_downed": false
	}


func _sincronizar_todos_membros() -> void:
	var lista = obter_membros()
	party_dados_atualizados.emit(lista)
	var nm = get_node_or_null("/root/NetworkManager")
	if nm != null and not nm.is_offline_singleplayer() and multiplayer.has_multiplayer_peer():
		for id in membros.keys():
			if id != lider_id and id != nm.local_peer_id:
				rpc_id(id, "rpc_atualizar_dados_party", lista, party_id, lider_id)


# ============================================================
# RPCS DE PARTY
# ============================================================

@rpc("any_peer", "call_remote", "reliable")
func rpc_receber_convite_party(de_lider_id: int, nome_lider: String) -> void:
	convite_recebido.emit(de_lider_id, nome_lider)
	EventBus.emit_toast("📜 Convite de Party de %s! Digite /aceitar" % nome_lider, Color(1.0, 0.85, 0.3))


@rpc("any_peer", "call_remote", "reliable")
func rpc_confirmar_entrada_party(dados_novo_membro: Dictionary) -> void:
	if not eh_lider():
		return
	var pid: int = int(dados_novo_membro.get("peer_id", 0))
	if pid > 0 and membros.size() < MAX_MEMBROS:
		membros[pid] = dados_novo_membro
		membro_entrou.emit(pid, dados_novo_membro.get("name", "Hunter"))
		_sincronizar_todos_membros()


@rpc("authority", "call_remote", "reliable")
func rpc_atualizar_dados_party(lista_membros: Array, p_id: String, l_id: int) -> void:
	party_id = p_id
	lider_id = l_id
	membros.clear()
	for m in lista_membros:
		membros[m.get("peer_id", 0)] = m
	party_dados_atualizados.emit(lista_membros)


@rpc("authority", "call_remote", "reliable")
func rpc_voce_foi_expulso() -> void:
	party_id = ""
	lider_id = 0
	membros.clear()
	party_dados_atualizados.emit([])
	EventBus.emit_toast("Você foi removido da party.", Color(1.0, 0.4, 0.4))
