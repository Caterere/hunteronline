class_name CardDuelSystem
extends RefCounted

# ============================================================
# HUNTER ONLINE — GREED ISLAND CARD DUEL (S4)
# ============================================================
# Duelo 1v1 por turnos usando subset de cartas GI.
# Não cria inventário paralelo: deck do jogador = owned ∩ catalog.
# ============================================================

enum Phase { IDLE, PLAYER_TURN, ENEMY_TURN, RESOLVE, FINISHED }

const STARTING_HP := 30
const HAND_SIZE := 4
const MAX_TURNS := 20

var phase: Phase = Phase.IDLE
var player_hp: int = STARTING_HP
var enemy_hp: int = STARTING_HP
var turn: int = 0
var player_deck: Array = []
var enemy_deck: Array = []
var player_hand: Array = []
var enemy_hand: Array = []
var last_log: String = ""
var winner: String = "" ## "player" | "enemy" | "draw" | ""
var opponent_name: String = "Duelista de Antokiba"


func reset() -> void:
	phase = Phase.IDLE
	player_hp = STARTING_HP
	enemy_hp = STARTING_HP
	turn = 0
	player_deck.clear()
	enemy_deck.clear()
	player_hand.clear()
	enemy_hand.clear()
	last_log = ""
	winner = ""


func start_duel(player_cards: Array, enemy_cards: Array, foe_name: String = "Duelista de Antokiba") -> Dictionary:
	reset()
	opponent_name = foe_name
	if player_cards.is_empty():
		return {"ok": false, "error": "sem_cartas"}
	if enemy_cards.is_empty():
		return {"ok": false, "error": "sem_oponente"}
	player_deck = player_cards.duplicate(true)
	enemy_deck = enemy_cards.duplicate(true)
	player_deck.shuffle()
	enemy_deck.shuffle()
	_draw_to_hand(true, HAND_SIZE)
	_draw_to_hand(false, HAND_SIZE)
	phase = Phase.PLAYER_TURN
	turn = 1
	last_log = "Duelo contra %s — escolha uma carta!" % opponent_name
	return {"ok": true, "player_hp": player_hp, "enemy_hp": enemy_hp, "hand": player_hand.duplicate(true)}


func start_from_inventory(difficulty: String = "antokiba") -> Dictionary:
	var owned: Array = GreedIslandCardCatalog.owned_duel_cards()
	if owned.is_empty():
		# Starter pack mínimo para first duel (não grava inventário — só sessão)
		owned = GreedIslandCardCatalog.duel_catalog().slice(10, 18)
	var foe := GreedIslandCardCatalog.npc_deck(difficulty)
	var name := "Razor" if difficulty == "razor" else "Duelista de Antokiba"
	return start_duel(owned, foe, name)


func can_play() -> bool:
	return phase == Phase.PLAYER_TURN and winner.is_empty()


func play_card_at(hand_index: int) -> Dictionary:
	if not can_play():
		return {"ok": false, "error": "nao_e_sua_vez"}
	if hand_index < 0 or hand_index >= player_hand.size():
		return {"ok": false, "error": "indice_invalido"}
	var player_card: Dictionary = player_hand[hand_index]
	player_hand.remove_at(hand_index)
	_draw_to_hand(true, 1)

	var enemy_card: Dictionary = _enemy_choose_card()
	var result := _resolve_clash(player_card, enemy_card)
	last_log = str(result.get("log", ""))
	turn += 1

	if player_hp <= 0 and enemy_hp <= 0:
		winner = "draw"
		phase = Phase.FINISHED
	elif enemy_hp <= 0:
		winner = "player"
		phase = Phase.FINISHED
	elif player_hp <= 0:
		winner = "enemy"
		phase = Phase.FINISHED
	elif turn > MAX_TURNS:
		if player_hp > enemy_hp:
			winner = "player"
		elif enemy_hp > player_hp:
			winner = "enemy"
		else:
			winner = "draw"
		phase = Phase.FINISHED
	else:
		phase = Phase.PLAYER_TURN

	return {
		"ok": true,
		"player_card": player_card,
		"enemy_card": enemy_card,
		"player_hp": player_hp,
		"enemy_hp": enemy_hp,
		"log": last_log,
		"winner": winner,
		"finished": phase == Phase.FINISHED,
		"hand": player_hand.duplicate(true),
		"turn": turn,
	}


func snapshot() -> Dictionary:
	return {
		"phase": phase,
		"player_hp": player_hp,
		"enemy_hp": enemy_hp,
		"turn": turn,
		"hand": player_hand.duplicate(true),
		"winner": winner,
		"log": last_log,
		"opponent": opponent_name,
	}


func _draw_to_hand(for_player: bool, count: int) -> void:
	for _i in count:
		if for_player:
			if player_deck.is_empty():
				return
			player_hand.append(player_deck.pop_back())
		else:
			if enemy_deck.is_empty():
				return
			enemy_hand.append(enemy_deck.pop_back())


func _enemy_choose_card() -> Dictionary:
	if enemy_hand.is_empty():
		_draw_to_hand(false, 1)
	if enemy_hand.is_empty():
		var fallback := GreedIslandCardCatalog.duel_catalog()
		return fallback[0] if not fallback.is_empty() else {"nome": "Carta Vazia", "atk": 1, "def": 1, "kind": "spell"}
	# Heurística: prioriza attack se player_hp baixo, senão maior atk+def
	var best_i := 0
	var best_score := -999
	for i in range(enemy_hand.size()):
		var c: Dictionary = enemy_hand[i]
		var score := int(c.get("atk", 0)) + int(c.get("def", 0))
		if player_hp <= 12 and str(c.get("kind", "")) == "attack":
			score += 5
		if enemy_hp <= 12 and str(c.get("kind", "")) == "heal":
			score += 4
		if score > best_score:
			best_score = score
			best_i = i
	var chosen: Dictionary = enemy_hand[best_i]
	enemy_hand.remove_at(best_i)
	_draw_to_hand(false, 1)
	return chosen


func _resolve_clash(player_card: Dictionary, enemy_card: Dictionary) -> Dictionary:
	var p_atk := int(player_card.get("atk", 0))
	var p_def := int(player_card.get("def", 0))
	var e_atk := int(enemy_card.get("atk", 0))
	var e_def := int(enemy_card.get("def", 0))
	var p_kind := str(player_card.get("kind", "spell"))
	var e_kind := str(enemy_card.get("kind", "spell"))

	var dmg_to_enemy := maxi(0, p_atk - int(e_def / 2.0))
	var dmg_to_player := maxi(0, e_atk - int(p_def / 2.0))

	if p_kind == "heal":
		player_hp = mini(STARTING_HP, player_hp + maxi(2, p_def / 2))
		dmg_to_enemy = maxi(0, int(p_atk / 3.0))
	if e_kind == "heal":
		enemy_hp = mini(STARTING_HP, enemy_hp + maxi(2, e_def / 2))
		dmg_to_player = maxi(0, int(e_atk / 3.0))

	if p_kind == "defend":
		dmg_to_player = maxi(0, dmg_to_player - 3)
	if e_kind == "defend":
		dmg_to_enemy = maxi(0, dmg_to_enemy - 3)

	enemy_hp = maxi(0, enemy_hp - dmg_to_enemy)
	player_hp = maxi(0, player_hp - dmg_to_player)

	var log := "Você: %s (%s) vs %s: %s (%s) → -%d / -%d HP" % [
		str(player_card.get("nome", "?")),
		p_kind,
		opponent_name,
		str(enemy_card.get("nome", "?")),
		e_kind,
		dmg_to_player,
		dmg_to_enemy,
	]
	return {"log": log, "dmg_to_player": dmg_to_player, "dmg_to_enemy": dmg_to_enemy}
