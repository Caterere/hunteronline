class_name CharacterAssetDatabase
extends RefCounted

# ============================================================
# HUNTER ONLINE - CHARACTER ASSET DATABASE & PRESETS
# ============================================================
#
# Catálogo central de partes modulares, paletas de cores,
# presets canônicos (Gon, Killua, Kurapika, Leorio) e gerador
# aleatório de NPCs e personagens com regras de estilo.
#
# ============================================================

const HAIR_STYLES: Array[Dictionary] = [
	{"id": "hair_gon_01", "name": "Espetado Hunter (Gon)", "layer": "hair_front", "color": Color(0.08, 0.12, 0.08, 1.0)},
	{"id": "hair_killua_01", "name": "Desfiado Rebelde (Killua)", "layer": "hair_front", "color": Color(0.92, 0.94, 0.98, 1.0)},
	{"id": "hair_kurapika_01", "name": "Médio Sedoso (Kurapika)", "layer": "hair_front", "color": Color(0.98, 0.88, 0.35, 1.0)},
	{"id": "hair_leorio_01", "name": "Curto Social (Leorio)", "layer": "hair_front", "color": Color(0.12, 0.10, 0.08, 1.0)},
	{"id": "hair_ponytail_01", "name": "Rabo de Cavalo Marcial", "layer": "hair_front", "color": Color(0.2, 0.15, 0.1, 1.0)},
	{"id": "hair_afro_01", "name": "Volume Urbano", "layer": "hair_front", "color": Color(0.15, 0.1, 0.05, 1.0)},
	{"id": "hair_bald_01", "name": "Careca Mestre de Nen", "layer": "none", "color": Color.WHITE}
]

const SHIRT_STYLES: Array[Dictionary] = [
	{"id": "shirt_hunter_01", "name": "Camiseta Hunter Verde", "color": Color(0.18, 0.58, 0.25, 1.0)},
	{"id": "shirt_tank_01", "name": "Regata de Treino Azul", "color": Color(0.15, 0.35, 0.75, 1.0)},
	{"id": "shirt_suit_01", "name": "Camisa Social com Gravata", "color": Color(0.95, 0.95, 0.95, 1.0)},
	{"id": "shirt_hoodie_01", "name": "Moletom Casual", "color": Color(0.55, 0.25, 0.65, 1.0)},
	{"id": "shirt_tabard_01", "name": "Túnica Kurta Cerimonial", "color": Color(0.15, 0.35, 0.85, 1.0)},
	{"id": "shirt_dark_01", "name": "Camiseta Tática Preta", "color": Color(0.15, 0.15, 0.18, 1.0)}
]

const PANTS_STYLES: Array[Dictionary] = [
	{"id": "pants_hunter_01", "name": "Shorts de Aventura Verde", "color": Color(0.15, 0.48, 0.22, 1.0)},
	{"id": "pants_shorts_01", "name": "Bermuda Folgada", "color": Color(0.2, 0.2, 0.28, 1.0)},
	{"id": "pants_suit_01", "name": "Calça Social Elegante", "color": Color(0.12, 0.15, 0.25, 1.0)},
	{"id": "pants_combat_01", "name": "Calça Cargo de Combate", "color": Color(0.35, 0.38, 0.30, 1.0)},
	{"id": "pants_white_01", "name": "Calça Branca Tradicional", "color": Color(0.92, 0.92, 0.95, 1.0)}
]

const ACCESSORY_STYLES: Array[Dictionary] = [
	{"id": "none", "name": "Nenhum Acessório", "color": Color.WHITE},
	{"id": "acc_hunter_license", "name": "Licença Hunter no Peito", "color": Color(1.0, 0.85, 0.2, 1.0)},
	{"id": "acc_sunglasses_01", "name": "Óculos Escuros Redondos", "color": Color(0.1, 0.1, 0.1, 1.0)},
	{"id": "acc_earring_kurta", "name": "Brinco de Rubi Kurta", "color": Color(0.85, 0.15, 0.2, 1.0)},
	{"id": "acc_bandage_face", "name": "Curativo de Batalha", "color": Color(0.9, 0.85, 0.75, 1.0)}
]

const SKIN_TONES: Array[Color] = [
	Color(1.0, 0.88, 0.76, 1.0),   # Tom Claro Padrão
	Color(0.95, 0.82, 0.68, 1.0),  # Tom Claro Quente
	Color(0.85, 0.68, 0.52, 1.0),  # Tom Bronzeado
	Color(0.68, 0.50, 0.38, 1.0),  # Tom Morena
	Color(0.48, 0.34, 0.24, 1.0),  # Tom Escuro Intenso
	Color(0.92, 0.92, 0.98, 1.0)   # Tom Pálido Zoldyck
]


# ============================================================
# PRESETS CANÔNICOS E ARQUÉTIPOS
# ============================================================

static func obter_preset(preset_name: String) -> Resource:
	var script_res = load("res://entities/character_creator/CharacterAppearance.gd")
	var app = script_res.new()
	
	match preset_name.to_upper():
		"GON":
			app.character_id = "preset_gon"
			app.name = "Gon Freecss"
			app.body_id = "body_male_01"
			app.skin_tone = Color(1.0, 0.88, 0.76, 1.0)
			app.hair_id = "hair_gon_01"
			app.hair_color = Color(0.08, 0.14, 0.08, 1.0)
			app.eyes_color = Color(0.55, 0.35, 0.15, 1.0)
			app.shirt_id = "shirt_hunter_01"
			app.shirt_color = Color(0.18, 0.58, 0.25, 1.0)
			app.pants_id = "pants_hunter_01"
			app.pants_color = Color(0.15, 0.48, 0.22, 1.0)
			app.shoes_id = "shoes_boots_01"
			app.shoes_color = Color(0.2, 0.45, 0.2, 1.0)
			app.accessory_id = "acc_hunter_license"
			
		"KILLUA":
			app.character_id = "preset_killua"
			app.name = "Killua Zoldyck"
			app.body_id = "body_male_01"
			app.skin_tone = Color(0.95, 0.94, 0.98, 1.0)
			app.hair_id = "hair_killua_01"
			app.hair_color = Color(0.94, 0.95, 0.98, 1.0)
			app.eyes_color = Color(0.15, 0.35, 0.85, 1.0)
			app.shirt_id = "shirt_tank_01"
			app.shirt_color = Color(0.18, 0.22, 0.45, 1.0)
			app.pants_id = "pants_shorts_01"
			app.pants_color = Color(0.22, 0.22, 0.28, 1.0)
			app.shoes_id = "shoes_boots_01"
			app.shoes_color = Color(0.45, 0.25, 0.55, 1.0)
			app.accessory_id = "none"
			
		"KURAPIKA":
			app.character_id = "preset_kurapika"
			app.name = "Kurapika"
			app.body_id = "body_male_01"
			app.skin_tone = Color(1.0, 0.92, 0.82, 1.0)
			app.hair_id = "hair_kurapika_01"
			app.hair_color = Color(0.98, 0.88, 0.35, 1.0)
			app.eyes_color = Color(0.85, 0.15, 0.2, 1.0) # Olhos Escarlates
			app.shirt_id = "shirt_tabard_01"
			app.shirt_color = Color(0.15, 0.35, 0.85, 1.0)
			app.pants_id = "pants_white_01"
			app.pants_color = Color(0.95, 0.95, 0.98, 1.0)
			app.shoes_id = "shoes_boots_01"
			app.shoes_color = Color(0.25, 0.25, 0.55, 1.0)
			app.accessory_id = "acc_earring_kurta"
			
		"LEORIO":
			app.character_id = "preset_leorio"
			app.name = "Leorio Paradinight"
			app.body_id = "body_male_01"
			app.skin_tone = Color(0.92, 0.78, 0.65, 1.0)
			app.hair_id = "hair_leorio_01"
			app.hair_color = Color(0.12, 0.10, 0.08, 1.0)
			app.eyes_color = Color(0.2, 0.15, 0.1, 1.0)
			app.shirt_id = "shirt_suit_01"
			app.shirt_color = Color(0.95, 0.95, 0.95, 1.0)
			app.pants_id = "pants_suit_01"
			app.pants_color = Color(0.12, 0.15, 0.25, 1.0)
			app.shoes_id = "shoes_boots_01"
			app.shoes_color = Color(0.1, 0.1, 0.1, 1.0)
			app.accessory_id = "acc_sunglasses_01"
			
		_:
			# Default Hunter Custom
			app = obter_preset("GON")
			app.character_id = "player_custom"
			app.name = "Novo Hunter"
			
	return app


# ============================================================
# GERADOR DE APARÊNCIA ALEATÓRIA
# ============================================================

static func gerar_aparencia_aleatoria() -> Resource:
	var script_res = load("res://entities/character_creator/CharacterAppearance.gd")
	var app = script_res.new()
	app.character_id = "npc_%d" % randi()
	app.skin_tone = SKIN_TONES[randi() % SKIN_TONES.size()]
	
	var hair = HAIR_STYLES[randi() % HAIR_STYLES.size()]
	app.hair_id = hair["id"]
	app.hair_color = hair.get("color", Color(0.2, 0.15, 0.1, 1.0))
	
	var shirt = SHIRT_STYLES[randi() % SHIRT_STYLES.size()]
	app.shirt_id = shirt["id"]
	app.shirt_color = shirt.get("color", Color.WHITE)
	
	var pants = PANTS_STYLES[randi() % PANTS_STYLES.size()]
	app.pants_id = pants["id"]
	app.pants_color = pants.get("color", Color.WHITE)
	
	var acc = ACCESSORY_STYLES[randi() % ACCESSORY_STYLES.size()]
	app.accessory_id = acc["id"]
	app.accessory_color = acc.get("color", Color.WHITE)
	
	app.shoes_id = "shoes_boots_01"
	app.shoes_color = Color(0.15, 0.15, 0.15, 1.0)
	
	return app
