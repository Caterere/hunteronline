class_name EnemyNenKit
extends RefCounted

# ============================================================
# HUNTER ONLINE — KIT DE NEN / ARQUÉTIPOS DE INIMIGO (HxH)
# ============================================================
# SSOT de perfis: categoria Nen, resistências, velocidade, padrão
# de ação e Hatsu sintético para elites/bosses sem rotina hardcoded.
# ============================================================

## Categorias alinhadas a HatsuData.Categoria
const NEN_INTENSIFICACAO := 0
const NEN_TRANSFORMACAO := 1
const NEN_EMISSAO := 2
const NEN_CONJURACAO := 3
const NEN_MANIPULACAO := 4
const NEN_ESPECIALIZACAO := 5

## Perfis por enemy_id (e aliases). Campos omitidos usam defaults seguros.
const PROFILES := {
	# --- Trash / fauna ---
	"slime": {
		"role": "bruiser", "move_speed_mult": 0.85, "attack_pattern": "pressure",
		"weakness": ["fire", "nen"], "resist": ["blunt"],
		"balance": {"hp": 1.1, "str": 1.05, "def": 1.0},
	},
	"slime_venenoso": {
		"role": "bruiser", "move_speed_mult": 0.80, "attack_pattern": "poison_burst",
		"nen_type": NEN_TRANSFORMACAO, "hatsu": "Névoa Tóxica",
		"weakness": ["fire", "nen"], "resist": ["poison", "piercing"],
		"attack_tags": ["poison"],
		"balance": {"hp": 1.15, "str": 1.1, "def": 1.05},
	},
	"lobo_selvagem": {
		"role": "fast", "move_speed_mult": 1.35, "attack_pattern": "flank",
		"weakness": ["blunt", "fire"], "resist": [],
		"balance": {"hp": 1.1, "str": 1.15, "def": 1.0},
	},
	"lobo_padokia": {
		"role": "fast", "move_speed_mult": 1.40, "attack_pattern": "flank",
		"weakness": ["blunt"], "resist": [],
		"balance": {"hp": 1.15, "str": 1.2, "def": 1.05},
	},
	"lobo_sombras": {
		"role": "ambusher", "move_speed_mult": 1.45, "attack_pattern": "ambush",
		"nen_type": NEN_EMISSAO, "hatsu": "Uivo de Aura", "npc_tier": 2,
		"weakness": ["nen", "fire", "gyo"], "resist": ["slashing"],
		"balance": {"hp": 1.2, "str": 1.2, "def": 1.1},
	},
	"javali_espinhoso": {
		"role": "tank", "move_speed_mult": 0.75, "attack_pattern": "charge",
		"weakness": ["blunt", "fire"], "resist": ["piercing", "slashing"],
		"balance": {"hp": 1.25, "str": 1.1, "def": 1.3},
	},
	"besouro_blindado": {
		"role": "tank", "move_speed_mult": 0.70, "attack_pattern": "guard_bash",
		"weakness": ["blunt", "ko"], "resist": ["slashing", "piercing", "poison"],
		"balance": {"hp": 1.3, "str": 1.05, "def": 1.4},
	},
	"serpente_sombra": {
		"role": "fast", "move_speed_mult": 1.30, "attack_pattern": "poison_burst",
		"nen_type": NEN_TRANSFORMACAO, "hatsu": "Presas de Nen",
		"weakness": ["fire", "blunt"], "resist": ["poison"],
		"attack_tags": ["poison", "piercing"],
		"balance": {"hp": 1.1, "str": 1.2, "def": 1.0},
	},
	# --- Humanos / Nen users ---
	"ladrao_estrada": {
		"role": "fast", "move_speed_mult": 1.25, "attack_pattern": "flank",
		"weakness": ["nen"], "resist": [],
		"balance": {"hp": 1.1, "str": 1.1, "def": 1.05},
	},
	"bandido_renegado": {
		"role": "bruiser", "move_speed_mult": 1.05, "attack_pattern": "pressure",
		"nen_type": NEN_INTENSIFICACAO, "hatsu": "Ko Selvagem", "npc_tier": 2,
		"weakness": ["nen"], "resist": ["blunt"],
		"attack_tags": ["blunt", "nen"],
		"balance": {"hp": 1.2, "str": 1.25, "def": 1.15},
	},
	"arqueiro_renegado": {
		"role": "ranged", "move_speed_mult": 1.10, "attack_pattern": "kite",
		"nen_type": NEN_EMISSAO, "hatsu": "Flecha de Aura",
		"weakness": ["slashing", "nen"], "resist": [],
		"attack_tags": ["piercing", "nen"],
		"balance": {"hp": 1.05, "str": 1.2, "def": 1.0},
	},
	"mercenario_mafia": {
		"role": "bruiser", "move_speed_mult": 1.05, "attack_pattern": "pressure",
		"nen_type": NEN_INTENSIFICACAO, "hatsu": "Punho Shu", "npc_tier": 2,
		"weakness": ["nen"], "resist": ["slashing"],
		"attack_tags": ["blunt", "nen"],
		"balance": {"hp": 1.25, "str": 1.3, "def": 1.2},
	},
	"cacador_furtivo": {
		"role": "assassin", "move_speed_mult": 1.50, "attack_pattern": "ambush",
		"nen_type": NEN_EMISSAO, "hatsu": "Disparo Zetsu", "npc_tier": 2,
		"weakness": ["area_of_effect", "nen"], "resist": [],
		"attack_tags": ["piercing", "nen"],
		"balance": {"hp": 1.1, "str": 1.35, "def": 1.05},
	},
	"iniciado_nen_sombrio": {
		"role": "nen_user", "move_speed_mult": 1.15, "attack_pattern": "hatsu_focus",
		"nen_type": NEN_MANIPULACAO, "hatsu": "Sombra Drenante", "npc_tier": 2,
		"weakness": ["gyo", "ko"], "resist": ["nen"],
		"attack_tags": ["nen", "drain"],
		"balance": {"hp": 1.3, "str": 1.25, "def": 1.15},
	},
	"candidato_exame": {
		"role": "bruiser", "move_speed_mult": 1.10, "attack_pattern": "pressure",
		"weakness": ["nen"], "resist": [],
		"balance": {"hp": 1.15, "str": 1.15, "def": 1.1},
	},
	"lutador_arena": {
		"role": "bruiser", "move_speed_mult": 1.20, "attack_pattern": "pressure",
		"nen_type": NEN_INTENSIFICACAO, "hatsu": "Ren de Arena", "npc_tier": 2,
		"weakness": ["nen"], "resist": ["blunt"],
		"attack_tags": ["blunt", "nen"],
		"balance": {"hp": 1.25, "str": 1.3, "def": 1.2},
	},
	"mafioso_yorknew": {
		"role": "bruiser", "move_speed_mult": 1.05, "attack_pattern": "pressure",
		"nen_type": NEN_INTENSIFICACAO, "hatsu": "Ko de Rua", "npc_tier": 2,
		"weakness": ["nen"], "resist": ["piercing"],
		"balance": {"hp": 1.2, "str": 1.25, "def": 1.15},
	},
	"membro_trupe": {
		"role": "fast", "move_speed_mult": 1.35, "attack_pattern": "hatsu_focus",
		"nen_type": NEN_INTENSIFICACAO, "hatsu": "Aura da Trupe", "npc_tier": 3,
		"weakness": ["nen"], "resist": ["blunt", "slashing"],
		"attack_tags": ["nen", "blunt"],
		"balance": {"hp": 1.4, "str": 1.4, "def": 1.3},
	},
	# --- Constructos / ruínas ---
	"sentinela_pedra": {
		"role": "tank", "move_speed_mult": 0.65, "attack_pattern": "guard_bash",
		"nen_type": NEN_CONJURACAO, "hatsu": "Muralha de Pedra", "npc_tier": 2,
		"weakness": ["blunt", "ko", "ren"], "resist": ["slashing", "piercing", "poison"],
		"attack_tags": ["blunt", "nen"],
		"balance": {"hp": 1.35, "str": 1.15, "def": 1.45},
	},
	"guardiao_elite": {
		"role": "tactician", "move_speed_mult": 0.90, "attack_pattern": "hatsu_focus",
		"nen_type": NEN_CONJURACAO, "hatsu": "Muralha de Pedra", "npc_tier": 2,
		"weakness": ["ko", "ren"], "resist": ["slashing", "piercing"],
		"attack_tags": ["blunt", "nen"],
		"balance": {"hp": 1.35, "str": 1.25, "def": 1.35},
	},
	"guardiao_ancestral": {
		"role": "boss", "move_speed_mult": 0.95, "attack_pattern": "boss_phase",
		"nen_type": NEN_CONJURACAO, "hatsu": "Selo Ancestral", "npc_tier": 4,
		"weakness": ["ko", "ren"], "resist": ["slashing", "piercing", "poison"],
		"attack_tags": ["blunt", "nen", "area_of_effect"],
		"balance": {"hp": 1.2, "str": 1.2, "def": 1.25},
	},
	"golem_pedra": {
		"role": "tank", "move_speed_mult": 0.60, "attack_pattern": "charge",
		"weakness": ["blunt", "ko"], "resist": ["slashing", "piercing", "fire"],
		"balance": {"hp": 1.4, "str": 1.15, "def": 1.5},
	},
	"boss_opcional_guardiao": {
		"role": "boss", "move_speed_mult": 0.95, "attack_pattern": "boss_phase",
		"nen_type": NEN_CONJURACAO, "hatsu": "Selo Ancestral", "npc_tier": 3,
		"weakness": ["ko", "ren"], "resist": ["slashing", "piercing"],
		"balance": {"hp": 1.25, "str": 1.2, "def": 1.3},
	},
	# --- Greed Island ---
	"monstro_greed": {
		"role": "bruiser", "move_speed_mult": 1.10, "attack_pattern": "pressure",
		"nen_type": NEN_EMISSAO, "hatsu": "Rajada de Carta",
		"weakness": ["nen", "fire"], "resist": [],
		"attack_tags": ["nen"],
		"balance": {"hp": 1.2, "str": 1.2, "def": 1.1},
	},
	"bomber_greed": {
		"role": "nen_user", "move_speed_mult": 1.15, "attack_pattern": "hatsu_focus",
		"nen_type": NEN_TRANSFORMACAO, "hatsu": "Little Flower", "npc_tier": 3,
		"weakness": ["nen", "water"], "resist": ["fire", "blunt"],
		"attack_tags": ["fire", "nen", "area_of_effect"],
		"balance": {"hp": 1.35, "str": 1.35, "def": 1.2},
	},
	"boss_razor": {
		"role": "boss", "move_speed_mult": 1.20, "attack_pattern": "boss_phase",
		"nen_type": NEN_EMISSAO, "hatsu": "14 Demônios", "npc_tier": 4,
		"weakness": ["nen"], "resist": ["blunt", "piercing"],
		"attack_tags": ["nen", "blunt"],
		"balance": {"hp": 1.15, "str": 1.2, "def": 1.15},
	},
	# --- Chimera Ants ---
	"formiga_soldado": {
		"role": "fast", "move_speed_mult": 1.30, "attack_pattern": "flank",
		"nen_type": NEN_INTENSIFICACAO, "hatsu": "Garras Quimera", "npc_tier": 2,
		"weakness": ["fire", "nen"], "resist": ["poison", "slashing"],
		"attack_tags": ["slashing", "nen"],
		"balance": {"hp": 1.25, "str": 1.3, "def": 1.2},
	},
	"formiga_lider": {
		"role": "tactician", "move_speed_mult": 1.25, "attack_pattern": "hatsu_focus",
		"nen_type": NEN_EMISSAO, "hatsu": "Comando de Matilha", "npc_tier": 3,
		"weakness": ["nen", "ko"], "resist": ["poison", "blunt"],
		"attack_tags": ["nen", "area_of_effect"],
		"balance": {"hp": 1.4, "str": 1.35, "def": 1.3},
	},
	"lider_matilha_quimera": {
		"role": "fast", "move_speed_mult": 1.40, "attack_pattern": "hatsu_focus",
		"nen_type": NEN_INTENSIFICACAO, "hatsu": "Garras Quimera", "npc_tier": 3,
		"weakness": ["nen", "fire"], "resist": ["poison"],
		"attack_tags": ["slashing", "nen"],
		"balance": {"hp": 1.3, "str": 1.35, "def": 1.2},
	},
	"alfa_ninho_elite": {
		"role": "ambusher", "move_speed_mult": 1.45, "attack_pattern": "ambush",
		"nen_type": NEN_EMISSAO, "hatsu": "Uivo de Aura", "npc_tier": 2,
		"weakness": ["ko", "nen", "gyo"], "resist": ["slashing"],
		"attack_tags": ["nen", "area_of_effect"],
		"balance": {"hp": 1.25, "str": 1.25, "def": 1.15},
	},
	"guarda_real": {
		"role": "boss", "move_speed_mult": 1.35, "attack_pattern": "boss_phase",
		"nen_type": NEN_ESPECIALIZACAO, "hatsu": "Aura da Guarda Real", "npc_tier": 4,
		"weakness": ["nen", "ko"], "resist": ["blunt", "slashing", "poison"],
		"attack_tags": ["nen", "slashing"],
		"balance": {"hp": 1.2, "str": 1.25, "def": 1.25},
	},
	"nen_beast_principe": {
		"role": "nen_user", "move_speed_mult": 1.20, "attack_pattern": "hatsu_focus",
		"nen_type": NEN_ESPECIALIZACAO, "hatsu": "Besta de Nen", "npc_tier": 3,
		"weakness": ["nen"], "resist": ["blunt"],
		"attack_tags": ["nen", "area_of_effect"],
		"balance": {"hp": 1.3, "str": 1.3, "def": 1.2},
	},
	# --- Canon bosses ---
	"boss_hisoka": {
		"role": "fast", "move_speed_mult": 1.55, "attack_pattern": "hatsu_focus",
		"nen_type": NEN_TRANSFORMACAO, "hatsu": "Bungee Gum", "npc_tier": 4,
		"weakness": ["fire", "nen"], "resist": ["blunt", "piercing"],
		"attack_tags": ["nen", "control"],
		"balance": {"hp": 1.0, "str": 1.1, "def": 1.05},
	},
	"boss_meruem": {
		"role": "boss", "move_speed_mult": 1.50, "attack_pattern": "boss_phase",
		"nen_type": NEN_ESPECIALIZACAO, "hatsu": "Fótons de En", "npc_tier": 4,
		"weakness": ["nen"], "resist": ["blunt", "slashing", "piercing", "poison", "fire"],
		"immunity": ["poison"],
		"attack_tags": ["nen", "area_of_effect"],
		"balance": {"hp": 1.0, "str": 1.1, "def": 1.1},
	},
	"mordomo_zoldyck": {
		"role": "tactician", "move_speed_mult": 1.20, "attack_pattern": "hatsu_focus",
		"nen_type": NEN_EMISSAO, "hatsu": "Disciplina Zoldyck", "npc_tier": 2,
		"weakness": ["nen"], "resist": ["blunt"],
		"attack_tags": ["nen", "blunt"],
		"balance": {"hp": 1.25, "str": 1.25, "def": 1.2},
	},
	"criatura_pantanal": {
		"role": "ambusher", "move_speed_mult": 0.95, "attack_pattern": "poison_burst",
		"nen_type": NEN_TRANSFORMACAO, "hatsu": "Lodo Vivo",
		"weakness": ["fire", "nen"], "resist": ["poison", "blunt"],
		"attack_tags": ["poison"],
		"balance": {"hp": 1.2, "str": 1.15, "def": 1.15},
	},
	"predador_miasma": {
		"role": "ambusher", "move_speed_mult": 1.25, "attack_pattern": "ambush",
		"nen_type": NEN_TRANSFORMACAO, "hatsu": "Névoa Devoradora", "npc_tier": 2,
		"weakness": ["nen", "fire"], "resist": ["poison"],
		"attack_tags": ["poison", "nen"],
		"balance": {"hp": 1.25, "str": 1.25, "def": 1.1},
	},
	"quimera_selvagem": {
		"role": "bruiser", "move_speed_mult": 1.15, "attack_pattern": "charge",
		"nen_type": NEN_INTENSIFICACAO, "hatsu": "Garras Quimera", "npc_tier": 2,
		"weakness": ["nen", "fire"], "resist": ["poison"],
		"attack_tags": ["slashing", "nen"],
		"balance": {"hp": 1.3, "str": 1.3, "def": 1.2},
	},
}


static func profile_for(enemy_id: String) -> Dictionary:
	var key := enemy_id.strip_edges().to_lower()
	if PROFILES.has(key):
		return (PROFILES[key] as Dictionary).duplicate(true)
	# aliases parciais
	for k in PROFILES.keys():
		if key.contains(str(k)) or str(k).contains(key):
			return (PROFILES[k] as Dictionary).duplicate(true)
	return {}


## Enriquece EnemyData in-place (tags, role, hatsu, speed, balance). Idempotente.
static func enrich(data: EnemyData) -> void:
	if data == null:
		return
	var id_str := str(data.enemy_id)
	if id_str.is_empty():
		id_str = data.enemy_name.to_lower().replace(" ", "_")
	var p := profile_for(id_str)
	if p.is_empty():
		# fallback leve por role
		p = _fallback_by_role(data.role if not data.role.is_empty() else "bruiser")
	_apply_profile(data, p)
	# Garante Hatsu modular sintetizado para tier ≥ 2
	if int(data.npc_tier) >= 2 or data.is_elite or data.is_boss or not str(data.hatsu_name).is_empty():
		if data.modular_hatsu == null:
			data.obter_hatsu_real()


static func _fallback_by_role(role: String) -> Dictionary:
	match role:
		"fast", "assassin":
			return {"move_speed_mult": 1.35, "attack_pattern": "flank", "weakness": ["blunt"], "resist": []}
		"tank", "brute":
			return {"move_speed_mult": 0.75, "attack_pattern": "guard_bash", "weakness": ["ko"], "resist": ["slashing"]}
		"ranged":
			return {"move_speed_mult": 1.1, "attack_pattern": "kite", "weakness": ["slashing"], "resist": []}
		"ambusher":
			return {"move_speed_mult": 1.3, "attack_pattern": "ambush", "weakness": ["nen"], "resist": []}
		"nen_user", "tactician":
			return {"move_speed_mult": 1.15, "attack_pattern": "hatsu_focus", "weakness": ["ko"], "resist": ["nen"], "npc_tier": 2}
		"boss":
			return {"move_speed_mult": 1.1, "attack_pattern": "boss_phase", "weakness": ["nen"], "resist": ["blunt"]}
		_:
			return {"move_speed_mult": 1.0, "attack_pattern": "pressure", "weakness": ["nen"], "resist": []}


static func _apply_profile(data: EnemyData, p: Dictionary) -> void:
	if p.has("role") and (data.role.is_empty() or data.role == "bruiser"):
		data.role = str(p["role"])
	elif p.has("role") and data.role == "bruiser" and str(p["role"]) != "bruiser":
		data.role = str(p["role"])
	if p.has("role") and str(data.enemy_id) in PROFILES:
		data.role = str(p["role"])

	if p.has("move_speed_mult"):
		data.set_meta("move_speed_mult", float(p["move_speed_mult"]))
	if p.has("attack_pattern"):
		data.set_meta("attack_pattern", str(p["attack_pattern"]))

	if p.has("nen_type"):
		data.nen_type = int(p["nen_type"])
	if p.has("hatsu") and data.hatsu_name.is_empty():
		data.hatsu_name = str(p["hatsu"])
	elif p.has("hatsu") and str(data.enemy_id) in PROFILES:
		data.hatsu_name = str(p["hatsu"])
	if p.has("npc_tier") and int(data.npc_tier) < int(p["npc_tier"]):
		data.npc_tier = int(p["npc_tier"]) as EnemyData.NPCTier

	if p.has("weakness"):
		_fill_tags(data.weakness_tags, p["weakness"])
	if p.has("resist"):
		_fill_tags(data.resistance_tags, p["resist"])
	if p.has("immunity"):
		_fill_tags(data.immunity_tags, p["immunity"])
	if p.has("attack_tags"):
		_fill_tags(data.attack_tags, p["attack_tags"])

	if p.has("balance") and not data.has_meta("nen_kit_balanced"):
		var b: Dictionary = p["balance"]
		data.max_health = maxi(1, int(round(float(data.max_health) * float(b.get("hp", 1.0)))))
		data.strength = maxi(1, int(round(float(data.strength) * float(b.get("str", 1.0)))))
		data.defense = maxi(0, int(round(float(data.defense) * float(b.get("def", 1.0)))))
		data.xp_reward = maxi(1, int(round(float(data.xp_reward) * float(b.get("hp", 1.0)))))
		data.set_meta("nen_kit_balanced", true)


static func _fill_tags(dest: Array, src: Variant) -> void:
	if src == null:
		return
	var seen: Dictionary = {}
	for t in dest:
		seen[str(t).to_lower()] = true
	for t in src:
		var s := str(t).to_lower()
		if s.is_empty() or seen.has(s):
			continue
		dest.append(s)
		seen[s] = true


static func move_speed_mult(data: EnemyData) -> float:
	if data != null and data.has_meta("move_speed_mult"):
		return float(data.get_meta("move_speed_mult"))
	return 1.0


static func attack_pattern(data: EnemyData) -> String:
	if data != null and data.has_meta("attack_pattern"):
		return str(data.get_meta("attack_pattern"))
	return "pressure"


## Tags de ataque derivadas da categoria/forma do Hatsu do jogador.
static func attack_tags_from_hatsu(hatsu: Resource) -> Array:
	var tags: Array = []
	if hatsu == null:
		return ["nen"]
	if "tags" in hatsu and hatsu.tags != null:
		for t in hatsu.tags:
			tags.append(str(t))
	if "categoria" in hatsu:
		match int(hatsu.categoria):
			NEN_INTENSIFICACAO:
				tags.append_array(["nen", "blunt", "ko"])
			NEN_TRANSFORMACAO:
				tags.append_array(["nen", "fire"])
			NEN_EMISSAO:
				tags.append_array(["nen", "long_range"])
			NEN_CONJURACAO:
				tags.append_array(["nen", "piercing"])
			NEN_MANIPULACAO:
				tags.append_array(["nen", "control"])
			NEN_ESPECIALIZACAO:
				tags.append_array(["nen", "special"])
			_:
				tags.append("nen")
	if "forma" in hatsu:
		var f := int(hatsu.forma)
		# Forma.AREA=1, Forma.ZONA=4
		if f == 1 or f == 4:
			tags.append("area_of_effect")
	if tags.is_empty():
		tags.append("nen")
	return GameplayTags.normalize(tags)


## Aplica fraqueza/resistência/imunidade do alvo ao dano de Hatsu do jogador.
static func apply_defense_tags(dano: float, enemy_data: EnemyData, hatsu: Resource) -> Dictionary:
	var tags := attack_tags_from_hatsu(hatsu)
	var out := {"dano": dano, "is_weakness": false, "is_resisted": false, "is_immune": false, "tags": tags}
	if enemy_data == null or dano <= 0.0:
		return out
	if enemy_data.eh_imune_a(tags):
		out["dano"] = 0.0
		out["is_immune"] = true
		return out
	if enemy_data.eh_vulneravel_a(tags):
		out["dano"] = dano * 1.50
		out["is_weakness"] = true
	if enemy_data.eh_resistente_a(tags):
		out["dano"] = float(out["dano"]) * 0.50
		out["is_resisted"] = true
	return out


## Constrói/atualiza HatsuData a partir do nome canônico / perfil.
static func build_named_hatsu(data: EnemyData) -> HatsuData:
	var HatsuComponentLibrary = load("res://resource/hatsu/HatsuComponentLibrary.gd")
	var h := HatsuData.new()
	var nome := data.hatsu_name if data != null and not data.hatsu_name.is_empty() else "Golpe de Nen"
	var e_lower := (str(data.enemy_id) + " " + data.enemy_name + " " + nome).to_lower() if data else nome.to_lower()
	var lvl := data.level if data else 1
	var stren := data.strength if data else 10

	h.usuario_original = data.enemy_name if data else "Inimigo"

	if "bungee" in e_lower or "hisoka" in e_lower:
		return null # handled by EnemyData canônicos / AI
	if "muralha" in e_lower or "selo ancestral" in e_lower:
		h.nome = nome
		h.categoria = HatsuData.Categoria.CONJURACAO
		h.forma = HatsuData.Forma.AREA
		h.objetivo = HatsuData.ObjetivoPrincipal.DEFESA if "muralha" in e_lower else HatsuData.ObjetivoPrincipal.DANO
		h.custom_damage = 28.0 + float(lvl) * 1.5 + float(stren) * 0.4
		h.custom_cooldown = 5.5
		h.estilo_visual = HatsuData.EstiloVisual.ANEIS_IMPACTO
		h.cor_aura = Color(0.65, 0.55, 0.35)
		h.sub_effects = [HatsuComponentLibrary.EffectType.KNOCKBACK]
		h.tags = ["nen", "blunt", "area_of_effect"]
	elif "uivo" in e_lower:
		h.nome = nome
		h.categoria = HatsuData.Categoria.EMISSAO
		h.forma = HatsuData.Forma.AREA
		h.objetivo = HatsuData.ObjetivoPrincipal.CONTROLE
		h.custom_damage = 22.0 + float(lvl) * 1.2
		h.custom_cooldown = 6.0
		h.estilo_visual = HatsuData.EstiloVisual.PURO_PULSANTE
		h.cor_aura = Color(0.55, 0.35, 0.95)
		h.sub_effects = [HatsuComponentLibrary.EffectType.STUN]
		h.tags = ["nen", "area_of_effect", "control"]
	elif "garras" in e_lower or "quimera" in e_lower:
		h.nome = nome
		h.categoria = HatsuData.Categoria.INTENSIFICACAO
		h.forma = HatsuData.Forma.TOQUE
		h.objetivo = HatsuData.ObjetivoPrincipal.DANO
		h.custom_damage = 35.0 + float(lvl) * 2.0 + float(stren) * 0.5
		h.custom_cooldown = 4.0
		h.estilo_visual = HatsuData.EstiloVisual.LAMINA_CORTE
		h.cor_aura = Color(0.9, 0.3, 0.25)
		h.sub_effects = [HatsuComponentLibrary.EffectType.PIERCING]
		h.tags = ["nen", "slashing"]
	elif "sombra" in e_lower or "drenante" in e_lower:
		h.nome = nome
		h.categoria = HatsuData.Categoria.MANIPULACAO
		h.forma = HatsuData.Forma.PROJETIL
		h.objetivo = HatsuData.ObjetivoPrincipal.CONTROLE
		h.custom_damage = 20.0 + float(lvl) * 1.5
		h.custom_cooldown = 5.0
		h.estilo_visual = HatsuData.EstiloVisual.PURO_PULSANTE
		h.cor_aura = Color(0.35, 0.1, 0.45)
		h.sub_effects = [HatsuComponentLibrary.EffectType.STUN]
		h.tags = ["nen", "drain", "control"]
	elif "little flower" in e_lower or "bomb" in e_lower:
		return null
	elif "ko " in e_lower or e_lower.begins_with("ko") or "ren de" in e_lower or "punho shu" in e_lower:
		h.nome = nome
		h.categoria = HatsuData.Categoria.INTENSIFICACAO
		h.forma = HatsuData.Forma.TOQUE
		h.objetivo = HatsuData.ObjetivoPrincipal.DANO
		h.custom_damage = 30.0 + float(lvl) * 1.8 + float(stren) * 0.6
		h.custom_cooldown = 3.5
		h.estilo_visual = HatsuData.EstiloVisual.ANEIS_IMPACTO
		h.cor_aura = Color(1.0, 0.75, 0.2)
		h.tags = ["nen", "blunt", "ko"]
	elif "flecha" in e_lower or "disparo" in e_lower or "rajada" in e_lower:
		h.nome = nome
		h.categoria = HatsuData.Categoria.EMISSAO
		h.forma = HatsuData.Forma.PROJETIL
		h.objetivo = HatsuData.ObjetivoPrincipal.DANO
		h.custom_damage = 24.0 + float(lvl) * 1.6
		h.custom_cooldown = 3.8
		h.estilo_visual = HatsuData.EstiloVisual.PURO_PULSANTE
		h.cor_aura = Color(0.4, 0.85, 1.0)
		h.tags = ["nen", "piercing", "long_range"]
	elif "névoa" in e_lower or "nevoa" in e_lower or "lodo" in e_lower or "presas" in e_lower:
		h.nome = nome
		h.categoria = HatsuData.Categoria.TRANSFORMACAO
		h.forma = HatsuData.Forma.AREA
		h.objetivo = HatsuData.ObjetivoPrincipal.DANO
		h.custom_damage = 18.0 + float(lvl) * 1.4
		h.custom_cooldown = 5.0
		h.estilo_visual = HatsuData.EstiloVisual.CHAMAS_FOGO if "tóx" in e_lower or "tox" in e_lower else HatsuData.EstiloVisual.PURO_PULSANTE
		h.cor_aura = Color(0.45, 0.85, 0.35)
		h.tags = ["nen", "poison", "area_of_effect"]
	elif "comando" in e_lower or "besta de nen" in e_lower or "guarda real" in e_lower or "trupe" in e_lower or "zoldyck" in e_lower:
		h.nome = nome
		h.categoria = HatsuData.Categoria.ESPECIALIZACAO if ("besta" in e_lower or "guarda" in e_lower) else HatsuData.Categoria.EMISSAO
		h.forma = HatsuData.Forma.AREA
		h.objetivo = HatsuData.ObjetivoPrincipal.DANO
		h.custom_damage = 40.0 + float(lvl) * 2.2
		h.custom_cooldown = 6.5
		h.estilo_visual = HatsuData.EstiloVisual.PURO_PULSANTE
		h.cor_aura = Color(0.95, 0.85, 0.35)
		h.tags = ["nen", "area_of_effect"]
	else:
		h.nome = nome
		h.categoria = HatsuData.Categoria.EMISSAO if (data != null and data.nen_type == NEN_EMISSAO) else HatsuData.Categoria.INTENSIFICACAO
		h.forma = HatsuData.Forma.PROJETIL if h.categoria == HatsuData.Categoria.EMISSAO else HatsuData.Forma.TOQUE
		h.objetivo = HatsuData.ObjetivoPrincipal.DANO
		h.custom_damage = float(maxi(15, stren * 2))
		h.custom_cooldown = maxf(2.5, data.hatsu_cooldown if data else 5.0)
		h.estilo_visual = HatsuData.EstiloVisual.PURO_PULSANTE
		h.cor_aura = Color(0.4, 0.8, 1.0)
		h.tags = ["nen"]

	h.custom_aura_cost = 20.0 + float(lvl) * 0.5
	return h
