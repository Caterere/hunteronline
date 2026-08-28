class_name BlackWhale1Map
extends Node2D
const StoryGate = preload("res://world/components/StoryGate.gd")

# ============================================================
# HUNTER ONLINE - MAPA DO BLACK WHALE 1 (ARCO 9 - 26 ETAPAS)
# ============================================================
#
# Coordena os eventos do Arco 9 (Guerra de Sucessão de Kakin):
# - Popula NPCs: Kurapika, Rainha Oito, Vaso Sagrado, Hinrigh, Chrollo, Hisoka.
# - Configura inimigos: Bestas Parasitárias, Assassinos Heil-Ly, Tserriednich e Boss Final.
# - STORY GATE: Exige conclusão das 26 etapas antes da Consagração Final no Lobby.
#
# ============================================================

var _marcos_notificados: Dictionary = {
	"conves_1": false,
	"conves_3": false,
	"aposentos": false,
	"porao": false
}


func _ready() -> void:
	_garantir_dialogue_ui()
	_popular_npcs_arco9()
	_configurar_inimigos()
	_configurar_portal_conclusao()
	_garantir_quest_ativa()
	if QuestSystem != null:
		QuestSystem.sincronizar_inimigos_do_mapa(self)


func _process(_delta: float) -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		return

	var px: float = player.global_position.x
	var hud = get_tree().get_first_node_in_group("player_hud")

	if px >= 0 and px < 1200 and not _marcos_notificados["conves_1"]:
		_marcos_notificados["conves_1"] = true
		if hud and hud.has_method("exibir_notificacao"):
			hud.exibir_notificacao("🚢 Convés 1 Real — A câmara blindada da Rainha Oito e do Príncipe Woble.")

	elif px >= 1200 and px < 2400 and not _marcos_notificados["conves_3"]:
		_marcos_notificados["conves_3"] = true
		if hud and hud.has_method("exibir_notificacao"):
			hud.exibir_notificacao("🏙️ Conveses Intermediários — Território das 3 famílias da Máfia de Kakin.")

	elif px >= 2400 and px < 3600 and not _marcos_notificados["aposentos"]:
		_marcos_notificados["aposentos"] = true
		if hud and hud.has_method("exibir_notificacao"):
			hud.exibir_notificacao("👑 Aposentos do 4º Príncipe Tserriednich — O covil da Besta de Dupla Face!")

	elif px >= 3600 and not _marcos_notificados["porao"]:
		_marcos_notificados["porao"] = true
		if hud and hud.has_method("exibir_notificacao"):
			hud.exibir_notificacao("⚓ Conveses Profundos — Caçada sangrenta da Trupe Fantasma e Hisoka!")


func _garantir_dialogue_ui() -> void:
	var visual_dialogue = get_tree().get_first_node_in_group("visual_dialogue_ui")
	if visual_dialogue == null:
		var scene = load("res://ui/dialogue/VisualDialogueUI.tscn")
		if scene:
			var ui = scene.instantiate()
			add_child(ui)


func _garantir_quest_ativa() -> void:
	if QuestSystem != null and QuestSystem.active_quests.is_empty():
		QuestSystem.garantir_quest_do_arco(9)


func _popular_npcs_arco9() -> void:
	var scn_npc = load("res://entities/npc/NPC.tscn")
	if scn_npc == null:
		print("[BlackWhale1Map] ERRO: NPC.tscn não encontrado!")
		return

	# 1. Kurapika (Convés 1)
	if get_node_or_null("Kurapika") == null:
		var scn_kurapika = load("res://entities/npc/kurapika/Kurapika.tscn")
		var kurapika
		if scn_kurapika:
			kurapika = scn_kurapika.instantiate()
		else:
			kurapika = scn_npc.instantiate()
			var spr = kurapika.get_node_or_null("Sprite2D") as Sprite2D
			if spr:
				spr.texture = load("res://assets/sprites/characters/player.png")
				spr.hframes = 6
				spr.vframes = 10
				spr.frame = 0
				spr.position = Vector2(0, -17)
				spr.modulate = Color(1.0, 0.3, 0.3, 1.0)
		
		kurapika.name = "Kurapika"
		kurapika.position = Vector2(150, -60)
		kurapika.npc_name = "Kurapika"
		kurapika.fala_padrao = "Meu Emperor Time está ativo. Protegerei o bebê Woble a qualquer custo enquanto monitoro os príncipes com o Stealth Dolphin."
		add_child(kurapika)

	# 2. Rainha Oito & Príncipe Woble
	if get_node_or_null("RainhaOito") == null:
		var oito = scn_npc.instantiate()
		oito.name = "RainhaOito"
		oito.position = Vector2(300, -80)
		var spr = oito.get_node_or_null("Sprite2D") as Sprite2D
		if spr:
			spr.texture = load("res://assets/sprites/characters/player.png")
			spr.hframes = 6
			spr.vframes = 10
			spr.frame = 0
			spr.position = Vector2(0, -17)
			spr.modulate = Color(0.9, 0.8, 0.6, 1.0)
		oito.npc_name = "Rainha Oito & Príncipe Woble"
		oito.fala_padrao = "Por favor, salvem meu bebê... Ele é apenas um recém-nascido no meio desta sangrenta guerra de sucessão!"
		add_child(oito)

	# 3. Vaso Sagrado de Kakin (Objeto)
	if get_node_or_null("VasoKakin") == null:
		var vaso = scn_npc.instantiate()
		vaso.name = "VasoKakin"
		vaso.position = Vector2(450, -50)
		vaso.npc_name = "Vaso Sagrado de Kakin"
		vaso.fala_padrao = "O Vaso Sagrado dos Primeiros Reis Hui Guo Rou. Ele alimenta as Bestas Parasitárias com o desejo do trono."
		add_child(vaso)

	# 4. Hinrigh Biganduffno (Máfia Xi-Yu)
	if get_node_or_null("Hinrigh") == null:
		var hinrigh = scn_npc.instantiate()
		hinrigh.name = "Hinrigh"
		hinrigh.position = Vector2(1600, -80)
		var spr = hinrigh.get_node_or_null("Sprite2D") as Sprite2D
		if spr:
			spr.texture = load("res://assets/sprites/characters/player.png")
			spr.hframes = 6
			spr.vframes = 10
			spr.frame = 0
			spr.position = Vector2(0, -17)
			spr.modulate = Color(0.4, 0.4, 0.6, 1.0)
		hinrigh.npc_name = "Hinrigh (Família Xi-Yu)"
		hinrigh.fala_padrao = "Meu Hatsu 'Biohazard' pode transformar revólveres em pombos e algemas em gatos. Vamos conter a loucura da família Heil-Ly."
		add_child(hinrigh)

	# 5. Chrollo Lucilfer (Conveses Profundos)
	if get_node_or_null("Chrollo") == null:
		var scn_chrollo = load("res://entities/npc/chrollo/Chrollo.tscn")
		var chrollo
		if scn_chrollo:
			chrollo = scn_chrollo.instantiate()
		else:
			chrollo = scn_npc.instantiate()
			var spr = chrollo.get_node_or_null("Sprite2D") as Sprite2D
			if spr:
				spr.texture = load("res://assets/sprites/characters/player.png")
				spr.hframes = 6
				spr.vframes = 10
				spr.frame = 0
				spr.position = Vector2(0, -17)
				spr.modulate = Color(0.1, 0.1, 0.1, 1.0)
		
		chrollo.name = "Chrollo"
		chrollo.position = Vector2(3600, -100)
		chrollo.npc_name = "Chrollo Lucilfer"
		chrollo.fala_padrao = "Hisoka está a bordo deste navio... e a Trupe Fantasma não descansará até que a cabeça do palhaço role pelo chão."
		add_child(chrollo)


func _configurar_inimigos() -> void:
	var configs = {
		"GuardaRealKakin1": {"id": &"besta_parasita", "nome": "Besta Parasita Guardiã", "etapa": 6},
		"GuardaRealKakin2": {"id": &"assassino_heilly", "nome": "Assassino da Família Heil-Ly", "etapa": 11},
		"CapangaTserriednich": {"id": &"besta_tserriednich", "nome": "Besta Guardiã de Tserriednich", "etapa": 18},
		"BestaNenGuardiã": {"id": &"tserriednich_boss", "nome": "Príncipe Tserriednich Boss", "etapa": 19},
		"AssassinoMafia": {"id": &"boss_final_kakin", "nome": "Comandante da Conspiração Boss", "etapa": 24}
	}
	
	for nome in configs:
		var node = get_node_or_null(nome)
		if node != null:
			var es = node.get_node_or_null("EnemySystem")
			if es != null:
				es.is_mission_enemy = true
				es.quest_arc = 9
				es.quest_etapa = configs[nome]["etapa"]
				es.enemy_id = configs[nome]["id"]
				es.enemy_name = configs[nome]["nome"]
				if not es.died.is_connected(QuestSystem.register_enemy_kill):
					es.died.connect(QuestSystem.register_enemy_kill)
				if QuestSystem != null:
					QuestSystem.registrar_spawn_posicao_missao(es.enemy_id, node.global_position, 9, es.quest_etapa, -1, null, es.enemy_name)


func _configurar_portal_conclusao() -> void:
	var portal = get_node_or_null("PortalLobby") as MapTransitionArea
	if portal != null:
		portal.portal_name = "Lobby Central (Conclusão Suprema)"
		portal.map_subtitle = "Vitória Total — Modo História 100% Concluído!"
		portal.story_gate = StoryGate.new(9, 26, true)
		portal.story_gate.gate_title = "Consagração do Maior Caçador da História"
		portal.story_gate.default_locked_message = "Você precisa concluir todas as 26 etapas da Guerra de Sucessão de Kakin antes de eternizar sua lenda!"
		portal.callback_dialogo_previo = func(mudar_cena_cb: Callable):
			StoryCutsceneManager.executar_guerra_sucessao_cutscene(get_tree(), mudar_cena_cb)
