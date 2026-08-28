class_name RegiaoValePadokiaMap
extends "res://world/generator/RegionWorldGenerator.gd"

# ============================================================
# HUNTER ONLINE - REGIÃO PILOTO: VALE DE PADOKIA (512x512 TILES)
# ============================================================
#
# Região laboratório completa para validação de escala, densidade,
# exploração com técnicas de Nen (Gyo, Ko, Ten, Zetsu, Ren),
# atalhos desbloqueáveis (Backtracking), interiores e streaming modular.
#
# ============================================================

const PadokiaQuestCatalogScript = preload("res://resource/quest/PadokiaQuestCatalog.gd")

var _zonas_notificadas: Dictionary = {
	"vila": false,
	"estrada": false,
	"floresta": false,
	"ravina_ten": false,
	"caverna_secreta": false,
	"ruinas_dungeon": false
}


func _ready() -> void:
	super._ready()
	_garantir_dialogue_ui()
	_configurar_audio_ambiente()
	_inicializar_quests_padokia()
	_notificar_entrada_regiao()
	if QuestSystem != null:
		QuestSystem.sincronizar_inimigos_do_mapa(self)


func _inicializar_quests_padokia() -> void:
	# Iniciar a quest principal do Mestre Wing caso o jogador ainda não a possua
	if QuestSystem != null and QuestSystem.has_method("start_quest"):
		var quest_princ = PadokiaQuestCatalogScript.obter_quest_principal()
		if not PlayerData.is_quest_active(quest_princ) and not PlayerData.is_quest_completed(quest_princ):
			QuestSystem.start_quest(quest_princ)
			print("[RegiaoValePadokiaMap] Quest Principal iniciada: ", quest_princ.quest_name)


func _notificar_entrada_regiao() -> void:
	var hud = get_tree().get_first_node_in_group("player_hud")
	if hud != null and hud.has_method("exibir_notificacao"):
		hud.exibir_notificacao("🗺️ Você entrou no [Vale de Padokia] — Tier 1 (Hunter Iniciante)")


func _configurar_audio_ambiente() -> void:
	if AudioManager != null and AudioManager.has_method("tocar_bgm"):
		AudioManager.tocar_bgm("world_adventure")


func _garantir_dialogue_ui() -> void:
	var visual_dialogue = get_tree().get_first_node_in_group("visual_dialogue_ui")
	if visual_dialogue == null:
		var scene = load("res://ui/dialogue/VisualDialogueUI.tscn")
		if scene:
			var ui = scene.instantiate()
			add_child(ui)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_F3:
			var overlay = get_tree().get_first_node_in_group("content_debug_overlay") as CanvasLayer
			if overlay:
				overlay.visible = not overlay.visible
				print("[RegiaoValePadokiaMap] Debug Overlay F3: ", "Visível" if overlay.visible else "Oculto")


func _process(_delta: float) -> void:
	var pl = get_tree().get_first_node_in_group("player")
	if pl == null:
		return
		
	var px: float = pl.global_position.x
	var py: float = pl.global_position.y
	var hud = get_tree().get_first_node_in_group("player_hud")
	
	# Banners de Imersão e Notificação de Sub-Zonas em 8192x8192 px
	if px < 2100 and py >= 3000 and not _zonas_notificadas["vila"]:
		_zonas_notificadas["vila"] = true
		if hud and hud.has_method("exibir_notificacao"):
			hud.exibir_notificacao("🏡 Vila de Padokia — Zona Segura de Reabastecimento")
			
	elif px >= 2100 and px < 3500 and not _zonas_notificadas["estrada"]:
		_zonas_notificadas["estrada"] = true
		if hud and hud.has_method("exibir_notificacao"):
			hud.exibir_notificacao("🛣️ Estrada Real — Baixa Densidade (Travessia & Ponte)")
			
	elif px >= 3500 and px < 5600 and py < 5000 and not _zonas_notificadas["floresta"]:
		_zonas_notificadas["floresta"] = true
		if hud and hud.has_method("exibir_notificacao"):
			hud.exibir_notificacao("🌲 Floresta dos Vestígios — Média Densidade & Árvore Milenar")
			
	elif px >= 5200 and py >= 5200 and not _zonas_notificadas["ravina_ten"]:
		_zonas_notificadas["ravina_ten"] = true
		if hud and hud.has_method("exibir_notificacao"):
			hud.exibir_notificacao("☠️ Ravina da Névoa Corrosiva — PERIGO: Requer TEN ativo!")
			
	elif px >= 5800 and py <= 2400 and not _zonas_notificadas["ruinas_dungeon"]:
		_zonas_notificadas["ruinas_dungeon"] = true
		if hud and hud.has_method("exibir_notificacao"):
			hud.exibir_notificacao("🏛️ Ruínas do Santuário de Zaban — Dungeon & Altar Ancestral")
