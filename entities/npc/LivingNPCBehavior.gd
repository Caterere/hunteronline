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

enum NPCHierarchy {
	COMMON,      # Aldeões e agricultores (diálogos leves, rotina dia/noite)
	FUNCTIONAL,  # Vendedor, Ferreiro, Comerciante (serviços, comércio)
	RECURRING,   # Nicol, Tonpa (aparece em múltiplas áreas/etapas comentando eventos)
	IMPORTANT,   # Mestre Wing, Guardião da Floresta (mentores, lore, treino de Nen)
	STORY,       # Elena, Satotz (Associação Hunter, marcos da trama principal)
	BOSS         # Guardião Ancestral, Líder Quimera (antagonistas e chefes com fala)
}

@export var hierarchy: NPCHierarchy = NPCHierarchy.COMMON
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

		# Resolver cargo, marcador e hierarquia por lore se não especificados
		var cargo_final := npc_cargo
		var marcador_final := tipo_marcador
		if cargo_final.is_empty():
			var n_lower = npc_nome.to_lower()
			if "wing" in n_lower:
				cargo_final = "Mestre de Nen"
				marcador_final = "trainer"
				hierarchy = NPCHierarchy.IMPORTANT
			elif "biscuit" in n_lower or "bisky" in n_lower:
				cargo_final = "Hunter Pro"
				marcador_final = "trainer"
				hierarchy = NPCHierarchy.IMPORTANT
			elif "elena" in n_lower:
				cargo_final = "Recepcionista da Associação"
				marcador_final = "story"
				hierarchy = NPCHierarchy.STORY
			elif "satotz" in n_lower:
				cargo_final = "Examinador Hunter"
				marcador_final = "quest"
				hierarchy = NPCHierarchy.STORY
			elif "menchi" in n_lower or "buhara" in n_lower:
				cargo_final = "Gourmet Hunter"
				marcador_final = "quest"
				hierarchy = NPCHierarchy.IMPORTANT
			elif "vendedor" in n_lower or "comerciante" in n_lower:
				cargo_final = "Comerciante Local"
				marcador_final = "merchant"
				hierarchy = NPCHierarchy.FUNCTIONAL
			elif "ferreiro" in n_lower:
				cargo_final = "Mestre Forjador"
				marcador_final = "blacksmith"
				hierarchy = NPCHierarchy.FUNCTIONAL
			elif "nicol" in n_lower:
				cargo_final = "Candidato Hunter"
				marcador_final = "recurring"
				hierarchy = NPCHierarchy.RECURRING
			elif "guardião da floresta" in n_lower or "guardiao da floresta" in n_lower:
				cargo_final = "Guardião Espiritual"
				marcador_final = "important"
				hierarchy = NPCHierarchy.IMPORTANT

		npc_cargo = cargo_final
		tipo_marcador = marcador_final

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
			"blacksmith": prefixo_marcador = "🔨 "
			"recurring": prefixo_marcador = "👤 "
			"important": prefixo_marcador = "💠 "

		if prefixo_marcador.is_empty():
			match hierarchy:
				NPCHierarchy.STORY: prefixo_marcador = "⭐ "
				NPCHierarchy.IMPORTANT: prefixo_marcador = "💠 "
				NPCHierarchy.FUNCTIONAL: prefixo_marcador = "💼 "
				NPCHierarchy.RECURRING: prefixo_marcador = "👤 "

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
		_aplicar_estilo_visual_modular(cargo_final, marcador_final)

	if EventBus != null:
		EventBus.time_phase_changed.connect(_on_time_phase_changed)
		if EventBus.has_signal("world_event_started"):
			EventBus.world_event_started.connect(_on_world_event_started)

	if WorldStateManager != null:
		WorldStateManager.rotina_npc_atualizada.connect(_on_rotina_atualizada)
		WorldStateManager.clima_alterado.connect(_on_clima_alterado)


func _aplicar_estilo_visual_modular(cargo: String, marcador: String) -> void:
	if npc_body == null:
		return

	var arquetipo := "civil"
	if marcador == "merchant" or cargo.contains("Mercador") or cargo.contains("Comerciante"):
		arquetipo = "comerciante"
	elif marcador == "trainer" or cargo.contains("Mestre") or cargo.contains("Instrutor"):
		arquetipo = "treinador"
	elif cargo.contains("Guarda") or cargo.contains("Sentinela"):
		arquetipo = "guardia"
	elif cargo.contains("Hunter") or marcador == "quest":
		arquetipo = "hunter"

	var char_rend = npc_body.get_node_or_null("CharacterRenderer")
	if char_rend != null and char_rend.has_method("aplicar_arquetipo"):
		char_rend.aplicar_arquetipo(arquetipo)
	else:
		var spr := npc_body.get_node_or_null("Sprite2D") as Sprite2D
		if spr != null and spr.material == null:
			# Aplicar tint temático sutil por arquétipo se não possuir renderer modular
			match arquetipo:
				"guardia": spr.modulate = Color(0.85, 0.9, 1.05, 1.0)
				"hunter": spr.modulate = Color(0.9, 1.05, 0.9, 1.0)
				"comerciante": spr.modulate = Color(1.05, 0.95, 0.85, 1.0)
				"treinador": spr.modulate = Color(1.0, 1.0, 1.08, 1.0)



func _on_world_event_started(ev_id: String, titulo: String, regiao: String) -> void:
	if regiao == regiao_id and npc_body != null:
		ComicBalloon.mostrar(npc_body, "🚨 Alerta em nossa região: %s!" % titulo, 2.8, -40.0)


func _on_clima_alterado(novo_clima: int, nome_clima: String) -> void:
	if npc_body == null:
		return
	match novo_clima:
		1: # CHUVA
			velocidade_andar *= 0.85
			pos_alvo = pos_inicial # Recua para perto da estrutura/toldo
			if randf() < 0.40:
				ComicBalloon.mostrar(npc_body, "🌧️ Chuva forte... É melhor me abrigar sob o toldo!", 2.2, -38.0)
		2: # NEBLINA
			velocidade_andar *= 0.90
		3: # TEMPESTADE_AURA
			if randf() < 0.50:
				ComicBalloon.mostrar(npc_body, "⚡ Que sensação estranha... O ar está pesado de Nen selvagem!", 2.5, -40.0)


func _on_rotina_atualizada(fase_tempo: int, clima: int) -> void:
	var nome_fase := "DAY"
	match fase_tempo:
		0: nome_fase = "DAWN"
		1: nome_fase = "DAY"
		2: nome_fase = "DUSK"
		3: nome_fase = "NIGHT"
	_on_time_phase_changed(nome_fase)


func _on_time_phase_changed(nova_fase: String) -> void:
	var eh_guarda: bool = "guarda" in npc_nome.to_lower() or "sentinela" in npc_nome.to_lower() or "guarda" in npc_cargo.to_lower()
	var eh_mercador: bool = "mercador" in npc_nome.to_lower() or tipo_marcador == "merchant"

	if schedule_data != null:
		match nova_fase:
			"MORNING", "DAWN":
				schedule_data.current_state = "working"
				if schedule_data.workplace_pos != Vector2.ZERO:
					pos_alvo = schedule_data.workplace_pos
				velocidade_andar = schedule_data.move_speed
			"DAY":
				schedule_data.current_state = "walking"
				if not schedule_data.patrol_route.is_empty():
					pos_alvo = schedule_data.patrol_route[randi() % schedule_data.patrol_route.size()]
				velocidade_andar = schedule_data.move_speed
			"EVENING", "DUSK":
				schedule_data.current_state = "training"
				velocidade_andar = schedule_data.move_speed * 0.8
			"NIGHT":
				if eh_guarda:
					schedule_data.current_state = "guarding"
					velocidade_andar = schedule_data.move_speed * 1.1
					if not schedule_data.patrol_route.is_empty():
						pos_alvo = schedule_data.patrol_route[0]
				else:
					schedule_data.current_state = "resting"
					if schedule_data.home_pos != Vector2.ZERO:
						pos_alvo = schedule_data.home_pos
					velocidade_andar = schedule_data.move_speed * 0.6
	else:
		match nova_fase:
			"NIGHT":
				if eh_guarda:
					raio_patrulha = 100.0 # Guardas patrulham mais à noite
					velocidade_andar = 28.0
					if randf() < 0.35 and npc_body != null:
						ComicBalloon.mostrar(npc_body, "🌙 Posto Noturno ativado. Vigília contra bestas!", 2.0, -38.0)
				elif eh_mercador:
					raio_patrulha = 10.0 # Mercador fecha barraca
					velocidade_andar = 14.0
					pos_alvo = pos_inicial
				else:
					raio_patrulha = 25.0
					velocidade_andar = 16.0
					pos_alvo = pos_inicial
			"DAY":
				raio_patrulha = 80.0
				velocidade_andar = 24.0


@export var schedule_waypoints: Array[Vector2] = []
var current_waypoint_idx: int = 0
var _cached_player: Node2D = null


func _physics_process(delta: float) -> void:
	if npc_body == null:
		return

	# Otimização: se o jogador estiver muito distante (> 480px), suspende cálculo de movimento
	if _cached_player == null or not is_instance_valid(_cached_player):
		var players = get_tree().get_nodes_in_group("player") if get_tree() else []
		if not players.is_empty():
			_cached_player = players[0] as Node2D

	if _cached_player != null and is_instance_valid(_cached_player):
		if npc_body.global_position.distance_to(_cached_player.global_position) > 480.0:
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
	if not schedule_waypoints.is_empty():
		current_waypoint_idx = (current_waypoint_idx + 1) % schedule_waypoints.size()
		pos_alvo = schedule_waypoints[current_waypoint_idx]
		return

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
	# -0.3 Reatividade à Memória Contextual de Mestres e Personagens (Task 3.2)
	if WorldState != null and WorldState.has_method("obter_dialogo_contextual_npc"):
		var fala_ctx = WorldState.obter_dialogo_contextual_npc(npc_nome)
		if not fala_ctx.begins_with("Saudações, Caçador"):
			return fala_ctx

	# -0.2 Reatividade à Crise Mundial / Invasão de Bestas Mágicas (Task 4.3)
	if WorldState != null and (WorldState.tem_flag_regional(regiao_id, "invasao_bestas_ativa") or (WorldStateManager != null and WorldStateManager.evento_invasao_ativo)):
		return "🚨 Alerta de Bestas Mágicas! Feras hostis romperam o perímetro da floresta. Cuidado redobrado!"

	# -0.1 Reatividade ao Clima (Task 4.2)
	if WorldStateManager != null:
		var c = WorldStateManager.obter_clima_atual()
		if c == WorldStateManager.Clima.CHUVA:
			return "🌧️ Essa chuva torrencial não dá trégua... É melhor ficar embaixo do toldo até a tempestade passar."
		elif c == WorldStateManager.Clima.TEMPESTADE_AURA:
			return "⚡ O céu está brilhando com aura pura... Esse fenômeno de Nen atmosférico é raríssimo e perigoso!"
		elif c == WorldStateManager.Clima.NEBLINA:
			return "🌫️ Esta neblina densa oculta presenças assassinas. Mantenha seu En ou Gyo bem afiados!"

	# -0.05 Reatividade a Horário Noturno para Comerciantes (Task 4.2)
	if TimeManager != null and TimeManager.current_phase == 3:
		if tipo_marcador == "merchant" or "mercador" in npc_nome.to_lower():
			return "🌙 A barraca está encerrada por esta noite. Volte assim que o sol raiar para negociar!"
		elif "guarda" in npc_nome.to_lower() or "sentinela" in npc_nome.to_lower():
			return "🌙 Patrulha noturna em andamento. Mantenha-se nas áreas iluminadas da vila."

	# 0. Reatividade à Escolhas do Protagonista (Causalidade Narrativa da Fase F)
	if StoryManager != null:
		if StoryManager.get_choice("suco_tonpa") == "desmascarar":
			return "🗣️ Bravo! Ouvi dizer que você desmascarou o 'Novato Killer' e o suco adulterado dele!"
		elif StoryManager.get_choice("suco_tonpa") == "recusar":
			return "🧐 Você tem bons instintos. O Exame Hunter não perdoa quem aceita gentilezas fáceis."
		elif StoryManager.get_story_flag("zaban_treino_concluido", false):
			return "🥋 Sua postura mudou... Sinto a estabilidade do fluxo de Nen ao seu redor."

	# 0.01 Reatividade à Saga Atual
	if StoryManager != null and StoryManager.current_saga >= 2:
		return "🏆 Você é um dos sobreviventes do 287º Exame Hunter! O mundo dos Caçadores respeita seu nome."

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


# ============================================================
# SUPORTE A TREINAMENTO ESTRUTURADO (FASE F - PROGRESSÃO)
# ============================================================

func pode_treinar() -> bool:
	return tipo_marcador == "trainer" or "treinador" in npc_nome.to_lower() or "wing" in npc_nome.to_lower() or "biscuit" in npc_nome.to_lower()


func executar_treinamento(tipo_treino: String = "ten_basico") -> Dictionary:
	if not pode_treinar():
		return {"sucesso": false, "mensagem": "Este cidadão não é um instrutor de Nen ou físico."}

	var resultado: Dictionary = {"sucesso": true, "recompensa": ""}
	match tipo_treino:
		"ten_basico":
			PlayerData.attributes["aura_max"] = float(PlayerData.attributes.get("aura_max", 100.0)) + 15.0
			PlayerData.attributes["aura"] = PlayerData.attributes["aura_max"]
			resultado["recompensa"] = "+15 Aura Máxima permanente pelo refinamento de Ten!"
		"resistencia_fisica":
			PlayerData.attributes["defesa"] = int(PlayerData.attributes.get("defesa", 10)) + 3
			resultado["recompensa"] = "+3 Defesa permanente pela postura corporal firme!"
		_:
			PlayerData.attributes["vida_max"] = int(PlayerData.attributes.get("vida_max", 100)) + 20
			PlayerData.attributes["vida"] = PlayerData.attributes["vida_max"]
			resultado["recompensa"] = "+20 Vida Máxima pelo treino de vigor!"

	if StoryManager != null:
		StoryManager.set_story_flag("treino_concluido_" + tipo_treino, true)
		StoryManager.set_pacing_state(StoryManager.StoryPacingState.EXPLORATION)

	return resultado


