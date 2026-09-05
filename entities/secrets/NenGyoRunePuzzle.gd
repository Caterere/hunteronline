class_name NenGyoRunePuzzle
extends Area2D

# ============================================================
# HUNTER ONLINE - NEN GYO RUNE PUZZLE (ENIGMA AMBIENTAL DE NEN)
# ============================================================
#
# Quebra-cabeça ambiental de exploração orgânica (Fase G — Epic 5):
# - Inscrição invisível em pedras/ruínas antigas.
# - Torna-se visível e legível APENAS com a técnica GYO ativa nos olhos.
# - Decifrar a runa concede fragmentos de lore antigos e Nen XP.
# - NUNCA aparece em bússolas ou waypoints de missões formais.
# ============================================================

signal runa_decifrada(runa_id: String, texto_lore: String)

@export var rune_id: String = "runa_ancestral_zaban"
@export var rune_title: String = "Inscrição Ancestral de Nen"
@export_multiline var rune_lore_text: String = "Quando a mente se fecha em Zetsu e os olhos despertam em Gyo, a verdadeira natureza da aura se revela além das formas materiais."
@export var reward_nen_xp: int = 150
@export var reward_lore_fragment_id: String = "fragmento_lore_tabuleta"

var decifrada: bool = false
var _label_indicador: Label = null
var _sprite_runa: Node2D = null

func _ready() -> void:
	collision_layer = 1
	collision_mask = 2 # Player
	monitoring = true

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	_construir_visual_runa()

	# Checar se já foi resolvida neste save
	if WorldState != null and WorldState.tem_marco_historico("runa_" + rune_id):
		decifrada = true


func _construir_visual_runa() -> void:
	_sprite_runa = Node2D.new()
	_sprite_runa.name = "VisualRuna"
	_sprite_runa.modulate.a = 0.0 # Invisível sem Gyo
	add_child(_sprite_runa)

	_label_indicador = Label.new()
	_label_indicador.text = "👁️ [E] Inscrição de Nen (Gyo)"
	_label_indicador.position = Vector2(-45, -28)
	_label_indicador.add_theme_font_size_override("font_size", 4)
	_label_indicador.add_theme_color_override("font_color", Color(1.0, 0.9, 0.3, 1.0))
	_label_indicador.visible = false
	add_child(_label_indicador)


func _physics_process(_delta: float) -> void:
	# Checar em tempo real se o jogador próximo está usando GYO
	var gyo_ativo = _verificar_gyo_jogador_proximo()

	if _sprite_runa != null:
		var alpha_alvo = 0.95 if gyo_ativo else 0.0
		_sprite_runa.modulate.a = lerpf(_sprite_runa.modulate.a, alpha_alvo, 0.15)

	if _label_indicador != null:
		_label_indicador.visible = gyo_ativo and not decifrada and _jogador_esta_proximo()


func _verificar_gyo_jogador_proximo() -> bool:
	var players = get_tree().get_nodes_in_group("player") if get_tree() else []
	if players.is_empty():
		return false

	var p = players[0]
	if p.global_position.distance_to(global_position) > 120.0:
		return false

	var nen = p.get_node_or_null("NenSystem") as NenSystem
	if nen != null and nen.has_method("tecnica_ativa"):
		return nen.tecnica_ativa(NenSystem.Tecnica.GYO)
	return false


var _player_dentro: bool = false

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_dentro = true


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_dentro = false


func _jogador_esta_proximo() -> bool:
	return _player_dentro


func _unhandled_input(event: InputEvent) -> void:
	if _player_dentro and event.is_action_pressed("interact") and not decifrada:
		if _verificar_gyo_jogador_proximo():
			interagir_decifrar()
		else:
			if EventBus != null:
				EventBus.emit_toast("Uma textura misteriosa parece esculpida na pedra... Você precisa de visão de Nen (Gyo) para focar.", Color(0.8, 0.8, 0.8))


func interagir_decifrar() -> void:
	if decifrada:
		return
	decifrada = true

	if EventBus != null:
		EventBus.emit_toast("📜 Runa de Nen Decifrada: '%s'" % rune_title, Color(1.0, 0.9, 0.3))
		EventBus.emit_camera_shake(0.30, 0.20)

	if ComicBalloon != null:
		ComicBalloon.mostrar(self, "✨ \"%s\"" % rune_lore_text, 4.0, -35.0)

	if WorldState != null:
		WorldState.registrar_marco_historico("runa_" + rune_id, {
			"titulo": rune_title,
			"lore": rune_lore_text,
			"data_ticks": Time.get_ticks_msec()
		})
		WorldState.alterar_notoriedade_nen(+15)

	if PlayerData != null:
		if reward_nen_xp > 0:
			PlayerData.adicionar_nen_xp(reward_nen_xp)
		if not reward_lore_fragment_id.is_empty():
			PlayerData.adicionar_item(StringName(reward_lore_fragment_id), 1)

	runa_decifrada.emit(rune_id, rune_lore_text)
	print("[GyoRunePuzzle] Runa antiga decifrada pelo jogador: %s" % rune_title)
