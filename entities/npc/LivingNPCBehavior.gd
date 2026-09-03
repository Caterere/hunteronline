class_name LivingNPCBehavior
extends Node

# ============================================================
# HUNTER ONLINE - LIVING NPC BEHAVIOR (ROTINA E VIDA NA CIDADE)
# ============================================================
#
# Adiciona comportamento autônomo e vivo para NPCs:
# 1. Patrulha e caminhada natural pelas ruas da cidade
# 2. Reações dinâmicas à proximidade do jogador
# 3. Comentários de rumores e fofocas sobre eventos mundiais e crimes
# 4. Paradas periódicas para descansar, treinar ou observar lojas
#
# ============================================================

@export var npc_nome: String = "Cidadão"
@export var velocidade_andar: float = 24.0
@export var raio_patrulha: float = 80.0

var npc_body: CharacterBody2D = null
var pos_inicial: Vector2
var pos_alvo: Vector2
var timer_espera: float = 0.0
var em_movimento: bool = false

const RUMORES_CIDADE := [
	"Ouvi dizer que um fugitivo da Máfia de Yorknew foi visto perto das montanhas...",
	"A Torre Celestial está pagando milhões de Jenny para quem passar do 100º andar!",
	"Você viu? Dizem que o Exame Hunter deste ano terá menos de 1% de aprovação.",
	"Dizem que há feras quimeras misteriosas surgindo nas florestas distantes.",
	"Quem dominar o Ryu consegue superar qualquer golpe direto em combate!"
]


@export var npc_id: String = "cidadao_padokia"
@export var regiao_id: String = "vale_padokia"
@export var identity: Resource = null
@export var schedule_data: NPCScheduleData = null
@export var npc_cargo: String = ""
@export var tipo_marcador: String = ""

func _ready() -> void:
	npc_body = get_parent() as CharacterBody2D
	if npc_body != null:
		pos_inicial = npc_body.global_position
		pos_alvo = pos_inicial
		timer_espera = randf_range(2.0, 5.0)

		# Resolver cargo e marcador padrão por lore se não especificados
		var cargo_final := npc_cargo
		var marcador_final := tipo_marcador
		if cargo_final.is_empty():
			match npc_nome.to_lower():
				"wing":
					cargo_final = "Mestre de Nen"
					marcador_final = "trainer"
				"biscuit", "bisky":
					cargo_final = "Hunter Pro"
					marcador_final = "trainer"
				"elena":
					cargo_final = "Recepcionista da Associação"
					marcador_final = "story"
				"satotz":
					cargo_final = "Examinador Hunter"
					marcador_final = "quest"
				"menchi", "buhara":
					cargo_final = "Gourmet Hunter"
					marcador_final = "quest"

		var badge := PanelContainer.new()
		badge.name = "LivingNPCNameBadge"
		badge.position = Vector2(-42, -32 if not cargo_final.is_empty() else -26)
		badge.custom_minimum_size = Vector2(84, 18 if not cargo_final.is_empty() else 11)
		badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
		badge.add_theme_stylebox_override("panel", HunterUIStyle.criar_style_overhead_badge(HunterUIStyle.COLOR_BORDER_SUBTLE))

		var m := MarginContainer.new()
		m.mouse_filter = Control.MOUSE_FILTER_IGNORE
		m.add_theme_constant_override("margin_left", 4)
		m.add_theme_constant_override("margin_right", 4)
		m.add_theme_constant_override("margin_top", 2)
		m.add_theme_constant_override("margin_bottom", 2)
		badge.add_child(m)

		var vbox := VBoxContainer.new()
		vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
		vbox.add_theme_constant_override("separation", 1)
		m.add_child(vbox)

		# Linha 1: Ícone de Função / Missão + Nome do NPC
		var prefixo_marcador := ""
		match marcador_final:
			"quest": prefixo_marcador = "📜 "
			"trainer": prefixo_marcador = "🥋 "
			"merchant": prefixo_marcador = "💰 "
			"story": prefixo_marcador = "⭐ "

		var lbl := Label.new()
		lbl.name = "LivingNPCNameLabel"
		lbl.text = prefixo_marcador + npc_nome
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		lbl.add_theme_font_size_override("font_size", 6)
		lbl.add_theme_color_override("font_color", HunterUIStyle.COLOR_TEXT_PRIMARY)
		lbl.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.9))
		lbl.add_theme_constant_override("shadow_offset_x", 1)
		lbl.add_theme_constant_override("shadow_offset_y", 1)
		vbox.add_child(lbl)

		# Linha 2: Cargo / Profissão do NPC
		if not cargo_final.is_empty():
			var lbl_sub := Label.new()
			lbl_sub.name = "LivingNPCRoleLabel"
			lbl_sub.text = cargo_final
			lbl_sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			lbl_sub.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			lbl_sub.add_theme_font_size_override("font_size", 5)
			lbl_sub.add_theme_color_override("font_color", HunterUIStyle.COLOR_TEXT_GOLD)
			lbl_sub.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.9))
			lbl_sub.add_theme_constant_override("shadow_offset_x", 1)
			lbl_sub.add_theme_constant_override("shadow_offset_y", 1)
			vbox.add_child(lbl_sub)

		npc_body.add_child.call_deferred(badge)

	if EventBus != null:
		EventBus.time_phase_changed.connect(_on_time_phase_changed)
		if EventBus.has_signal("world_event_started"):
			EventBus.world_event_started.connect(_on_world_event_started)


func _on_world_event_started(ev_id: String, titulo: String, regiao: String) -> void:
	if regiao == regiao_id and npc_body != null:
		ComicBalloon.mostrar(npc_body, "🚨 Alerta em nossa região: %s!" % titulo, 2.8, -40.0)


func _on_time_phase_changed(nova_fase: String) -> void:
	if schedule_data != null:
		match nova_fase:
			"MORNING":
				schedule_data.current_state = "working"
				if schedule_data.workplace_pos != Vector2.ZERO:
					pos_alvo = schedule_data.workplace_pos
				velocidade_andar = schedule_data.move_speed
			"DAY":
				schedule_data.current_state = "walking"
				if not schedule_data.patrol_route.is_empty():
					pos_alvo = schedule_data.patrol_route[randi() % schedule_data.patrol_route.size()]
				velocidade_andar = schedule_data.move_speed
			"EVENING":
				schedule_data.current_state = "training"
				velocidade_andar = schedule_data.move_speed * 0.8
			"NIGHT":
				schedule_data.current_state = "resting"
				if schedule_data.home_pos != Vector2.ZERO:
					pos_alvo = schedule_data.home_pos
				velocidade_andar = schedule_data.move_speed * 0.6
	else:
		match nova_fase:
			"NIGHT":
				raio_patrulha = 30.0 # Reduz patrulha à noite
				velocidade_andar = 16.0
			"DAY":
				raio_patrulha = 80.0
				velocidade_andar = 24.0


func _physics_process(delta: float) -> void:
	if npc_body == null:
		return

	if timer_espera > 0.0:
		timer_espera -= delta
		npc_body.velocity = Vector2.ZERO
		return

	# Se chegou ao destino, esperar um pouco
	if npc_body.global_position.distance_to(pos_alvo) <= 6.0:
		timer_espera = randf_range(3.0, 7.0)
		_escolher_novo_destino()
		return

	# Mover em direção ao alvo
	var dir = (pos_alvo - npc_body.global_position).normalized()
	npc_body.velocity = dir * velocidade_andar
	npc_body.move_and_slide()



func _escolher_novo_destino() -> void:
	var angulo = randf_range(0, TAU)
	var dist = randf_range(20.0, raio_patrulha)
	pos_alvo = pos_inicial + Vector2(cos(angulo), sin(angulo)) * dist


func obter_rumor_aleatorio() -> String:
	if RumorSystem != null:
		var rum = RumorSystem.obter_rumor_para_npc(regiao_id)
		if not rum.is_empty():
			return "🗣️ [Rumor] " + rum.get("descricao", "")
	return RUMORES_CIDADE[randi() % RUMORES_CIDADE.size()]


func obter_dialogo_reativo() -> String:
	# 0. Reatividade ao Medo / Hostilidade pelo RelationshipSystem
	if RelationshipSystem != null and RelationshipSystem.obter_medo(npc_id) >= 70.0:
		return "😨 P-Por favor, não me machuque! Eu não vi nada, juro!"

	# 0.05 Reatividade a Alta Confiança / Revelação de Segredos
	if RelationshipSystem != null and RelationshipSystem.pode_revelar_segredo(npc_id):
		return "🤫 Já que posso confiar em você: há rotas ancestrais e jazidas escondidas perto das montanhas."

	# 0.1 Reatividade a Alta Infâmia / Crimes no WorldState
	if WorldState != null and WorldState.obter_infamia() >= 50:
		return "⚠️ Fique longe de mim! Há caçadores de recompensa e patrulhas atrás de você!"

	# 0.2 Reatividade ao Posto Hunter em Padokia
	if WorldState != null and WorldState.tem_flag_regional("vale_padokia", "posto_hunter_ativo"):
		return "🏛️ A Associação Hunter abriu o posto avançado na vila! Os caminhos estão mais seguros do que nunca."

	# 1. Reatividade a Gyo ativado pelo jogador
	var players = get_tree().get_nodes_in_group("player") if get_tree() else []
	if not players.is_empty():
		var p = players[0]
		var nen = p.get_node_or_null("NenSystem") as NenSystem
		if nen != null and nen.has_method("tecnica_ativa") and nen.tecnica_ativa(NenSystem.Tecnica.GYO):
			return "👁️ Seus olhos brilham com a clareza de Gyo... Você consegue enxergar a verdade oculta neste mundo."

	# 2. Reatividade a Licença Hunter
	if PlayerData.tem_item(StringName("licenca_hunter")):
		return "🏹 Saudações, senhor Hunter Licenciado! É uma honra ver um membro de elite protegendo nossa região."

	# 3. Reatividade a Vitória sobre o Guardião Ancestral das Ruínas
	if (WorldState != null and WorldState.tem_flag_regional("ruinas_zaban", "guardiao_derrotado")) or PlayerData.quest_states.get("boss_derrotado", false):
		return "🏆 Você é o guerreiro que pacificou as Ruínas de Zaban! Os caminhos da floresta estão seguros graças a você!"

	# 4. Reatividade a Mestria de Nen Avançada
	var nen_lvl: int = int(PlayerData.attributes.get("nivel_nen", 0))
	if nen_lvl >= 3:
		return "⚡ Que aura formidável... Posso sentir a densidade do seu Ten mesmo à distância!"

	# 5. Reatividade a Reputação da Associação Hunter
	if ReputationSystem != null and ReputationSystem.has_method("obter_reputacao_str"):
		var rep_assoc = ReputationSystem.obter_reputacao_str("associacao_hunter")
		if rep_assoc >= 500:
			return "🤝 Sua lealdade e bravura são reconhecidas em todas as vilas, amigo Hunter."
		elif rep_assoc <= -300:
			return "⚠️ Fique longe de mim... Há boatos sombrios sobre suas ações recentes."

	# 6. Rumor orgânico do RumorSystem ou ambiente
	return obter_rumor_aleatorio()


