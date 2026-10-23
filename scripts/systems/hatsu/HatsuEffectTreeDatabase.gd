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

	# Cadeia de nós (distância crescente)
	var chain: Array[Dictionary] = _spoke_content(cat, str(sp["nome"]))
	var prev: StringName = hub_id
	for i in range(chain.size()):
		var step: Dictionary = chain[i]
		var nid := StringName("%s_n%d" % [prefix, i])
		var dist: float = 140.0 + float(i) * 55.0
		# leve offset lateral em nós pares
		var lateral := Vector2(-dir.y, dir.x) * (8.0 if i % 2 == 0 else -8.0)
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
			"cor": sp["cor"]
		}
		prev = nid


static func _spoke_content(cat: int, cat_nome: String) -> Array[Dictionary]:
	match cat:
		HatsuData.Categoria.INTENSIFICACAO:
			return [
				{"nome": "Ko no Punho", "kind": NodeKind.SMALL, "cost": 1, "effects": {"poder": 12}, "desc": "+12 poder de impacto."},
				{"nome": "Postura Firme", "kind": NodeKind.SMALL, "cost": 1, "effects": {"require_stationary": true, "poder": 8}, "desc": "Exige parado; +8 poder."},
				{"nome": "Carga Pesada", "kind": NodeKind.MAJOR, "cost": 2, "effects": {"charged": true, "poder": 25}, "desc": "Ativação CHARGED; +25 poder."},
				{"nome": "Quebra-Osso", "kind": NodeKind.SMALL, "cost": 1, "effects": {"poder": 18, "knockback": 40}, "desc": "+18 poder e empurrão."},
				{"nome": "Impacto Decisivo", "kind": NodeKind.KEYSTONE, "cost": 3, "effects": {"poder": 45, "cooldown": 4.0}, "desc": "+45 poder; +4s CD. Identidade Intensificação."},
			]
		HatsuData.Categoria.EMISSAO:
			return [
				{"nome": "Projeção Básica", "kind": NodeKind.SMALL, "cost": 1, "effects": {"forma_projetil": true, "alcance": 40}, "desc": "Forma projétil; +40 alcance."},
				{"nome": "Velocidade de Aura", "kind": NodeKind.SMALL, "cost": 1, "effects": {"proj_speed": 40}, "desc": "Projétil mais rápido."},
				{"nome": "Alcance Estendido", "kind": NodeKind.MAJOR, "cost": 2, "effects": {"alcance": 80, "poder": 8}, "desc": "+80 alcance, +8 poder."},
				{"nome": "Rajada Dupla", "kind": NodeKind.SMALL, "cost": 2, "effects": {"multishot": 2, "poder": -5}, "desc": "2 projéteis; −5 poder cada."},
				{"nome": "Emissão Distante", "kind": NodeKind.KEYSTONE, "cost": 3, "effects": {"alcance": 120, "poder": 20, "aura_cost": 8}, "desc": "+120 alcance, +20 poder, +8 aura. Identidade Emissão."},
			]
		HatsuData.Categoria.TRANSFORMACAO:
			return [
				{"nome": "Propriedade Nova", "kind": NodeKind.SMALL, "cost": 1, "effects": {"poder": 10}, "desc": "+10 poder transmutado."},
				{"nome": "Elasticidade", "kind": NodeKind.MAJOR, "cost": 2, "effects": {"control_pull": true, "poder": 5}, "desc": "Puxão/controle elástico."},
				{"nome": "Lâmina de Aura", "kind": NodeKind.SMALL, "cost": 1, "effects": {"piercing": 15, "poder": 12}, "desc": "Corte; +piercing."},
				{"nome": "Modo Sustentado", "kind": NodeKind.MAJOR, "cost": 2, "effects": {"transformation_mode": true, "duracao": 6.0, "aura_drain": 2.0}, "desc": "Modo timed com dreno."},
				{"nome": "Transmutação Suprema", "kind": NodeKind.KEYSTONE, "cost": 3, "effects": {"poder": 30, "exclusive_transform": true}, "desc": "+30; trava outros modos. Identidade Transformação."},
			]
		HatsuData.Categoria.CONJURACAO:
			return [
				{"nome": "Materializar Forma", "kind": NodeKind.SMALL, "cost": 1, "effects": {"conjure": true, "poder": 8}, "desc": "Objeto/aura conjurada."},
				{"nome": "Corrente / Prisão", "kind": NodeKind.MAJOR, "cost": 2, "effects": {"control_bind": true, "poder": 5}, "desc": "Controle/prisão leve."},
				{"nome": "Cura Conjurada", "kind": NodeKind.SMALL, "cost": 2, "effects": {"cura": 35, "rooted_heal": true}, "desc": "+35 cura; sugere imóvel."},
				{"nome": "Invocação de Área", "kind": NodeKind.MAJOR, "cost": 2, "effects": {"forma_area": true, "raio": 50, "poder": 15}, "desc": "Explosão/área."},
				{"nome": "Constructo Durável", "kind": NodeKind.KEYSTONE, "cost": 3, "effects": {"duracao": 10.0, "poder": 25, "aura_cost": 10}, "desc": "Constructo longo. Identidade Conjuração."},
			]
		HatsuData.Categoria.MANIPULACAO:
			return [
				{"nome": "Comando Simples", "kind": NodeKind.SMALL, "cost": 1, "effects": {"control": true, "poder": 6}, "desc": "Controle básico."},
				{"nome": "Paralisia Curta", "kind": NodeKind.SMALL, "cost": 1, "effects": {"stun": 0.8}, "desc": "Stun 0.8s."},
				{"nome": "Marionete", "kind": NodeKind.MAJOR, "cost": 2, "effects": {"puppet_buff": true, "poder": 10, "duracao": 8.0}, "desc": "Buff corporal temporário."},
				{"nome": "Ordem em Área", "kind": NodeKind.MAJOR, "cost": 2, "effects": {"forma_area": true, "raio": 40, "control": true}, "desc": "Controle em área."},
				{"nome": "Domínio da Vontade", "kind": NodeKind.KEYSTONE, "cost": 3, "effects": {"stun": 1.5, "poder": 20, "cooldown": 3.0}, "desc": "Controle forte. Identidade Manipulação."},
			]
		HatsuData.Categoria.ESPECIALIZACAO:
			return [
				{"nome": "Regra Única", "kind": NodeKind.SMALL, "cost": 1, "effects": {"poder": 10}, "desc": "+10 sob regra especial."},
				{"nome": "Biblioteca / Página", "kind": NodeKind.MAJOR, "cost": 2, "effects": {"library": true, "storage": 3}, "desc": "Armazena até 3 técnicas."},
				{"nome": "Absorção Fraca", "kind": NodeKind.MAJOR, "cost": 2, "effects": {"absorb": true, "absorb_rate": 0.03}, "desc": "Absorve fração após abate."},
				{"nome": "Eficiência Total", "kind": NodeKind.SMALL, "cost": 2, "effects": {"emperor_like": true, "duracao": 20.0, "auto_dano": true}, "desc": "100% eficiência temporária (custo vital)."},
				{"nome": "Exceção da Natureza", "kind": NodeKind.KEYSTONE, "cost": 4, "effects": {"poder": 35, "versatile": true, "aura_cost": 12}, "desc": "Poder versátil caro. Identidade Especialização."},
			]
		_:
			return [
				{"nome": "Refino", "kind": NodeKind.SMALL, "cost": 1, "effects": {"poder": 8}, "desc": "+8 poder genérico."},
			]


static func node_radius(kind: int) -> float:
	match kind:
		NodeKind.HUB: return 10.0
		NodeKind.SMALL: return 6.0
		NodeKind.MAJOR: return 8.0
		NodeKind.KEYSTONE: return 11.0
		_: return 6.0
