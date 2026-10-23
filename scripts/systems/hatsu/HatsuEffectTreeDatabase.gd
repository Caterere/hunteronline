class_name HatsuEffectTreeDatabase
extends RefCounted

# ============================================================
# Árvore de efeitos do Hatsu Creator (compacta, 6 raios Nen)
# ============================================================
# NÃO é a Nen Skill Tree do personagem (400+ nós).
# Aqui cada Hatsu tem ~50–70 nós: centro + 6 categorias × ~8–10.
# ============================================================

enum NodeKind {
	HUB,       ## centro / marco de categoria
	SMALL,     ## +stat leve
	MAJOR,     ## efeito estrutural
	KEYSTONE   ## identidade da categoria (caro)
}


static func build_tree() -> Dictionary:
	## id -> { id, name, kind, category, cost, prereqs, effects, pos, desc }
	var nodes: Dictionary = {}
	# Centro
	nodes[&"hx_center"] = {
		"id": &"hx_center",
		"nome": "Núcleo do Hatsu",
		"kind": NodeKind.HUB,
		"categoria": -1,
		"cost": 0,
		"prereqs": [],
		"effects": {"core": true},
		"pos": Vector2.ZERO,
		"desc": "Origem da técnica. Escolha um raio de categoria para definir o que ela FAZ."
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
		"desc": "Compromete o Hatsu com esta categoria. Raios opostos ficam mais caros.",
		"cor": sp["cor"]
	}

	# Cadeia principal + 1 ramo lateral (constelação legível, não PoE de 400 nós)
	var chain: Array[Dictionary] = _spoke_content(cat, str(sp["nome"]))
	var side: Array[Dictionary] = _spoke_side_branch(cat)
	var prev: StringName = hub_id
	var branch_anchor: StringName = hub_id
	for i in range(chain.size()):
		var step: Dictionary = chain[i]
		var nid := StringName("%s_n%d" % [prefix, i])
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
			"icon": int(step.get("icon", i % 12))
		}
		if i == 1:
			branch_anchor = nid
		prev = nid

	for j in range(side.size()):
		var sstep: Dictionary = side[j]
		var sid := StringName("%s_s%d" % [prefix, j])
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
			"icon": int(sstep.get("icon", (j + 3) % 12))
		}


static func _spoke_content(cat: int, cat_nome: String) -> Array[Dictionary]:
	match cat:
		HatsuData.Categoria.INTENSIFICACAO:
			return [
				{"nome": "Ko no Punho", "kind": NodeKind.SMALL, "cost": 1, "icon": 0, "effects": {"poder": 12}, "desc": "+12 poder de impacto."},
				{"nome": "Postura Firme", "kind": NodeKind.SMALL, "cost": 1, "icon": 1, "effects": {"require_stationary": true, "poder": 8}, "desc": "Exige parado; +8 poder."},
				{"nome": "Carga Pesada", "kind": NodeKind.MAJOR, "cost": 2, "effects": {"charged": true, "poder": 25}, "desc": "Ativação CHARGED; +25 poder."},
				{"nome": "Quebra-Osso", "kind": NodeKind.SMALL, "cost": 1, "icon": 2, "effects": {"poder": 18, "knockback": 40}, "desc": "+18 poder e empurrão."},
				{"nome": "Impacto Decisivo", "kind": NodeKind.KEYSTONE, "cost": 3, "effects": {"poder": 45, "cooldown": 4.0}, "desc": "+45 poder; +4s CD. Identidade Intensificação."},
			]
		HatsuData.Categoria.EMISSAO:
			return [
				{"nome": "Projeção Básica", "kind": NodeKind.SMALL, "cost": 1, "icon": 3, "effects": {"forma_projetil": true, "alcance": 40}, "desc": "Forma projétil; +40 alcance."},
				{"nome": "Velocidade de Aura", "kind": NodeKind.SMALL, "cost": 1, "icon": 4, "effects": {"proj_speed": 40}, "desc": "Projétil mais rápido."},
				{"nome": "Alcance Estendido", "kind": NodeKind.MAJOR, "cost": 2, "effects": {"alcance": 80, "poder": 8}, "desc": "+80 alcance, +8 poder."},
				{"nome": "Rajada Dupla", "kind": NodeKind.SMALL, "cost": 2, "icon": 5, "effects": {"multishot": 2, "poder": -5}, "desc": "2 projéteis; −5 poder cada."},
				{"nome": "Emissão Distante", "kind": NodeKind.KEYSTONE, "cost": 3, "effects": {"alcance": 120, "poder": 20, "aura_cost": 8}, "desc": "+120 alcance, +20 poder, +8 aura. Identidade Emissão."},
			]
		HatsuData.Categoria.TRANSFORMACAO:
			return [
				{"nome": "Propriedade Nova", "kind": NodeKind.SMALL, "cost": 1, "icon": 6, "effects": {"poder": 10}, "desc": "+10 poder transmutado."},
				{"nome": "Elasticidade", "kind": NodeKind.MAJOR, "cost": 2, "effects": {"control_pull": true, "poder": 5}, "desc": "Puxão/controle elástico."},
				{"nome": "Lâmina de Aura", "kind": NodeKind.SMALL, "cost": 1, "icon": 7, "effects": {"piercing": 15, "poder": 12}, "desc": "Corte; +piercing."},
				{"nome": "Modo Sustentado", "kind": NodeKind.MAJOR, "cost": 2, "effects": {"transformation_mode": true, "duracao": 6.0, "aura_drain": 2.0}, "desc": "Modo timed com dreno."},
				{"nome": "Transmutação Suprema", "kind": NodeKind.KEYSTONE, "cost": 3, "effects": {"poder": 30, "exclusive_transform": true}, "desc": "+30; trava outros modos. Identidade Transformação."},
			]
		HatsuData.Categoria.CONJURACAO:
			return [
				{"nome": "Materializar Forma", "kind": NodeKind.SMALL, "cost": 1, "icon": 8, "effects": {"conjure": true, "poder": 8}, "desc": "Objeto/aura conjurada."},
				{"nome": "Corrente / Prisão", "kind": NodeKind.MAJOR, "cost": 2, "effects": {"control_bind": true, "poder": 5}, "desc": "Controle/prisão leve."},
				{"nome": "Cura Conjurada", "kind": NodeKind.SMALL, "cost": 2, "icon": 9, "effects": {"cura": 35, "rooted_heal": true}, "desc": "+35 cura; sugere imóvel."},
				{"nome": "Invocação de Área", "kind": NodeKind.MAJOR, "cost": 2, "effects": {"forma_area": true, "raio": 50, "poder": 15}, "desc": "Explosão/área."},
				{"nome": "Constructo Durável", "kind": NodeKind.KEYSTONE, "cost": 3, "effects": {"duracao": 10.0, "poder": 25, "aura_cost": 10}, "desc": "Constructo longo. Identidade Conjuração."},
			]
		HatsuData.Categoria.MANIPULACAO:
			return [
				{"nome": "Comando Simples", "kind": NodeKind.SMALL, "cost": 1, "icon": 10, "effects": {"control": true, "poder": 6}, "desc": "Controle básico."},
				{"nome": "Paralisia Curta", "kind": NodeKind.SMALL, "cost": 1, "icon": 11, "effects": {"stun": 0.8}, "desc": "Stun 0.8s."},
				{"nome": "Marionete", "kind": NodeKind.MAJOR, "cost": 2, "effects": {"puppet_buff": true, "poder": 10, "duracao": 8.0}, "desc": "Buff corporal temporário."},
				{"nome": "Ordem em Área", "kind": NodeKind.MAJOR, "cost": 2, "effects": {"forma_area": true, "raio": 40, "control": true}, "desc": "Controle em área."},
				{"nome": "Domínio da Vontade", "kind": NodeKind.KEYSTONE, "cost": 3, "effects": {"stun": 1.5, "poder": 20, "cooldown": 3.0}, "desc": "Controle forte. Identidade Manipulação."},
			]
		HatsuData.Categoria.ESPECIALIZACAO:
			return [
				{"nome": "Regra Única", "kind": NodeKind.SMALL, "cost": 1, "icon": 0, "effects": {"poder": 10}, "desc": "+10 sob regra especial."},
				{"nome": "Biblioteca / Página", "kind": NodeKind.MAJOR, "cost": 2, "effects": {"library": true, "storage": 3}, "desc": "Armazena até 3 técnicas."},
				{"nome": "Absorção Fraca", "kind": NodeKind.MAJOR, "cost": 2, "effects": {"absorb": true, "absorb_rate": 0.03}, "desc": "Absorve fração após abate."},
				{"nome": "Eficiência Total", "kind": NodeKind.SMALL, "cost": 2, "icon": 1, "effects": {"emperor_like": true, "duracao": 20.0, "auto_dano": true}, "desc": "100% eficiência temporária (custo vital)."},
				{"nome": "Exceção da Natureza", "kind": NodeKind.KEYSTONE, "cost": 4, "effects": {"poder": 35, "versatile": true, "aura_cost": 12}, "desc": "Poder versátil caro. Identidade Especialização."},
			]
		_:
			return [
				{"nome": "Refino", "kind": NodeKind.SMALL, "cost": 1, "effects": {"poder": 8}, "desc": "+8 poder genérico."},
			]


static func _spoke_side_branch(cat: int) -> Array[Dictionary]:
	## Ramo lateral curto: 2 nós (major opcional + small) por categoria.
	match cat:
		HatsuData.Categoria.INTENSIFICACAO:
			return [
				{"nome": "Ten Endurecido", "kind": NodeKind.SMALL, "cost": 1, "icon": 2, "effects": {"poder": 6}, "desc": "Defesa/impacto leve."},
				{"nome": "Ko Concentrado", "kind": NodeKind.MAJOR, "cost": 2, "effects": {"poder": 20, "require_stationary": true}, "desc": "Mais poder parado."},
			]
		HatsuData.Categoria.EMISSAO:
			return [
				{"nome": "Eco de Aura", "kind": NodeKind.SMALL, "cost": 1, "icon": 4, "effects": {"alcance": 25}, "desc": "+25 alcance."},
				{"nome": "Trilha Persistente", "kind": NodeKind.MAJOR, "cost": 2, "effects": {"duracao": 3.0, "poder": 8}, "desc": "Projétil deixa trilha."},
			]
		HatsuData.Categoria.TRANSFORMACAO:
			return [
				{"nome": "Atrito", "kind": NodeKind.SMALL, "cost": 1, "icon": 6, "effects": {"poder": 8}, "desc": "+8 calor/atrito."},
				{"nome": "Condutividade", "kind": NodeKind.MAJOR, "cost": 2, "effects": {"stun": 0.5, "poder": 10}, "desc": "Propriedade elétrica leve."},
			]
		HatsuData.Categoria.CONJURACAO:
			return [
				{"nome": "Âncora", "kind": NodeKind.SMALL, "cost": 1, "icon": 8, "effects": {"duracao": 2.0}, "desc": "Constructo mais estável."},
				{"nome": "Selo Menor", "kind": NodeKind.MAJOR, "cost": 2, "effects": {"control_bind": true, "duracao": 4.0}, "desc": "Selo curto."},
			]
		HatsuData.Categoria.MANIPULACAO:
			return [
				{"nome": "Sugestão", "kind": NodeKind.SMALL, "cost": 1, "icon": 10, "effects": {"control": true}, "desc": "Controle fraco."},
				{"nome": "Elo Mental", "kind": NodeKind.MAJOR, "cost": 2, "effects": {"stun": 1.0, "cooldown": 1.5}, "desc": "Stun curto."},
			]
		HatsuData.Categoria.ESPECIALIZACAO:
			return [
				{"nome": "Cláusula Extra", "kind": NodeKind.SMALL, "cost": 1, "icon": 0, "effects": {"poder": 6}, "desc": "+6 sob cláusula."},
				{"nome": "Exceção Local", "kind": NodeKind.KEYSTONE, "cost": 3, "effects": {"versatile": true, "poder": 15, "aura_cost": 6}, "desc": "Mini-identidade especial."},
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
