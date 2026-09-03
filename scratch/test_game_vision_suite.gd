extends Node2D

# ============================================================
# HUNTER ONLINE — GAME VISION ALIGNMENT TEST SUITE
# ============================================================
#
# Valida a conformidade da base com a Definitive Gameplay Direction:
# 1. Hub World Mandate (Carregamento sempre abre o Hub / Lobby)
# 2. Story Checkpoint & Story Gateway NPC
# 3. Nen 100% Passivo (Sem botões manuais de stance)
# 4. Level Up (+1 SP) e Aplicação Real na Skill Tree
# 5. Hatsu como Skills Ativas (1 a 4) com Custo e Cooldown
# 6. Facções, Reputação Multi-Grupo e Persistência
# ============================================================

var _total: int = 0
var _passados: int = 0


func _ready() -> void:
	print("\n============================================================")
	print("🎯 EXECUTANDO SUÍTE DE ALINHAMENTO: GAME VISION DEFINITIVA")
	print("============================================================")

	_teste_1_hub_world_mandate()
	_teste_2_story_checkpoint_e_gateway_npc()
	_teste_3_nen_100_passivo()
	_teste_4_level_up_skill_tree()
	_teste_5_hatsu_skills_ativas()
	_teste_6_faccoes_reputacao_persistencia()

	print("\n============================================================")
	print("🏆 RESULTADO: %d / %d TESTES APROVADOS" % [_passados, _total])
	if _passados == _total:
		print("   STATUS: 100% ALINHADO COM A DEFINITIVE GAMEPLAY DIRECTION!")
	else:
		printerr("   ALERTA: %d testes falharam!" % (_total - _passados))
	print("============================================================\n")


func _assinalar(condicao: bool, msg_ok: String, msg_erro: String) -> void:
	_total += 1
	if condicao:
		_passados += 1
		print("  ✅ [PASS] " + msg_ok)
	else:
		printerr("  ❌ [FAIL] " + msg_erro)


# ------------------------------------------------------------------------------
# 1. HUB WORLD MANDATE (Save nunca abre missão direto)
# ------------------------------------------------------------------------------
func _teste_1_hub_world_mandate() -> void:
	print("\n[TESTE 1/6] Validando Hub World Mandate (Lobby como ponto central)...")
	PlayerData.reset()
	PlayerData.nome_personagem = "Gon Freecss"
	PlayerData.mapa_atual_salvo = "res://world/maps/arena_celestial.tscn" # Simula salvar dentro de arena

	SaveManager.salvar_jogo(97)

	# Carregar jogo novamente
	SaveManager.carregar_jogo(97)

	var foi_pro_lobby: bool = PlayerData.mapa_atual_salvo == "res://world/lobby.tscn"

	_assinalar(foi_pro_lobby,
		"Carregar jogo sempre redireciona para o Hub World (Lobby), nunca abrindo a arena diretamente.",
		"SaveManager carregou a arena de combate diretamente em vez do Hub World!")


# ------------------------------------------------------------------------------
# 2. STORY CHECKPOINT & STORY GATEWAY NPC
# ------------------------------------------------------------------------------
func _teste_2_story_checkpoint_e_gateway_npc() -> void:
	print("\n[TESTE 2/6] Validando Story Checkpoints e Story Gateway NPC...")
	StoryManager.iniciar_saga(1)
	StoryManager.definir_checkpoint(&"pantano_numere")

	var cp_ativo: Dictionary = StoryManager.obter_checkpoint_ativo()
	var cp_ok: bool = str(cp_ativo.get("nome", "")) == "Pântano Numere (Ninho de Trapaceiros)"

	var scn_npc = load("res://entities/npc/NPC.tscn")
	var guia: NPC = scn_npc.instantiate()
	guia.set_script(load("res://entities/npc/story_gateway/StoryGatewayNPC.gd"))
	add_child(guia)

	var npc_pronto := guia != null and guia.npc_name == "Guia da História"
	guia.queue_free()

	_assinalar(cp_ok and npc_pronto,
		"StoryManager gerencia checkpoints formais e StoryGatewayNPC está pronto para despacho.",
		"Falha no catálogo de checkpoints ou no StoryGatewayNPC!")


# ------------------------------------------------------------------------------
# 3. NEN 100% PASSIVO (Sem teclas ativas)
# ------------------------------------------------------------------------------
func _teste_3_nen_100_passivo() -> void:
	print("\n[TESTE 3/6] Validando Nen 100% Passivo (Sem Toggles Manuais)...")
	var nen_sys = NenSystem.new()
	add_child(nen_sys)

	PlayerData.despertou_nen = true
	PlayerData.attributes["aura"] = 100.0
	PlayerData.attributes["aura_max"] = 100.0

	# Em Nen passivo, Ten está ativo permanentemente protegendo o personagem
	var ten_passivo_ok := nen_sys.esta_em_ten() == true
	var aura_inicial := nen_sys.obter_aura()

	# Processar técnicas sem dreno de aura
	nen_sys._processar_tecnicas(0.5)
	var aura_pos := nen_sys.obter_aura()
	var sem_dreno_passivo := aura_pos >= aura_inicial # Não drenou por simplesmente ter Ten

	nen_sys.queue_free()

	_assinalar(ten_passivo_ok and sem_dreno_passivo,
		"Nen opera de forma 100% passiva sem teclas manuais de stance nem dreno indevido de aura.",
		"NenSystem ainda exige ativação manual ou drena aura passivamente!")


# ------------------------------------------------------------------------------
# 4. LEVEL UP (+1 SP) E SKILL TREE
# ------------------------------------------------------------------------------
func _teste_4_level_up_skill_tree() -> void:
	print("\n[TESTE 4/6] Validando Level Up (+1 SP) e modificadores da Nen Skill Tree...")
	PlayerData.reset()
	PlayerData.attributes["nivel"] = 1
	PlayerData.nen_skill_points = 0

	var xp_sys = XPSystem.new()
	add_child(xp_sys)

	# Simular ganho de XP suficiente para level up (Nível 1 requer 300 XP)
	xp_sys.adicionar_xp(350, "Batalha")
	var subiu_nivel := int(PlayerData.attributes["nivel"]) >= 2
	var ganhou_sp := PlayerData.nen_skill_points >= 1

	# Testar Skill Tree
	var tree = NenSkillTree.new()
	add_child(tree)
	var pontos_disp := tree.obter_pontos_disponiveis()
	var pode_investir := tree.pode_investir("ten_1")

	xp_sys.queue_free()
	tree.queue_free()

	_assinalar(subiu_nivel and ganhou_sp and pontos_disp >= 1 and pode_investir,
		"Level Up concede +1 Skill Point que pode ser alocado na Nen Skill Tree.",
		"Falha no fluxo de Level Up ou investimento na Skill Tree!")


# ------------------------------------------------------------------------------
# 5. HATSU COMO SKILLS ATIVAS (SLOTS 1 A 4)
# ------------------------------------------------------------------------------
func _teste_5_hatsu_skills_ativas() -> void:
	print("\n[TESTE 5/6] Validando Hatsu como habilidades ativas 1-4...")
	var h_sys = HatsuSystem.new()
	add_child(h_sys)

	# Criar um Hatsu ativo de teste
	var h_data = HatsuData.new()
	h_data.nome = "Impacto da Rocha"
	h_data.custo_aura_base = 25.0
	h_data.cooldown_base = 1.0
	h_data.poder_base = 60.0
	PlayerData.equipar_hatsu_slot(0, h_data)

	PlayerData.despertou_nen = true
	PlayerData.attributes["aura"] = 100.0
	PlayerData.attributes["aura_max"] = 100.0

	var usou_ok := h_sys.usar_hatsu(0)
	var aura_gastou := float(PlayerData.attributes["aura"]) <= 80.0

	h_sys.queue_free()

	_assinalar(usou_ok and aura_gastou,
		"Hatsu opera como habilidade ativa em combate consumindo Aura e entrando em recarga.",
		"HatsuSystem falhou ao conjurar habilidade ativa ou não consumiu Aura!")


# ------------------------------------------------------------------------------
# 6. FACÇÕES, REPUTAÇÃO E PERSISTÊNCIA
# ------------------------------------------------------------------------------
func _teste_6_faccoes_reputacao_persistencia() -> void:
	print("\n[TESTE 6/6] Validando Reputação Multi-Facção e Persistência no Save...")
	ReputationSystem.alterar_reputacao(ReputationSystem.Faccao.MERCADORES, 500, "Missão de Comércio")
	var mult_preco := ReputationSystem.obter_multiplicador_preco_loja()
	var desconto_ok := mult_preco < 1.0 # Teve desconto

	SaveManager.salvar_jogo(97)

	# Resetar em memória
	ReputationSystem.reputacao_dados[ReputationSystem.Faccao.MERCADORES] = 0

	# Recarregar
	SaveManager.carregar_jogo(97)
	var rep_restaurada := ReputationSystem.obter_reputacao(ReputationSystem.Faccao.MERCADORES) >= 500

	_assinalar(desconto_ok and rep_restaurada,
		"Reputação concede descontos em lojas e persiste integralmente entre sessões de jogo.",
		"Falha no cálculo de desconto de reputação ou na persistência do SaveManager!")
