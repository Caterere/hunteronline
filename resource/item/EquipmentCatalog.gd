class_name EquipmentCatalog
extends RefCounted

# ============================================================
# HUNTER ONLINE — CATÁLOGO MÍNIMO DE EQUIPAMENTO JOGÁVEL
# ============================================================
# Slots canônicos (EQUIPMENT_BIBLE): cabeca, corpo, mao_princ,
# mao_sec, acessorio, licenca.
# Bônus entram via StatModifier (fonte "equip_<item_id>").
# ============================================================

const SLOTS: Array[StringName] = [
	&"cabeca", &"corpo", &"mao_princ", &"mao_sec", &"acessorio", &"licenca"
]

## item_id -> definição
const ITEMS: Dictionary = {
	"faixa_concentracao": {
		"nome": "Faixa de Concentração",
		"slot": &"cabeca",
		"raridade": "Comum",
		"descricao": "Faixa leve que estabiliza o fluxo de aura na fronte.",
		"bonus": {"aura_max": 15.0},
		"preco": 180,
	},
	"colete_cacador": {
		"nome": "Colete de Caçador",
		"slot": &"corpo",
		"raridade": "Comum",
		"descricao": "Colete reforçado usado por aspirantes em Zaban.",
		"bonus": {"defesa": 5.0, "vida_max": 20.0},
		"preco": 320,
	},
	"quimono_treino": {
		"nome": "Quimono de Treino",
		"slot": &"corpo",
		"raridade": "Incomum",
		"descricao": "Tecido leve do dojo Shingen-ryu. Favorece mobilidade.",
		"bonus": {"defesa": 2.0, "velocidade": 2.0},
		"preco": 450,
	},
	"adaga_zaban": {
		"nome": "Adaga de Zaban",
		"slot": &"mao_princ",
		"raridade": "Comum",
		"descricao": "Lâmina curta. Aceita Shu com facilidade.",
		"bonus": {"forca": 4.0, "dano_arma": 0.10},
		"preco": 280,
	},
	"varinha_canalizadora": {
		"nome": "Varinha Canalizadora",
		"slot": &"mao_princ",
		"raridade": "Incomum",
		"descricao": "Catalisador de aura usado em exercícios de Gyo.",
		"bonus": {"forca": 2.0, "aura_max": 25.0, "dano_arma": 0.15},
		"preco": 520,
	},
	"espada_aco": {
		"nome": "Espada de Aço",
		"slot": &"mao_princ",
		"raridade": "Incomum",
		"descricao": "Forjada na Capital. Bom veículo para Shu.",
		"bonus": {"forca": 8.0, "dano_arma": 0.20},
		"preco": 500,
		"craft": true,
	},
	"escudo_leve": {
		"nome": "Escudo Leve",
		"slot": &"mao_sec",
		"raridade": "Comum",
		"descricao": "Broquel compacto para aparar golpes rápidos.",
		"bonus": {"defesa": 4.0},
		"preco": 240,
	},
	"armadura_ferro": {
		"nome": "Armadura de Ferro",
		"slot": &"corpo",
		"raridade": "Raro",
		"descricao": "Placas de ferro temperado. Pesada, mas confiável.",
		"bonus": {"defesa": 10.0, "vida_max": 40.0},
		"preco": 800,
		"craft": true,
	},
	"amuleto_forca": {
		"nome": "Amuleto de Força",
		"slot": &"acessorio",
		"raridade": "Comum",
		"descricao": "Pingente de pedra bruto. Empurra a força física.",
		"bonus": {"forca": 3.0},
		"preco": 150,
	},
	"anel_aura": {
		"nome": "Anel de Aura",
		"slot": &"acessorio",
		"raridade": "Incomum",
		"descricao": "Anel de prata que retém um fio fino de Nen.",
		"bonus": {"aura_max": 30.0},
		"preco": 400,
	},
	"pingente_nen": {
		"nome": "Pingente de Nen",
		"slot": &"acessorio",
		"raridade": "Raro",
		"descricao": "Relíquia do dojo. Amplifica aura e impacto.",
		"bonus": {"aura_max": 40.0, "forca": 2.0},
		"preco": 700,
	},
	"licenca_hunter": {
		"nome": "Licença Hunter",
		"slot": &"licenca",
		"raridade": "Lendário",
		"descricao": "Documento oficial. Livre trânsito e descontos mundiais.",
		"bonus": {"defesa": 1.0, "aura_max": 10.0},
		"preco": 0,
	},
}


static func obter(item_id: String) -> Dictionary:
	if ITEMS.has(item_id):
		return ITEMS[item_id]
	return {}


static func eh_equipamento(item_id: String) -> bool:
	return ITEMS.has(item_id)


static func obter_slot(item_id: String) -> StringName:
	var d: Dictionary = obter(item_id)
	return d.get("slot", &"") as StringName


static func obter_nome(item_id: String) -> String:
	var d: Dictionary = obter(item_id)
	return str(d.get("nome", item_id))


static func obter_descricao_completa(item_id: String) -> String:
	var d: Dictionary = obter(item_id)
	if d.is_empty():
		return "Item desconhecido."
	var linhas: PackedStringArray = []
	linhas.append(str(d.get("nome", item_id)))
	linhas.append("[%s] Slot: %s" % [str(d.get("raridade", "?")), str(d.get("slot", "?"))])
	linhas.append(str(d.get("descricao", "")))
	var bonus: Dictionary = d.get("bonus", {})
	if not bonus.is_empty():
		var partes: PackedStringArray = []
		for k in bonus.keys():
			var v: float = float(bonus[k])
			if k == "dano_arma":
				partes.append("Shu +%d%%" % int(v * 100.0))
			else:
				partes.append("%s +%s" % [str(k).capitalize(), str(int(v)) if v == floor(v) else str(v)])
		linhas.append("Bônus: " + ", ".join(partes))
	return "\n".join(linhas)


static func listar_crafts() -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for id in ITEMS.keys():
		var d: Dictionary = ITEMS[id]
		if bool(d.get("craft", false)):
			out.append({
				"id": str(id),
				"nome": str(d.get("nome", id)),
				"custo": int(d.get("preco", 100)),
				"descricao": str(d.get("descricao", "")),
			})
	return out


static func ids() -> Array:
	return ITEMS.keys()
