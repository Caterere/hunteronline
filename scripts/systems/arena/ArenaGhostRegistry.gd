class_name ArenaGhostRegistry
extends RefCounted

# ============================================================
# HUNTER ONLINE — Arena Ghost Registry (PvP assíncrono local)
# ============================================================
#
# Guarda snapshots de combate do jogador ao limpar andares da Torre.
# Outros runs / andares especiais puxam ghosts (ou proxies de Besta de Nen)
# sem precisar de rede. Persistido em PlayerData.attributes["arena_ghosts"].
#
# ============================================================

const ATTR_KEY := "arena_ghosts"
const MAX_GHOSTS := 24


## Snapshot do lutador atual no andar vencido.
static func capturar_do_jogador(andar: int) -> Dictionary:
	var nivel: int = 1
	var hp: int = 120
	var frc: int = 12
	var dfs: int = 8
	var nome: String = "Caçador Fantasma"
	var tem_nen: bool = false
	var besta: String = ""

	if PlayerData != null:
		nivel = int(PlayerData.attributes.get("nivel", 1))
		hp = maxi(80, int(PlayerData.attributes.get("vida_max", 100)))
		frc = maxi(8, int(PlayerData.attributes.get("forca", 10)))
		dfs = maxi(4, int(PlayerData.attributes.get("defesa", 10)))
		tem_nen = PlayerData.despertou_nen
		nome = str(PlayerData.attributes.get("nome", "Caçador Fantasma"))
		if nome.strip_edges().is_empty():
			nome = "Caçador Fantasma"
		if PlayerData.besta_nen_equipada != null:
			besta = str(PlayerData.besta_nen_equipada.nome_besta)

	return {
		"kind": "ghost",
		"nome": nome,
		"andar_origem": maxi(1, andar),
		"nivel": nivel,
		"max_health": hp,
		"strength": frc,
		"defense": dfs,
		"tem_nen": tem_nen,
		"besta_nome": besta,
		"xp_reward": 40 + andar * 10,
	}


static func registrar(ghost: Dictionary) -> void:
	if PlayerData == null or ghost.is_empty():
		return
	var lista: Array = []
	var raw = PlayerData.attributes.get(ATTR_KEY, [])
	if raw is Array:
		lista = (raw as Array).duplicate(true)
	lista.append(ghost.duplicate(true))
	while lista.size() > MAX_GHOSTS:
		lista.pop_front()
	PlayerData.attributes[ATTR_KEY] = lista


static func limpar() -> void:
	if PlayerData != null:
		PlayerData.attributes[ATTR_KEY] = []


static func listar() -> Array:
	if PlayerData == null:
		return []
	var raw = PlayerData.attributes.get(ATTR_KEY, [])
	return raw if raw is Array else []


## Escolhe ghost do andar mais próximo (preferência: origem <= andar atual).
static func obter_para_andar(andar: int) -> Dictionary:
	var lista := listar()
	if lista.is_empty():
		return {}
	var melhor: Dictionary = {}
	var melhor_dist: int = 999999
	for item in lista:
		if typeof(item) != TYPE_DICTIONARY:
			continue
		var g: Dictionary = item
		var origem: int = int(g.get("andar_origem", 1))
		var dist: int = absi(andar - origem)
		# Prefere ghosts um pouco abaixo do andar (rival "já conquistado").
		if origem > andar:
			dist += 3
		if dist < melhor_dist:
			melhor_dist = dist
			melhor = g
	return melhor.duplicate(true)


## Proxy temático de Besta de Nen quando não há ghost gravado.
static func criar_proxy_besta(andar: int) -> Dictionary:
	var a: int = maxi(1, andar)
	var nome: String
	var cor_hint: String
	if a >= 200:
		nome = "Eco da Besta Guardiã"
		cor_hint = "nen"
	elif a >= 100:
		nome = "Sombra da Besta de Nen"
		cor_hint = "beast"
	elif a >= 50:
		nome = "Projeção de Besta Aprendiz"
		cor_hint = "beast"
	else:
		nome = "Miragem de Aura Bestial"
		cor_hint = "ghost"

	var hp: int = 220 + a * 16
	var frc: int = 14 + int(float(a) * 1.05)
	var dfs: int = 8 + int(float(a) * 0.75)
	if a % 10 == 0:
		hp = int(float(hp) * 1.4)
		frc = int(float(frc) * 1.2)

	return {
		"kind": "nen_beast",
		"nome": nome,
		"andar_origem": a,
		"nivel": maxi(1, 10 + a / 5),
		"max_health": hp,
		"strength": frc,
		"defense": dfs,
		"tem_nen": a >= 50,
		"besta_nome": nome,
		"cor_hint": cor_hint,
		"xp_reward": 50 + a * 12,
	}


## Decide oponente assíncrono: ghost local ou proxy de Besta.
static func obter_oponente_async(andar: int) -> Dictionary:
	var ghost := obter_para_andar(andar)
	if not ghost.is_empty():
		# Escala leve para o andar atual (ghost antigo não fica trivial).
		var origem: int = int(ghost.get("andar_origem", 1))
		if andar > origem:
			var delta: int = andar - origem
			ghost["max_health"] = int(ghost.get("max_health", 100)) + delta * 10
			ghost["strength"] = int(ghost.get("strength", 10)) + int(delta * 0.6)
			ghost["defense"] = int(ghost.get("defense", 5)) + int(delta * 0.4)
			ghost["xp_reward"] = int(ghost.get("xp_reward", 40)) + delta * 4
		ghost["kind"] = "ghost"
		return ghost
	return criar_proxy_besta(andar)


static func deve_usar_oponente_async(andar: int) -> bool:
	# Andares especiais: a cada 5 (inclui bosses %10).
	return andar > 0 and andar % 5 == 0
