extends SceneTree

func _init() -> void:
	print("==================================================")
	print(">>> INICIANDO TESTE DO SISTEMA DE HATSU & VOWS <<<")
	print("==================================================")

	var hatsu_mgr = load("res://autoload/HatsuManager.gd").new()
	root.add_child(hatsu_mgr)

	var erros: int = 0

	# ------------------------------------------------------------
	# TESTE 1: AVALIADOR DE JURAMENTOS (NEN VOW ENGINE)
	# ------------------------------------------------------------
	print("\n--- TESTE 1: AVALIADOR INTELIGENTE DE NEN ---")

	# Teste 1.1: Rejeição de Voto Trivial
	var an_trivial = hatsu_mgr.analisar_juramento_inteligente("só funciona quando estou de costas")
	if an_trivial["rejeitado"] == true and an_trivial["multiplicador"] == 1.0:
		print("✅ [PASS] Rejeição de voto trivial ('de costas') funcionou com sucesso.")
	else:
		print("❌ [FAIL] Falha ao rejeitar voto trivial: ", an_trivial)
		erros += 1

	var an_trivial2 = hatsu_mgr.analisar_juramento_inteligente("sou bonito")
	if an_trivial2["rejeitado"] == true:
		print("✅ [PASS] Rejeição de texto sem valor restritivo ('sou bonito') funcionou.")
	else:
		print("❌ [FAIL] Falha na rejeição: ", an_trivial2)
		erros += 1

	# Teste 1.2: Voto Extremo - Se Errar Morro
	var an_morte = hatsu_mgr.analisar_juramento_inteligente("se errar morro no cadafalso")
	if an_morte["valido"] and an_morte["tier"] == HatsuData.Tier.VOTO_EXTREMO and an_morte["multiplicador"] >= 2.0:
		print("✅ [PASS] Voto Extremo (Cadafalso) reconhecido: Tier 🔴 | Mult: ", an_morte["multiplicador"])
	else:
		print("❌ [FAIL] Falha em Voto Extremo: ", an_morte)
		erros += 1

	# Teste 1.3: Juramento Sério - Contra quem atacou primeiro
	var an_retorno = hatsu_mgr.analisar_juramento_inteligente("só funciona contra quem me atacou primeiro")
	if an_retorno["valido"] and an_retorno["tier"] == HatsuData.Tier.JURAMENTO and an_retorno["multiplicador"] >= 1.70:
		print("✅ [PASS] Juramento Sério (Contra quem atacou primeiro) reconhecido: Tier 🟡 | Mult: ", an_retorno["multiplicador"])
	else:
		print("❌ [FAIL] Falha em Juramento de Contra-Ataque: ", an_retorno)
		erros += 1

	# Teste 1.4: Juramento Sério - Zetsu pós-uso
	var an_zetsu = hatsu_mgr.analisar_juramento_inteligente("depois de usar entro em zetsu por 15 segundos")
	if an_zetsu["valido"] and an_zetsu["categoria_voto"] == "POS_USO_ZETSU":
		print("✅ [PASS] Juramento Pós-Uso (Zetsu 15s) reconhecido: Tier 🟡 | Mult: ", an_zetsu["multiplicador"])
	else:
		print("❌ [FAIL] Falha em Juramento de Zetsu pós-uso: ", an_zetsu)
		erros += 1

	# ------------------------------------------------------------
	# TESTE 2: CRIAÇÃO E CÁLCULO PONDERADO DE HATSU
	# ------------------------------------------------------------
	print("\n--- TESTE 2: CÁLCULO PONDERADO DE PODER & TIERS ---")

	var hatsu_base = hatsu_mgr.criar_hatsu("Golpe Simples", HatsuData.Categoria.INTENSIFICACAO, HatsuData.Forma.TOQUE, [])
	var mult_base = hatsu_base.obter_multiplicador_poder()
	print("Mult Base: ", mult_base)
	if mult_base == 1.0:
		print("✅ [PASS] Hatsu sem condições possui multiplicador 1.0.")
	else:
		print("❌ [FAIL] Hatsu base esperado 1.0, obteve: ", mult_base)
		erros += 1

	# Hatsu com Condição 🟢 (HP < 50%)
	var hatsu_cond = hatsu_mgr.criar_hatsu("Golpe Tático", HatsuData.Categoria.INTENSIFICACAO, HatsuData.Forma.TOQUE, [HatsuData.Condicao.HP_ABAIXO_50])
	var mult_cond = hatsu_cond.obter_multiplicador_poder()
	print("Mult Tier 🟢 (HP < 50%): ", mult_cond)
	if mult_cond > 1.25 and mult_cond < 1.45:
		print("✅ [PASS] Hatsu Tier 🟢 calculou multiplicador proporcional (+30%).")
	else:
		print("❌ [FAIL] Multiplicador fora da faixa: ", mult_cond)
		erros += 1

	# Hatsu com Voto Extremo 🔴 (Uso Único por Combate)
	var hatsu_ext = hatsu_mgr.criar_hatsu("Golpe Final", HatsuData.Categoria.INTENSIFICACAO, HatsuData.Forma.TOQUE, [HatsuData.Condicao.USO_UNICO_POR_COMBATE])
	var mult_ext = hatsu_ext.obter_multiplicador_poder()
	print("Mult Tier 🔴 (Uso Único): ", mult_ext)
	if mult_ext >= 2.0:
		print("✅ [PASS] Hatsu Tier 🔴 calculou multiplicador extremo (> +100%).")
	else:
		print("❌ [FAIL] Multiplicador extremo incorreto: ", mult_ext)
		erros += 1

	# ------------------------------------------------------------
	# TESTE 3: EXECUÇÃO RUNTIME E VALIDAÇÃO DE CONDIÇÕES (pode_usar)
	# ------------------------------------------------------------
	print("\n--- TESTE 3: VALIDAÇÃO DE CONDIÇÕES (pode_usar) ---")

	# Teste 3.1: Validação de HP < 50%
	var ctx_hp_cheio = {"hp": 100, "hp_max": 100, "aura": 100.0, "aura_max": 100.0}
	var ctx_hp_baixo = {"hp": 30, "hp_max": 100, "aura": 100.0, "aura_max": 100.0}

	var res_hp1 = hatsu_cond.pode_usar(ctx_hp_cheio)
	var res_hp2 = hatsu_cond.pode_usar(ctx_hp_baixo)

	if not res_hp1["pode"] and res_hp2["pode"]:
		print("✅ [PASS] Restrição de HP < 50% bloqueou com HP cheio e liberou com HP baixo.")
	else:
		print("❌ [FAIL] Falha no teste de HP: ", res_hp1, res_hp2)
		erros += 1

	# Teste 3.2: Contra quem atacou primeiro
	var hatsu_contra = hatsu_mgr.criar_hatsu("Contra Vingança", HatsuData.Categoria.INTENSIFICACAO, HatsuData.Forma.TOQUE, [HatsuData.Condicao.CONTRA_QUEM_ATACOU_PRIMEIRO])
	var ctx_sem_atacante = {"hp": 100, "hp_max": 100, "primeiro_atacante_id": &""}
	var ctx_com_atacante = {"hp": 80, "hp_max": 100, "primeiro_atacante_id": &"goblin_floresta"}

	var res_c1 = hatsu_contra.pode_usar(ctx_sem_atacante, {"enemy_id": &"goblin_floresta"})
	var res_c2 = hatsu_contra.pode_usar(ctx_com_atacante, {"enemy_id": &"goblin_floresta"})
	var res_c3 = hatsu_contra.pode_usar(ctx_com_atacante, {"enemy_id": &"outro_inimigo"})

	if not res_c1["pode"] and res_c2["pode"] and not res_c3["pode"]:
		print("✅ [PASS] Restrição 'Contra quem atacou primeiro' funcionou perfeitamente.")
	else:
		print("❌ [FAIL] Falha na restrição de agressor: c1=", res_c1, " c2=", res_c2, " c3=", res_c3)
		erros += 1

	# Teste 3.3: Uso Único por Combate
	var res_u1 = hatsu_ext.pode_usar(ctx_hp_cheio)
	hatsu_ext.usado_no_combate_atual = true
	var res_u2 = hatsu_ext.pode_usar(ctx_hp_cheio)

	if res_u1["pode"] and not res_u2["pode"]:
		print("✅ [PASS] Restrição 'Uso Único por Combate' bloqueou re-utilização.")
	else:
		print("❌ [FAIL] Falha no teste de Uso Único: u1=", res_u1, " u2=", res_u2)
		erros += 1

	# ------------------------------------------------------------
	# RESULTADO FINAL
	# ------------------------------------------------------------
	print("\n==================================================")
	if erros == 0:
		print("🎉 TODOS OS TESTES PASSARAM COM 100% DE SUCESSO!")
	else:
		print("❌ TOTAL DE ERROS ENCONTRADOS: ", erros)
	print("==================================================")
	quit(0 if erros == 0 else 1)
