class_name CharacterAppearance
extends Resource

# ============================================================
# HUNTER ONLINE - CHARACTER APPEARANCE DATA
# ============================================================
#
# Estrutura de dados modular e serializável para representar a
# aparência completa de um personagem (Player ou NPC):
# - Compatível com Saves (JSON / Dictionary)
# - Compatível com Multiplayer / Networking (dados leves)
#
# ============================================================

@export var character_id: String = "player_custom"
@export var name: String = "Hunter"

# 1. Base e Pele
@export var body_id: String = "body_male_01"
@export var skin_tone: Color = Color(1.0, 0.88, 0.76, 1.0)

# 2. Rosto e Olhos
@export var eyes_id: String = "eyes_01"
@export var eyes_color: Color = Color(0.15, 0.45, 0.85, 1.0)

# 3. Cabelo
@export var hair_id: String = "hair_gon_01"
@export var hair_color: Color = Color(0.1, 0.1, 0.12, 1.0)

# 4. Roupas
@export var shirt_id: String = "shirt_hunter_01"
@export var shirt_color: Color = Color(0.18, 0.58, 0.25, 1.0)

@export var jacket_id: String = "jacket_none"
@export var jacket_color: Color = Color.WHITE

@export var pants_id: String = "pants_hunter_01"
@export var pants_color: Color = Color(0.15, 0.45, 0.2, 1.0)

@export var shoes_id: String = "shoes_boots_01"
@export var shoes_color: Color = Color(0.12, 0.12, 0.12, 1.0)

# 5. Acessórios e Armas
@export var accessory_id: String = "none"
@export var accessory_color: Color = Color.WHITE

@export var weapon_id: String = "none"
@export var effect_id: String = "none"
@export var effect_color: Color = Color(0.3, 0.8, 1.0, 0.8)


# ============================================================
# SERIALIZAÇÃO & NETWORKING
# ============================================================

func to_dict() -> Dictionary:
	return {
		"character_id": character_id,
		"name": name,
		"body_id": body_id,
		"skin_tone": skin_tone.to_html(true),
		"eyes_id": eyes_id,
		"eyes_color": eyes_color.to_html(true),
		"hair_id": hair_id,
		"hair_color": hair_color.to_html(true),
		"shirt_id": shirt_id,
		"shirt_color": shirt_color.to_html(true),
		"jacket_id": jacket_id,
		"jacket_color": jacket_color.to_html(true),
		"pants_id": pants_id,
		"pants_color": pants_color.to_html(true),
		"shoes_id": shoes_id,
		"shoes_color": shoes_color.to_html(true),
		"accessory_id": accessory_id,
		"accessory_color": accessory_color.to_html(true),
		"weapon_id": weapon_id,
		"effect_id": effect_id,
		"effect_color": effect_color.to_html(true)
	}


static func from_dict(data: Dictionary) -> CharacterAppearance:
	var script_res = load("res://entities/character_creator/CharacterAppearance.gd")
	var app = script_res.new() as CharacterAppearance
	app.character_id = data.get("character_id", "player_custom")
	app.name = data.get("name", "Hunter")
	app.body_id = data.get("body_id", "body_male_01")
	app.skin_tone = Color.from_string(data.get("skin_tone", "ffeedcff"), Color(1.0, 0.88, 0.76, 1.0))
	app.eyes_id = data.get("eyes_id", "eyes_01")
	app.eyes_color = Color.from_string(data.get("eyes_color", "2673d9ff"), Color(0.15, 0.45, 0.85, 1.0))
	app.hair_id = data.get("hair_id", "hair_gon_01")
	app.hair_color = Color.from_string(data.get("hair_color", "1a1a1fff"), Color(0.1, 0.1, 0.12, 1.0))
	app.shirt_id = data.get("shirt_id", "shirt_hunter_01")
	app.shirt_color = Color.from_string(data.get("shirt_color", "2e9440ff"), Color(0.18, 0.58, 0.25, 1.0))
	app.jacket_id = data.get("jacket_id", "jacket_none")
	app.jacket_color = Color.from_string(data.get("jacket_color", "ffffffff"), Color.WHITE)
	app.pants_id = data.get("pants_id", "pants_hunter_01")
	app.pants_color = Color.from_string(data.get("pants_color", "267333ff"), Color(0.15, 0.45, 0.2, 1.0))
	app.shoes_id = data.get("shoes_id", "shoes_boots_01")
	app.shoes_color = Color.from_string(data.get("shoes_color", "1f1f1fff"), Color(0.12, 0.12, 0.12, 1.0))
	app.accessory_id = data.get("accessory_id", "none")
	app.accessory_color = Color.from_string(data.get("accessory_color", "ffffffff"), Color.WHITE)
	app.weapon_id = data.get("weapon_id", "none")
	app.effect_id = data.get("effect_id", "none")
	app.effect_color = Color.from_string(data.get("effect_color", "4dccffcc"), Color(0.3, 0.8, 1.0, 0.8))
	return app
