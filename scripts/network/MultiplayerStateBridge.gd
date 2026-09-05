class_name MultiplayerStateBridge
extends RefCounted

# ============================================================
# HUNTER ONLINE — MULTIPLAYER STATE ABSTRACTION & BRIDGE
# ============================================================
#
# Camada de abstração que isola a lógica de controle de entidades
# do processamento local:
# 1. Single-player First: No modo OFFLINE_SINGLEPLAYER o sistema opera
#    sem overhead de rede ou latência.
# 2. Reconciliação e Serialização: Prepara interfaces para Co-op,
#    Party (Grupos de Caçada), World Bosses Globais e Arenas PvP.
# 3. Separação Estrita de Autoridade (Local Authority vs Remote Ghost).
# ============================================================

const NetworkEntitySnapshot = preload("res://scripts/network/NetworkEntitySnapshot.gd")

enum NetworkMode {
	OFFLINE_SINGLEPLAYER,
	CLIENT_PEER,
	DEDICATED_SERVER,
	HOST_LISTEN
}

enum AuthorityType {
	LOCAL_AUTHORITY,
	REMOTE_REPLICATED,
	SERVER_AUTHORITATIVE
}

static var current_mode: NetworkMode = NetworkMode.OFFLINE_SINGLEPLAYER
static var _registered_entities: Dictionary = {} # int (net_id) -> Dictionary { "node": Node, "type": String, "authority": AuthorityType }
static var _next_net_id: int = 1000

# Eventos de barramento de rede
static var on_entity_synced: Callable
static var on_combat_event_received: Callable
static var on_party_updated: Callable
static var on_boss_state_changed: Callable


static func is_offline_singleplayer() -> bool:
	var main_loop = Engine.get_main_loop()
	if main_loop != null and main_loop is SceneTree and main_loop.root != null:
		var nm = main_loop.root.get_node_or_null("NetworkManager")
		if nm != null and nm.has_method("is_offline_singleplayer"):
			return nm.is_offline_singleplayer()
	return current_mode == NetworkMode.OFFLINE_SINGLEPLAYER


static func is_local_authority(node: Node) -> bool:
	if is_offline_singleplayer():
		return true

	for nid in _registered_entities.keys():
		var entry = _registered_entities[nid]
		if entry.get("node") == node:
			return entry.get("authority") == AuthorityType.LOCAL_AUTHORITY

	return true


static func registrar_entidade(node: Node, tipo: String = "player", net_id: int = -1, autoridade: AuthorityType = AuthorityType.LOCAL_AUTHORITY) -> int:
	if node == null:
		return -1

	var final_id := net_id
	if final_id <= 0:
		_next_net_id += 1
		final_id = _next_net_id

	_registered_entities[final_id] = {
		"node": node,
		"type": tipo,
		"authority": autoridade,
		"last_snapshot": null
	}

	# Conectar sinal de remoção da árvore para auto-desregistro seguro
	if not node.tree_exited.is_connected(_on_entity_tree_exited.bind(final_id)):
		node.tree_exited.connect(_on_entity_tree_exited.bind(final_id))

	return final_id


static func desregistrar_entidade(net_id: int) -> void:
	if _registered_entities.has(net_id):
		_registered_entities.erase(net_id)


static func _on_entity_tree_exited(net_id: int) -> void:
	desregistrar_entidade(net_id)


# Captura snapshot da entidade local
static func capturar_snapshot(net_id: int) -> NetworkEntitySnapshot:
	if not _registered_entities.has(net_id):
		return null

	var entry = _registered_entities[net_id]
	var node: Node = entry.get("node")
	if node == null or not is_instance_valid(node):
		return null

	var snap := NetworkEntitySnapshot.new()
	snap.net_id = net_id
	snap.entity_type = entry.get("type", "entity")
	snap.timestamp_ms = int(Time.get_ticks_msec())

	if node is CharacterBody2D:
		snap.position = node.global_position
		snap.velocity = node.velocity

	var pd = node.get_node_or_null("/root/PlayerData") if node.is_inside_tree() else null
	if node.is_in_group("player") and pd != null:
		snap.hp = int(pd.attributes.get("vida", 100))
		snap.hp_max = int(pd.attributes.get("vida_max", 100))
		snap.aura = float(pd.attributes.get("aura", 100.0))
		snap.aura_max = float(pd.attributes.get("aura_max", 100.0))
		snap.nen_tech = str(pd.quest_states.get("tecnica_nen_ativa", ""))

	entry["last_snapshot"] = snap
	return snap


# Aplica snapshot vindo da rede em entidade réplica (Remote Ghost)
static func aplicar_snapshot(net_id: int, snap: NetworkEntitySnapshot) -> void:
	if snap == null or not _registered_entities.has(net_id):
		return

	var entry = _registered_entities[net_id]
	var node: Node = entry.get("node")
	if node == null or not is_instance_valid(node):
		return

	# Não sobrescrever posição se for a autoridade local
	if entry.get("authority") == AuthorityType.LOCAL_AUTHORITY:
		return

	if node is CharacterBody2D:
		# Aplica interpolação suave
		node.global_position = snap.position
		node.velocity = snap.velocity


# Interfaces desacopladas para subsistemas de expansão multiplayer:

# 1. Party & Co-op (Sincronização de Caçadores Aliados)
static func sincronizar_membros_party(party_data: Array) -> void:
	if on_party_updated.is_valid():
		on_party_updated.call(party_data)


# 2. World Bosses & Raids de Greed Island / NGL
static func sincronizar_world_boss(boss_id: String, fase_atual: int, hp_atual: int, hp_max: int, alvo_atual: String = "") -> void:
	if on_boss_state_changed.is_valid():
		on_boss_state_changed.call({
			"boss_id": boss_id,
			"fase": fase_atual,
			"hp": hp_atual,
			"hp_max": hp_max,
			"alvo": alvo_atual
		})


# 3. Evento de Combate Arbitrado (Dano, Stun, Knockback)
static func despachar_evento_combate(origem_net_id: int, destino_net_id: int, dano: int, tipo_dano: String, direcao_impacto: Vector2 = Vector2.ZERO) -> void:
	if is_offline_singleplayer():
		return # Em single player, o CombatSystem local processa instantaneamente

	if on_combat_event_received.is_valid():
		on_combat_event_received.call({
			"origem": origem_net_id,
			"destino": destino_net_id,
			"dano": dano,
			"tipo": tipo_dano,
			"dir": direcao_impacto
		})
