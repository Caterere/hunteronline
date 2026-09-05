class_name CoopWorldBossCoordinator
extends RefCounted

# ============================================================
# HUNTER ONLINE — CO-OP WORLD BOSS COORDINATOR
# ============================================================
#
# Gerencia a integridade cooperativa de encontros com Chefes Mundiais:
# - Tabela de Ameaça Dinâmica (Threat Table) multi-jogador
# - Rastreamento de Contribuição de Dano individual
# - Sincronização de Fases (50% e 25% HP)
# - Geração e distribuição individualizada de Recompensas
# ============================================================

var boss_id: String = ""
var boss_name: String = "Chefe Mundial"
var max_hp: int = 100000
var current_hp: int = 100000
var current_phase: int = 1

var threat_table: Dictionary = {} # peer_id -> float
var damage_contribution: Dictionary = {} # peer_id -> int


func inicializar_boss(b_id: String, b_nome: String, vida_max: int) -> void:
	boss_id = b_id
	boss_name = b_nome
	max_hp = vida_max
	current_hp = vida_max
	current_phase = 1
	threat_table.clear()
	damage_contribution.clear()


func registrar_dano(peer_id: int, dano: int, is_taunt: bool = false) -> void:
	var dano_aplicado = min(current_hp, dano)
	current_hp = max(0, current_hp - dano_aplicado)

	# Registrar dano para tabela de loot
	var atual_dano = int(damage_contribution.get(peer_id, 0))
	damage_contribution[peer_id] = atual_dano + dano_aplicado

	# Atualizar Threat Table
	var mult_ameaca: float = 2.5 if is_taunt else 1.0
	var ameaca_atual: float = float(threat_table.get(peer_id, 0.0))
	threat_table[peer_id] = ameaca_atual + (float(dano_aplicado) * mult_ameaca)

	# Checar avanço de fases
	var pct: float = float(current_hp) / float(max_hp)
	if pct <= 0.25 and current_phase < 3:
		current_phase = 3
	elif pct <= 0.50 and current_phase < 2:
		current_phase = 2


func obter_alvo_aggro() -> int:
	var maior_ameaca: float = -1.0
	var melhor_alvo: int = 1
	for pid in threat_table.keys():
		var valor = float(threat_table[pid])
		if valor > maior_ameaca:
			maior_ameaca = valor
			melhor_alvo = pid
	return melhor_alvo


func esta_morto() -> bool:
	return current_hp <= 0


func calcular_recompensas_coop(xp_total: int, jenny_total: int, drop_garantido_id: String = "") -> Dictionary:
	var resultados: Dictionary = {}
	var dano_total_causado: int = 0
	for pid in damage_contribution.keys():
		dano_total_causado += int(damage_contribution[pid])

	if dano_total_causado <= 0:
		dano_total_causado = 1

	for pid in damage_contribution.keys():
		var causado: int = int(damage_contribution[pid])
		var participacao_pct: float = float(causado) / float(dano_total_causado)

		# Mínimo de 1% de dano para receber loot
		if participacao_pct >= 0.01:
			var xp_ganho: int = max(10, int(float(xp_total) * clampf(participacao_pct * 1.5, 0.25, 1.0)))
			var jenny_ganho: int = max(50, int(float(jenny_total) * clampf(participacao_pct * 1.5, 0.25, 1.0)))
			var itens: Array[String] = []
			if not drop_garantido_id.is_empty():
				itens.append(drop_garantido_id)

			resultados[pid] = {
				"peer_id": pid,
				"xp": xp_ganho,
				"jenny": jenny_ganho,
				"itens": itens,
				"participacao_pct": snappedf(participacao_pct * 100.0, 0.1)
			}

	return resultados
