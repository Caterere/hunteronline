class_name DuelSystem
extends RefCounted

# ============================================================
# HUNTER ONLINE — DUEL SYSTEM (CONSENSUAL 1V1 PVP FOUNDATION)
# ============================================================
#
# Sistema de duelo amigável entre dois caçadores:
# - Estritamente consensual
# - Arena circular de combate com limite visual
# - Finalização segura ao atingir 1 HP (sem mortes ou perda de itens)
# - Revigoramento instantâneo após a luta
# ============================================================

enum DuelState {
	NONE,
	INVITED,
	COUNTDOWN,
	FIGHTING,
	FINISHED
}

var state: DuelState = DuelState.NONE
var challenger_id: int = 0
var target_id: int = 0
var arena_center: Vector2 = Vector2.ZERO
var arena_radius: float = 250.0
var countdown_timer: float = 3.0


func iniciar_desafio(desafiante: int, alvo: int, centro: Vector2) -> bool:
	if state != DuelState.NONE:
		return false

	challenger_id = desafiante
	target_id = alvo
	arena_center = centro
	state = DuelState.INVITED
	return true


func aceitar_desafio() -> void:
	if state == DuelState.INVITED:
		state = DuelState.COUNTDOWN
		countdown_timer = 3.0


func iniciar_combate() -> void:
	state = DuelState.FIGHTING


func verificar_saida_de_arena(posicao_lutador: Vector2) -> bool:
	if state != DuelState.FIGHTING:
		return false
	return posicao_lutador.distance_to(arena_center) > arena_radius


func aplicar_dano_duelo(hp_atual: int, dano: int) -> Dictionary:
	# O dano nunca mata o duelista, parando em 1 HP
	var novo_hp = max(1, hp_atual - dano)
	var finalizou = (novo_hp <= 1)
	if finalizou:
		state = DuelState.FINISHED

	return {
		"hp_restante": novo_hp,
		"duelo_terminou": finalizou
	}


func encerrar_duelo() -> void:
	state = DuelState.NONE
	challenger_id = 0
	target_id = 0


## Se Arena ranqueada estiver ON, registra MMR cosmético (S2). Não altera HP/itens.
func reportar_ranqueado(vencedor_foi_desafiante: bool, opponent_mmr: int = 1000, opponent_name: String = "Duelista") -> Dictionary:
	if not ClassDB.class_exists("ArenaRankedSeason") and not ResourceLoader.exists("res://scripts/systems/arena/ArenaRankedSeason.gd"):
		return {"skipped": true, "reason": "no_ranked"}
	var Ranked = load("res://scripts/systems/arena/ArenaRankedSeason.gd")
	if Ranked == null:
		return {"skipped": true, "reason": "no_ranked"}
	return Ranked.report_duel_result(vencedor_foi_desafiante, opponent_mmr, opponent_name)
