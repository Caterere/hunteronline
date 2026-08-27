class_name PlayerHouse
extends Node2D

# ============================================================
# HUNTER ONLINE - PLAYER HOUSE / PERSONAL BASE
# ============================================================
#
# Base particular do Caçador:
# 1. Cama de Descanso (Restaura HP & Aura + Buff de Descanso +25% XP)
# 2. Baú de Armazenamento (Guarda itens, cartas e equipamentos)
# 3. Boneco de Teste de DPS (Mede dano e cadência dos Hatsus)
# 4. NPC Treinador Pessoal de Nen (Acesso aos minijogos de treino)
# 5. Porta de Retorno ao Lobby
#
# ============================================================

const InteractionComponent = preload("res://entities/components/InteractionComponent.gd")

var dps_dummy_hp: int = 1000000
var dps_total_dano: int = 0
var dps_tempo_inicio: float = 0.0
var dps_ativo: bool = false

var lbl_dps_display: Label = null


func _ready() -> void:
	if AudioManager != null:
		AudioManager.tocar_musica("kujirato_yori")

	print("=================================")
	print("[PlayerHouse] BEM-VINDO À SUA CASA / BASE DE CAÇADOR!")
	print("=================================")
	_criar_elementos_casa()


func _criar_elementos_casa() -> void:
	# 1. Cama de Descanso
	_criar_zona_interativa("Cama de Descanso", Vector2(100, 80), _ao_usar_cama, "🛏️ Cama de Descanso\n[E] Descansar (HP/Aura 100%)")

	# 2. Baú de Armazenamento
	_criar_zona_interativa("Baú de Itens", Vector2(180, 80), _ao_usar_bau, "📦 Baú de Itens\n[E] Abrir Baú Pessoal")

	# 3. Treinador de Nen
	_criar_zona_interativa("Mestre Pessoal", Vector2(260, 80), _ao_usar_treinador, "🥋 Mestre Pessoal\n[E] Minigames de Nen")

	# 4. Boneco de Treino de DPS
	_criar_boneco_dps(Vector2(200, 140))

	# 5. Porta de Saída
	_criar_zona_interativa("Porta de Saída", Vector2(40, 120), _ao_sair_de_casa, "🚪 Porta de Saída\n[E] Voltar ao Lobby")


func _criar_zona_interativa(nome: String, pos: Vector2, callback: Callable, texto_hud: String) -> void:
	var body := StaticBody2D.new()
	body.name = nome
	body.position = pos

	var lbl := Label.new()
	lbl.text = texto_hud
	lbl.position = Vector2(-50, -28)
	lbl.custom_minimum_size = Vector2(100, 14)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.add_theme_font_size_override("font_size", 3)
	lbl.add_theme_color_override("font_color", Color(1.0, 0.9, 0.4))
	lbl.add_theme_color_override("font_shadow_color", Color.BLACK)
	body.add_child(lbl)

	var inter = InteractionComponent.new()
	inter.name = "InteractionComponent"
	inter.interaction_text = texto_hud
	inter.interaction_radius = 18.0
	inter.interacted.connect(func(_p): callback.call())
	body.add_child(inter)

	add_child(body)


func _ao_usar_cama() -> void:
	var hp_max = PlayerData.attributes.get("vida_max", 100)
	var aura_max = PlayerData.attributes.get("aura_max", 100)
	PlayerData.attributes["vida"] = hp_max
	PlayerData.attributes["aura"] = aura_max
	
	var hud = get_tree().get_first_node_in_group("player_hud")
	if hud and hud.has_method("exibir_notificacao"):
		hud.exibir_notificacao("🛏️ Totalmente Descansado! HP & Aura 100% Restaurados (+25% Bônus de XP de Descanso)")
	print("[PlayerHouse] Jogador descansou na cama. Vida e Aura recuperadas.")


func _ao_usar_bau() -> void:
	var hud = get_tree().get_first_node_in_group("player_hud")
	if hud and hud.has_method("exibir_notificacao"):
		hud.exibir_notificacao("📦 Baú Pessoal Aberto (Capacidade Expandida: 100 Slots)")


func _ao_usar_treinador() -> void:
	var minigame_scene = load("res://ui/Minigames/NenTrainingMinigame.tscn")
	if minigame_scene:
		var minigame = minigame_scene.instantiate()
		add_child(minigame)
		minigame.start_minigame()


func _ao_sair_de_casa() -> void:
	var trans = get_node_or_null("/root/SceneTransition")
	if trans != null and trans.has_method("mudar_cena"):
		trans.mudar_cena("res://world/lobby.tscn", "Capital dos Caçadores", "Hunter Plaza — Hub Central")
	else:
		get_tree().change_scene_to_file("res://world/lobby.tscn")


# ============================================================
# BONECO DE TESTE DE DPS DE NEN
# ============================================================
func _criar_boneco_dps(pos: Vector2) -> void:
	var dummy_body := CharacterBody2D.new()
	dummy_body.name = "DPS_Dummy"
	dummy_body.position = pos
	dummy_body.add_to_group("enemies")
	dummy_body.add_to_group("dps_dummy")

	var col := CollisionShape2D.new()
	var box := RectangleShape2D.new()
	box.size = Vector2(24, 32)
	col.shape = box
	dummy_body.add_child(col)

	var sprite := Sprite2D.new()
	sprite.texture = load("res://assets/sprites/characters/player.png")
	sprite.hframes = 6
	sprite.vframes = 10
	sprite.frame = 0
	sprite.position = Vector2(0, -17)
	sprite.modulate = Color(0.8, 0.4, 0.2, 0.9)
	dummy_body.add_child(sprite)

	lbl_dps_display = Label.new()
	lbl_dps_display.text = "🎯 BONECO DE TREINO\nDPS: 0.0 | Total: 0"
	lbl_dps_display.position = Vector2(-45, -34)
	lbl_dps_display.add_theme_font_size_override("font_size", 3)
	lbl_dps_display.add_theme_color_override("font_color", Color(1.0, 0.9, 0.3))
	lbl_dps_display.add_theme_color_override("font_shadow_color", Color.BLACK)
	dummy_body.add_child(lbl_dps_display)

	add_child(dummy_body)


func registrar_dano_boneco(dano: int) -> void:
	if not dps_ativo:
		dps_ativo = true
		dps_tempo_inicio = Time.get_ticks_msec() / 1000.0
		dps_total_dano = 0

	dps_total_dano += dano
	var tempo = max(0.1, Time.get_ticks_msec() / 1000.0 - dps_tempo_inicio)
	var dps = float(dps_total_dano) / tempo

	if lbl_dps_display:
		lbl_dps_display.text = "🎯 BONECO DE TREINO\nDPS: %.1f | Dano: %d" % [dps, dps_total_dano]
