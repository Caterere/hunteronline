class_name HatsuEffectTreeDatabase
extends RefCounted

# ============================================================
# Árvore de efeitos do Hatsu Creator (compacta, 6 raios Nen)
# ============================================================
# Maximizar é difícil de propósito: anéis gated + custos altos +
# poucos pontos. O jogador escolhe um caminho e se apega a ele.
# ============================================================

enum NodeKind {
	HUB,       ## centro / marco de categoria
	SMALL,     ## +stat leve
	MAJOR,     ## efeito estrutural
	KEYSTONE   ## identidade da categoria (caro + gated)
}


static func build_tree() -> Dictionary:
	## id -> { id, nome, kind, categoria, cost, prereqs, effects, pos, desc, ring, ... }
	var nodes: Dictionary = {}
	nodes[&"hx_center"] = {
		"id": &"hx_center",
		"nome": "Núcleo do Hatsu",
		"kind": NodeKind.HUB,
		"categoria": -1,
		"cost": 0,
		"prereqs": [],
		"effects": {"core": true},
		"pos": Vector2.ZERO,
		"ring": 0,
		"desc": "Origem da técnica. Escolha UM raio — maximizar todos é quase impossível."
	}

	var spokes := [
		{"cat": HatsuData.Categoria.INTENSIFICACAO, "nome": "Intensificação", "ang": -90.0, "cor": Color(0.95, 0.45, 0.25)},
		{"cat": HatsuData.Categoria.EMISSAO, "nome": "Emissão", "ang": -30.0, "cor": Color(0.35, 0.75, 1.0)},
		{"cat": HatsuData.Categoria.TRANSFORMACAO, "nome": "Transformação", "ang": 30.0, "cor": Color(0.55, 1.0, 0.55)},
		{"cat": HatsuData.Categoria.CONJURACAO, "nome": "Conjuração", "ang": 90.0, "cor": Color(0.85, 0.7, 1.0)},
		{"cat": HatsuData.Categoria.MANIPULACAO, "nome": "Manipulação", "ang": 150.0, "cor": Color(1.0, 0.85, 0.35)},
		{"cat": HatsuData.Categoria.ESPECIALIZACAO, "nome": "Especialização", "ang": 210.0, "cor": Color(1.0, 0.35, 0.75)},
	]
	for sp in spokes:
		_build_spoke(nodes, sp)
	return nodes


static func _build_spoke(nodes: Dictionary, sp: Dictionary) -> void:
	var cat: int = int(sp["cat"])
	var ang: float = deg_to_rad(float(sp["ang"]))
	var dir := Vector2(cos(ang), sin(ang))
	var prefix := "hx_c%d" % cat
	var hub_id := StringName("%s_hub" % prefix)
	nodes[hub_id] = {
		"id": hub_id,
		"nome": "Marco: %s" % str(sp["nome"]),
		"kind": NodeKind.HUB,
		"categoria": cat,
		"cost": 1,
		"prereqs": [&"hx_center"],
		"effects": {"lock_category": cat},
		"pos": dir * 90.0,
		"ring": 0,
		"desc": "Compromete o Hatsu com esta categoria. Outros raios ficam bem mais caros.",
		"cor": sp["cor"]
	}

	var chain: Array[Dictionary] = _spoke_content(cat)
	var side: Array[Dictionary] = _spoke_side_branch(cat)
	var prev: StringName = hub_id
	var branch_anchor: StringName = hub_id
	for i in range(chain.size()):
		var step: Dictionary = chain[i]
		var nid := StringName("%s_n%d" % [prefix, i])
		var ring: int = int(step.get("ring", _default_ring_for_index(i, int(step.get("kind", NodeKind.SMALL)))))
		var dist: float = 140.0 + float(i) * 55.0
		var lateral := Vector2(-dir.y, dir.x) * (10.0 if i % 2 == 0 else -10.0)
		nodes[nid] = {
			"id": nid,
			"nome": str(step.get("nome", "Nó")),
			"kind": int(step.get("kind", NodeKind.SMALL)),
			"categoria": cat,
			"cost": int(step.get("cost", 1)),
			"prereqs": [prev],
			"effects": step.get("effects", {}),
			"pos": dir * dist + lateral,
			"desc": str(step.get("desc", "")),
			"cor": sp["cor"],
			"icon": int(step.get("icon", i % 12)),
			"ring": ring
		}
		if i == 1:
			branch_anchor = nid
		prev = nid

	for j in range(side.size()):
		var sstep: Dictionary = side[j]
		var sid := StringName("%s_s%d" % [prefix, j])
		var sring: int = int(sstep.get("ring", 1 + j))
		var sdist: float = 175.0 + float(j) * 48.0
		var slat := Vector2(-dir.y, dir.x) * (42.0 + float(j) * 8.0)
		nodes[sid] = {
			"id": sid,
			"nome": str(sstep.get("nome", "Ramo")),
			"kind": int(sstep.get("kind", NodeKind.SMALL)),
			"categoria": cat,
			"cost": int(sstep.get("cost", 1)),
			"prereqs": [branch_anchor if j == 0 else StringName("%s_s%d" % [prefix, j - 1])],
			"effects": sstep.get("effects", {}),
			"pos": dir * sdist + slat,
			"desc": str(sstep.get("desc", "")),
			"cor": sp["cor"],
			"icon": int(sstep.get("icon", (j + 3) % 12)),
			"ring": sring
		}


static func _default_ring_for_index(i: int, kind: int) -> int:
	if kind == NodeKind.KEYSTONE:
		return 3
	if i <= 1:
		return 1
	if i <= 3:
		return 2
	return 3


static func _spoke_content(cat: int) -> Array[Dictionary]:
	## Custos altos no fim; poder cedo é modesto — identidade vem do keystone gated.
	match cat:
		HatsuData.Categoria.INTENSIFICACAO:
			return [
				{"nome": "Ko no Punho", "kind": NodeKind.SMALL, "cost": 1, "ring": 1, "icon": 0, "effects": {"poder": 8}, "desc": "+8 impacto. Base humilde."},
				{"nome": "Postura Firme", "kind": NodeKind.SMALL, "cost": 1, "ring": 1, "icon": 1, "effects": {"require_stationary": true, "poder": 6}, "desc": "Exige parado; +6 poder."},
				{"nome": "Carga Pesada", "kind": NodeKind.MAJOR, "cost": 3, "ring": 2, "effects": {"charged": true, "poder": 18}, "desc": "CHARGED; +18. Anel médio."},
				{"nome": "Quebra-Osso", "kind": NodeKind.SMALL, "cost": 2, "ring": 2, "icon": 2, "effects": {"poder": 12, "knockback": 30}, "desc": "+12 e empurrão."},
				{"nome": "Impacto Decisivo", "kind": NodeKind.KEYSTONE, "cost": 5, "ring": 3, "effects": {"poder": 40, "cooldown": 5.0, "aura_cost": 10}, "desc": "Identidade Intensificação. Caro e exigente."},
			]
		HatsuData.Categoria.EMISSAO:
			return [
				{"nome": "Projeção Básica", "kind": NodeKind.SMALL, "cost": 1, "ring": 1, "icon": 3, "effects": {"forma_projetil": true, "alcance": 30}, "desc": "Projétil; +30 alcance."},
				{"nome": "Velocidade de Aura", "kind": NodeKind.SMALL, "cost": 1, "ring": 1, "icon": 4, "effects": {"proj_speed": 30}, "desc": "Projétil mais rápido."},
				{"nome": "Alcance Estendido", "kind": NodeKind.MAJOR, "cost": 3, "ring": 2, "effects": {"alcance": 55, "poder": 5}, "desc": "+55 alcance."},
				{"nome": "Rajada Dupla", "kind": NodeKind.SMALL, "cost": 3, "ring": 2, "icon": 5, "effects": {"multishot": 2, "poder": -8}, "desc": "2 projéteis; −8 cada."},
				{"nome": "Emissão Distante", "kind": NodeKind.KEYSTONE, "cost": 5, "ring": 3, "effects": {"alcance": 100, "poder": 16, "aura_cost": 12}, "desc": "Identidade Emissão."},
			]
		HatsuData.Categoria.TRANSFORMACAO:
			return [
				{"nome": "Propriedade Nova", "kind": NodeKind.SMALL, "cost": 1, "ring": 1, "icon": 6, "effects": {"poder": 7}, "desc": "+7 transmutado."},
				{"nome": "Elasticidade", "kind": NodeKind.MAJOR, "cost": 3, "ring": 2, "effects": {"control_pull": true, "poder": 4}, "desc": "Puxão elástico."},
				{"nome": "Lâmina de Aura", "kind": NodeKind.SMALL, "cost": 2, "ring": 2, "icon": 7, "effects": {"piercing": 12, "poder": 8}, "desc": "Corte; piercing."},
				{"nome": "Modo Sustentado", "kind": NodeKind.MAJOR, "cost": 3, "ring": 2, "effects": {"transformation_mode": true, "duracao": 5.0, "aura_drain": 2.5}, "desc": "Modo com dreno."},
				{"nome": "Transmutação Suprema", "kind": NodeKind.KEYSTONE, "cost": 5, "ring": 3, "effects": {"poder": 26, "exclusive_transform": true, "aura_cost": 8}, "desc": "Identidade Transformação."},
			]
		HatsuData.Categoria.CONJURACAO:
			return [
				{"nome": "Materializar Forma", "kind": NodeKind.SMALL, "cost": 1, "ring": 1, "icon": 8, "effects": {"conjure": true, "poder": 6}, "desc": "Objeto conjurado."},
				{"nome": "Corrente / Prisão", "kind": NodeKind.MAJOR, "cost": 3, "ring": 2, "effects": {"control_bind": true, "poder": 4}, "desc": "Prisão leve."},
				{"nome": "Cura Conjurada", "kind": NodeKind.SMALL, "cost": 2, "ring": 2, "icon": 9, "effects": {"cura": 28, "rooted_heal": true}, "desc": "+28 cura; imóvel."},
				{"nome": "Invocação de Área", "kind": NodeKind.MAJOR, "cost": 3, "ring": 2, "effects": {"forma_area": true, "raio": 40, "poder": 10}, "desc": "Área."},
				{"nome": "Constructo Durável", "kind": NodeKind.KEYSTONE, "cost": 5, "ring": 3, "effects": {"duracao": 10.0, "poder": 20, "aura_cost": 12}, "desc": "Identidade Conjuração."},
			]
		HatsuData.Categoria.MANIPULACAO:
			return [
				{"nome": "Comando Simples", "kind": NodeKind.SMALL, "cost": 1, "ring": 1, "icon": 10, "effects": {"control": true, "poder": 4}, "desc": "Controle básico."},
				{"nome": "Paralisia Curta", "kind": NodeKind.SMALL, "cost": 2, "ring": 1, "icon": 11, "effects": {"stun": 0.6}, "desc": "Stun 0.6s."},
				{"nome": "Marionete", "kind": NodeKind.MAJOR, "cost": 3, "ring": 2, "effects": {"puppet_buff": true, "poder": 8, "duracao": 6.0}, "desc": "Buff corporal."},
				{"nome": "Ordem em Área", "kind": NodeKind.MAJOR, "cost": 3, "ring": 2, "effects": {"forma_area": true, "raio": 32, "control": true}, "desc": "Controle em área."},
				{"nome": "Domínio da Vontade", "kind": NodeKind.KEYSTONE, "cost": 5, "ring": 3, "effects": {"stun": 1.4, "poder": 16, "cooldown": 4.0}, "desc": "Identidade Manipulação."},
			]
		HatsuData.Categoria.ESPECIALIZACAO:
			return [
				{"nome": "Regra Única", "kind": NodeKind.SMALL, "cost": 1, "ring": 1, "icon": 0, "effects": {"poder": 7}, "desc": "+7 sob regra."},
				{"nome": "Biblioteca / Página", "kind": NodeKind.MAJOR, "cost": 3, "ring": 2, "effects": {"library": true, "storage": 2}, "desc": "Até 2 técnicas."},
				{"nome": "Absorção Fraca", "kind": NodeKind.MAJOR, "cost": 3, "ring": 2, "effects": {"absorb": true, "absorb_rate": 0.025}, "desc": "Absorve fração."},
				{"nome": "Eficiência Total", "kind": NodeKind.SMALL, "cost": 3, "ring": 2, "icon": 1, "effects": {"emperor_like": true, "duracao": 12.0, "auto_dano": true}, "desc": "Eficiência com custo vital."},
				{"nome": "Exceção da Natureza", "kind": NodeKind.KEYSTONE, "cost": 6, "ring": 3, "effects": {"poder": 28, "versatile": true, "aura_cost": 14}, "desc": "Identidade Especialização. O mais caro."},
			]
		_:
			return [{"nome": "Refino", "kind": NodeKind.SMALL, "cost": 1, "ring": 1, "effects": {"poder": 5}, "desc": "+5 genérico."}]


static func _spoke_side_branch(cat: int) -> Array[Dictionary]:
	match cat:
		HatsuData.Categoria.INTENSIFICACAO:
			return [
				{"nome": "Ten Endurecido", "kind": NodeKind.SMALL, "cost": 1, "ring": 1, "icon": 2, "effects": {"poder": 4}, "desc": "Refino defensivo."},
				{"nome": "Ko Concentrado", "kind": NodeKind.MAJOR, "cost": 3, "ring": 2, "effects": {"poder": 14, "require_stationary": true}, "desc": "Poder parado (anel 2)."},
			]
		HatsuData.Categoria.EMISSAO:
			return [
				{"nome": "Eco de Aura", "kind": NodeKind.SMALL, "cost": 1, "ring": 1, "icon": 4, "effects": {"alcance": 18}, "desc": "+18 alcance."},
				{"nome": "Trilha Persistente", "kind": NodeKind.MAJOR, "cost": 3, "ring": 2, "effects": {"duracao": 2.5, "poder": 5}, "desc": "Trilha (anel 2)."},
			]
		HatsuData.Categoria.TRANSFORMACAO:
			return [
				{"nome": "Atrito", "kind": NodeKind.SMALL, "cost": 1, "ring": 1, "icon": 6, "effects": {"poder": 5}, "desc": "+5 atrito."},
				{"nome": "Condutividade", "kind": NodeKind.MAJOR, "cost": 3, "ring": 2, "effects": {"stun": 0.4, "poder": 7}, "desc": "Choque leve."},
			]
		HatsuData.Categoria.CONJURACAO:
			return [
				{"nome": "Âncora", "kind": NodeKind.SMALL, "cost": 1, "ring": 1, "icon": 8, "effects": {"duracao": 1.5}, "desc": "Mais estável."},
				{"nome": "Selo Menor", "kind": NodeKind.MAJOR, "cost": 3, "ring": 2, "effects": {"control_bind": true, "duracao": 3.0}, "desc": "Selo curto."},
			]
		HatsuData.Categoria.MANIPULACAO:
			return [
				{"nome": "Sugestão", "kind": NodeKind.SMALL, "cost": 1, "ring": 1, "icon": 10, "effects": {"control": true}, "desc": "Controle fraco."},
				{"nome": "Elo Mental", "kind": NodeKind.MAJOR, "cost": 3, "ring": 2, "effects": {"stun": 0.8, "cooldown": 2.0}, "desc": "Stun curto."},
			]
		HatsuData.Categoria.ESPECIALIZACAO:
			return [
				{"nome": "Cláusula Extra", "kind": NodeKind.SMALL, "cost": 1, "ring": 1, "icon": 0, "effects": {"poder": 4}, "desc": "+4 cláusula."},
				{"nome": "Exceção Local", "kind": NodeKind.KEYSTONE, "cost": 4, "ring": 3, "effects": {"versatile": true, "poder": 10, "aura_cost": 8}, "desc": "Mini-ápice especial (anel 3)."},
			]
		_:
			return []


static func node_radius(kind: int) -> float:
	match kind:
		NodeKind.HUB: return 10.0
		NodeKind.SMALL: return 6.0
		NodeKind.MAJOR: return 8.0
		NodeKind.KEYSTONE: return 11.0
		_: return 6.0


static func ring_label(ring: int) -> String:
	match ring:
		0: return "Núcleo"
		1: return "Anel 1 · Despertar"
		2: return "Anel 2 · Ofício"
		3: return "Anel 3 · Lenda"
		_: return "Anel ?"
