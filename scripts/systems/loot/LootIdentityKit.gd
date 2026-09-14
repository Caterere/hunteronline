class_name LootIdentityKit
extends RefCounted
## Tabelas densas por inimigo, raridade com peso real e uniques/sets leves.

const CHANCE_MULT_ELITE := 1.55
const CHANCE_MULT_BOSS := 1.9
const JENNY_MULT_ELITE := 2.35
const JENNY_MULT_BOSS := 3.4

const PESO_RARIDADE := {
	"comum": 1.0,
	"incomum": 1.35,
	"raro": 1.85,
	"epico": 2.55,
	"épico": 2.55,
	"lendario": 3.4,
	"lendário": 3.4,
}

const SET_CACADOR := "set_cacador_exame"
const SET_FORMIGA := "set_formiga_soldado"
const SET_PALACIO := "set_palacio_real"


static func tabela_padrao_para(enemy_id: String) -> Array:
	match String(enemy_id):
		"candidato_exame":
			return [
				{"item_id": "pocao_vida", "chance": 0.42, "quantidade": 1},
				{"item_id": "elixir_aura", "chance": 0.22, "quantidade": 1},
				{"item_id": "lamina_cacador", "chance": 0.08, "quantidade": 1},
				{"item_id": "amuleto_forca", "chance": 0.06, "quantidade": 1},
				{"item_id": "unique_laminas_exame", "chance": 0.018, "quantidade": 1},
				{"item_id": "set_cacador_botas", "chance": 0.04, "quantidade": 1},
			]
		"lutador_arena", "mordomo_zoldyck":
			return [
				{"item_id": "pocao_vida", "chance": 0.38, "quantidade": 1},
				{"item_id": "traje_nen_concentrado", "chance": 0.07, "quantidade": 1},
				{"item_id": "adaga_envenenada", "chance": 0.06, "quantidade": 1},
				{"item_id": "unique_escudo_torneio", "chance": 0.016, "quantidade": 1},
				{"item_id": "set_cacador_peito", "chance": 0.035, "quantidade": 1},
			]
		"mafioso_yorknew", "membro_trupe":
			return [
				{"item_id": "pocao_vida", "chance": 0.4, "quantidade": 1},
				{"item_id": "elixir_aura", "chance": 0.2, "quantidade": 1},
				{"item_id": "adaga_envenenada", "chance": 0.1, "quantidade": 1},
				{"item_id": "anel_explorador_ancestral", "chance": 0.04, "quantidade": 1},
				{"item_id": "unique_laminas_exame", "chance": 0.02, "quantidade": 1},
				{"item_id": "set_cacador_botas", "chance": 0.03, "quantidade": 1},
			]
		"formiga_soldado", "formiga_lider":
			return [
				{"item_id": "pocao_vida", "chance": 0.4, "quantidade": 1},
				{"item_id": "elixir_aura", "chance": 0.22, "quantidade": 1},
				{"item_id": "amuleto_forca", "chance": 0.08, "quantidade": 1},
				{"item_id": "unique_garras_quirmera", "chance": 0.022, "quantidade": 1},
				{"item_id": "set_formiga_garras", "chance": 0.045, "quantidade": 1},
				{"item_id": "set_formiga_couraca", "chance": 0.03, "quantidade": 1},
			]
		"guarda_real", "boss_meruem":
			return [
				{"item_id": "pocao_vida", "chance": 0.36, "quantidade": 1},
				{"item_id": "elixir_aura", "chance": 0.28, "quantidade": 1},
				{"item_id": "traje_nen_concentrado", "chance": 0.1, "quantidade": 1},
				{"item_id": "unique_manto_palacio", "chance": 0.025, "quantidade": 1},
				{"item_id": "set_palacio_elmo", "chance": 0.04, "quantidade": 1},
				{"item_id": "set_palacio_manto", "chance": 0.035, "quantidade": 1},
			]
		"guarda_black_whale", "nen_beast_principe":
			return [
				{"item_id": "pocao_vida", "chance": 0.38, "quantidade": 1},
				{"item_id": "adaga_envenenada", "chance": 0.09, "quantidade": 1},
				{"item_id": "unique_manto_palacio", "chance": 0.018, "quantidade": 1},
				{"item_id": "set_palacio_elmo", "chance": 0.03, "quantidade": 1},
			]
		"monstro_greed", "bomber_greed", "boss_razor":
			return [
				{"item_id": "pocao_vida", "chance": 0.4, "quantidade": 1},
				{"item_id": "elixir_aura", "chance": 0.25, "quantidade": 1},
				{"item_id": "lamina_cacador", "chance": 0.1, "quantidade": 1},
				{"item_id": "unique_laminas_exame", "chance": 0.02, "quantidade": 1},
				{"item_id": "set_cacador_peito", "chance": 0.03, "quantidade": 1},
			]
		"criatura_pantanal", "boss_hisoka":
			return [
				{"item_id": "pocao_vida", "chance": 0.4, "quantidade": 1},
				{"item_id": "elixir_aura", "chance": 0.3, "quantidade": 1},
				{"item_id": "unique_escudo_torneio", "chance": 0.02, "quantidade": 1},
				{"item_id": "fragmento_lore_tabuleta", "chance": 0.05, "quantidade": 1},
			]
		_:
			return [
				{"item_id": "pocao_vida", "chance": 0.35, "quantidade": 1},
				{"item_id": "elixir_aura", "chance": 0.18, "quantidade": 1},
				{"item_id": "amuleto_forca", "chance": 0.05, "quantidade": 1},
			]


static func tabela_efetiva(enemy_data: EnemyData) -> Array:
	if enemy_data == null:
		return []
	var eid := String(enemy_data.enemy_id)
	var base: Array = []
	if not enemy_data.drop_table.is_empty():
		base = _array_from_typed(enemy_data.drop_table)
		if base.size() < 3:
			base.append_array(tabela_padrao_para(eid))
	else:
		base = tabela_padrao_para(eid).duplicate(true)
	if enemy_data.is_elite:
		return _multiplicar_chances(base, CHANCE_MULT_ELITE)
	if enemy_data.is_boss:
		return _multiplicar_chances(base, CHANCE_MULT_BOSS)
	return base


static func tabela_elite_de(base_id: String) -> Array:
	return _multiplicar_chances(tabela_padrao_para(base_id), CHANCE_MULT_ELITE)


static func jenny_multiplier(enemy_data: EnemyData) -> float:
	if enemy_data == null:
		return 1.0
	if enemy_data.is_boss:
		return JENNY_MULT_BOSS
	if enemy_data.is_elite:
		return JENNY_MULT_ELITE
	return 1.0


static func peso_raridade(raridade: String) -> float:
	return float(PESO_RARIDADE.get(String(raridade).to_lower(), 1.0))


static func catalogo_efeitos_unicos() -> Dictionary:
	return {
		"laminas_exame": {
			"nome": "Corte do Candidato",
			"desc": "+8% dano contra elites e bosses.",
			"bonus_vs_elite_pct": 0.08,
		},
		"garras_quirmera": {
			"nome": "Feromônio de Caça",
			"desc": "+6% chance crítica em combate.",
			"bonus_crit_pct": 0.06,
		},
		"manto_palacio": {
			"nome": "Etiqueta Real",
			"desc": "+12 defesa e +5% XP de missões de saga.",
			"bonus_def": 12,
			"bonus_xp_saga_pct": 0.05,
		},
		"escudo_torneio": {
			"nome": "Guarda da Arena",
			"desc": "Reduz 10% do dano recebido de elites.",
			"reducao_elite_pct": 0.1,
		},
	}


static func catalogo_sets() -> Dictionary:
	return {
		SET_CACADOR: {
			"nome": "Conjunto do Exame",
			"pecas": ["set_cacador_botas", "set_cacador_peito"],
			"bonus_2": {"bonus_forca": 4, "bonus_velocidade": 3},
			"desc_2": "2 peças: +4 FOR / +3 VEL",
		},
		SET_FORMIGA: {
			"nome": "Couraça Quirmera",
			"pecas": ["set_formiga_garras", "set_formiga_couraca"],
			"bonus_2": {"bonus_forca": 6, "bonus_vida": 40},
			"desc_2": "2 peças: +6 FOR / +40 HP",
		},
		SET_PALACIO: {
			"nome": "Protocolo do Palácio",
			"pecas": ["set_palacio_elmo", "set_palacio_manto"],
			"bonus_2": {"bonus_defesa": 8, "bonus_dano_hatsu_pct": 0.06},
			"desc_2": "2 peças: +8 DEF / +6% dano Hatsu",
		},
	}


static func bonus_set_para_pecas(equip_ids: Array) -> Dictionary:
	var out := {
		"bonus_forca": 0,
		"bonus_defesa": 0,
		"bonus_vida": 0,
		"bonus_velocidade": 0,
		"bonus_dano_hatsu_pct": 0.0,
		"sets_ativos": [],
	}
	var owned: Dictionary = {}
	for eid in equip_ids:
		owned[String(eid)] = true
	var sets: Dictionary = catalogo_sets()
	for sid in sets.keys():
		var spec: Dictionary = sets[sid]
		var pecas: Array = spec.get("pecas", [])
		var count := 0
		for p in pecas:
			if owned.has(String(p)):
				count += 1
		if count >= 2:
			out["sets_ativos"].append(sid)
			var b: Dictionary = spec.get("bonus_2", {})
			out["bonus_forca"] = int(out["bonus_forca"]) + int(b.get("bonus_forca", 0))
			out["bonus_defesa"] = int(out["bonus_defesa"]) + int(b.get("bonus_defesa", 0))
			out["bonus_vida"] = int(out["bonus_vida"]) + int(b.get("bonus_vida", 0))
			out["bonus_velocidade"] = int(out["bonus_velocidade"]) + int(b.get("bonus_velocidade", 0))
			out["bonus_dano_hatsu_pct"] = float(out["bonus_dano_hatsu_pct"]) + float(b.get("bonus_dano_hatsu_pct", 0.0))
	return out


static func registrar_itens_identidade(dm: Node) -> void:
	if dm == null:
		return
	_reg(dm, "unique_laminas_exame", "Lâminas do Exame", "Lendário",
		{"bonus_forca": 14, "bonus_velocidade": 4}, "laminas_exame", "", "")
	_reg(dm, "unique_garras_quirmera", "Garras Quirmera", "Épico",
		{"bonus_forca": 18, "bonus_velocidade": 3}, "garras_quirmera", "", "")
	_reg(dm, "unique_manto_palacio", "Manto do Palácio", "Épico",
		{"bonus_defesa": 16, "bonus_vida": 35}, "manto_palacio", "", "")
	_reg(dm, "unique_escudo_torneio", "Escudo do Torneio", "Raro",
		{"bonus_defesa": 20, "bonus_vida": 25}, "escudo_torneio", "", "")

	_reg(dm, "set_cacador_botas", "Botas do Candidato", "Raro",
		{"bonus_velocidade": 5}, "", SET_CACADOR, "botas")
	_reg(dm, "set_cacador_peito", "Peitoral do Candidato", "Raro",
		{"bonus_forca": 6, "bonus_defesa": 8}, "", SET_CACADOR, "peito")
	_reg(dm, "set_formiga_garras", "Garras de Soldado", "Épico",
		{"bonus_forca": 10, "bonus_velocidade": 4}, "", SET_FORMIGA, "garras")
	_reg(dm, "set_formiga_couraca", "Couraça de Soldado", "Épico",
		{"bonus_defesa": 14, "bonus_vida": 40}, "", SET_FORMIGA, "couraca")
	_reg(dm, "set_palacio_elmo", "Elmo do Protocolo", "Épico",
		{"bonus_defesa": 6, "bonus_dano_hatsu_pct": 0.04}, "", SET_PALACIO, "elmo")
	_reg(dm, "set_palacio_manto", "Manto do Protocolo", "Épico",
		{"bonus_defesa": 10, "bonus_dano_hatsu_pct": 0.05}, "", SET_PALACIO, "manto")


static func _multiplicar_chances(tabela: Array, mult: float) -> Array:
	var out: Array = []
	for entry in tabela:
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		var e: Dictionary = (entry as Dictionary).duplicate(true)
		e["chance"] = clampf(float(e.get("chance", 0.0)) * mult, 0.0, 0.95)
		out.append(e)
	return out


static func _array_from_typed(tabela) -> Array:
	var out: Array = []
	for entry in tabela:
		if typeof(entry) == TYPE_DICTIONARY:
			out.append((entry as Dictionary).duplicate(true))
	return out


static func _reg(
	dm: Node,
	id: String,
	nome: String,
	raridade: String,
	bonus: Dictionary,
	efeito_id: String,
	set_id_val: String,
	set_peca: String
) -> void:
	var key := StringName(id)
	if dm.equipment_registry.has(key) or dm.items_registry.has(key):
		return
	var eq := EquipmentData.new()
	eq.item_id = key
	eq.nome_item = nome
	eq.descricao = "Equipamento de identidade de loot."
	eq.tipo = ItemData.TipoItem.EQUIPAMENTO
	eq.raridade = raridade
	eq.acumulavel = false
	eq.preco_compra = int(80.0 * peso_raridade(raridade))
	eq.preco_venda = int(float(eq.preco_compra) * 0.4)
	eq.bonus_forca = int(bonus.get("bonus_forca", 0))
	eq.bonus_defesa = int(bonus.get("bonus_defesa", 0))
	eq.bonus_vida = int(bonus.get("bonus_vida", 0))
	eq.bonus_velocidade = int(bonus.get("bonus_velocidade", 0))
	eq.bonus_dano_hatsu_pct = float(bonus.get("bonus_dano_hatsu_pct", 0.0))
	eq.efeito_unico_id = efeito_id
	eq.set_id = set_id_val
	eq.set_peca_id = set_peca
	if not efeito_id.is_empty():
		var cat: Dictionary = catalogo_efeitos_unicos()
		if cat.has(efeito_id):
			eq.efeito_unico_desc = String(cat[efeito_id].get("desc", ""))
			eq.trade_off_descricao = "✦ Único: " + eq.efeito_unico_desc
	elif not set_id_val.is_empty():
		var sets: Dictionary = catalogo_sets()
		if sets.has(set_id_val):
			eq.trade_off_descricao = "◎ Set: " + String(sets[set_id_val].get("desc_2", ""))
	dm.equipment_registry[key] = eq
	dm.items_registry[key] = eq
