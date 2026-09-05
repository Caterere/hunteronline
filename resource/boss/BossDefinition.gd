class_name BossDefinition
extends Resource

# ============================================================
# HUNTER ONLINE — BOSS DEFINITION (FASE L)
# ============================================================
#
# Template reutilizável e declarativo para criação de Chefes:
# - Atributos básicos (HP, dano, defesa, velocidade, resistências).
# - Fases de combate dinâmicas com BossPhaseData (frenesi, minions, aura burst).
# - Habilidades e Hatsus declarativos.
# - Tabela de loot e recompensas individuais anti-duplicação.
# - Telas de apresentação com BossIntroBanner e citações canônicas.
# - Suporte a ameaça cooperativa e chefes secretos (sem GPS).
# ============================================================

const BossPhaseDataScript = preload("res://resource/status/BossPhaseData.gd")

@export var boss_id: StringName = &""
@export var boss_name: String = ""
@export var title: String = ""
@export_multiline var description: String = ""

# Stats Base
@export var base_stats: Dictionary = {
	"max_health": 25000,
	"damage": 350,
	"defense": 180,
	"move_speed": 95.0,
	"nen_defense": 120,
	"knockback_resistance": 0.95,
	"hit_invulnerability_time": 0.15,
	"xp_reward": 5000,
	"gold_reward": 15000
}

# Fases do Chefe (HP <= 0.70, 0.40, etc.)
@export var phases: Array[Resource] = []

# Hatsus e Habilidades Especiais
@export var hatsu_abilities: Array = []

# Perfil de IA: aggressive, tactical, ranged_kite, berserk
@export var ai_profile: String = "aggressive"

# Cena da Arena e Mídia
@export var arena_scene: String = ""
@export var intro_quote: String = "Você se atreveu a pisar no meu domínio?!"
@export var intro_banner_theme: Dictionary = {
	"title_color": Color(1.0, 0.25, 0.25, 1.0),
	"subtitle": "Guardião Ancestral da Região"
}

# Loot e Drops: [{"item_id": "nucleo_nen", "chance": 0.50, "min": 1, "max": 2}]
@export var loot_table: Array = []

# Parâmetros Especiais
@export var coop_threat_multiplier: float = 1.25
@export var is_secret_boss: bool = false
@export var flags: Array = [&"boss", &"pve", &"coop"]


func _init(
	p_id: StringName = &"",
	p_name: String = "",
	p_title: String = "",
	p_hp: int = 25000,
	p_dmg: int = 350
) -> void:
	boss_id = p_id
	boss_name = p_name
	title = p_title
	base_stats["max_health"] = p_hp
	base_stats["damage"] = p_dmg


func get_phase(index: int) -> Resource:
	for p in phases:
		if p != null and p.get("phase_index") == index:
			return p
	return null


func add_phase_data(phase_idx: int, hp_thresh: float, p_name: String, quote: String, mechanic: int = 1) -> void:
	var phase_data = BossPhaseDataScript.new()
	phase_data.phase_index = phase_idx
	phase_data.hp_threshold = hp_thresh
	phase_data.phase_name = p_name
	phase_data.dialogue_quote = quote
	phase_data.mechanic = mechanic as BossPhaseData.MecanicaFase
	phases.append(phase_data)


func add_loot_drop(item_id: String, chance: float, min_qty: int = 1, max_qty: int = 1) -> void:
	loot_table.append({
		"item_id": item_id,
		"chance": clampf(chance, 0.0, 1.0),
		"min_qty": min_qty,
		"max_qty": max_qty
	})


func to_dict() -> Dictionary:
	var phases_serialized: Array = []
	for p in phases:
		if p != null:
			phases_serialized.append({
				"phase_index": p.get("phase_index"),
				"hp_threshold": p.get("hp_threshold"),
				"phase_name": p.get("phase_name"),
				"dialogue_quote": p.get("dialogue_quote"),
				"mechanic": int(p.get("mechanic")) if p.get("mechanic") != null else 0,
				"speed_multiplier": float(p.get("speed_multiplier")) if p.get("speed_multiplier") != null else 1.0,
				"color_modulate": [p.color_modulate.r, p.color_modulate.g, p.color_modulate.b, p.color_modulate.a] if "color_modulate" in p else [1,1,1,1]
			})

	return {
		"boss_id": String(boss_id),
		"boss_name": boss_name,
		"title": title,
		"description": description,
		"base_stats": base_stats.duplicate(true),
		"phases": phases_serialized,
		"hatsu_abilities": hatsu_abilities.duplicate(),
		"ai_profile": ai_profile,
		"arena_scene": arena_scene,
		"intro_quote": intro_quote,
		"intro_banner_theme": intro_banner_theme.duplicate(true),
		"loot_table": loot_table.duplicate(true),
		"coop_threat_multiplier": coop_threat_multiplier,
		"is_secret_boss": is_secret_boss,
		"flags": flags.map(func(f): return String(f))
	}


static func from_dict(data: Dictionary) -> Resource:
	var def = (load("res://resource/boss/BossDefinition.gd") as GDScript).new()
	def.boss_id = StringName(data.get("boss_id", ""))
	def.boss_name = str(data.get("boss_name", ""))
	def.title = str(data.get("title", ""))
	def.description = str(data.get("description", ""))
	def.base_stats = (data.get("base_stats", def.base_stats) as Dictionary).duplicate(true)
	
	def.phases.clear()
	for p_data in data.get("phases", []):
		if p_data is Dictionary:
			var p = BossPhaseDataScript.new()
			p.phase_index = int(p_data.get("phase_index", 2))
			p.hp_threshold = float(p_data.get("hp_threshold", 0.5))
			p.phase_name = str(p_data.get("phase_name", ""))
			p.dialogue_quote = str(p_data.get("dialogue_quote", ""))
			p.mechanic = int(p_data.get("mechanic", 0)) as BossPhaseData.MecanicaFase
			p.speed_multiplier = float(p_data.get("speed_multiplier", 1.25))
			def.phases.append(p)
			
	def.hatsu_abilities.clear()
	for h in data.get("hatsu_abilities", []):
		def.hatsu_abilities.append(str(h))
		
	def.ai_profile = str(data.get("ai_profile", "aggressive"))
	def.arena_scene = str(data.get("arena_scene", ""))
	def.intro_quote = str(data.get("intro_quote", ""))
	def.intro_banner_theme = (data.get("intro_banner_theme", def.intro_banner_theme) as Dictionary).duplicate(true)
	def.loot_table = (data.get("loot_table", []) as Array).duplicate(true)
	def.coop_threat_multiplier = float(data.get("coop_threat_multiplier", 1.25))
	def.is_secret_boss = bool(data.get("is_secret_boss", false))
	
	def.flags.clear()
	for f in data.get("flags", []):
		def.flags.append(StringName(f))
		
	return def
