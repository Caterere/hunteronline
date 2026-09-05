class_name NetworkEvents
extends RefCounted

# ============================================================
# HUNTER ONLINE — NETWORK EVENTS BUS
# ============================================================
#
# Barramento desacoplado de sinais de rede para coordenar
# conexão, sincronização de jogadores, combate em rede e chat.
# ============================================================

signal peer_connected(peer_id: int)
signal peer_disconnected(peer_id: int)
signal connection_succeeded()
signal connection_failed(reason: String)
signal server_disconnected()

signal player_state_updated(peer_id: int, state: PlayerNetworkState)
signal combat_action_replicated(attacker_id: int, target_id: int, action_type: String, value: int, is_crit: bool)
signal hatsu_cast_replicated(caster_id: int, slot_index: int, hatsu_nome: String, direction: Vector2)

signal party_updated(members: Array)
signal world_boss_synced(boss_data: Dictionary)
signal chat_message_received(sender_name: String, channel: String, message: String)
signal latency_updated(peer_id: int, rtt_ms: int)
