class_name FarmZoneCatalog
extends RefCounted

# ============================================================
# Catálogo canônico das farm zones Padokia (fatia 1).
# ============================================================

const FarmZoneScript = preload("res://resource/world/FarmZone.gd")

const ZONE_ESTRADA := &"farm_estrada_campos"
const ZONE_FLORESTA := &"farm_floresta_vestigios"
const ZONE_RUINAS := &"farm_ruinas_zaban_outer"


static func obter_todas() -> Array:
	return [
		criar_zona_estrada(),
		criar_zona_floresta(),
		criar_zona_ruinas(),
	]


static func obter_por_id(zone_id: StringName):
	for z in obter_todas():
		if z.zone_id == zone_id:
			return z
	return null


static func obter_para_mapa(scene_path: String):
	var norm := scene_path.replace("\\", "/")
	for z in obter_todas():
		if z == null:
			continue
		var path_z := str(z.map_scene_path)
		if path_z == norm or (not path_z.is_empty() and norm.ends_with(path_z.get_file())):
			return z
	return null


static func _entry(enemy_id: String, weight: float = 1.0, elite_chance: float = 0.1, force_hatsu: bool = false) -> Dictionary:
	return {
		"enemy_id": enemy_id,
		"weight": weight,
		"elite_chance": elite_chance,
		"force_hatsu": force_hatsu,
	}


static func _buff(item_id: String, chance: float, qtd: int = 1, elite_bonus: float = 0.08) -> Dictionary:
	return {
		"item_id": item_id,
		"chance": chance,
		"quantidade": qtd,
		"elite_bonus": elite_bonus,
	}


static func criar_zona_estrada():
	var z = FarmZoneScript.new()
	z.zone_id = ZONE_ESTRADA
	z.display_name = "Campos da Estrada Real"
	z.map_scene_path = "res://world/maps/estrada_padokia.tscn"
	z.level_min = 1
	z.level_max = 30
	z.max_alive = 7
	z.respawn_delay = 16.0
	z.spawn_rect = Rect2(60, 90, 680, 460)
	z.enemy_pool = [
		_entry("slime", 1.4, 0.05),
		_entry("rato_gigante", 1.1, 0.05),
		_entry("lobo_selvagem", 1.0, 0.08),
		_entry("javali_selvagem", 0.9, 0.08),
		_entry("ladrao_estrada", 1.0, 0.12),
		_entry("arqueiro_renegado", 0.7, 0.1),
		_entry("candidato_exame", 0.5, 0.15),
		_entry("iniciado_nen_sombrio", 0.35, 0.55, true),
	]
	z.buff_drop_table = [
		_buff("tonico_forca", 0.08, 1, 0.10),
		_buff("essencia_velocidade", 0.06, 1, 0.08),
		_buff("oleo_ken", 0.05, 1, 0.08),
	]
	return z


static func criar_zona_floresta():
	var z = FarmZoneScript.new()
	z.zone_id = ZONE_FLORESTA
	z.display_name = "Floresta dos Vestígios"
	z.map_scene_path = "res://world/maps/floresta_vestigios.tscn"
	z.level_min = 25
	z.level_max = 50
	z.max_alive = 8
	z.respawn_delay = 20.0
	z.spawn_rect = Rect2(70, 100, 660, 620)
	z.enemy_pool = [
		_entry("cao_cacador", 1.0, 0.1),
		_entry("serpente_sombra", 1.0, 0.12),
		_entry("macaco_carnivoro", 0.9, 0.1),
		_entry("urso_caverna", 0.7, 0.15),
		_entry("criatura_pantanal", 0.8, 0.12),
		_entry("bandido_renegado", 0.9, 0.15),
		_entry("fera_floresta", 1.1, 0.1),
		_entry("lobo_padokia", 1.0, 0.1),
		_entry("alfa_ninho_elite", 0.35, 0.7, true),
		_entry("iniciado_nen_sombrio", 0.4, 0.6, true),
	]
	z.buff_drop_table = [
		_buff("tonico_forca", 0.07, 1, 0.12),
		_buff("oleo_ken", 0.09, 1, 0.12),
		_buff("ampola_aura", 0.07, 1, 0.10),
		_buff("essencia_velocidade", 0.05, 1, 0.08),
	]
	return z


static func criar_zona_ruinas():
	var z = FarmZoneScript.new()
	z.zone_id = ZONE_RUINAS
	z.display_name = "Ruínas de Zaban (Exterior)"
	z.map_scene_path = "res://world/maps/dungeon_ruinas_zaban.tscn"
	z.level_min = 45
	z.level_max = 70
	z.max_alive = 6
	z.respawn_delay = 24.0
	z.spawn_rect = Rect2(60, 80, 520, 300)
	z.enemy_pool = [
		_entry("golem_pedra", 1.0, 0.15),
		_entry("sentinela_pedra", 1.2, 0.12),
		_entry("guardiao_elite", 0.6, 0.75, true),
		_entry("mafioso_yorknew", 0.8, 0.2),
		_entry("membro_trupe", 0.5, 0.55, true),
		_entry("mercenario_mafia", 0.7, 0.2),
		_entry("predador_miasma", 0.6, 0.25),
		_entry("lider_matilha_quimera", 0.25, 0.85, true),
	]
	z.buff_drop_table = [
		_buff("tonico_forca", 0.06, 1, 0.14),
		_buff("oleo_ken", 0.08, 1, 0.14),
		_buff("ampola_aura", 0.10, 1, 0.14),
		_buff("essencia_velocidade", 0.05, 1, 0.10),
		_buff("elixir_cacador", 0.03, 1, 0.08),
	]
	return z
