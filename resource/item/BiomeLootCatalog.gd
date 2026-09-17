class_name BiomeLootCatalog
extends RefCounted

# ============================================================
# HUNTER ONLINE — DROPS RAROS POR BIOMA
# ============================================================
# 1 drop raro característico por bioma (chance baixa em kills).
# ============================================================

const DROPS_POR_BIOMA: Dictionary = {
	"forest": {
		"item_id": "presa_lobo_encantada",
		"nome": "Presa de Lobo Encantada",
		"chance": 0.08,
		"equip_id": "amuleto_forca",  # mapeia para equipamento existente se item custom ausente
		"toast": "Presa rara do bosque!",
	},
	"ruins": {
		"item_id": "fragmento_aura_antiga",
		"nome": "Fragmento de Aura Antiga",
		"chance": 0.07,
		"equip_id": "anel_aura",
		"toast": "Fragmento de aura das ruínas!",
	},
	"city": {
		"item_id": "plaqueta_contrabando",
		"nome": "Plaqueta de Contrabando",
		"chance": 0.06,
		"equip_id": "escudo_leve",
		"toast": "Plaqueta de mercado negro!",
	},
	"dungeon": {
		"item_id": "nucleo_sentinela",
		"nome": "Núcleo de Sentinela",
		"chance": 0.09,
		"equip_id": "varinha_canalizadora",
		"toast": "Núcleo de sentinela!",
	},
	"arena": {
		"item_id": "faixa_campeao",
		"nome": "Faixa do Campeão",
		"chance": 0.07,
		"equip_id": "faixa_concentracao",
		"toast": "Faixa do campeão da arena!",
	},
}


static func resolver_bioma_cena(scene_path: String) -> String:
	var p: String = scene_path.to_lower()
	if "yorknew" in p or "lobby" in p or "associacao" in p or "house" in p:
		return "city"
	if "arena" in p or "celestial" in p:
		return "arena"
	if "dungeon" in p or "ruina" in p or "zaban" in p or "exame" in p or "whale" in p or "maratona" in p:
		return "dungeon"
	if "ngl" in p or "continente" in p:
		return "ruins"
	if "kukuroo" in p or "greed" in p or "padokia" in p or "floresta" in p:
		return "forest"
	return ""


static func tentar_drop_raro(parent: Node, world_pos: Vector2, scene_path: String = "", bonus_chance: float = 0.0) -> Dictionary:
	if parent == null:
		return {"sucesso": false}
	var path: String = scene_path
	if path.is_empty() and parent.get_tree() != null and parent.get_tree().current_scene != null:
		path = parent.get_tree().current_scene.scene_file_path
	var bioma: String = resolver_bioma_cena(path)
	if bioma.is_empty() or not DROPS_POR_BIOMA.has(bioma):
		return {"sucesso": false, "bioma": bioma}
	var info: Dictionary = DROPS_POR_BIOMA[bioma]
	var chance: float = float(info.get("chance", 0.05)) + bonus_chance
	if randf() > chance:
		return {"sucesso": false, "bioma": bioma, "tentou": true}

	# Preferir item de equipamento real do catálogo
	var equip_id: String = str(info.get("equip_id", ""))
	var drop_id: String = equip_id if not equip_id.is_empty() else str(info.get("item_id", ""))
	if drop_id.is_empty():
		return {"sucesso": false}

	if LootDrop != null:
		LootDrop.spawn_item_drop(parent, world_pos + Vector2(randf_range(-8, 8), randf_range(-6, 6)), drop_id)
	elif PlayerData != null:
		PlayerData.adicionar_item(StringName(drop_id), 1)

	# Toast raro específico do bioma (além do feedback genérico do LootDrop)
	if EventBus != null:
		EventBus.emit_toast("💎 %s" % str(info.get("toast", "Drop raro!")), Color(1.0, 0.85, 0.35))

	return {
		"sucesso": true,
		"bioma": bioma,
		"item_id": drop_id,
		"nome": str(info.get("nome", drop_id)),
	}
