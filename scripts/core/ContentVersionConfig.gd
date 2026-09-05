class_name ContentVersionConfig
extends RefCounted

# ============================================================
# HUNTER ONLINE — CONTENT VERSIONING & MIGRATION CONFIG (FASE L)
# ============================================================
#
# Centraliza os três eixos de versionamento do projeto:
# 1. GAME_VERSION: Versão do executável e motor de jogo (Godot 4.6).
# 2. CONTENT_VERSION: Versão do pipeline de dados, sagas e expansões.
# 3. SAVE_VERSION: Schema estrutural dos arquivos de save do jogador.
#
# Fornece o motor de migração retrocompatível automática.
# ============================================================

const GAME_VERSION: String = "1.0.0"
const CONTENT_VERSION: String = "1.2.0"
const SAVE_VERSION: String = "2.4"


static func get_version_info() -> Dictionary:
	return {
		"game_version": GAME_VERSION,
		"content_version": CONTENT_VERSION,
		"save_version": SAVE_VERSION
	}


static func migrate_save_data(data: Dictionary) -> Dictionary:
	var migrated: Dictionary = data.duplicate(true)
	var original_ver: String = str(migrated.get("version", "1.0"))

	# Se já estiver na versão mais recente, nada a migrar
	if original_ver == SAVE_VERSION:
		return migrated

	print("[SaveMigration] 🔄 Iniciando migração de Save Schema: v%s -> v%s" % [original_ver, SAVE_VERSION])

	# 1. Injetar coleções do Hunter Códex se ausentes
	if not migrated.has("collections"):
		migrated["collections"] = {
			"hatsu": [],
			"equipment": [],
			"titles": [],
			"achievements": [],
			"npcs": [],
			"regions": [],
			"bosses": [],
			"secrets": []
		}

	# 2. Injetar Memórias de NPCs se ausentes
	if not migrated.has("npc_memories"):
		migrated["npc_memories"] = {
			"version": "1.0",
			"memories": {}
		}

	# 3. Injetar Eventos Vivos se ausentes
	if not migrated.has("live_events"):
		migrated["live_events"] = {
			"active_events": {},
			"event_history": {}
		}

	# 4. Injetar Rotas de Viagem se ausentes
	if not migrated.has("unlocked_routes"):
		migrated["unlocked_routes"] = []

	# 5. Garantir flags de Sagas Modulares no story_data
	if migrated.has("story_data") and migrated["story_data"] is Dictionary:
		var sd: Dictionary = migrated["story_data"]
		if not sd.has("current_custom_saga_id"):
			sd["current_custom_saga_id"] = ""

	# 6. Atualizar versão final do save
	migrated["version"] = SAVE_VERSION
	migrated["content_version"] = CONTENT_VERSION
	migrated["migrated_from"] = original_ver
	migrated["migration_timestamp"] = Time.get_datetime_string_from_system()

	print("[SaveMigration] ✅ Migração para v%s concluída com sucesso sem perda de dados!" % SAVE_VERSION)
	return migrated
