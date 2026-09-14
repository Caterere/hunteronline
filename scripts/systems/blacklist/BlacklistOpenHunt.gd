class_name BlacklistOpenHunt
extends RefCounted

# ============================================================
# HUNTER ONLINE — A7 BLACKLIST OPEN HUNT
# ============================================================
#
# Caça aberta S-rank: rumor → cartaz → spawn de world boss co-op
# com CoopWorldBossCoordinator (threat + loot por contribuição).
# IDs alinhados com BountySystem (open_hunt: true).
#
# ============================================================

const OPEN_HUNT_CONTRACTS := {
	"bounty_cacador_renegado_zaban": {
		"id": "bounty_cacador_renegado_zaban",
		"nome_alvo": "Karkov, o Caçador Desonrado",
		"enemy_id": "arqueiro_renegado",
		"regiao": "ruinas_zaban",
		"nivel_alvo": 120,
		"recompensa_jenny": 150000,
		"xp_total": 4000,
		"boss_hp": 4500,
		"drop_garantido": "licenca_hunter",
		"descricao": "S-rank Blacklist: traidor da Associação. Caça aberta — party bem-vinda.",
		"open_hunt": true,
		"spawn_pos": Vector2(420, 280)
	},
	"bounty_esquadrao_rebelde_chimera": {
		"id": "bounty_esquadrao_rebelde_chimera",
		"nome_alvo": "General Formiga Renegado 'Drakon'",
		"enemy_id": "lider_matilha_quimera",
		"regiao": "ngl_formigas",
		"nivel_alvo": 680,
		"recompensa_jenny": 15000000,
		"xp_total": 25000,
		"boss_hp": 18000,
		"drop_garantido": "olho_quimera",
		"descricao": "S-rank Blacklist: esquadrão mutante. Threat multi-party.",
		"open_hunt": true,
		"spawn_pos": Vector2(320, 240)
	}
}

static var active_hunts: Dictionary = {} ## hunt_id -> {coordinator, enemy_node, contract}


static func list_open_hunts() -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for k in OPEN_HUNT_CONTRACTS.keys():
		out.append(OPEN_HUNT_CONTRACTS[k].duplicate(true))
	return out


static func get_hunt(hunt_id: String) -> Dictionary:
	return OPEN_HUNT_CONTRACTS.get(hunt_id, {}).duplicate(true)


static func is_open_hunt(contrato_id: String) -> bool:
	if OPEN_HUNT_CONTRACTS.has(contrato_id):
		return true
	if BountySystem != null and BountySystem.active_bounty_contracts.has(contrato_id):
		return bool(BountySystem.active_bounty_contracts[contrato_id].get("open_hunt", false))
	return false


static func iniciar_caca(hunt_id: String, parent: Node, spawn_override: Vector2 = Vector2.ZERO) -> Dictionary:
	var contract: Dictionary = get_hunt(hunt_id)
	if contract.is_empty():
		return {"ok": false, "erro": "Hunt não catalogada"}
	if active_hunts.has(hunt_id):
		return {"ok": false, "erro": "Caça já ativa"}
	if parent == null:
		return {"ok": false, "erro": "Parent inválido"}

	if RumorSystem != null and RumorSystem.has_method("criar_rumor"):
		RumorSystem.criar_rumor(
			"rumor_%s" % hunt_id,
			"Blacklist: %s avistado" % str(contract.get("nome_alvo")),
			str(contract.get("descricao")),
			str(contract.get("regiao", "lobby")),
			""
		)
	if WorldEventManager != null and WorldEventManager.has_method("criar_evento_dinamico"):
		WorldEventManager.criar_evento_dinamico(
			"event_%s" % hunt_id,
			"Caça Aberta: %s" % str(contract.get("nome_alvo")),
			str(contract.get("descricao")),
			str(contract.get("regiao", "lobby")),
			12.0,
			int(mini(99, int(contract.get("nivel_alvo", 50)) / 10))
		)

	var coord_script = load("res://scripts/network/CoopWorldBossCoordinator.gd")
	if coord_script == null:
		return {"ok": false, "erro": "CoopWorldBossCoordinator ausente"}
	var coord = coord_script.new()
	coord.inicializar_boss(
		str(contract.get("enemy_id")),
		str(contract.get("nome_alvo")),
		int(contract.get("boss_hp", 3000))
	)

	var spawn_pos: Vector2 = spawn_override if spawn_override != Vector2.ZERO else contract.get("spawn_pos", Vector2(320, 240))
	var enemy_node: Node = _spawn_world_boss(parent, contract, spawn_pos, coord, hunt_id)
	if enemy_node == null:
		return {"ok": false, "erro": "Falha ao spawnar boss"}

	if BountySystem != null:
		var cid := str(contract.get("id"))
		if not BountySystem.active_bounty_contracts.has(cid):
			var c := contract.duplicate(true)
			c["aceito"] = true
			c["concluido"] = false
			BountySystem.active_bounty_contracts[cid] = c
		else:
			BountySystem.active_bounty_contracts[cid]["aceito"] = true
			BountySystem.active_bounty_contracts[cid]["open_hunt"] = true

	active_hunts[hunt_id] = {
		"coordinator": coord,
		"enemy_node": enemy_node,
		"contract": contract
	}

	if EventBus != null:
		EventBus.emit_toast("🏴 Caça Aberta: %s" % str(contract.get("nome_alvo")), Color(1.0, 0.35, 0.35))
		if EventBus.has_signal("world_event_triggered"):
			EventBus.world_event_triggered.emit(hunt_id, "Blacklist Open Hunt", spawn_pos)

	MultiplayerStateBridge.sincronizar_world_boss(
		str(contract.get("enemy_id")),
		1,
		int(contract.get("boss_hp", 3000)),
		int(contract.get("boss_hp", 3000)),
		str(contract.get("nome_alvo"))
	)

	return {"ok": true, "hunt_id": hunt_id, "enemy": enemy_node, "coordinator": coord}


static func _spawn_world_boss(parent: Node, contract: Dictionary, pos: Vector2, coord, hunt_id: String) -> Node:
	var enemy_scn = load("res://scripts/systems/EnemySystem/Enemy.tscn")
	if enemy_scn == null:
		return null
	var enemy = enemy_scn.instantiate()
	enemy.name = str(contract.get("nome_alvo", "BlacklistBoss")).replace(" ", "_").replace("'", "")
	enemy.position = pos
	parent.add_child(enemy)
	var es = enemy.get_node_or_null("EnemySystem")
	if es == null:
		return enemy
	es.is_boss = true
	es.max_health = int(contract.get("boss_hp", 3000))
	es.health = es.max_health
	es.xp_reward = int(contract.get("xp_total", 1000))
	es.nen_xp_reward = int(float(contract.get("xp_total", 1000)) * 0.4)
	es.enemy_id = StringName(str(contract.get("enemy_id", "boss")))
	es.enemy_name = str(contract.get("nome_alvo"))
	if DataManager != null and DataManager.has_method("get_enemy"):
		var ed = DataManager.get_enemy(es.enemy_id)
		if ed != null:
			es.enemy_data = ed
			if "attack_telegraph_type" in ed:
				ed.attack_telegraph_type = "aoe_circle"
	if es.has_signal("damaged"):
		es.damaged.connect(func(dano: int):
			var pid := 1
			if NetworkManager != null and "local_peer_id" in NetworkManager:
				pid = maxi(1, int(NetworkManager.local_peer_id))
			coord.registrar_dano(pid, dano, false)
		)
	es.died.connect(func(_id):
		_finalizar_caca(hunt_id, parent, coord)
	)
	var tree := parent.get_tree()
	if tree != null:
		var hud = tree.get_first_node_in_group("player_hud")
		if hud and hud.has_method("registrar_boss"):
			hud.registrar_boss(es)
	return enemy


static func _finalizar_caca(hunt_id: String, parent: Node, coord) -> void:
	var contract: Dictionary = get_hunt(hunt_id)
	if contract.is_empty() and active_hunts.has(hunt_id):
		contract = active_hunts[hunt_id].get("contract", {})

	var rewards: Dictionary = {}
	if coord != null and coord.has_method("calcular_recompensas_coop"):
		rewards = coord.calcular_recompensas_coop(
			int(contract.get("xp_total", 1000)),
			int(contract.get("recompensa_jenny", 1000)),
			str(contract.get("drop_garantido", ""))
		)

	var local_id := 1
	if NetworkManager != null and "local_peer_id" in NetworkManager:
		local_id = maxi(1, int(NetworkManager.local_peer_id))
	var mine: Dictionary = rewards.get(local_id, {})
	if mine.is_empty() and not rewards.is_empty():
		mine = rewards[rewards.keys()[0]]

	var drop_pos := Vector2(320, 240)
	if active_hunts.has(hunt_id):
		var en = active_hunts[hunt_id].get("enemy_node")
		if en != null and is_instance_valid(en):
			drop_pos = en.global_position if "global_position" in en else en.position

	if not mine.is_empty():
		if Economy != null:
			Economy.adicionar_gold(int(mine.get("jenny", 0)))
		if parent != null and parent.get_tree() != null:
			var players = parent.get_tree().get_nodes_in_group("player")
			if not players.is_empty():
				var xp_sys = players[0].get_node_or_null("XPSystem")
				if xp_sys != null and xp_sys.has_method("adicionar_xp"):
					xp_sys.adicionar_xp(int(mine.get("xp", 0)), "Blacklist Open Hunt")
		for it in mine.get("itens", []):
			if PlayerData != null:
				PlayerData.adicionar_item(StringName(str(it)), 1)
			if parent != null:
				LootDrop.spawn_item_drop(parent, drop_pos + Vector2(randf_range(-12, 12), randf_range(-6, 6)), str(it))
		if parent != null:
			LootDrop.spawn_jenny(parent, drop_pos + Vector2(0, 10), int(mine.get("jenny", 50)))

	# Marca concluído sem pagar jenny cheia de novo (loot já veio por contribuição)
	if BountySystem != null and BountySystem.has_method("concluir_contrato"):
		BountySystem.concluir_contrato(hunt_id, true)
	if FactionManager != null and FactionManager.faccao_atual == "blacklist":
		FactionManager.adicionar_faccao_xp(250)

	if EventBus != null:
		EventBus.emit_toast("🏴 Caça concluída — loot por contribuição", Color(0.95, 0.75, 0.2))
		EventBus.enemy_defeated.emit(str(contract.get("enemy_id", hunt_id)), int(mine.get("xp", 0)), 0)

	active_hunts.erase(hunt_id)


static func registrar_dano_local(hunt_id: String, dano: int, is_taunt: bool = false) -> void:
	if not active_hunts.has(hunt_id):
		return
	var coord = active_hunts[hunt_id].get("coordinator")
	if coord == null:
		return
	var pid := 1
	if NetworkManager != null and "local_peer_id" in NetworkManager:
		pid = maxi(1, int(NetworkManager.local_peer_id))
	coord.registrar_dano(pid, dano, is_taunt)


static func limpar_caca(hunt_id: String) -> void:
	if not active_hunts.has(hunt_id):
		return
	var entry = active_hunts[hunt_id]
	var en = entry.get("enemy_node")
	if en != null and is_instance_valid(en):
		en.queue_free()
	active_hunts.erase(hunt_id)
