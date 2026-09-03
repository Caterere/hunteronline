extends Resource
class_name EnemyData


# =========================================================
# IDENTIDADE
# =========================================================

@export_category("Identity")

@export var enemy_id: StringName = &""

@export var enemy_name: String = "Inimigo"
@export var level: int = 1


# =========================================================
# STATUS
# =========================================================

@export_category("Stats")

@export var max_health: int = 100
@export var defense: int = 5
@export var strength: int = 10


# =========================================================
# PROGRESSÃO
# =========================================================

@export_category("Progression")

@export var xp_reward: int = 40


# =========================================================
# COMBATE
# =========================================================

@export_category("Combat")

@export var is_boss: bool = false
@export var is_elite: bool = false
@export var knockback_resistance: float = 0.0
@export var hit_invulnerability_time: float = 0.15
@export var hatsu_name: String = ""
@export var hatsu_cooldown: float = 5.0
@export var nen_type: int = 0
@export var modular_hatsu: HatsuData = null
@export var attack_windup: float = 0.25
@export var attack_recovery: float = 0.35
@export var attack_telegraph_type: String = "flash" # "flash", "exclamation", "aoe_circle"
@export var role: String = "bruiser" # "bruiser", "fast", "tank", "ranged", "boss", "swarm"

# Tags Canônicas de Combate & Fraquezas
@export var attack_tags: Array[String] = []
@export var weakness_tags: Array[String] = []
@export var resistance_tags: Array[String] = []
@export var immunity_tags: Array[String] = []

# =========================================================
# AGGRO, ARQUÉTIPOS & FASES DE CHEFE (FASES 4 & 6)
# =========================================================

@export_category("Aggro & Boss Phases")
@export var aggro_leash_distance: float = 420.0
@export var can_flee_at_low_hp: bool = false
@export var flee_hp_threshold: float = 0.20
@export var aggro_decay_rate: float = 5.0
@export var boss_phases: Array[Resource] = []


func eh_vulneravel_a(tags: Array) -> bool:
	return GameplayTags.has_any(weakness_tags, tags)


func eh_resistente_a(tags: Array) -> bool:
	return GameplayTags.has_any(resistance_tags, tags)


func eh_imune_a(tags: Array) -> bool:
	return GameplayTags.has_any(immunity_tags, tags)



# =========================================================
# DROPS & LOOT (VOL 8)
# =========================================================

@export_category("Loot")

# Array de dicionários: [{"item_id": "minerio_aco", "chance": 0.8, "quantidade": 1}]
@export var drop_table: Array[Dictionary] = []


# =========================================================
# UNIVERSAL NEN ENGINE — HATSU REAL DO INIMIGO
# =========================================================

func obter_hatsu_real() -> HatsuData:
	if modular_hatsu != null:
		return modular_hatsu

	var HatsuComponentLibrary = load("res://resource/hatsu/HatsuComponentLibrary.gd")
	var h := HatsuData.new()
	var e_lower: String = (str(enemy_id) + " " + enemy_name + " " + hatsu_name).to_lower()

	if "hisoka" in e_lower or "bungee" in e_lower:
		h.nome = "Bungee Gum"
		h.categoria = HatsuData.Categoria.TRANSFORMACAO
		h.forma = HatsuData.Forma.PROJETIL
		h.objetivo = HatsuData.ObjetivoPrincipal.CONTROLE
		h.custom_damage = 30.0 + float(level * 2)
		h.custom_cooldown = 4.5
		h.custom_aura_cost = 25.0
		h.estilo_visual = HatsuData.EstiloVisual.PURO_PULSANTE
		h.cor_aura = Color(1.0, 0.35, 0.75)
		h.sub_effects = [HatsuComponentLibrary.EffectType.STUN]
	elif "uvogin" in e_lower or "big bang" in e_lower:
		h.nome = "Big Bang Impact"
		h.categoria = HatsuData.Categoria.INTENSIFICACAO
		h.forma = HatsuData.Forma.AREA
		h.objetivo = HatsuData.ObjetivoPrincipal.DANO
		h.custom_damage = 50.0 + float(level * 3)
		h.custom_cooldown = 6.0
		h.custom_aura_cost = 40.0
		h.estilo_visual = HatsuData.EstiloVisual.ANEIS_IMPACTO
		h.cor_aura = Color(1.0, 0.85, 0.2)
		h.sub_effects = [HatsuComponentLibrary.EffectType.KNOCKBACK]
	elif "feitan" in e_lower or "pain packer" in e_lower or "rising sun" in e_lower:
		h.nome = "Pain Packer / Rising Sun"
		h.categoria = HatsuData.Categoria.TRANSFORMACAO
		h.forma = HatsuData.Forma.AREA
		h.objetivo = HatsuData.ObjetivoPrincipal.DANO
		h.custom_damage = 60.0 + float(level * 3)
		h.custom_cooldown = 8.0
		h.custom_aura_cost = 50.0
		h.estilo_visual = HatsuData.EstiloVisual.CHAMAS_FOGO
		h.cor_aura = Color(1.0, 0.3, 0.1)
		h.condicoes = [HatsuData.Condicao.HP_ABAIXO_50]
	elif "nobunaga" in e_lower or "iai" in e_lower:
		h.nome = "Iai Slash"
		h.categoria = HatsuData.Categoria.CONJURACAO
		h.forma = HatsuData.Forma.AREA
		h.objetivo = HatsuData.ObjetivoPrincipal.DANO
		h.custom_damage = 45.0 + float(level * 2)
		h.custom_cooldown = 4.0
		h.custom_aura_cost = 20.0
		h.estilo_visual = HatsuData.EstiloVisual.LAMINA_CORTE
		h.cor_aura = Color(0.9, 0.9, 1.0)
		h.sub_effects = [HatsuComponentLibrary.EffectType.PIERCING]
	elif "phinks" in e_lower or "ripper" in e_lower:
		h.nome = "Ripper Cyclotron"
		h.categoria = HatsuData.Categoria.INTENSIFICACAO
		h.forma = HatsuData.Forma.TOQUE
		h.objetivo = HatsuData.ObjetivoPrincipal.DANO
		h.custom_damage = 55.0 + float(level * 3)
		h.custom_cooldown = 5.0
		h.custom_aura_cost = 35.0
		h.estilo_visual = HatsuData.EstiloVisual.ANEIS_IMPACTO
		h.cor_aura = Color(1.0, 0.8, 0.2)
	elif "illumi" in e_lower or "agulhas" in e_lower:
		h.nome = "Agulhas de Manipulação"
		h.categoria = HatsuData.Categoria.MANIPULACAO
		h.forma = HatsuData.Forma.PROJETIL
		h.objetivo = HatsuData.ObjetivoPrincipal.CONTROLE
		h.custom_damage = 25.0 + float(level * 2)
		h.custom_cooldown = 5.0
		h.custom_aura_cost = 30.0
		h.estilo_visual = HatsuData.EstiloVisual.LAMINA_CORTE
		h.cor_aura = Color(0.6, 0.2, 0.8)
		h.sub_effects = [HatsuComponentLibrary.EffectType.STUN]
	elif "zeno" in e_lower or "dragon" in e_lower:
		h.nome = "Dragon Dive"
		h.categoria = HatsuData.Categoria.TRANSFORMACAO
		h.forma = HatsuData.Forma.AREA
		h.objetivo = HatsuData.ObjetivoPrincipal.DANO
		h.custom_damage = 65.0 + float(level * 3)
		h.custom_cooldown = 7.0
		h.custom_aura_cost = 55.0
		h.estilo_visual = HatsuData.EstiloVisual.DRAGAO_SERPENTE
		h.cor_aura = Color(1.0, 0.85, 0.2)
	elif "silva" in e_lower or "orbes" in e_lower:
		h.nome = "Orbes Gigantes de Emissão"
		h.categoria = HatsuData.Categoria.EMISSAO
		h.forma = HatsuData.Forma.PROJETIL
		h.objetivo = HatsuData.ObjetivoPrincipal.DANO
		h.custom_damage = 60.0 + float(level * 3)
		h.custom_cooldown = 6.0
		h.custom_aura_cost = 45.0
		h.estilo_visual = HatsuData.EstiloVisual.PURO_PULSANTE
		h.cor_aura = Color(0.3, 0.6, 1.0)
		h.sub_effects = [HatsuComponentLibrary.EffectType.AREA_BURST]
	elif "genthru" in e_lower or "little flower" in e_lower or "bomb" in e_lower:
		h.nome = "Little Flower"
		h.categoria = HatsuData.Categoria.TRANSFORMACAO
		h.forma = HatsuData.Forma.TOQUE
		h.objetivo = HatsuData.ObjetivoPrincipal.DANO
		h.custom_damage = 40.0 + float(level * 2)
		h.custom_cooldown = 4.0
		h.custom_aura_cost = 25.0
		h.estilo_visual = HatsuData.EstiloVisual.CHAMAS_FOGO
		h.cor_aura = Color(1.0, 0.4, 0.1)
	elif "razor" in e_lower:
		h.nome = "Esferas de Nen"
		h.categoria = HatsuData.Categoria.EMISSAO
		h.forma = HatsuData.Forma.PROJETIL
		h.objetivo = HatsuData.ObjetivoPrincipal.DANO
		h.custom_damage = 45.0 + float(level * 2)
		h.custom_cooldown = 4.0
		h.custom_aura_cost = 30.0
		h.estilo_visual = HatsuData.EstiloVisual.PURO_PULSANTE
		h.cor_aura = Color(0.9, 0.2, 0.2)
		h.sub_effects = [HatsuComponentLibrary.EffectType.KNOCKBACK]
	else:
		var h_nome_final: String = hatsu_name if not hatsu_name.is_empty() else "Golpe de Nen Remoto"
		h.nome = h_nome_final
		h.categoria = HatsuData.Categoria.EMISSAO if nen_type == 1 else HatsuData.Categoria.INTENSIFICACAO
		h.forma = HatsuData.Forma.PROJETIL if nen_type == 1 else HatsuData.Forma.TOQUE
		h.objetivo = HatsuData.ObjetivoPrincipal.DANO
		h.custom_damage = float(max(15, strength * 2))
		h.custom_cooldown = max(2.0, hatsu_cooldown)
		h.custom_aura_cost = 20.0
		h.estilo_visual = HatsuData.EstiloVisual.PURO_PULSANTE
		h.cor_aura = Color(0.4, 0.8, 1.0)

	h.usuario_original = enemy_name
	modular_hatsu = h
	return modular_hatsu
