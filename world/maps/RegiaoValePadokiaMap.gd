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


var canvas_modulate: CanvasModulate = null


func _ready() -> void:
	super._ready()
	_garantir_dialogue_ui()
	_configurar_audio_ambiente()
	_configurar_iluminacao_e_clima()
	_inicializar_quests_padokia()
	_notificar_entrada_regiao()
	_checar_cutscene_chegada()
	if QuestSystem != null:
		QuestSystem.sincronizar_inimigos_do_mapa(self)
	MapAtmosphereDecorator.attach(self, MapAtmosphereDecorator.MapKind.VALE)


func _configurar_iluminacao_e_clima() -> void:
	if canvas_modulate == null:
		canvas_modulate = CanvasModulate.new()
		canvas_modulate.name = "AmbientLightModulate"
		add_child(canvas_modulate)

	_atualizar_luz_ambiente()

	if EventBus != null:
		if not EventBus.time_phase_changed.is_connected(_on_time_phase_changed):
			EventBus.time_phase_changed.connect(_on_time_phase_changed)
	if WorldStateManager != null:
		if not WorldStateManager.clima_alterado.is_connected(_on_clima_alterado):
			WorldStateManager.clima_alterado.connect(_on_clima_alterado)


func _on_time_phase_changed(_phase_name: String) -> void:
	_atualizar_luz_ambiente()


func _on_clima_alterado(_novo_clima: int, _nome: String) -> void:
	_atualizar_luz_ambiente()


func _atualizar_luz_ambiente() -> void:
	if canvas_modulate == null or not is_inside_tree():
		return
	var cor_luz: Color = Color.WHITE
	if TimeManager != null and TimeManager.has_method("get_ambient_light_color"):
		cor_luz = TimeManager.get_ambient_light_color()
	
	if WorldStateManager != null:
		match WorldStateManager.clima_atual:
			WorldStateManager.Clima.CHUVA:
				cor_luz = cor_luz.lerp(Color(0.65, 0.75, 0.85, 1.0), 0.4)
			WorldStateManager.Clima.NEBLINA:
				cor_luz = cor_luz.lerp(Color(0.80, 0.82, 0.85, 1.0), 0.3)
			WorldStateManager.Clima.TEMPESTADE_AURA:
				cor_luz = cor_luz.lerp(Color(0.9, 0.7, 1.2, 1.0), 0.35)

	var tween = create_tween()
	if tween != null:
		tween.tween_property(canvas_modulate, "color", cor_luz, 2.5)


func _checar_cutscene_chegada() -> void:
	if PlayerData == null:
		return
	if not PlayerData.quest_states.get("chegada_padokia_vista", false):
		PlayerData.quest_states["chegada_padokia_vista"] = true
		get_tree().create_timer(1.0).timeout.connect(func():
			var wing_node = find_child("Mestre_Wing", true, false)
			if wing_node != null and wing_node.has_method("falar_balao"):
				wing_node.falar_balao("Bem-vindo ao Vale de Padokia! Sinta o fluxo de aura que percorre esta terra ancestral...", 4.5)
		)


func _inicializar_quests_padokia() -> void:
	# Iniciar a quest principal do Mestre Wing caso o jogador ainda não a possua
	if QuestSystem != null and QuestSystem.has_method("start_quest"):
		var quest_princ = PadokiaQuestCatalogScript.obter_quest_principal()
		if not PlayerData.is_quest_active(quest_princ) and not PlayerData.is_quest_completed(quest_princ):
			QuestSystem.start_quest(quest_princ)
			print("[RegiaoValePadokiaMap] Quest Principal iniciada: ", quest_princ.quest_name)

		var quest_inv = PadokiaQuestCatalogScript.obter_quest_investigacao_furto()
		if not PlayerData.is_quest_active(quest_inv) and not PlayerData.is_quest_completed(quest_inv):
			# Oferecida ao entrar na região — o 1º objetivo é falar com o mercador
			QuestSystem.start_quest(quest_inv)
			print("[RegiaoValePadokiaMap] Quest Investigativa iniciada: ", quest_inv.quest_name)

	_popular_pistas_furto_gyo()


func _popular_pistas_furto_gyo() -> void:
	# Trilha Gyo na vila (~tile 100–110 / y 250) — coords mundo 16px
	NenSensorFactory.criar_gyo(
		self,
		"PistaFurtoJanela",
		Vector2(108 * 16, 252 * 16),
		&"pista_furto_janela",
		"Marca na Janela do Empório",
		"Resíduo de Nen de Intensificação na moldura. Alguém forçou a janela com aura concentrada.",
		"Intensificação",
		1,
		Color(1.0, 0.75, 0.35, 0.9)
	)
	NenSensorFactory.criar_gyo(
		self,
		"PistaFurtoPegada",
		Vector2(118 * 16, 258 * 16),
		&"pista_furto_pegada",
		"Pegada de Aura na Rua",
		"Rastro diluído de aura seguindo para o beco norte. O ladrão estava com pressa.",
		"Especialização",
		1,
		Color(0.45, 0.9, 1.0, 0.9)
	)
	NenSensorFactory.criar_gyo(
		self,
		"PistaFurtoEsconderijo",
		Vector2(95 * 16, 248 * 16),
		&"pista_furto_esconderijo",
		"Esconderijo sob o Barril",
		"Fragmento de pedra Nen oculto sob um barril. O furto foi amador — a aura ainda vibra.",
		"Materialização",
		1,
		Color(0.7, 1.0, 0.55, 0.9)
	)


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
