class_name HatsuEffectTree
extends RefCounted

# ============================================================
# Runtime: saldo → alocação com gates de anel (Lv + mastery)
# ============================================================

const DB = preload("res://scripts/systems/hatsu/HatsuEffectTreeDatabase.gd")
const Cfg = preload("res://scripts/systems/hatsu/HatsuConfig.gd")

signal pontos_alterados(restantes: int)
signal no_alocado(node_id: StringName)

var nodes: Dictionary = {}
var allocated: Dictionary = {}
var budget_total: int = 0
var budget_spent: int = 0
var primary_category: int = -1
var player_level: int = 1
var mastery_level: float = 0.0
var bond_uses: int = 0
var deepen_count: int = 0


func _init() -> void:
	nodes = DB.build_tree()
	allocated.clear()
	allocated[&"hx_center"] = true


func reset(budget: int, categoria_primaria: int = -1, p_level: int = 1, mastery: float = 0.0) -> void:
	nodes = DB.build_tree()
	allocated.clear()
	allocated[&"hx_center"] = true
	budget_total = maxi(0, budget)
	budget_spent = 0
	primary_category = categoria_primaria
	player_level = maxi(1, p_level)
	mastery_level = maxf(0.0, mastery)
	pontos_alterados.emit(obter_saldo())


func configurar_contexto(p_level: int, mastery: float, uses: int = 0, deepens: int = 0) -> void:
	player_level = maxi(1, p_level)
	mastery_level = maxf(0.0, mastery)
	bond_uses = maxi(0, uses)
	deepen_count = maxi(0, deepens)


func obter_saldo() -> int:
	return budget_total - budget_spent


func obter_custo_efetivo(node_id: StringName) -> int:
	if not nodes.has(node_id):
		return 999
	var def: Dictionary = nodes[node_id]
	var base_cost: int = int(def.get("cost", 1))
	var cat: int = int(def.get("categoria", -1))
	if primary_category < 0 or cat < 0 or cat == primary_category:
		return base_cost
	# Fora do raio: caro de propósito (apego ao caminho)
	var dist: int = _nen_distance(primary_category, cat)
	if dist == 1:
		return base_cost + 2
	return base_cost + 3


func _nen_distance(a: int, b: int) -> int:
	if a == b:
		return 0
	if a == int(HatsuData.Categoria.ESPECIALIZACAO) or b == int(HatsuData.Categoria.ESPECIALIZACAO):
		return 2
	var ring := [
		int(HatsuData.Categoria.INTENSIFICACAO),
		int(HatsuData.Categoria.TRANSFORMACAO),
		int(HatsuData.Categoria.EMISSAO),
		int(HatsuData.Categoria.CONJURACAO),
		int(HatsuData.Categoria.MANIPULACAO)
	]
	var ia := ring.find(a)
	var ib := ring.find(b)
	if ia < 0 or ib < 0:
		return 2
	var d: int = absi(ia - ib)
	return mini(d, ring.size() - d)


func gate_anel(ring: int) -> Dictionary:
	var lvl_need: int = 0
	var mast_need: int = 0
	if ring >= 0 and ring < Cfg.TREE_RING_LEVEL.size():
		lvl_need = int(Cfg.TREE_RING_LEVEL[ring])
	if ring >= 0 and ring < Cfg.TREE_RING_MASTERY.size():
		mast_need = int(Cfg.TREE_RING_MASTERY[ring])
	var lvl_ok: bool = player_level >= lvl_need
	var mast_ok: bool = mastery_level + 0.001 >= float(mast_need)
	if ring >= 3 and Cfg.TREE_KEYSTONE_REQUIRES_BOTH:
		if not lvl_ok or not mast_ok:
			return {
				"ok": false,
				"reason": "Anel 3 exige Lv.%d E Mastery %d (agora Lv.%d / M%.0f)" % [
					lvl_need, mast_need, player_level, mastery_level
				]
			}
	else:
		# Anéis 1–2: nível OU mastery (crescer como caçador OU com a técnica)
		if ring >= 2 and not lvl_ok and not mast_ok:
			return {
				"ok": false,
				"reason": "Anel %d: precisa Lv.%d ou Mastery %d" % [ring, lvl_need, mast_need]
			}
		if ring == 1 and not lvl_ok and not mast_ok:
			return {"ok": false, "reason": "Anel 1 bloqueado"}
	return {"ok": true, "reason": "OK", "lvl_need": lvl_need, "mast_need": mast_need}


func pode_alocar(node_id: StringName) -> Dictionary:
	if allocated.get(node_id, false):
		return {"ok": false, "reason": "Já alocado"}
	if not nodes.has(node_id):
		return {"ok": false, "reason": "Nó inválido"}
	var def: Dictionary = nodes[node_id]
	for p in def.get("prereqs", []):
		if not allocated.get(p, false):
			return {"ok": false, "reason": "Pré-requisito bloqueado"}
	var gate := gate_anel(int(def.get("ring", 0)))
	if not gate.get("ok", false):
		return gate
	var cost: int = obter_custo_efetivo(node_id)
	if cost > obter_saldo():
		return {"ok": false, "reason": "Pontos insuficientes (%d)" % cost}
	return {"ok": true, "reason": "OK", "cost": cost}


func alocar(node_id: StringName) -> bool:
	var check := pode_alocar(node_id)
	if not check.get("ok", false):
		return false
	var cost: int = int(check.get("cost", obter_custo_efetivo(node_id)))
	allocated[node_id] = true
	budget_spent += cost
	var def: Dictionary = nodes[node_id]
	if primary_category < 0 and int(def.get("categoria", -1)) >= 0 and def.get("effects", {}).has("lock_category"):
		primary_category = int(def["categoria"])
	pontos_alterados.emit(obter_saldo())
	no_alocado.emit(node_id)
	return true


func desfazer_folha(node_id: StringName) -> bool:
	if node_id == &"hx_center" or not allocated.get(node_id, false):
		return false
	for nid in nodes.keys():
		if allocated.get(nid, false):
			var pr: Array = nodes[nid].get("prereqs", [])
			if node_id in pr:
				return false
	var cost: int = obter_custo_efetivo(node_id)
	allocated.erase(node_id)
	budget_spent = maxi(0, budget_spent - cost)
	pontos_alterados.emit(obter_saldo())
	return true


func tem_compromisso_categoria() -> bool:
	for nid in allocated.keys():
		if not nodes.has(nid):
			continue
		var def: Dictionary = nodes[nid]
		if int(def.get("kind", -1)) == int(DB.NodeKind.HUB) and int(def.get("categoria", -1)) >= 0:
			return true
	return false


func coletar_efeitos() -> Dictionary:
	var merged: Dictionary = {
		"poder": 0.0, "alcance": 0.0, "cura": 0.0, "raio": 0.0,
		"duracao": 0.0, "aura_cost": 0.0, "cooldown": 0.0, "flags": []
	}
	for nid in allocated.keys():
		if not nodes.has(nid):
			continue
		var fx: Dictionary = nodes[nid].get("effects", {})
		for k in fx.keys():
			var v = fx[k]
			if typeof(v) in [TYPE_INT, TYPE_FLOAT] and merged.has(k):
				merged[k] = float(merged[k]) + float(v)
			elif typeof(v) == TYPE_BOOL and v:
				(merged["flags"] as Array).append(str(k))
			elif k == "lock_category":
				merged["lock_category"] = int(v)
			else:
				merged[k] = v
	return merged


func serializar_alocacao() -> Dictionary:
	var ids: Array = []
	for nid in allocated.keys():
		ids.append(str(nid))
	return {
		"allocated": ids,
		"budget_total": budget_total,
		"budget_spent": budget_spent,
		"primary_category": primary_category,
		"deepen_count": deepen_count,
		"bond_uses": bond_uses
	}


func restaurar_alocacao(state: Dictionary) -> void:
	nodes = DB.build_tree()
	allocated.clear()
	allocated[&"hx_center"] = true
	budget_total = int(state.get("budget_total", budget_total))
	budget_spent = 0
	primary_category = int(state.get("primary_category", primary_category))
	deepen_count = int(state.get("deepen_count", deepen_count))
	bond_uses = int(state.get("bond_uses", bond_uses))
	var ids: Array = state.get("allocated", [])
	# Reaplica na ordem de dependência (várias passadas)
	var pending: Array = ids.duplicate()
	var guard := 0
	while not pending.is_empty() and guard < 64:
		guard += 1
		var next_pending: Array = []
		for raw in pending:
			var nid := StringName(str(raw))
			if nid == &"hx_center" or allocated.get(nid, false):
				continue
			if not nodes.has(nid):
				continue
			var ok_prereq := true
			for p in nodes[nid].get("prereqs", []):
				if not allocated.get(p, false):
					ok_prereq = false
					break
			if not ok_prereq:
				next_pending.append(raw)
				continue
			# Força alocação ignorando gates de anel (já conquistado)
			var cost: int = obter_custo_efetivo(nid)
			allocated[nid] = true
			budget_spent += cost
			var def: Dictionary = nodes[nid]
			if primary_category < 0 and int(def.get("categoria", -1)) >= 0 and def.get("effects", {}).has("lock_category"):
				primary_category = int(def["categoria"])
		pending = next_pending
	# Corrige spent se state tinha valor explícito inconsistente
	if int(state.get("budget_spent", -1)) >= 0:
		budget_spent = mini(budget_total, maxi(budget_spent, int(state.get("budget_spent", budget_spent))))
	pontos_alterados.emit(obter_saldo())


func expandir_budget(novos_pontos: int) -> void:
	budget_total += maxi(0, novos_pontos)
	pontos_alterados.emit(obter_saldo())


func aplicar_em_hatsu(hatsu: HatsuData) -> void:
	if hatsu == null:
		return
	if not hatsu.parametros_conceito is Dictionary:
		hatsu.parametros_conceito = {}
	var bag: Dictionary = hatsu.parametros_conceito.get("effect_tree", {})
	if typeof(bag) != TYPE_DICTIONARY:
		bag = {}

	# Snapshot da forja (antes da árvore) para reaplicar sem duplicar
	if not bag.has("forge_snapshot"):
		bag["forge_snapshot"] = {
			"poder_base": hatsu.poder_base,
			"alcance": hatsu.alcance,
			"cura_base": hatsu.cura_base,
			"raio": hatsu.raio,
			"duracao": hatsu.duracao,
			"custo_aura_base": hatsu.custo_aura_base,
			"cooldown_base": hatsu.cooldown_base,
			"forma": int(hatsu.forma),
			"activation_type": int(hatsu.activation_type),
			"stun_duracao": hatsu.stun_duracao,
			"aura_drain_per_sec": hatsu.aura_drain_per_sec,
			"exclusive_group": hatsu.exclusive_group,
			"concurrent_allowed": hatsu.concurrent_allowed,
			"arquetipo": int(hatsu.arquetipo),
			"is_storage_hatsu": hatsu.is_storage_hatsu,
			"storage_capacity": hatsu.storage_capacity,
			"core_component": hatsu.core_component,
			"absorption_rate": hatsu.absorption_rate,
			"categoria": int(hatsu.categoria),
			"objetivo": int(hatsu.objetivo),
		}
	else:
		var snap: Dictionary = bag["forge_snapshot"]
		hatsu.poder_base = float(snap.get("poder_base", hatsu.poder_base))
		hatsu.alcance = float(snap.get("alcance", hatsu.alcance))
		hatsu.cura_base = float(snap.get("cura_base", hatsu.cura_base))
		hatsu.raio = float(snap.get("raio", hatsu.raio))
		hatsu.duracao = float(snap.get("duracao", hatsu.duracao))
		hatsu.custo_aura_base = float(snap.get("custo_aura_base", hatsu.custo_aura_base))
		hatsu.cooldown_base = float(snap.get("cooldown_base", hatsu.cooldown_base))
		hatsu.forma = int(snap.get("forma", int(hatsu.forma))) as HatsuData.Forma
		hatsu.activation_type = int(snap.get("activation_type", int(hatsu.activation_type))) as HatsuData.ActivationType
		hatsu.stun_duracao = float(snap.get("stun_duracao", hatsu.stun_duracao))
		hatsu.aura_drain_per_sec = float(snap.get("aura_drain_per_sec", hatsu.aura_drain_per_sec))
		hatsu.exclusive_group = str(snap.get("exclusive_group", hatsu.exclusive_group))
		hatsu.concurrent_allowed = bool(snap.get("concurrent_allowed", hatsu.concurrent_allowed))
		hatsu.arquetipo = int(snap.get("arquetipo", int(hatsu.arquetipo))) as HatsuData.Arquetipo
		hatsu.is_storage_hatsu = bool(snap.get("is_storage_hatsu", hatsu.is_storage_hatsu))
		hatsu.storage_capacity = int(snap.get("storage_capacity", hatsu.storage_capacity))
		hatsu.core_component = int(snap.get("core_component", hatsu.core_component))
		hatsu.absorption_rate = float(snap.get("absorption_rate", hatsu.absorption_rate))
		hatsu.categoria = int(snap.get("categoria", int(hatsu.categoria))) as HatsuData.Categoria
		hatsu.objetivo = int(snap.get("objetivo", int(hatsu.objetivo))) as HatsuData.ObjetivoPrincipal

	var fx := coletar_efeitos()
	hatsu.poder_base = maxf(10.0, hatsu.poder_base + float(fx.get("poder", 0.0)))
	hatsu.alcance = maxf(20.0, hatsu.alcance + float(fx.get("alcance", 0.0)))
	hatsu.cura_base = maxf(0.0, hatsu.cura_base + float(fx.get("cura", 0.0)))
	hatsu.raio = maxf(20.0, hatsu.raio + float(fx.get("raio", 0.0)))
	hatsu.duracao = maxf(0.0, hatsu.duracao + float(fx.get("duracao", 0.0)))
	hatsu.custo_aura_base = maxf(5.0, hatsu.custo_aura_base + float(fx.get("aura_cost", 0.0)))
	hatsu.cooldown_base = maxf(0.5, hatsu.cooldown_base + float(fx.get("cooldown", 0.0)))
	var flags: Array = fx.get("flags", [])
	if "forma_projetil" in flags or bool(fx.get("forma_projetil", false)):
		hatsu.forma = HatsuData.Forma.PROJETIL
	if "forma_area" in flags or bool(fx.get("forma_area", false)):
		hatsu.forma = HatsuData.Forma.AREA
	if "charged" in flags or bool(fx.get("charged", false)):
		hatsu.activation_type = HatsuData.ActivationType.CHARGED
	if "transformation_mode" in flags or bool(fx.get("transformation_mode", false)):
		hatsu.activation_type = HatsuData.ActivationType.TRANSFORMATION
		hatsu.exclusive_group = "transformation_mode"
	if "library" in flags or bool(fx.get("library", false)):
		hatsu.arquetipo = HatsuData.Arquetipo.LIVRO_COLECAO
		hatsu.is_storage_hatsu = true
		hatsu.storage_capacity = int(fx.get("storage", 2))
	if "absorb" in flags or bool(fx.get("absorb", false)):
		hatsu.core_component = HatsuComponentLibrary.CoreType.ABSORPTION
		hatsu.absorption_rate = float(fx.get("absorb_rate", 0.025))
	if "require_stationary" in flags:
		if not (HatsuData.Condicao.PARADO_CANALIZACAO in hatsu.condicoes):
			hatsu.condicoes.append(HatsuData.Condicao.PARADO_CANALIZACAO)
	if "rooted_heal" in flags:
		if not (HatsuData.Condicao.IMOVEL_DURANTE_USO in hatsu.condicoes):
			hatsu.condicoes.append(HatsuData.Condicao.IMOVEL_DURANTE_USO)
	if "auto_dano" in flags or bool(fx.get("auto_dano", false)):
		if not (HatsuData.Condicao.AUTO_DANO in hatsu.condicoes):
			hatsu.condicoes.append(HatsuData.Condicao.AUTO_DANO)
	if fx.has("stun") or "stun" in flags:
		hatsu.stun_duracao = maxf(hatsu.stun_duracao, float(fx.get("stun", 1.0)))
		if hatsu.objetivo != HatsuData.ObjetivoPrincipal.CONTROLE:
			hatsu.objetivo = HatsuData.ObjetivoPrincipal.CONTROLE
	if fx.has("aura_drain"):
		hatsu.aura_drain_per_sec = maxf(hatsu.aura_drain_per_sec, float(fx.get("aura_drain", 0.0)))
	if "exclusive_transform" in flags or bool(fx.get("exclusive_transform", false)):
		hatsu.exclusive_group = "transformation_mode"
		hatsu.concurrent_allowed = false
	if fx.has("lock_category"):
		hatsu.categoria = fx["lock_category"] as HatsuData.Categoria
	elif primary_category >= 0:
		hatsu.categoria = primary_category as HatsuData.Categoria

	var combat: Dictionary = {}
	if fx.has("multishot"):
		combat["multishot"] = int(fx.get("multishot", 1))
	if fx.has("knockback"):
		combat["knockback"] = float(fx.get("knockback", 0.0))
	if fx.has("proj_speed"):
		combat["proj_speed"] = float(fx.get("proj_speed", 0.0))
	if fx.has("piercing"):
		combat["piercing"] = float(fx.get("piercing", 0.0))
	if fx.has("control_pull") or "control_pull" in flags:
		combat["control_pull"] = true
	if fx.has("control_bind") or "control_bind" in flags:
		combat["control_bind"] = true
	if fx.has("control") or "control" in flags:
		combat["control"] = true
	if fx.has("puppet_buff") or "puppet_buff" in flags:
		combat["puppet_buff"] = true
	if fx.has("versatile") or "versatile" in flags:
		combat["versatile"] = true
	if fx.has("emperor_like") or "emperor_like" in flags:
		combat["emperor_like"] = true

	var ser := serializar_alocacao()
	for k in ser.keys():
		bag[k] = ser[k]
	bag["combat"] = combat
	bag["budget_spent"] = budget_spent
	bag["budget_total"] = budget_total
	if not bag.has("chronicle"):
		bag["chronicle"] = []
	hatsu.parametros_conceito["effect_tree"] = bag

	var tags: Array[String] = []
	for t in hatsu.tags:
		if not str(t).begins_with("eft:"):
			tags.append(str(t))
	tags.append("eft:tree")
	if combat.get("multishot", 0) > 1:
		tags.append("multishot")
	if combat.get("control_pull", false):
		tags.append("control_pull")
	if combat.get("knockback", 0.0) > 0.0:
		tags.append("knockback")
	if combat.get("piercing", 0.0) > 0.0:
		tags.append("piercing")
	for nid in allocated.keys():
		if nid != &"hx_center":
			tags.append("eft:%s" % str(nid))
	hatsu.tags = tags


static func calcular_budget_de_hatsu(hatsu: HatsuData) -> int:
	if hatsu == null:
		return 0
	var credits: float = hatsu.calcular_limitation_credits()
	var pts: int = int(floor(credits / Cfg.TREE_CREDITS_PER_POINT))
	return clampi(pts, Cfg.TREE_BUDGET_MIN, Cfg.TREE_BUDGET_MAX)


static func calcular_pontos_deepen(creditos_antes: float, creditos_depois: float, deepen_ja: int) -> int:
	var ganho: float = maxf(0.0, creditos_depois - creditos_antes)
	if ganho < Cfg.DEEPEN_MIN_CREDIT_GAIN:
		return 0
	var raw: float = ganho / Cfg.TREE_CREDITS_PER_POINT
	var eff: float = Cfg.DEEPEN_POINT_EFFICIENCY * pow(0.88, float(deepen_ja))
	return maxi(0, int(floor(raw * eff)))


static func obter_bond_chapter(uses: int) -> int:
	return clampi(int(floor(float(uses) / float(Cfg.BOND_USES_PER_CHAPTER))) + 1, 1, Cfg.BOND_MAX_CHAPTER)


static func bond_titulo(chapter: int) -> String:
	match chapter:
		1: return "Conhecidos"
		2: return "Companheiros"
		3: return "Cicatrizes Compartilhadas"
		4: return "Pacto Silencioso"
		5: return "Lenda Pessoal"
		_: return "Vínculo"
