class_name BountySystemClass
extends Node

# ============================================================
# HUNTER ONLINE - DYNAMIC BOUNTY & PURSUIT SYSTEM (FACTIONS & LAW)
# ============================================================
#
# Gerencia a caçada de recompensas em duas vias:
# 1. JOGADOR COMO ALVO: Crimes geram infâmia, preço na cabeça e caçadores
# 2. JOGADOR COMO CAÇADOR: Contratos da Lista Negra para caçar foras-da-lei
# 3. ESCALAÇÃO: A cada 100 de infâmia, o nível dos perseguidores aumenta
#
# ============================================================

signal recompensa_cabeca_alterada(novo_valor: int, faccao_emissora: String)
signal contrato_bounty_adicionado(contrato_id: String, alvo_nome: String, recompensa_jenny: int)
signal contrato_bounty_concluido(contrato_id: String, recompensa_jenny: int)
signal perseguidor_spawn_solicitado(nivel_perseguidor: int, posicao_spawn: Vector2)

# Contratos que o jogador pode aceitar
var active_bounty_contracts: Dictionary = {}
var timer_verificacao_perseguicao: float = 0.0

func _ready() -> void:
	add_to_group("bounty_system")
	_inicializar_contratos_iniciais()
	_conectar_event_bus()
	print("=================================")
	print("[BountySystem] SISTEMA DE BOUNTY & PERSEGUIÇÃO ATIVO")
	print("=================================")


func _inicializar_contratos_iniciais() -> void:
	active_bounty_contracts = {
		"bounty_ladrao_padokia": {
			"id": "bounty_ladrao_padokia",
			"nome_alvo": "Goran, o Mão-Leve",
			"regiao": "vale_padokia",
			"nivel_alvo": 3,
			"recompensa_jenny": 1500,
			"descricao": "Procurado por furtar mercadorias dos depósitos da vila.",
			"concluido": false
		},
		"bounty_desertor_mafia": {
			"id": "bounty_desertor_mafia",
			"nome_alvo": "Vito 'Cicatriz' Morlani",
			"regiao": "ruinas_zaban",
			"nivel_alvo": 5,
			"recompensa_jenny": 5000,
			"descricao": "Ex-capo da Máfia de Yorknew em fuga com documentos sigilosos.",
			"concluido": false
		}
	}


func _conectar_event_bus() -> void:
	if EventBus == null:
		return
	if EventBus.has_signal("enemy_defeated"):
		EventBus.enemy_defeated.connect(_on_enemy_defeated)
	if EventBus.has_signal("time_hour_ticked"):
		EventBus.time_hour_ticked.connect(_on_time_hour_ticked)


func obter_recompensa_cabeca_jogador() -> int:
	if WorldState == null:
		return 0
	var infamia = WorldState.obter_infamia()
	return infamia * 50 # Ex: 100 de infâmia = 5.000 Jenny de recompensa


func concluir_contrato(contrato_id: String) -> void:
	if not active_bounty_contracts.has(contrato_id):
		return
	var c = active_bounty_contracts[contrato_id]
	if c["concluido"]:
		return
	c["concluido"] = true
	var premio = c["recompensa_jenny"]
	
	if Economy != null:
		Economy.adicionar_gold(premio)
	if ReputationSystem != null:
		ReputationSystem.alterar_reputacao(ReputationSystem.Faccao.ASSOCIACAO_HUNTER, +80, "Contrato de Bounty Cumprido")
	if EventBus != null and EventBus.has_signal("player_stat_changed"):
		EventBus.player_stat_changed.emit("xp", premio / 5)
		
	contrato_bounty_concluido.emit(contrato_id, premio)
	if EventBus != null and EventBus.has_signal("toast_requested"):
		EventBus.emit_toast("💰 Recompensa Coletada: +%d Jenny (%s)!" % [premio, c["nome_alvo"]], Color(1.0, 0.85, 0.2))


func _on_enemy_defeated(enemy_id: String, _xp: int, _nen_xp: int) -> void:
	for c_id in active_bounty_contracts.keys():
		var c = active_bounty_contracts[c_id]
		if enemy_id.to_lower() in c["nome_alvo"].to_lower() or c["id"] == enemy_id:
			concluir_contrato(c_id)


func _on_time_hour_ticked(_hour: int, _minute: int) -> void:
	if WorldState == null:
		return
	var infamia = WorldState.obter_infamia()
	if infamia >= 100:
		# Se a infâmia do jogador for alta, avaliar se um caçador deve iniciar perseguição
		var nivel_cassador = clamp(int(infamia / 50), 2, 10)
		perseguidor_spawn_solicitado.emit(nivel_cassador, Vector2.ZERO)
		print("[BountySystem] Alerta: Caçador de Recompensa Nível %d rastreando jogador!" % nivel_cassador)


# ============================================================
# PERSISTÊNCIA SAVE / LOAD
# ============================================================

func salvar_dados() -> Dictionary:
	return {"active_bounty_contracts": active_bounty_contracts.duplicate(true)}


func carregar_dados(dados: Dictionary) -> void:
	if dados.is_empty():
		_inicializar_contratos_iniciais()
		return
	active_bounty_contracts = dados.get("active_bounty_contracts", {}).duplicate(true)