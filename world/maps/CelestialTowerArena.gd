class_name CelestialTowerArena
extends Node2D

# ============================================================
# HUNTER ONLINE - CELESTIAL TOWER (TORRE CELESTIAL - HEAVENS ARENA)
# ============================================================
#
# Escalada infinita e progressiva de andares da Torre Celestial:
# - Andares 1 a 199: Lutas de artes marciais normais com premiação em Jenny.
# - Andar 200: O Batismo de Nen (Exige Nen ativo / Ten para sobreviver à intenção assassina).
# - Andares 200 a 250+: Mestres de Andar (Floor Masters) e usuários de Hatsu avançado.
#
# ============================================================

@onready var player: CharacterBody2D = $Player
var andar_atual: int = 1
var inimigos_restantes: int = 0
var painel_torre: PanelContainer = null
var lbl_andar_info: Label = null
var lbl_recompensa_info: Label = null
var em_combate: bool = false


const InteractionComponent = preload("res://entities/components/InteractionComponent.gd")

func _ready() -> void:
	if AudioManager != null:
		AudioManager.tocar_musica("legend_of_the_martial_artist")

	# Progresso unificado: UI da Arena + torre real
	var ui_andar: int = int(PlayerData.attributes.get("andar_arena", 1)) if PlayerData != null else 1
	andar_atual = maxi(1, maxi(ui_andar, PlayerData.torre_andar_atual if PlayerData != null else 1))
	_sincronizar_progresso_andar(andar_atual)
	print("=================================")
	print("[CelestialTower] BEM-VINDO À TORRE CELESTIAL! ANDAR: ", andar_atual)
	print("=================================")
	_criar_ui_torre()
	_criar_elevador_saida()
	_iniciar_andar(andar_atual)


func _sincronizar_progresso_andar(andar: int) -> void:
	if PlayerData == null:
		return
	PlayerData.torre_andar_atual = andar
	PlayerData.attributes["andar_arena"] = andar


func _obter_cena_retorno() -> String:
	var fallback := "res://world/lobby.tscn"
	if PlayerData == null:
		return fallback
	var ret = str(PlayerData.attributes.get("torre_cena_retorno", ""))
	if ret.is_empty() or not ResourceLoader.exists(ret):
		return fallback
	return ret


func _criar_elevador_saida() -> void:
	var elevador := StaticBody2D.new()
	elevador.name = "ElevadorSaida"
	elevador.position = Vector2(40, 140)

	var lbl := Label.new()
	lbl.text = "🚪 Elevador\n[E] Sair do Ringue"
	lbl.position = Vector2(-50, -28)
	lbl.custom_minimum_size = Vector2(100, 14)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.add_theme_font_size_override("font_size", 3)
	lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
	lbl.add_theme_color_override("font_shadow_color", Color.BLACK)
	elevador.add_child(lbl)

	var inter = InteractionComponent.new()
	inter.name = "InteractionComponent"
	inter.interaction_text = "[E] Sair do Ringue"
	inter.interaction_radius = 20.0
	inter.interacted.connect(func(_p):
		var destino := _obter_cena_retorno()
		var nome := "Arena Celestial" if "arena_celestial" in destino else "Capital dos Caçadores"
		var sub := "Corredor dos Andares" if "arena_celestial" in destino else "Hunter Plaza — Hub Central"
		var trans = get_node_or_null("/root/SceneTransition")
		if trans != null and trans.has_method("mudar_cena"):
			trans.mudar_cena(destino, nome, sub)
		else:
			get_tree().change_scene_to_file(destino)
	)
	elevador.add_child(inter)
	add_child(elevador)


func _criar_ui_torre() -> void:
	painel_torre = PanelContainer.new()
	painel_torre.position = Vector2(10, 10)
	painel_torre.custom_minimum_size = Vector2(150, 45)
	
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.06, 0.08, 0.14, 0.92)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.border_color = Color(1.0, 0.8, 0.2, 1.0)
	style.corner_radius_top_left = 3
	style.corner_radius_top_right = 3
	style.corner_radius_bottom_right = 3
	style.corner_radius_bottom_left = 3
	painel_torre.add_theme_stylebox_override("panel", style)
	add_child(painel_torre)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 2)
	painel_torre.add_child(vbox)

	lbl_andar_info = Label.new()
	lbl_andar_info.text = "🏯 TORRE CELESTIAL: ANDAR %d" % andar_atual
	lbl_andar_info.add_theme_font_size_override("font_size", 4)
	lbl_andar_info.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
	vbox.add_child(lbl_andar_info)

	lbl_recompensa_info = Label.new()
	lbl_recompensa_info.text = "Inimigos: 0 | Prêmio: 10.000 J"
	lbl_recompensa_info.add_theme_font_size_override("font_size", 3)
	lbl_recompensa_info.add_theme_color_override("font_color", Color(0.4, 1.0, 0.4))
	vbox.add_child(lbl_recompensa_info)


func _iniciar_andar(andar: int) -> void:
	andar_atual = andar
	_sincronizar_progresso_andar(andar_atual)
	lbl_andar_info.text = "🏯 TORRE CELESTIAL: ANDAR %d" % andar_atual
	
	# Verificar Batismo do 200º Andar
	if andar == 200:
		var tem_nen := PlayerData != null and PlayerData.despertou_nen
		if not tem_nen:
			_falha_batismo_nen()
			return

	var premio_jenny: int = andar * 800 + 2000
	lbl_recompensa_info.text = "Andar %d | Prêmio: %s J" % [andar, Economy.formatar_numero(premio_jenny)]
	
	_spawnar_desafiantes(andar)


func _falha_batismo_nen() -> void:
	var hud = get_tree().get_first_node_in_group("player_hud")
	if hud and hud.has_method("exibir_notificacao"):
		hud.exibir_notificacao("⚠️ A Barreira Assassina de Nen bloqueou sua passagem! Desperte o Nen antes do 200º Andar!")
	get_tree().create_timer(3.0).timeout.connect(func():
		var destino := _obter_cena_retorno()
		var trans = get_node_or_null("/root/SceneTransition")
		if trans != null and trans.has_method("mudar_cena"):
			trans.mudar_cena(destino, "Retorno", "Batismo de Nen incompleto")
		else:
			get_tree().change_scene_to_file(destino)
	)


func _spawnar_desafiantes(andar: int) -> void:
	inimigos_restantes = 1 if andar % 10 == 0 else min(3, 1 + (andar / 50))
	
	for i in range(inimigos_restantes):
		var inimigo = _criar_gladiador(andar, i)
		add_child(inimigo)
		inimigo.global_position = Vector2(150 + i * 60, 100 + (i % 2) * 40)


func _criar_gladiador(andar: int, idx: int) -> Node2D:
	var enemy_scene = load("res://scripts/systems/EnemySystem/Enemy.tscn")
	var body: CharacterBody2D
	if enemy_scene:
		body = enemy_scene.instantiate() as CharacterBody2D
	else:
		body = CharacterBody2D.new()
	body.name = "Gladiador_Andar_%d_%d" % [andar, idx]
	body.add_to_group("enemies")

	var sprite: Sprite2D = body.get_node_or_null("Sprite2D")
	if sprite != null:
		if andar >= 200:
			sprite.modulate = Color(1.0, 0.3, 0.4, 1.0) # Usuário de Nen
		elif andar >= 100:
			sprite.modulate = Color(0.3, 0.8, 1.0, 1.0)
		else:
			sprite.modulate = Color(0.9, 0.9, 0.5, 1.0)

	var sys: EnemySystem = body.get_node_or_null("EnemySystem")
	if sys == null:
		sys = EnemySystem.new()
		sys.name = "EnemySystem"
		body.add_child(sys)

	# Escala alinhada ao soft-max da Arena (~lv 35–60), sem HP de endgame
	var ed := EnemyData.new()
	ed.enemy_name = "Gladiador do Andar %d" % andar if andar < 200 else "Mestre de Andar (Nen)"
	var hp: int = 280 + (andar * 18)
	var frc: int = 12 + int(float(andar) * 1.15)
	var dfs: int = 6 + int(float(andar) * 0.85)
	ed.is_boss = (andar % 10 == 0)
	if ed.is_boss:
		hp = int(float(hp) * 1.65)
		frc = int(float(frc) * 1.25)
	ed.max_health = hp
	ed.strength = frc
	ed.defense = dfs
	ed.xp_reward = 28 + (andar * 12)
	sys.enemy_data = ed
	sys.max_health = ed.max_health
	sys.health = ed.max_health
	sys.strength = ed.strength
	sys.defense = ed.defense
	sys.xp_reward = ed.xp_reward
	sys.enemy_name = ed.enemy_name
	sys.is_boss = ed.is_boss

	sys.died.connect(func(_type):
		inimigos_restantes -= 1
		if inimigos_restantes <= 0:
			_ao_vencer_andar()
	)

	return body


func _ao_vencer_andar() -> void:
	var premio: int = andar_atual * 800 + 2000
	Economy.adicionar_gold(premio)
	_sincronizar_progresso_andar(andar_atual + 1)
	
	var hud = get_tree().get_first_node_in_group("player_hud")
	if hud and hud.has_method("exibir_notificacao"):
		hud.exibir_notificacao("🏆 VENCEU O ANDAR %d! +%s Jenny!" % [andar_atual, Economy.formatar_numero(premio)])

	get_tree().create_timer(2.0).timeout.connect(func():
		_iniciar_andar(andar_atual + 1)
	)
