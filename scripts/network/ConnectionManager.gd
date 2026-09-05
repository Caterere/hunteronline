class_name ConnectionManager
extends RefCounted

# ============================================================
# HUNTER ONLINE — CONNECTION MANAGER (ENET SOCKET CONTROLLER)
# ============================================================
#
# Gerencia a inicialização, conexão direta e encerramento de sockets
# UDP através do ENetMultiplayerPeer integrado da Godot 4.6.
# ============================================================

const PADRAO_PORTA: int = 7777
const PADRAO_IP: String = "127.0.0.1"

var peer: ENetMultiplayerPeer = null
var is_server: bool = false
var is_client: bool = false


func iniciar_servidor(porta: int = PADRAO_PORTA, max_clients: int = 4) -> Error:
	fechar_conexao()
	peer = ENetMultiplayerPeer.new()
	var err: Error = peer.create_server(porta, max_clients)
	if err != OK:
		peer = null
		return err

	is_server = true
	is_client = false
	return OK


func conectar_cliente(ip: String = PADRAO_IP, porta: int = PADRAO_PORTA) -> Error:
	fechar_conexao()
	peer = ENetMultiplayerPeer.new()
	var err: Error = peer.create_client(ip, porta)
	if err != OK:
		peer = null
		return err

	is_server = false
	is_client = true
	return OK


func fechar_conexao() -> void:
	if peer != null:
		peer.close()
		peer = null
	is_server = false
	is_client = false


func esta_ativo() -> bool:
	return peer != null and peer.get_connection_status() != MultiplayerPeer.CONNECTION_DISCONNECTED


func obter_status_conexao() -> MultiplayerPeer.ConnectionStatus:
	if peer == null:
		return MultiplayerPeer.CONNECTION_DISCONNECTED
	return peer.get_connection_status()


func obter_peer_id() -> int:
	if peer == null:
		return 1
	return peer.get_unique_id()
