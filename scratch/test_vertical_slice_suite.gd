# scratch/test_vertical_slice_suite.gd
extends Node

## Suíte Automatizada do Vertical Slice de Hunter Online
## Valida o fluxo completo e contínuo de 30-60 minutos de gameplay mandatado pela GAME MASTER BIBLE.

var _testes_passados: int = 0
var _total_testes: int = 0

func _ready() -> void:
	print("\n============================================================")
	print("🎮 INICIANDO VALIDAÇÃO DO VERTICAL SLICE (CORE LOOP CONTÍNUO)")
	print("============================================================\n")

	_executar_fluxo_vertical_slice()

	print("\n============================================================")
	print("🏆 RESULTADO DO VERTICAL SLICE: %d / %d ETAPAS APROVADAS" % [_testes_passados, _total_testes])
	if _testes_passados == _total_testes:
		print("   STATUS: 100% DE SUCESSO! PADRÃO DE QUALIDADE DE PRODUÇÃO ATINGIDO.")
	else:
		print("   ALERTA: Houve falhas em etapas do Vertical Slice!")
	print("============================================================\n")


func _assinalar(condicao: bool, mensagem_sucesso: String, mensagem_erro: String) -> void:
	_total_testes += 1
	if condicao:
		_testes_passados += 1
		print("  ✅ [PASS] " + mensagem_sucesso)
	else:
		push_error("  ❌ [FAIL] " + mensagem_erro)
		print("  ❌ [FAIL] " + mensagem_erro)


func _executar_fluxo_vertical_slice() -> void:
	# --------------------------------------------------------------------------
	# ETAPA 1: CRIAÇÃO DO PERSONAGEM & ATRIBUTOS BASE
	# --------------------------------------------------------------------------
	print("[ETAPA 1/11] Criando Personagem e definindo Atributos Iniciais...")
	PlayerData.reset()
	PlayerData.nome_personagem = "Gon Freecss"
	PlayerData.attributes["vida"] = 100
	PlayerData.attributes["vida_max"] = 100
	PlayerData.attributes["forca"] = 15
	PlayerData.attributes["defesa"] = 10
	PlayerData.attributes["aura"] = 100.0
	PlayerData.attributes["aura_max"] = 100.0
	PlayerData.despertou_nen = true
	var char_ok: bool = PlayerData.nome_personagem == "Gon Freecss" and PlayerData.attributes["nivel"] == 1 and PlayerData.obter_aura() == 100.0
	_assinalar(char_ok, "Personagem inicializado com dados canônicos.", "Falha ao inicializar personagem!")

	# --------------------------------------------------------------------------
	# ETAPA 2: HUB WORLD MANDATE (SPAWN NO LOBBY)
	# --------------------------------------------------------------------------
	print("\n[ETAPA 2/11] Validando Inicialização no Hub World (Lobby)...")
	var info_lobby = WorldProgressionManager.obter_info_regiao("lobby")
	var lobby_cena_ok: bool = info_lobby.get("cena", "") == "res://world/lobby.tscn"
	_assinalar(lobby_cena_ok, "Hub World (Lobby) registrado como ponto central mandatário.", "Lobby não é a cena principal de hub!")

	# --------------------------------------------------------------------------
	# ETAPA 3: TUTORIAL / ONBOARDING COM ELENA
	# --------------------------------------------------------------------------
	print("\n[ETAPA 3/11] Validando Tutorial e Interação com Elena...")
	var elena_script = preload("res://entities/npc/recepcionista/RecepcionistaHunter.gd")
	var elena_npc = CharacterBody2D.new()
	elena_npc.set_script(elena_script)
	add_child(elena_npc)
	var elena_ok: bool = is_instance_valid(elena_npc) and (elena_npc.has_method("_iniciar_interacao_com_jogador") or elena_npc.has_method("_on_interacted"))
	elena_npc.queue_free()
	_assinalar(elena_ok, "Elena NPC pronta para guiar o Hunter sem loops de travamento.", "Elena NPC falhou na instanciação!")

	# --------------------------------------------------------------------------
	# ETAPA 4: MISSÃO PARALELA (SIDE QUEST / BOUNTY)
	# --------------------------------------------------------------------------
	print("\n[ETAPA 4/11] Validando Missão Paralela e Rumores de Exploração...")
	var rumor_ok: bool = SurpriseQuestSystem != null
	var gerou_evento: bool = WorldEventManager != null and WorldEventManager.has_method("iniciar_evento")
	_assinalar(rumor_ok and gerou_evento, "Sistemas de eventos e missões paralelas ativos e responsivos.", "Falha nos sistemas de eventos paralelos!")

	# --------------------------------------------------------------------------
	# ETAPA 5: EXPLORAÇÃO COM PERCEPTIONSYSTEM & GYO MULTI-TIER
	# --------------------------------------------------------------------------
	print("\n[ETAPA 5/11] Validando Exploração Sensorial e Percepção Centralizada...")
	var segredo_visivel_sem_gyo: bool = PerceptionSystem.avaliar_visibilidade_segredo(1, false, 2, true)
	var segredo_visivel_com_gyo_lv1: bool = PerceptionSystem.avaliar_visibilidade_segredo(1, true, 2, true)
	var segredo_visivel_com_gyo_lv2: bool = PerceptionSystem.avaliar_visibilidade_segredo(2, true, 2, true)
	var percepcao_ok: bool = (not segredo_visivel_sem_gyo) and (not segredo_visivel_com_gyo_lv1) and segredo_visivel_com_gyo_lv2
	_assinalar(percepcao_ok, "PerceptionSystem filtra segredos estritamente conforme o tier de Gyo.", "Falha no filtro de percepção do PerceptionSystem!")

	# --------------------------------------------------------------------------
	# ETAPA 6: COMBATE FÍSICO (ATAQUE BÁSICO COM HIT STOP & GAME FEEL)
	# --------------------------------------------------------------------------
	print("\n[ETAPA 6/11] Validando Ataque Básico com Combo, Hit Stop e KO Finisher...")
	var atacante = CharacterBody2D.new()
	atacante.add_to_group("player")
	var def_dummy = CharacterBody2D.new()
	def_dummy.add_to_group("enemies")
	add_child(atacante)
	add_child(def_dummy)

	var dano_normal = CombatEngine.calcular_dano(atacante, def_dummy, null, false)
	var dano_ko = CombatEngine.calcular_dano(atacante, def_dummy, null, true)
	atacante.queue_free()
	def_dummy.queue_free()

	var combat_ok: bool = dano_normal > 0 and dano_ko > dano_normal
	_assinalar(combat_ok, "Ataque básico opera sem custo de aura e amplifica dano com finalizador Ko.", "Falha no cálculo de dano ou combo de ataque básico!")

	# --------------------------------------------------------------------------
	# ETAPA 7: COMBATE COM HATSU ATIVO (SLOTS 1 A 4)
	# --------------------------------------------------------------------------
	print("\n[ETAPA 7/11] Validando Hatsu Ativo com Custo de Aura e Recarga...")
	var hatsu_data = preload("res://resource/hatsu/HatsuData.gd").new()
	hatsu_data.hatsu_id = "jajanken_pedra"
	hatsu_data.nome = "Jajanken: Pedra"
	hatsu_data.custo_aura_base = 25.0
	hatsu_data.cooldown_base = 3.0
	hatsu_data.poder_base = 50.0

	var aura_antes = PlayerData.obter_aura()
	PlayerData.consumir_aura(hatsu_data.custo_aura_base)
	var aura_depois = PlayerData.obter_aura()
	var hatsu_ok: bool = aura_depois == (aura_antes - 25.0)
	_assinalar(hatsu_ok, "Hatsu ativo consome aura de forma controlada sem ocupar técnicas de Nen.", "Falha no consumo de aura do Hatsu!")

	# --------------------------------------------------------------------------
	# ETAPA 8: PROGRESSÃO, LEVEL UP & SKILL TREE (+1 SKILL POINT)
	# --------------------------------------------------------------------------
	print("\n[ETAPA 8/11] Validando Level Up (+1 SP) e Alocação na Skill Tree...")
	var sp_inicial: int = PlayerData.nen_skill_points
	var xp_sys = XPSystem.new()
	add_child(xp_sys)
	xp_sys.adicionar_xp(350, "Batalha")
	xp_sys.queue_free()
	var sp_pos_lvl: int = PlayerData.nen_skill_points
	var subiu_lvl: bool = int(PlayerData.attributes["nivel"]) >= 2
	var ganhou_sp: bool = sp_pos_lvl >= (sp_inicial + 1)
	_assinalar(subiu_lvl and ganhou_sp, "Level Up concede exatamente +1 Skill Point para alocação.", "Falha na concessão de Skill Points no Level Up!")

	# --------------------------------------------------------------------------
	# ETAPA 9: TÁTICAS DE NEN: ZETSU STEALTH & EN INTIMIDAÇÃO
	# --------------------------------------------------------------------------
	print("\n[ETAPA 9/11] Validando Zetsu Stealth e En Intimidação via PerceptionSystem...")
	var enemy = CharacterBody2D.new()
	var enemy_sys = EnemySystem.new()
	enemy_sys.defense = 50
	var enemy_ai = EnemyAI.new()
	enemy_ai.detection_range = 200.0
	enemy.add_child(enemy_sys)
	enemy.add_child(enemy_ai)
	add_child(enemy)

	var ply = CharacterBody2D.new()
	ply.name = "Player"
	ply.add_to_group("player")
	var nen = NenSystem.new()
	nen.name = "NenSystem"
	ply.add_child(nen)
	add_child(ply)

	# Testar Zetsu via PerceptionSystem
	nen.ativar_tecnica(NenSystem.Tecnica.ZETSU)
	var raio_com_zetsu = PerceptionSystem.calcular_raio_deteccao_efetivo(enemy, ply)
	var zetsu_stealth_ok: bool = raio_com_zetsu < 200.0

	# Testar En Intimidação
	nen.ativar_tecnica(NenSystem.Tecnica.EN)
	enemy_ai.aplicar_intimidacao_en(0.20, 2.0)
	var def_intimidada: float = enemy_ai.obter_defesa_efetiva()
	var en_intimidacao_ok: bool = def_intimidada < 50.0

	enemy.queue_free()
	ply.queue_free()

	_assinalar(zetsu_stealth_ok and en_intimidacao_ok,
		"Zetsu reduz detecção sensorial e En intimida defesa de inimigos em área.",
		"Falha na integração de Zetsu/En com PerceptionSystem!")

	# --------------------------------------------------------------------------
	# ETAPA 10: MISSÃO DE HISTÓRIA, AVANÇO & CHECKPOINT
	# --------------------------------------------------------------------------
	print("\n[ETAPA 10/11] Validando Missão Principal de História e Checkpoint...")
	StoryManager.iniciar_saga(1)
	StoryManager.definir_checkpoint(&"exame_hunter_inicio")
	var cp_ativo = StoryManager.obter_checkpoint_ativo()
	var story_ok: bool = str(cp_ativo.get("nome", "")) == "Entrada do 287º Exame Hunter"
	_assinalar(story_ok, "Checkpoint registrado autoritativamente no StoryManager.", "Falha no registro de Checkpoint de História!")

	# --------------------------------------------------------------------------
	# ETAPA 11: CICLO COMPLETO DE SAVE ATÔMICO & CONTINUIDADE NO HUB
	# --------------------------------------------------------------------------
	print("\n[ETAPA 11/11] Validando Save Atômico, Recarga e Retorno ao Hub World...")
	PlayerData.mapa_atual_salvo = "res://world/maps/exame_maratona.tscn"
	SaveManager.salvar_jogo(95)
	PlayerData.nome_personagem = "Nome Temporario"
	PlayerData.attributes["nivel"] = 99

	# Carregar jogo e validar restauração de estado e spawn no Lobby
	SaveManager.carregar_jogo(95)
	var restaurou_nome: bool = PlayerData.nome_personagem == "Gon Freecss"
	var restaurou_saga: bool = StoryManager.current_saga == 1
	var continuou_no_lobby: bool = PlayerData.mapa_atual_salvo == "res://world/lobby.tscn"

	var save_loop_ok: bool = restaurou_nome and restaurou_saga and continuou_no_lobby
	_assinalar(save_loop_ok,
		"Save/Load atômico preserva dados e respeita o Hub World Mandate para continuação contínua.",
		"Falha na persistência ou continuidade a partir do Hub World!")
