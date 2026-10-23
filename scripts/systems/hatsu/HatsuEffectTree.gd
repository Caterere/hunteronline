class_name HatsuEffectTree
extends RefCounted

# ============================================================
# Runtime: saldo de pontos → alocação na árvore de efeitos
# ============================================================

const DB = preload("res://scripts/systems/hatsu/HatsuEffectTreeDatabase.gd")

signal pontos_alterados(restantes: int)
signal no_alocado(node_id: StringName)

var nodes: Dictionary = {} ## id -> def
var allocated: Dictionary = {} ## id -> true
var budget_total: int = 0
var budget_spent: int = 0
var primary_category: int = -1 ## categoria escolhida na base


func _init() -> void:
	nodes = DB.build_tree()
	allocated.clear()
	allocated[&"hx_center"] = true


func reset(budget: int, categoria_primaria: int = -1) -> void:
	nodes = DB.build_tree()
	allocated.clear()
	allocated[&"hx_center"] = true
	budget_total = maxi(0, budget)
	budget_spent = 0
	primary_category = categoria_primaria
	pontos_alterados.emit(obter_saldo())


func obter_saldo() -> int:
	return budget_total - budget_spent


func obter_custo_efetivo(node_id: StringName) -> int:
	if not nodes.has(node_id):
		return 999
	var def: Dictionary = nodes[node_id]
	var base_cost: int = int(def.get("cost", 1))
	var cat: int = int(def.get("categoria", -1))
	if primary_category < 0 or cat < 0:
		return base_cost
	if cat == primary_category:
		return base_cost
	# Adjacente no hexágono Nen: +1; oposto: +2
	var dist: int = _nen_distance(primary_category, cat)
	if dist == 1:
		return base_cost + 1
	if dist >= 2:
		return base_cost + 2
	return base_cost


func _nen_distance(a: int, b: int) -> int:
	# Ordem HxH no hexágono (enum do projeto):
	# Intensificação(0)-Transformação(1)-Emissão(2)-Conjuração(3)-Manipulação(4) | Especialização(5)
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


func pode_alocar(node_id: StringName) -> Dictionary:
	if allocated.get(node_id, false):
		return {"ok": false, "reason": "Já alocado"}
	if not nodes.has(node_id):
		return {"ok": false, "reason": "Nó inválido"}
	var def: Dictionary = nodes[node_id]
	for p in def.get("prereqs", []):
		if not allocated.get(p, false):
			return {"ok": false, "reason": "Pré-requisito bloqueado"}
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
	# Se for hub de categoria e ainda não há primary, fixa
	var def: Dictionary = nodes[node_id]
	if primary_category < 0 and int(def.get("categoria", -1)) >= 0 and def.get("effects", {}).has("lock_category"):
		primary_category = int(def["categoria"])
	pontos_alterados.emit(obter_saldo())
	no_alocado.emit(node_id)
	return true


func desfazer_folha(node_id: StringName) -> bool:
	## Só desfaz se nenhum outro nó depende dele
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


func coletar_efeitos() -> Dictionary:
	var merged: Dictionary = {
		"poder": 0.0,
		"alcance": 0.0,
		"cura": 0.0,
		"raio": 0.0,
		"duracao": 0.0,
		"aura_cost": 0.0,
		"cooldown": 0.0,
		"flags": []
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


func aplicar_em_hatsu(hatsu: HatsuData) -> void:
	if hatsu == null:
		return
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
		hatsu.storage_capacity = int(fx.get("storage", 3))
	if "absorb" in flags or bool(fx.get("absorb", false)):
		hatsu.core_component = HatsuComponentLibrary.CoreType.ABSORPTION
		hatsu.absorption_rate = float(fx.get("absorb_rate", 0.03))
	if "require_stationary" in flags:
		if not (HatsuData.Condicao.PARADO_CANALIZACAO in hatsu.condicoes):
			hatsu.condicoes.append(HatsuData.Condicao.PARADO_CANALIZACAO)
	if "rooted_heal" in flags:
		if not (HatsuData.Condicao.IMOVEL_DURANTE_USO in hatsu.condicoes):
			hatsu.condicoes.append(HatsuData.Condicao.IMOVEL_DURANTE_USO)
	if "auto_dano" in flags or bool(fx.get("auto_dano", false)):
		if not (HatsuData.Condicao.AUTO_DANO in hatsu.condicoes):
			hatsu.condicoes.append(HatsuData.Condicao.AUTO_DANO)
	if fx.has("lock_category"):
		hatsu.categoria = fx["lock_category"] as HatsuData.Categoria
	elif primary_category >= 0:
		hatsu.categoria = primary_category as HatsuData.Categoria
	# Tag dos nós alocados
	var tags: Array[String] = []
	for t in hatsu.tags:
		if not str(t).begins_with("eft:"):
			tags.append(str(t))
	tags.append("eft:tree")
	for nid in allocated.keys():
		if nid != &"hx_center":
			tags.append("eft:%s" % str(nid))
	hatsu.tags = tags


static func calcular_budget_de_hatsu(hatsu: HatsuData) -> int:
	## Saldo = créditos de limitação (já existentes) convertidos em pontos de árvore.
	if hatsu == null:
		return 0
	var credits: float = hatsu.calcular_limitation_credits()
	# 10 créditos ≈ 1 ponto; mínimo 3, máximo 28 (árvore compacta)
	var pts: int = int(floor(credits / 10.0))
	return clampi(pts, 3, 28)
