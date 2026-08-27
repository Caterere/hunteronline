class_name ZetsuSensorZone
extends Area2D

# ============================================================
# HUNTER ONLINE - ZETSU SENSOR ZONE (CORREDOR DE SENTINELAS)
# ============================================================
#
# Área patrulhada por feras predatórias ou sensores de aura.
# - Se o jogador cruzar sem ZETSU: o alarme é disparado e emboscadas surgem.
# - Se o jogador cruzar em ZETSU: passa despercebido com sucesso.
#
# ============================================================

signal alarme_disparado(posicao: Vector2)
signal travessia_furtiva_sucesso(player: Node2D)

@export var zone_id: StringName = &"sensor_patrulha"
@export var zone_name: String = "Território de Predadores Sensíveis a Aura"
@export var spawn_inimigos_ao_falhar: bool = true

var jogador_dentro: CharacterBody2D = null
var falhou_stealth: bool = false

func _enter_tree() -> void:
	collision_layer = 0
	collision_mask = 2 # Player (Layer 2)

func _ready() -> void:
	add_to_group("zetsu_sensor_zone")
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body is CharacterBody2D:
		jogador_dentro = body as CharacterBody2D
		falhou_stealth = false
		_checar_presenca_aura()

func _on_body_exited(body: Node2D) -> void:
	if body == jogador_dentro:
		if not falhou_stealth and is_instance_valid(jogador_dentro):
			# Travessia concluída em sigilo!
			travessia_furtiva_sucesso.emit(jogador_dentro)
			var nen_sys = jogador_dentro.get_node_or_null("NenSystem") as NenSystem
			if nen_sys != null and nen_sys.has_method("adicionar_nen_xp"):
				nen_sys.adicionar_nen_xp(35)
			if EventBus != null:
				EventBus.emit_toast("🥷 Travessia Furtiva com Zetsu Concluída (+35 Nen XP)!", Color(0.4, 1.0, 0.4, 1.0))
			var quest_sys = Engine.get_main_loop().root.get_node_or_null("/root/QuestSystem") if Engine.get_main_loop() else null
			if quest_sys != null and quest_sys.has_method("register_stealth_pass"):
				quest_sys.register_stealth_pass(zone_id)
		jogador_dentro = null

func _process(_delta: float) -> void:
	if jogador_dentro != null and not falhou_stealth:
		_checar_presenca_aura()

func _checar_presenca_aura() -> void:
	var nen_sys = jogador_dentro.get_node_or_null("NenSystem") as NenSystem
	var em_zetsu: bool = (nen_sys != null and nen_sys.has_method("tecnica_ativa") and nen_sys.tecnica_ativa(NenSystem.Tecnica.ZETSU))
	
	if not em_zetsu and not falhou_stealth:
		falhou_stealth = true
		alarme_disparado.emit(global_position)
		_acionar_alerta_emboscada()

func _acionar_alerta_emboscada() -> void:
	var hud = get_tree().get_first_node_in_group("player_hud")
	if hud != null and hud.has_method("exibir_notificacao"):
		hud.exibir_notificacao("⚠️ ALARME! Sua presença de aura atraiu os predadores!")
