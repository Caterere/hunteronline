class_name HatsuComponentLibrary
extends RefCounted

# ============================================================
# HUNTER ONLINE - BIBLIOTECA MODULAR DE COMPONENTES DE HATSU
# ============================================================
#
# Define o catálogo de blocos de construção universais de Nen:
# 1. Core Components (Forma fundamental de liberação)
# 2. Effect Modules (Efeitos e modificadores acopláveis)
# 3. Conditions (Condições de ativação e juramentos)
# 4. Restrictions (Restrições táticas e de postura)
# 5. Drawbacks (Consequências e custos vitais)
#
# ============================================================

enum CoreType {
	STRIKE,            # 0. Golpe físico concentrado de curta distância (Ko / Intensificação)
	PROJECTILE,        # 1. Projétil balístico disparado à distância (Emissão)
	BEAM,              # 2. Feixe contínuo linear de alta intensidade
	ZONE,              # 3. Área territorial de efeito (Domínio de En / Chuva de Aura)
	TRANSFORMATION,    # 4. Transformação corporal / neural (Godspeed, Emperor Time)
	SUMMON,            # 5. Materialização física de objeto, arma ou criatura (Conjuração)
	BARRIER,           # 6. Escudo ou cúpula defensiva de proteção
	MARK,              # 7. Aplicação de marca / selo tático no alvo com gatilho
	TRAP,              # 8. Mina de aura latente ativada por aproximação ou temporizador
	ABSORPTION,        # 9. Absorção / Devour de aura, energia ou status (Especialização)
	MEMORY_ROLLBACK,   # 10. Registro de snapshot temporal para retorno sob condição
	RULE_ZONE,         # 11. Imposição de regras invioláveis de Nen em uma área
	EXCHANGE           # 12. Sacrifício / Conversão direta de um recurso em outro
}

enum EffectType {
	DAMAGE,            # 0. Dano físico/energético no alvo
	HEALING,           # 1. Regeneração celular de HP
	SHIELD,            # 2. Pontos de vida temporários de aura
	STAT_MOD,          # 3. Modificação temporária de status (Força, Defesa, Velocidade)
	MOVEMENT_DASH,     # 4. Avanço rápido / Shunpo com I-frames
	TELEPORT,          # 5. Deslocamento instantâneo no espaço
	KNOCKBACK,         # 6. Repulsão direcional de impacto
	STUN,              # 7. Paralisia / atordoamento completo
	SLOW,              # 8. Redução de velocidade de movimento do alvo
	AURA_DRAIN,        # 9. Queima / esgotamento forçado de aura do oponente
	AURA_GAIN,         # 10. Recuperação direta de pontos de aura
	PIERCING,          # 11. Perfuração de armadura e mitigação de Ten
	TRACKING,          # 12. Projétil que persegue ativamente o alvo
	REFLECTION,        # 13. Reflexão de dano ou projéteis recebidos
	AREA_BURST,        # 14. Detonação secundária em raio ao impactar
	CHAIN,             # 15. Salto do efeito para alvos adjacentes próximos
	DEVOUR_STATS,      # 16. Absorção permanente/temporária de atributos do inimigo
	STATE_ROLLBACK,    # 17. Reversão de HP/Aura para o estado de X segundos atrás
	RULE_ENFORCE,      # 18. Penalização de Nen para quem violar regra da zona
	INFORMATION        # 19. Descoberta de fraquezas e status com Gyo
}

enum ConditionType {
	HP_BELOW_50,            # 0. HP do usuário abaixo de 50%
	HP_BELOW_30,            # 1. HP do usuário abaixo de 30% (Crítico)
	HP_BELOW_20,            # 2. À beira da morte (HP < 20%)
	HP_FULL,                # 3. HP 100% intacto
	AURA_MIN_50,            # 4. Pelo menos 50% de Aura restante
	REQUIRES_TEN,           # 5. Requer Ten ativo
	REQUIRES_REN,           # 6. Requer Ren ativo
	POST_PERFECT_DODGE,     # 7. Nos 2s após Esquiva Perfeita
	FIRST_ATTACKER_ONLY,    # 8. Apenas contra quem atacou primeiro (Contra-ataque)
	TARGET_BOSS_ELITE,      # 9. Apenas contra Chefes e Elites com Nen
	STATIONARY_CHANNEL,     # 10. Requer permanecer imóvel durante canalização
	CLOSE_RANGE_ZERO,       # 11. Proximidade extrema (< 40px)
	LONG_RANGE_SNIPER,      # 12. Distância longa (> 200px)
	SOULS_COLLECTED,        # 13. Requer almas acumuladas de abates
	PAIN_ACCUMULATED,       # 14. Requer dor/dano acumulado recentemente
	ENEMY_DEFEATED,         # 15. Gatilho ativado na derrota do oponente
	ENEMY_USED_HATSU,       # 16. Inimigo precisa ter usado um Hatsu em combate
	SOLO_COMBAT             # 17. Jogador deve estar lutando sozinho
}

enum RestrictionType {
	IMMOBILE_DURING_USE,       # 0. Não pode se mover durante o efeito
	CANNOT_DODGE,              # 1. Bloqueio de esquiva durante a habilidade
	CANNOT_USE_OTHER_HATSU,    # 2. Não pode usar outros Hatsus enquanto este estiver ativo
	SINGLE_TARGET_LOCK,        # 3. Focado em um único alvo exclusivo
	ONCE_PER_COMBAT,           # 4. Uso único por combate inteiro
	TOUCH_REQUIRED,            # 5. Requer toque físico direto
	ANNOUNCE_ABILITY,          # 6. Voto da revelação: anunciar o nome e funcionamento
	SACRIFICE_HP,              # 7. Sacrifício voluntário de HP (-10% a -30%)
	SACRIFICE_AURA_MAX,        # 8. Esvazia 100% da aura (Zero Ko)
	DEATH_PENALTY_ON_MISS      # 9. Se falhar ou errar, sofre metade do HP e Zetsu forçado
}

enum DrawbackType {
	ZETSU_FORCED_15S,          # 0. Entra em Zetsu forçado por 15 segundos após o uso
	NEN_OVERHEAT_10S,          # 1. Nós de Nen sobreaquecidos por 10 segundos
	HP_DRAIN_CONTINUOUS,       # 2. Drena vida continuamente durante a execução
	AURA_REGEN_LOCKED_10S,     # 3. Regeneração de aura congelada por 10s
	STAT_REDUCTION_TEMP,       # 4. Redução temporária de Força/Defesa pós-uso
	EXHAUSTION_SLOW            # 5. Exaustão física (-50% velocidade por 5s)
}


# ============================================================
# METADADOS E TABELAS DE VALORES DOS COMPONENTES
# ============================================================

enum NenCategory {
	INTENSIFICACAO = 0,
	TRANSFORMACAO = 1,
	EMISSAO = 2,
	CONJURACAO = 3,
	MANIPULACAO = 4,
	ESPECIALIZACAO = 5
}

static func get_core_info(core: CoreType) -> Dictionary:
	match core:
		CoreType.STRIKE:
			return {
				"name": "Golpe Físico (Strike)",
				"category": NenCategory.INTENSIFICACAO,
				"base_power": 60.0, "base_cost": 25.0, "base_cd": 3.0, "base_range": 45.0,
				"budget_weight": 1.0,
				"desc": "Concentração densa de aura no membro de ataque para impacto imediato."
			}
		CoreType.PROJECTILE:
			return {
				"name": "Projétil de Aura (Projectile)",
				"category": NenCategory.EMISSAO,
				"base_power": 45.0, "base_cost": 22.0, "base_cd": 2.5, "base_range": 180.0,
				"budget_weight": 1.0,
				"desc": "Desprendimento e disparo de esfera balística de Nen à distância."
			}
		CoreType.BEAM:
			return {
				"name": "Feixe Linear (Beam / Ray)",
				"category": NenCategory.TRANSFORMACAO,
				"base_power": 75.0, "base_cost": 38.0, "base_cd": 6.0, "base_range": 220.0,
				"budget_weight": 1.3,
				"desc": "Feixe contínuo canalizado perfurante de eletricidade ou calor."
			}
		CoreType.ZONE:
			return {
				"name": "Território / Área (Zone)",
				"category": NenCategory.EMISSAO,
				"base_power": 70.0, "base_cost": 45.0, "base_cd": 8.0, "base_range": 100.0,
				"budget_weight": 1.4,
				"desc": "Expansão de aura em raio esférico que afeta todos os ocupantes."
			}
		CoreType.TRANSFORMATION:
			return {
				"name": "Transformação Corporal (Transformation)",
				"category": NenCategory.TRANSFORMACAO,
				"base_power": 55.0, "base_cost": 40.0, "base_cd": 15.0, "base_range": 0.0,
				"budget_weight": 1.5,
				"desc": "Altera propriedades neurais ou celulares para amplificar atributos."
			}
		CoreType.SUMMON:
			return {
				"name": "Materialização / Invocação (Summon)",
				"category": NenCategory.CONJURACAO,
				"base_power": 65.0, "base_cost": 35.0, "base_cd": 10.0, "base_range": 50.0,
				"budget_weight": 1.35,
				"desc": "Criação de arma física, objeto ou entidade de Nen com regras próprias."
			}
		CoreType.BARRIER:
			return {
				"name": "Barreira Protetora (Barrier)",
				"category": NenCategory.CONJURACAO,
				"base_power": 60.0, "base_cost": 30.0, "base_cd": 7.0, "base_range": 35.0,
				"budget_weight": 1.1,
				"desc": "Membrana condensada de contenção que absorve impactos."
			}
		CoreType.MARK:
			return {
				"name": "Marcação Tática (Mark / Tag)",
				"category": NenCategory.MANIPULACAO,
				"base_power": 50.0, "base_cost": 28.0, "base_cd": 5.0, "base_range": 80.0,
				"budget_weight": 1.2,
				"desc": "Aplica selos no alvo para detonação ou controle posterior."
			}
		CoreType.TRAP:
			return {
				"name": "Armadilha Oculta (Trap)",
				"category": NenCategory.TRANSFORMACAO,
				"base_power": 65.0, "base_cost": 30.0, "base_cd": 6.5, "base_range": 60.0,
				"budget_weight": 1.15,
				"desc": "Mina de Nen invisível armada no solo."
			}
		CoreType.ABSORPTION:
			return {
				"name": "Absorção / Predação (Absorption)",
				"category": NenCategory.ESPECIALIZACAO,
				"base_power": 40.0, "base_cost": 60.0, "base_cd": 20.0, "base_range": 40.0,
				"budget_weight": 1.8,
				"desc": "Extração de aura vital e atributos de alvos derrotados."
			}
		CoreType.MEMORY_ROLLBACK:
			return {
				"name": "Memória & Reversão Temporal (Memory)",
				"category": NenCategory.ESPECIALIZACAO,
				"base_power": 30.0, "base_cost": 75.0, "base_cd": 30.0, "base_range": 0.0,
				"budget_weight": 2.0,
				"desc": "Registra o estado vital para retroceder sob dano letal."
			}
		CoreType.RULE_ZONE:
			return {
				"name": "Domínio de Regras (Rule Zone)",
				"category": NenCategory.ESPECIALIZACAO,
				"base_power": 50.0, "base_cost": 55.0, "base_cd": 18.0, "base_range": 120.0,
				"budget_weight": 1.7,
				"desc": "Cria um território com leis de combate invioláveis."
			}
		CoreType.EXCHANGE:
			return {
				"name": "Troca de Recursos (Exchange)",
				"category": NenCategory.ESPECIALIZACAO,
				"base_power": 70.0, "base_cost": 35.0, "base_cd": 10.0, "base_range": 60.0,
				"budget_weight": 1.4,
				"desc": "Converte frações de HP ou Aura em bônus massivo de impacto."
			}
	return {"name": "Desconhecido", "category": NenCategory.INTENSIFICACAO, "base_power": 30.0, "base_cost": 20.0, "base_cd": 5.0, "base_range": 50.0, "budget_weight": 1.0, "desc": ""}


static func get_effect_info(effect: EffectType) -> Dictionary:
	match effect:
		EffectType.DAMAGE:
			return {"name": "Dano Direto", "cost_mod": 1.0, "complexity": 5, "desc": "Causa dano proporcional ao poder final."}
		EffectType.HEALING:
			return {"name": "Cura Celular", "cost_mod": 1.2, "complexity": 10, "desc": "Restaura pontos de vida do usuário."}
		EffectType.SHIELD:
			return {"name": "Escudo de Aura", "cost_mod": 1.15, "complexity": 8, "desc": "Gera barreira protetora temporária."}
		EffectType.STAT_MOD:
			return {"name": "Modificador de Status", "cost_mod": 1.3, "complexity": 12, "desc": "Aplica buff ou debuff em atributos."}
		EffectType.MOVEMENT_DASH:
			return {"name": "Avanço Rápido (Dash)", "cost_mod": 0.85, "complexity": 6, "desc": "Concede mobilidade veloz e esquiva."}
		EffectType.TELEPORT:
			return {"name": "Teletransporte", "cost_mod": 1.6, "complexity": 18, "desc": "Deslocamento espacial instantâneo."}
		EffectType.KNOCKBACK:
			return {"name": "Impacto / Repulsão", "cost_mod": 0.9, "complexity": 4, "desc": "Empurra inimigos com força física."}
		EffectType.STUN:
			return {"name": "Paralisia / Stun", "cost_mod": 1.45, "complexity": 14, "desc": "Interrompe e imobiliza o alvo."}
		EffectType.SLOW:
			return {"name": "Desaceleração", "cost_mod": 1.1, "complexity": 7, "desc": "Reduz velocidade de movimento do inimigo."}
		EffectType.AURA_DRAIN:
			return {"name": "Queima de Aura", "cost_mod": 1.4, "complexity": 15, "desc": "Esgota a energia Nen do alvo."}
		EffectType.AURA_GAIN:
			return {"name": "Recuperação de Aura", "cost_mod": 1.5, "complexity": 15, "desc": "Regenera aura através de impacto."}
		EffectType.PIERCING:
			return {"name": "Perfuração de Ten", "cost_mod": 1.25, "complexity": 10, "desc": "Ignora parte da defesa corporal do alvo."}
		EffectType.TRACKING:
			return {"name": "Perseguição Homing", "cost_mod": 1.35, "complexity": 12, "desc": "Projétil rastreia o alvo em movimento."}
		EffectType.REFLECTION:
			return {"name": "Reflexão de Ataques", "cost_mod": 1.5, "complexity": 16, "desc": "Devolve parte do golpe recebido."}
		EffectType.AREA_BURST:
			return {"name": "Detonação em Área", "cost_mod": 1.3, "complexity": 10, "desc": "Explosão de impacto em raio amplo."}
		EffectType.CHAIN:
			return {"name": "Salto em Cadeia", "cost_mod": 1.4, "complexity": 14, "desc": "O efeito salta para outros inimigos."}
		EffectType.DEVOUR_STATS:
			return {"name": "Devour / Extração Vital", "cost_mod": 2.0, "complexity": 25, "desc": "Absorve permanentemente frações de atributos."}
		EffectType.STATE_ROLLBACK:
			return {"name": "Retorno Temporal", "cost_mod": 2.2, "complexity": 30, "desc": "Reverte HP/Aura para estado anterior sob perigo."}
		EffectType.RULE_ENFORCE:
			return {"name": "Execução de Regra", "cost_mod": 1.7, "complexity": 22, "desc": "Aplica punição automática por violação."}
		EffectType.INFORMATION:
			return {"name": "Análise de Nen (Gyo)", "cost_mod": 0.8, "complexity": 5, "desc": "Revela fraquezas e status ocultos."}
	return {"name": "Efeito Básico", "cost_mod": 1.0, "complexity": 5, "desc": ""}


static func get_condition_info(cond: ConditionType) -> Dictionary:
	match cond:
		ConditionType.HP_BELOW_50:
			return {"name": "HP < 50%", "budget_bonus": 20.0, "risk": 25, "desc": "Só ativa quando o usuário estiver com vida < 50%."}
		ConditionType.HP_BELOW_30:
			return {"name": "HP < 30% (Desespero)", "budget_bonus": 45.0, "risk": 50, "desc": "Só ativa em situação crítica de HP < 30%."}
		ConditionType.HP_BELOW_20:
			return {"name": "HP < 20% (À Beira da Morte)", "budget_bonus": 80.0, "risk": 90, "desc": "Supernova ativada exclusivamente em perigo letal."}
		ConditionType.HP_FULL:
			return {"name": "HP 100% Intacto", "budget_bonus": 15.0, "risk": 15, "desc": "Só pode ser usado com a vida completamente cheia."}
		ConditionType.AURA_MIN_50:
			return {"name": "Aura >= 50%", "budget_bonus": 15.0, "risk": 10, "desc": "Requer metade da aura disponível."}
		ConditionType.REQUIRES_TEN:
			return {"name": "Requer Ten Ativo", "budget_bonus": 15.0, "risk": 10, "desc": "O usuário precisa estar mantendo a postura Ten."}
		ConditionType.REQUIRES_REN:
			return {"name": "Requer Ren Ativo", "budget_bonus": 20.0, "risk": 20, "desc": "Requer explosão de Ren contínua."}
		ConditionType.POST_PERFECT_DODGE:
			return {"name": "Após Esquiva Perfeita", "budget_bonus": 30.0, "risk": 30, "desc": "Janela de 2s após esquivar de um golpe no momento exato."}
		ConditionType.FIRST_ATTACKER_ONLY:
			return {"name": "Apenas Contra Agressor", "budget_bonus": 50.0, "risk": 35, "desc": "Só pode atacar quem desferiu o primeiro golpe."}
		ConditionType.TARGET_BOSS_ELITE:
			return {"name": "Exclusivo: Chefes / Elites", "budget_bonus": 55.0, "risk": 40, "desc": "Juramento de Chain Jail — restrito a inimigos de elite."}
		ConditionType.STATIONARY_CHANNEL:
			return {"name": "Canalização Estática", "budget_bonus": 30.0, "risk": 45, "desc": "O usuário deve permanecer completamente imóvel."}
		ConditionType.CLOSE_RANGE_ZERO:
			return {"name": "Proximidade Extrema (< 40px)", "budget_bonus": 25.0, "risk": 35, "desc": "Requer contato direto quase corpo a corpo."}
		ConditionType.LONG_RANGE_SNIPER:
			return {"name": "Distância Sniper (> 200px)", "budget_bonus": 20.0, "risk": 20, "desc": "Alvo deve estar bem distante para ativação."}
		ConditionType.SOULS_COLLECTED:
			return {"name": "Colheita de Almas", "budget_bonus": 40.0, "risk": 25, "desc": "Requer abates prévios para carregar o golpe."}
		ConditionType.PAIN_ACCUMULATED:
			return {"name": "Dor Acumulada (Pain Packer)", "budget_bonus": 50.0, "risk": 60, "desc": "Poder proporcional ao dano sofrido recentemente."}
		ConditionType.ENEMY_DEFEATED:
			return {"name": "Ao Derrotar Inimigo", "budget_bonus": 25.0, "risk": 20, "desc": "Gatilho acionado imediatamente no abate do oponente."}
		ConditionType.ENEMY_USED_HATSU:
			return {"name": "Inimigo Usou Hatsu", "budget_bonus": 30.0, "risk": 30, "desc": "O alvo precisa ter revelado sua habilidade de Nen."}
		ConditionType.SOLO_COMBAT:
			return {"name": "Duelo Solitário", "budget_bonus": 25.0, "risk": 25, "desc": "O usuário não pode ter ajuda de aliados."}
	return {"name": "Condição Básica", "budget_bonus": 15.0, "risk": 10, "desc": ""}


static func get_restriction_info(res: RestrictionType) -> Dictionary:
	match res:
		RestrictionType.IMMOBILE_DURING_USE:
			return {"name": "Imóvel Durante Uso", "budget_bonus": 40.0, "risk": 35, "desc": "Velocidade zerada enquanto a habilidade é executada."}
		RestrictionType.CANNOT_DODGE:
			return {"name": "Bloqueio de Esquiva", "budget_bonus": 35.0, "risk": 40, "desc": "Não pode realizar Dash ou esquiva durante o efeito."}
		RestrictionType.CANNOT_USE_OTHER_HATSU:
			return {"name": "Exclusividade de Hatsu", "budget_bonus": 30.0, "risk": 20, "desc": "Trava todos os outros 3 slots de Hatsu enquanto ativo."}
		RestrictionType.SINGLE_TARGET_LOCK:
			return {"name": "Alvo Único Obrigatório", "budget_bonus": 20.0, "risk": 15, "desc": "Não afeta nenhum outro inimigo na área."}
		RestrictionType.ONCE_PER_COMBAT:
			return {"name": "1 Uso por Batalha", "budget_bonus": 90.0, "risk": 75, "desc": "Apenas um único disparo em todo o combate."}
		RestrictionType.TOUCH_REQUIRED:
			return {"name": "Requer Toque Físico", "budget_bonus": 30.0, "risk": 30, "desc": "Requer encostar a palma da mão no oponente."}
		RestrictionType.ANNOUNCE_ABILITY:
			return {"name": "Voto da Revelação", "budget_bonus": 20.0, "risk": 20, "desc": "O personagem fala em voz alta o funcionamento do golpe."}
		RestrictionType.SACRIFICE_HP:
			return {"name": "Sacrifício Vital (-10% a -30% HP)", "budget_bonus": 50.0, "risk": 60, "desc": "Consome vida máxima própria ao disparar."}
		RestrictionType.SACRIFICE_AURA_MAX:
			return {"name": "Zero Ko (Dreno Total de Aura)", "budget_bonus": 90.0, "risk": 85, "desc": "Zera completamente a barra de energia Nen."}
		RestrictionType.DEATH_PENALTY_ON_MISS:
			return {"name": "Voto do Cadafalso (Punição)", "budget_bonus": 120.0, "risk": 100, "desc": "Se errar ou for interrompido, sofre 50% HP e Zetsu forçado."}
	return {"name": "Restrição Básica", "budget_bonus": 20.0, "risk": 15, "desc": ""}


static func get_drawback_info(drawback: DrawbackType) -> Dictionary:
	match drawback:
		DrawbackType.ZETSU_FORCED_15S:
			return {"name": "Zetsu Forçado (15s)", "budget_bonus": 60.0, "risk": 80, "desc": "Desliga todos os nós de Nen por 15 segundos após o término."}
		DrawbackType.NEN_OVERHEAT_10S:
			return {"name": "Sobrecarga de Nen (10s)", "budget_bonus": 40.0, "risk": 45, "desc": "Impede o uso de técnicas avançadas de Nen por 10s."}
		DrawbackType.HP_DRAIN_CONTINUOUS:
			return {"name": "Dreno Contínuo de HP", "budget_bonus": 45.0, "risk": 55, "desc": "Consome frações de vida a cada segundo sustentado."}
		DrawbackType.AURA_REGEN_LOCKED_10S:
			return {"name": "Regeneração Congelada (10s)", "budget_bonus": 30.0, "risk": 35, "desc": "Impede a recuperação natural de aura por 10s."}
		DrawbackType.STAT_REDUCTION_TEMP:
			return {"name": "Exaustão Muscular (-30% Força)", "budget_bonus": 25.0, "risk": 30, "desc": "Reduz força física temporariamente após o uso."}
		DrawbackType.EXHAUSTION_SLOW:
			return {"name": "Lentidão Pós-Impacto (-50% Vel)", "budget_bonus": 20.0, "risk": 25, "desc": "Reduz velocidade do personagem por 5s pós-uso."}
	return {"name": "Consequência Leve", "budget_bonus": 15.0, "risk": 15, "desc": ""}