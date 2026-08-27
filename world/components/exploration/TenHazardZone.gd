class_name TenHazardZone
extends Area2D

# ============================================================
# HUNTER ONLINE - TEN HAZARD ZONE (ZONA DE PERIGO AMBIENTAL)
# ============================================================
#
# Área com névoa ácida, miasma venenoso ou radiação hostil.
# - Se o jogador estiver sem TEN: sofre dano contínuo a cada 0.6s.
# - Se o jogador mantiver TEN ativo: a película de aura anula o dano.
#
# ============================================================

signal jogador_entrou_na_zona(player: Node2D)
signal dano_aplicado_sem_ten(dano: int)

@export var hazard_name: String = "Névoa Corrosiva"
@export var dano_por_tick: int = 8
@export var intervalo_tick: float = 0.6
@export var cor_miasma: Color = Color(0.4, 0.9, 0.2, 0.45)

var jogador_na_zona: CharacterBody2D = null
var timer_tick: float = 0.0

func _enter_tree() -> void:
	collision_layer = 0
	collision_mask = 2 # Detecta Player (Layer 2)

func _ready() -> void:
	add_to_group("ten_hazard_zone")
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body is CharacterBody2D:
		jogador_na_zona = body as CharacterBody2D
		jogador_entrou_na_zona.emit(jogador_na_zona)
		timer_tick = 0.1 # Primeiro tick rápido

func _on_body_exited(body: Node2D) -> void:
	if body == jogador_na_zona:
		jogador_na_zona = null

func _process(delta: float) -> void:
	if jogador_na_zona == null or not is_instance_valid(jogador_na_zona):
		return
		
	timer_tick -= delta
	if timer_tick <= 0.0:
		timer_tick = intervalo_tick
		_processar_dano_ambiental()

func _processar_dano_ambiental() -> void:
	var nen_sys = jogador_na_zona.get_node_or_null("NenSystem") as NenSystem
	var em_ten: bool = (nen_sys != null and nen_sys.has_method("tecnica_ativa") and nen_sys.tecnica_ativa(NenSystem.Tecnica.TEN))
	
	if em_ten:
		# Protegido por TEN - consome pequena aura e protege HP
		return
	else:
		# Sem TEN - sofre dano direto de miasma
		if jogador_na_zona.has_method("receber_dano"):
			jogador_na_zona.receber_dano(dano_por_tick, Vector2.ZERO, 0.0, self)
			dano_aplicado_sem_ten.emit(dano_por_tick)
