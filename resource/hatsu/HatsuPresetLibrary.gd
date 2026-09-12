class_name HatsuPresetLibrary
extends RefCounted

# ============================================================
# HUNTER ONLINE - BIBLIOTECA DE PRESETS E CONCEITOS DE HATSU
# ============================================================
#
# Define o catálogo de templates, arquétipos e conceitos iniciais
# para o Hatsu Creator.
# Cada preset pré-configura os blocos modulares sem hardcode no combate:
# - Categoria de Nen recomendada
# - Arquétipo canônico
# - Core Component & Efeito Principal
# - Efeitos Secundários sugeridos
# - Condições e Restrições sugeridas
# - Opções de personalização de funcionamento
#
# ============================================================

enum PresetId {
	CRIAR_DO_ZERO,
	ROUBAR_HABILIDADES,
	DRENAR_NEN,
	COPIAR_HATSU,
	ARMAZENAR_HATSU,
	LIVRO_HABILIDADES,
	ABSORVER_PODER,
	SELAR_HATSU,
	TRANSFERIR_HATSU,
	ROUBAR_ATRIBUTOS,
	TRANSFORMACAO_ESPECIAL,
	CRIAR_REGRAS,
	MANIPULAR_PROBABILIDADE,
	TROCAR_PROPRIEDADES,
	HATSU_EVOLUTIVO,
	# --- Expansão temática (inspiração anime; nomes originais do jogo) ---
	SOCO_CARREGADO,
	PALMA_CURATIVA,
	CORPO_COLOSSAL,
	PROJETIL_AURA,
	DIVIDA_INTERESSE,
	FUMACA_SOLDADOS,
	MARCA_REMOTA,
	GOMA_ELASTICA,
	LAMINAS_DEDOS,
	EXPLOSAO_DOR,
	ESTATUA_ORACAO,
	ASPIRADOR_NEN,
	CARTAS_DESTINO,
	FIOS_COSTURA,
	AGULHAS_MARIONETE,
	DISPOSITIVO_AUTO,
	BALA_MEMORIA,
	ORACAO_COMBATE
}


static func obter_todos_presets() -> Array[Dictionary]:
	return [
		# 1. ROUBAR HABILIDADES (Ability Theft)
		{
			"id": PresetId.ROUBAR_HABILIDADES,
			"slug": "roubar_habilidades",
			"nome": "🗡️ Roubar Habilidades",
			"titulo_conceito": "Roubo de Hatsu (Ability Theft)",
			"categoria": HatsuData.Categoria.ESPECIALIZACAO,
			"arquetipo": HatsuData.Arquetipo.LIVRO_COLECAO,
			"core": HatsuComponentLibrary.CoreType.ABSORPTION,
			"efeito_principal": HatsuComponentLibrary.EffectType.AURA_DRAIN,
			"objetivo": HatsuData.ObjetivoPrincipal.CONTROLE,
			"forma": HatsuData.Forma.TOQUE,
			"alvo": HatsuData.Alvo.INIMIGO_UNICO,
			"elemento": HatsuData.Elemento.NEN_PURO,
			"efeitos_secundarios": [HatsuComponentLibrary.EffectType.STUN],
			"condicoes": [HatsuData.Condicao.REVELACAO_HABILIDADE, HatsuData.Condicao.CURTO_ALCANCE_EXTREMO],
			"restricoes": [HatsuComponentLibrary.RestrictionType.TOUCH_REQUIRED, HatsuComponentLibrary.RestrictionType.CANNOT_USE_OTHER_HATSU],
			"preparation_steps": [
				{"id": "step_1", "description": "Tocar a palma da mão no oponente", "action_required": "TOQUE_FISICO", "time_required": 0.0, "credit_value": 30.0},
				{"id": "step_2", "description": "Observar o Hatsu do oponente em ação", "action_required": "OBSERVAR", "time_required": 0.0, "credit_value": 30.0},
				{"id": "step_3", "description": "Fazer o oponente revelar seu funcionamento", "action_required": "INTERROGATORIO", "time_required": 0.0, "credit_value": 35.0}
			],
			"custom_vow_sugerido": "Preciso tocar a palma da mão no oponente após ele usar sua habilidade para roubar seu Hatsu.",
			"opcoes_funcionamento": {
				"metodo": ["Tocar no alvo", "Derrotar o alvo", "Fazer o alvo revelar o Hatsu", "Cumprir 4 condições estritas", "Utilizar um item"],
				"o_que_roubado": ["Hatsu inteiro", "Efeito específico", "Propriedade", "Técnica primária"],
				"duracao": ["Temporário (60s)", "Permanente até descarte", "Enquanto o alvo estiver vivo"]
			},
			"desc": "Extrai e confisca a técnica de Nen de oponentes após satisfazer condições táticas rigorosas."
		},

		# 2. DRENAR NEN (Aura Drain)
		{
			"id": PresetId.DRENAR_NEN,
			"slug": "drenar_nen",
			"nome": "🩸 Drenar Nen",
			"titulo_conceito": "Dreno e Esgotamento de Aura",
			"categoria": HatsuData.Categoria.ESPECIALIZACAO,
			"arquetipo": HatsuData.Arquetipo.SIMPLES,
			"core": HatsuComponentLibrary.CoreType.STRIKE,
			"efeito_principal": HatsuComponentLibrary.EffectType.AURA_DRAIN,
			"objetivo": HatsuData.ObjetivoPrincipal.CONTROLE,
			"forma": HatsuData.Forma.TOQUE,
			"alvo": HatsuData.Alvo.INIMIGO_UNICO,
			"elemento": HatsuData.Elemento.SOMBRA,
			"efeitos_secundarios": [HatsuComponentLibrary.EffectType.AURA_GAIN, HatsuComponentLibrary.EffectType.SLOW],
			"condicoes": [HatsuData.Condicao.CURTO_ALCANCE_EXTREMO],
			"restricoes": [HatsuComponentLibrary.RestrictionType.TOUCH_REQUIRED],
			"custom_vow_sugerido": "Ao golpear o alvo, dreno sua energia vital de Nen para abastecer minhas próprias reservas.",
			"opcoes_funcionamento": {
				"destino_aura": ["Transferida para o usuário (+Aura)", "Descartada / Queimada", "Armazenada em reserva temporária"],
				"velocidade_dreno": ["Instantâneo por golpe", "Contínuo por segundo", "Detonação ao acumular 5 marcas"],
				"alcance_dreno": ["Toque físico direto", "Curta distância (raio de 3m)", "Fios de aura conectados"]
			},
			"desc": "Força a queima da aura do alvo a cada contato, transferindo ou dissipando a energia Nen do oponente."
		},

		# 3. LIVRO DE HABILIDADES (Skill Hunter / Grimoire)
		{
			"id": PresetId.LIVRO_HABILIDADES,
			"slug": "livro_habilidades",
			"nome": "📖 Livro de Habilidades",
			"titulo_conceito": "Grimório de Nen (Skill Hunter)",
			"categoria": HatsuData.Categoria.ESPECIALIZACAO,
			"arquetipo": HatsuData.Arquetipo.LIVRO_COLECAO,
			"core": HatsuComponentLibrary.CoreType.SUMMON,
			"efeito_principal": HatsuComponentLibrary.EffectType.INFORMATION,
			"objetivo": HatsuData.ObjetivoPrincipal.SUPORTE,
			"forma": HatsuData.Forma.PESSOAL,
			"alvo": HatsuData.Alvo.PROPRIO_USUARIO,
			"elemento": HatsuData.Elemento.NEN_PURO,
			"efeitos_secundarios": [HatsuComponentLibrary.EffectType.DEVOUR_STATS],
			"condicoes": [HatsuData.Condicao.REVELACAO_HABILIDADE],
			"restricoes": [HatsuComponentLibrary.RestrictionType.ANNOUNCE_ABILITY, HatsuComponentLibrary.RestrictionType.CANNOT_USE_OTHER_HATSU],
			"preparation_steps": [
				{"id": "step_1", "description": "Materializar o Grimório de Nen", "action_required": "CONJURAR_LIVRO", "time_required": 1.0, "credit_value": 25.0},
				{"id": "step_2", "description": "Manter a página aberta com a mão direita", "action_required": "CANALIZAR_LIVRO", "time_required": 0.0, "credit_value": 30.0},
				{"id": "step_3", "description": "Cumprir ritual de registro com o oponente", "action_required": "REGISTRO_NEN", "time_required": 0.0, "credit_value": 40.0}
			],
			"custom_vow_sugerido": "Materializo um livro de Nen que cataloga e permite invocar técnicas registradas pelo mundo.",
			"opcoes_funcionamento": {
				"capacidade": ["3 habilidades", "5 habilidades", "10 páginas (com Marcador Duplo)"],
				"requisito_uso": ["Manter o livro aberto na mão", "Gastar dobro de aura", "Uso com marcador"],
				"metodo_registro": ["4 condições de Chrollo", "Derrota em duelo individual", "Estudo e pacto amigável"]
			},
			"desc": "Materializa um grimório místico que armazena múltiplas técnicas para alternar e conjurar em combate."
		},

		# 4. COPIAR HATSU (Copy Hatsu)
		{
			"id": PresetId.COPIAR_HATSU,
			"slug": "copiar_hatsu",
			"nome": "🪞 Copiar Hatsu",
			"titulo_conceito": "Mimetismo e Cópia de Hatsu",
			"categoria": HatsuData.Categoria.TRANSFORMACAO,
			"arquetipo": HatsuData.Arquetipo.SIMPLES,
			"core": HatsuComponentLibrary.CoreType.TRANSFORMATION,
			"efeito_principal": HatsuComponentLibrary.EffectType.REFLECTION,
			"objetivo": HatsuData.ObjetivoPrincipal.DANO,
			"forma": HatsuData.Forma.PESSOAL,
			"alvo": HatsuData.Alvo.PROPRIO_USUARIO,
			"elemento": HatsuData.Elemento.NEN_PURO,
			"efeitos_secundarios": [HatsuComponentLibrary.EffectType.STAT_MOD],
			"condicoes": [HatsuData.Condicao.REVELACAO_HABILIDADE, HatsuData.Condicao.APOS_ESQUIVA_PERFEITA],
			"restricoes": [HatsuComponentLibrary.RestrictionType.SINGLE_TARGET_LOCK],
			"custom_vow_sugerido": "Ao testemunhar e esquivar com perfeição do Hatsu inimigo, posso mimetizar sua técnica no combate.",
			"opcoes_funcionamento": {
				"metodo_copia": ["Observar a técnica com Gyo", "Receber o dano do ataque", "Esquiva perfeita no último segundo"],
				"o_que_copiar": ["Hatsu inteiro", "Propriedade elemental", "Potência do golpe"],
				"duracao": ["Uso único em contra-ataque", "Duração de 30 segundos", "Enquanto durar o combate"]
			},
			"desc": "Mimetiza a forma e elemento de ataques inimigos após analisá-los com Gyo ou esquiva precisa."
		},

		# 5. ARMAZENAR HATSU (Hatsu Storage)
		{
			"id": PresetId.ARMAZENAR_HATSU,
			"slug": "armazenar_hatsu",
			"nome": "📦 Armazenar Hatsu",
			"titulo_conceito": "Reservatório & Bateria de Hatsu",
			"categoria": HatsuData.Categoria.EMISSAO,
			"arquetipo": HatsuData.Arquetipo.SIMPLES,
			"core": HatsuComponentLibrary.CoreType.SUMMON,
			"efeito_principal": HatsuComponentLibrary.EffectType.AURA_GAIN,
			"objetivo": HatsuData.ObjetivoPrincipal.SUPORTE,
			"forma": HatsuData.Forma.PESSOAL,
			"alvo": HatsuData.Alvo.PROPRIO_USUARIO,
			"elemento": HatsuData.Elemento.NEN_PURO,
			"efeitos_secundarios": [HatsuComponentLibrary.EffectType.SHIELD],
			"condicoes": [HatsuData.Condicao.PARADO_CANALIZACAO],
			"restricoes": [HatsuComponentLibrary.RestrictionType.IMMOBILE_DURING_USE],
			"custom_vow_sugerido": "Acumulo e condenso minha própria aura durante repouso para liberar rajadas em momento crítico.",
			"opcoes_funcionamento": {
				"capacidade_reserva": ["Bateria pequena (+25% Aura)", "Bateria média (+50% Aura)", "Super-reserva (+100% Aura)"],
				"gatilho_liberacao": ["Ativação manual", "Liberação automática ao chegar a 20% HP", "Ao quebrar o escudo"]
			},
			"desc": "Armazena cargas extras de aura condensada que podem ser liberadas instantaneamente em batalha."
		},

		# 6. ABSORVER PODER (Power Absorption / Stat Devour)
		{
			"id": PresetId.ABSORVER_PODER,
			"slug": "absorver_poder",
			"nome": "🌀 Absorver Poder",
			"titulo_conceito": "Predação & Extração Vital (Devour)",
			"categoria": HatsuData.Categoria.ESPECIALIZACAO,
			"arquetipo": HatsuData.Arquetipo.SIMPLES,
			"core": HatsuComponentLibrary.CoreType.ABSORPTION,
			"efeito_principal": HatsuComponentLibrary.EffectType.DEVOUR_STATS,
			"objetivo": HatsuData.ObjetivoPrincipal.DANO,
			"forma": HatsuData.Forma.TOQUE,
			"alvo": HatsuData.Alvo.INIMIGO_UNICO,
			"elemento": HatsuData.Elemento.SOMBRA,
			"efeitos_secundarios": [HatsuComponentLibrary.EffectType.HEALING, HatsuComponentLibrary.EffectType.STAT_MOD],
			"condicoes": [HatsuData.Condicao.ALMAS_INIMIGOS],
			"restricoes": [HatsuComponentLibrary.RestrictionType.TOUCH_REQUIRED],
			"custom_vow_sugerido": "Ao derrotar uma presa com Nen, absorvo frações de sua força física e densidade de aura.",
			"opcoes_funcionamento": {
				"o_que_absorver": ["Aura e Aura Máxima", "Força física (+Dano)", "Defesa corporal (+Ten)", "Velocidade e Reflexos"],
				"duracao": ["Temporário (buff de combate)", "Cumulativo até descanso", "Permanente por abates raros"]
			},
			"desc": "Converte a energia e atributos vitais de oponentes derrotados em fortalecimento contínuo."
		},

		# 7. SELAR HATSU (Zetsu Forçado / Selamento)
		{
			"id": PresetId.SELAR_HATSU,
			"slug": "selar_hatsu",
			"nome": "⛓️ Selar Hatsu",
			"titulo_conceito": "Imposição de Zetsu & Correntes de Restrição",
			"categoria": HatsuData.Categoria.CONJURACAO,
			"arquetipo": HatsuData.Arquetipo.CONTRATO_DUELO,
			"core": HatsuComponentLibrary.CoreType.SUMMON,
			"efeito_principal": HatsuComponentLibrary.EffectType.STUN,
			"objetivo": HatsuData.ObjetivoPrincipal.CONTROLE,
			"forma": HatsuData.Forma.PROJETIL,
			"alvo": HatsuData.Alvo.INIMIGO_UNICO,
			"elemento": HatsuData.Elemento.NEN_PURO,
			"efeitos_secundarios": [HatsuComponentLibrary.EffectType.AURA_DRAIN],
			"condicoes": [HatsuData.Condicao.ALVO_ELITE_BOSS],
			"restricoes": [HatsuComponentLibrary.RestrictionType.DEATH_PENALTY_ON_MISS, HatsuComponentLibrary.RestrictionType.SINGLE_TARGET_LOCK],
			"preparation_steps": [
				{"id": "step_1", "description": "Declarar o oponente como alvo exclusivo do juramento", "action_required": "DECLARACAO", "time_required": 0.0, "credit_value": 35.0},
				{"id": "step_2", "description": "Envolver o oponente com a Corrente de Julgamento", "action_required": "CONJURAR_CORRENTE", "time_required": 0.0, "credit_value": 45.0}
			],
			"custom_vow_sugerido": "Corrente inquebrável que impõe Zetsu forçado no oponente. Se usada fora do juramento, sofro punição de vida.",
			"opcoes_funcionamento": {
				"efeito_selo": ["Zetsu Forçado total (desativa Nen)", "Trava de Hatsu (impede técnicas)", "Imobilização física absoluta"],
				"duracao_selo": ["5 segundos", "10 segundos", "Até quebrar o vínculo físico"]
			},
			"desc": "Conjura correntes ou selos inquebráveis que forçam o oponente a entrar no estado de Zetsu absoluto."
		},

		# 8. TRANSFERIR HATSU (Transfer Hatsu / Empréstimo)
		{
			"id": PresetId.TRANSFERIR_HATSU,
			"slug": "transferir_hatsu",
			"nome": "🤝 Transferir Hatsu",
			"titulo_conceito": "Empréstimo & Concessão de Nen",
			"categoria": HatsuData.Categoria.EMISSAO,
			"arquetipo": HatsuData.Arquetipo.SIMPLES,
			"core": HatsuComponentLibrary.CoreType.PROJECTILE,
			"efeito_principal": HatsuComponentLibrary.EffectType.STAT_MOD,
			"objetivo": HatsuData.ObjetivoPrincipal.SUPORTE,
			"forma": HatsuData.Forma.TOQUE,
			"alvo": HatsuData.Alvo.ALIADO,
			"elemento": HatsuData.Elemento.LUZ,
			"efeitos_secundarios": [HatsuComponentLibrary.EffectType.AURA_GAIN, HatsuComponentLibrary.EffectType.SHIELD],
			"condicoes": [HatsuData.Condicao.CURTO_ALCANCE_EXTREMO],
			"restricoes": [HatsuComponentLibrary.RestrictionType.SACRIFICE_HP],
			"preparation_steps": [],
			"custom_vow_sugerido": "Transfiro parte da minha própria aura e uma técnica para um companheiro de combate.",
			"opcoes_funcionamento": {
				"o_que_conceder": ["Buff massivo de ataque (+50% Força)", "Escudo compartilhado de Ren", "Empréstimo de uma técnica secundária"],
				"custo_usuario": ["Consumo dobrado de aura", "Zetsu temporário após concessão", "Vínculo de dano compartilhado"]
			},
			"desc": "Concede porções de sua aura ou habilidades temporárias a aliados para amplificar o trabalho em equipe."
		},

		# 9. ROUBAR ATRIBUTOS (Stat Steal / Debuff para Buff)
		{
			"id": PresetId.ROUBAR_ATRIBUTOS,
			"slug": "roubar_atributos",
			"nome": "📉 Roubar Atributos",
			"titulo_conceito": "Trocação Desigual & Dreno de Status",
			"categoria": HatsuData.Categoria.MANIPULACAO,
			"arquetipo": HatsuData.Arquetipo.SIMPLES,
			"core": HatsuComponentLibrary.CoreType.STRIKE,
			"efeito_principal": HatsuComponentLibrary.EffectType.STAT_MOD,
			"objetivo": HatsuData.ObjetivoPrincipal.CONTROLE,
			"forma": HatsuData.Forma.TOQUE,
			"alvo": HatsuData.Alvo.INIMIGO_UNICO,
			"elemento": HatsuData.Elemento.VENENO,
			"efeitos_secundarios": [HatsuComponentLibrary.EffectType.SLOW],
			"condicoes": [HatsuData.Condicao.CURTO_ALCANCE_EXTREMO],
			"restricoes": [HatsuComponentLibrary.RestrictionType.TOUCH_REQUIRED],
			"preparation_steps": [],
			"custom_vow_sugerido": "A cada soco desferido, reduzo a velocidade e defesa do oponente enquanto aumento as minhas.",
			"opcoes_funcionamento": {
				"atributo_alvo": ["Velocidade (-Alvo / +Usuário)", "Defesa corporal (-Ten / +Ten)", "Força de impacto (-Dano / +Dano)"],
				"acumulo": ["Até 3 acúmulos por combate", "Acúmulo infinito com decaimento", "Transferência em pulso único"]
			},
			"desc": "Reduz gradualmente atributos vitais do oponente e transfere os mesmos bônus diretamente para o usuário."
		},

		# 10. TRANSFORMAÇÃO ESPECIAL (Body / Neural Morph / Mode)
		{
			"id": PresetId.TRANSFORMACAO_ESPECIAL,
			"slug": "transformacao_especial",
			"nome": "⚡ Transformação Especial",
			"titulo_conceito": "Modo de Aura & Transmutação Neural",
			"categoria": HatsuData.Categoria.TRANSFORMACAO,
			"arquetipo": HatsuData.Arquetipo.SIMPLES,
			"core": HatsuComponentLibrary.CoreType.TRANSFORMATION,
			"efeito_principal": HatsuComponentLibrary.EffectType.STAT_MOD,
			"objetivo": HatsuData.ObjetivoPrincipal.MOBILIDADE,
			"forma": HatsuData.Forma.PESSOAL,
			"alvo": HatsuData.Alvo.PROPRIO_USUARIO,
			"elemento": HatsuData.Elemento.ELETRICIDADE,
			"efeitos_secundarios": [HatsuComponentLibrary.EffectType.MOVEMENT_DASH, HatsuComponentLibrary.EffectType.DAMAGE],
			"condicoes": [HatsuData.Condicao.AURA_MINIMA_50],
			"restricoes": [HatsuComponentLibrary.RestrictionType.SACRIFICE_AURA_MAX],
			"preparation_steps": [],
			"custom_vow_sugerido": "Transmuto minha aura em impulsos bioelétricos para alcançar reflexos e velocidade ultrassônicos (Godspeed).",
			"opcoes_funcionamento": {
				"tipo_transformacao": ["Velocidade Relâmpago (+100% Vel / Dash)", "Couraça de Diamante (+80% Defesa / Super-Armadura)", "Corpo Incandescente (Dano contínuo de contato)"],
				"sustentacao": ["Dreno contínuo de 2.0 aura/segundo", "Duração fixa de 12 segundos", "Até esgotar a aura"]
			},
			"desc": "Altera o estado físico ou bioelétrico do corpo através de Nen sustentado de altíssima intensidade."
		},

		# 11. CRIAR REGRAS (Zone Rule / Território)
		{
			"id": PresetId.CRIAR_REGRAS,
			"slug": "criar_regras",
			"nome": "📐 Criar Regras (Território)",
			"titulo_conceito": "Domínio de En com Leis Invioláveis",
			"categoria": HatsuData.Categoria.ESPECIALIZACAO,
			"arquetipo": HatsuData.Arquetipo.TERRITORIO_EN,
			"core": HatsuComponentLibrary.CoreType.RULE_ZONE,
			"efeito_principal": HatsuComponentLibrary.EffectType.RULE_ENFORCE,
			"objetivo": HatsuData.ObjetivoPrincipal.CONTROLE,
			"forma": HatsuData.Forma.ZONA,
			"alvo": HatsuData.Alvo.AREA,
			"elemento": HatsuData.Elemento.NEN_PURO,
			"efeitos_secundarios": [HatsuComponentLibrary.EffectType.AURA_DRAIN, HatsuComponentLibrary.EffectType.STUN],
			"condicoes": [HatsuData.Condicao.PARADO_CANALIZACAO],
			"restricoes": [HatsuComponentLibrary.RestrictionType.ANNOUNCE_ABILITY, HatsuComponentLibrary.RestrictionType.IMMOBILE_DURING_USE],
			"preparation_steps": [
				{"id": "step_1", "description": "Expandir cúpula de En e permanecer imóvel", "action_required": "EN_EXPANSAO", "time_required": 1.5, "credit_value": 35.0},
				{"id": "step_2", "description": "Anunciar a regra territorial aos presentes", "action_required": "REVELAR_REGRA", "time_required": 0.0, "credit_value": 40.0}
			],
			"custom_vow_sugerido": "Dentro da minha cúpula de En, nenhuma violência física é permitida sem resposta punitiva imediata.",
			"opcoes_funcionamento": {
				"regra_imposta": ["Proibição de violência (quem atacar sofre dano)", "Imposição de Zetsu em área", "Duelo obrigatório de 1 contra 1"],
				"raio_dominio": ["Pequeno (raio de 80px)", "Médio (raio de 150px)", "Grande (raio de 250px)"]
			},
			"desc": "Expande o En territorial para impor leis de combate que penalizam qualquer entidade que as desrespeite."
		},

		# 12. MANIPULAR PROBABILIDADE (Crazy Slots / Dados / Roleta)
		{
			"id": PresetId.MANIPULAR_PROBABILIDADE,
			"slug": "manipular_probabilidade",
			"nome": "🎲 Manipular Probabilidade",
			"titulo_conceito": "Roleta do Destino & Dados de Nen",
			"categoria": HatsuData.Categoria.CONJURACAO,
			"arquetipo": HatsuData.Arquetipo.ARSENAL_ROLETA,
			"core": HatsuComponentLibrary.CoreType.SUMMON,
			"efeito_principal": HatsuComponentLibrary.EffectType.DAMAGE,
			"objetivo": HatsuData.ObjetivoPrincipal.DANO,
			"forma": HatsuData.Forma.PROJETIL,
			"alvo": HatsuData.Alvo.INIMIGO_UNICO,
			"elemento": HatsuData.Elemento.NEN_PURO,
			"efeitos_secundarios": [HatsuComponentLibrary.EffectType.AREA_BURST],
			"condicoes": [],
			"restricoes": [HatsuComponentLibrary.RestrictionType.CANNOT_USE_OTHER_HATSU],
			"custom_vow_sugerido": "Abro mão de escolher minha arma. Uma roleta mágica sorteia um armamento entre 1 e 6 com poder amplificado.",
			"opcoes_funcionamento": {
				"mecanica_sorteio": ["Roleta de 6 armas (Crazy Slots)", "Dado místico de 6 faces (multiplicador 1x a 6x)", "Moeda da sorte (Cara = Dano 2.5x / Coroa = Zetsu)"],
				"bonificacao_risco": ["+50% a +85% de poder por abrir mão de escolha", "Multiplicador crítico no número máximo"]
			},
			"desc": "Submete a manifestação do Hatsu a regras de aleatoriedade mística, ganhando bônus de poder massivos em troca."
		},

		# 13. TROCAR PROPRIEDADES (Property Transmutation)
		{
			"id": PresetId.TROCAR_PROPRIEDADES,
			"slug": "trocar_propriedades",
			"nome": "🧪 Trocar Propriedades",
			"titulo_conceito": "Transmutação de Propriedades da Aura",
			"categoria": HatsuData.Categoria.TRANSFORMACAO,
			"arquetipo": HatsuData.Arquetipo.SIMPLES,
			"core": HatsuComponentLibrary.CoreType.STRIKE,
			"efeito_principal": HatsuComponentLibrary.EffectType.DAMAGE,
			"objetivo": HatsuData.ObjetivoPrincipal.DANO,
			"forma": HatsuData.Forma.TOQUE,
			"alvo": HatsuData.Alvo.INIMIGO_UNICO,
			"elemento": HatsuData.Elemento.FOGO,
			"efeitos_secundarios": [HatsuComponentLibrary.EffectType.SLOW, HatsuComponentLibrary.EffectType.KNOCKBACK],
			"condicoes": [],
			"restricoes": [],
			"custom_vow_sugerido": "Transmuto minha aura para ter simultaneamente a elasticidade da borracha e a aderência do chiclete.",
			"opcoes_funcionamento": {
				"propriedade_primaria": ["Goma & Borracha (Aderência e Elasticidade)", "Fogo & Combustão (Queimadura)", "Gelo & Criogenia (Congelamento)"],
				"aplicacao": ["Revestimento corporal", "Armadilha no solo", "Projétil retrátil"]
			},
			"desc": "Combina múltiplas propriedades físicas ou químicas na aura para criar sinergias de combate únicas."
		},

		# 14. HATSU EVOLUTIVO (Progressive Evolution)
		{
			"id": PresetId.HATSU_EVOLUTIVO,
			"slug": "hatsu_evolutivo",
			"nome": "🌱 Hatsu Evolutivo",
			"titulo_conceito": "Técnica de Crescimento & Camadas de Nen",
			"categoria": HatsuData.Categoria.INTENSIFICACAO,
			"arquetipo": HatsuData.Arquetipo.SIMPLES,
			"core": HatsuComponentLibrary.CoreType.STRIKE,
			"efeito_principal": HatsuComponentLibrary.EffectType.DAMAGE,
			"objetivo": HatsuData.ObjetivoPrincipal.DANO,
			"forma": HatsuData.Forma.TOQUE,
			"alvo": HatsuData.Alvo.INIMIGO_UNICO,
			"elemento": HatsuData.Elemento.NEN_PURO,
			"efeitos_secundarios": [HatsuComponentLibrary.EffectType.PIERCING, HatsuComponentLibrary.EffectType.STAT_MOD],
			"condicoes": [HatsuData.Condicao.AURA_MINIMA_50],
			"restricoes": [],
			"custom_vow_sugerido": "Hatsu de domínio progressivo que desbloqueia novas camadas de potência a cada marco de nível alcançado.",
			"opcoes_funcionamento": {
				"estagio_evolucao": ["3 Estágios (Iniciante, Mestre, Supremo)", "5 Camadas de Potência", "Escala contínua por nível do personagem"]
			},
			"desc": "Técnica viva projetada para evoluir organicamente do nível 1 ao nível 100, expandindo seus efeitos."
		},


		# 16. SOCO CARREGADO (Intensificação — impacto canalizado)
		{
			"id": PresetId.SOCO_CARREGADO,
			"slug": "soco_carregado",
			"nome": "👊 Soco Carregado",
			"titulo_conceito": "Impacto Canalizado de Ko",
			"categoria": HatsuData.Categoria.INTENSIFICACAO,
			"arquetipo": HatsuData.Arquetipo.SIMPLES,
			"core": HatsuComponentLibrary.CoreType.STRIKE,
			"efeito_principal": HatsuComponentLibrary.EffectType.DAMAGE,
			"objetivo": HatsuData.ObjetivoPrincipal.DANO,
			"forma": HatsuData.Forma.TOQUE,
			"alvo": HatsuData.Alvo.INIMIGO_UNICO,
			"elemento": HatsuData.Elemento.NEN_PURO,
			"efeitos_secundarios": [HatsuComponentLibrary.EffectType.KNOCKBACK],
			"condicoes": [HatsuData.Condicao.PARADO_CANALIZACAO],
			"restricoes": [HatsuComponentLibrary.RestrictionType.IMMOBILE_DURING_USE],
			"preparation_steps": [
				{"id": "step_charge", "description": "Canalizar Ko no punho por 1.5s", "action_required": "CANALIZAR", "time_required": 1.5, "credit_value": 30.0}
			],
			"custom_vow_sugerido": "Permaneço imóvel enquanto concentro Ko no punho; se interrompido, perco o golpe.",
			"opcoes_funcionamento": {
				"carga": ["Curta (1s)", "Média (1.5s)", "Longa (3s — poder máximo)"],
				"forma_golpe": ["Soco direto", "Palmada explosiva", "Cotovelada de curto alcance"]
			},
			"desc": "Concentra aura no punho e libera um impacto devastador. Quanto maior a força pedida, mais votos são necessários."
		},

		# 17. PALMA CURATIVA
		{
			"id": PresetId.PALMA_CURATIVA,
			"slug": "palma_curativa",
			"nome": "🤲 Palma Curativa",
			"titulo_conceito": "Regeneração por Toque Intensificado",
			"categoria": HatsuData.Categoria.INTENSIFICACAO,
			"arquetipo": HatsuData.Arquetipo.SIMPLES,
			"core": HatsuComponentLibrary.CoreType.STRIKE,
			"efeito_principal": HatsuComponentLibrary.EffectType.HEALING,
			"objetivo": HatsuData.ObjetivoPrincipal.CURA,
			"forma": HatsuData.Forma.TOQUE,
			"alvo": HatsuData.Alvo.ALIADO,
			"elemento": HatsuData.Elemento.LUZ,
			"efeitos_secundarios": [HatsuComponentLibrary.EffectType.SHIELD],
			"condicoes": [HatsuData.Condicao.CURTO_ALCANCE_EXTREMO],
			"restricoes": [HatsuComponentLibrary.RestrictionType.TOUCH_REQUIRED],
			"custom_vow_sugerido": "Só curo quem tocar com a palma; em troca, minha aura é consumida no dobro.",
			"opcoes_funcionamento": {
				"foco": ["Cura rápida de combate", "Cura profunda fora de combate", "Escudo regenerativo curto"]
			},
			"desc": "Intensifica o fluxo vital por contato. Fora da afinidade natal a cura efetiva cai conforme o hexágono."
		},

		# 18. CORPO COLOSSAL
		{
			"id": PresetId.CORPO_COLOSSAL,
			"slug": "corpo_colossal",
			"nome": "🦍 Corpo Colossal",
			"titulo_conceito": "Hipertrofia de Aura Corporal",
			"categoria": HatsuData.Categoria.INTENSIFICACAO,
			"arquetipo": HatsuData.Arquetipo.SIMPLES,
			"core": HatsuComponentLibrary.CoreType.TRANSFORMATION,
			"efeito_principal": HatsuComponentLibrary.EffectType.STAT_MOD,
			"objetivo": HatsuData.ObjetivoPrincipal.DANO,
			"forma": HatsuData.Forma.PESSOAL,
			"alvo": HatsuData.Alvo.PROPRIO_USUARIO,
			"elemento": HatsuData.Elemento.NEN_PURO,
			"efeitos_secundarios": [HatsuComponentLibrary.EffectType.DAMAGE, HatsuComponentLibrary.EffectType.KNOCKBACK],
			"condicoes": [HatsuData.Condicao.AURA_MINIMA_50],
			"restricoes": [HatsuComponentLibrary.RestrictionType.CANNOT_USE_OTHER_HATSU],
			"custom_vow_sugerido": "Enquanto o modo colossal estiver ativo, não posso usar outras técnicas de Nen.",
			"opcoes_funcionamento": {
				"escala": ["+40% massa", "+80% massa", "Forma extrema (+120%)"]
			},
			"desc": "Amplifica força e massa corporal com Nen. Poder absurdo exige restrições pesadas de crédito."
		},

		# 19. PROJÉTIL DE AURA
		{
			"id": PresetId.PROJETIL_AURA,
			"slug": "projetil_aura",
			"nome": "💥 Projétil de Aura",
			"titulo_conceito": "Disparo de Emissão Concentrada",
			"categoria": HatsuData.Categoria.EMISSAO,
			"arquetipo": HatsuData.Arquetipo.SIMPLES,
			"core": HatsuComponentLibrary.CoreType.PROJECTILE,
			"efeito_principal": HatsuComponentLibrary.EffectType.DAMAGE,
			"objetivo": HatsuData.ObjetivoPrincipal.DANO,
			"forma": HatsuData.Forma.PROJETIL,
			"alvo": HatsuData.Alvo.INIMIGO_UNICO,
			"elemento": HatsuData.Elemento.NEN_PURO,
			"efeitos_secundarios": [HatsuComponentLibrary.EffectType.KNOCKBACK],
			"condicoes": [],
			"restricoes": [],
			"custom_vow_sugerido": "",
			"opcoes_funcionamento": {
				"formato": ["Esfera", "Lança", "Rajada em leque"]
			},
			"desc": "Emite aura condensada à distância. Emissores nativos mantêm 100%; conjuradores opostos sofrem 40%."
		},

		# 20. DÍVIDA & JUROS (estilo Hakoware temático)
		{
			"id": PresetId.DIVIDA_INTERESSE,
			"slug": "divida_interesse",
			"nome": "💳 Dívida & Juros",
			"titulo_conceito": "Contrato de Aura com Juros Compostos",
			"categoria": HatsuData.Categoria.EMISSAO,
			"arquetipo": HatsuData.Arquetipo.CONTRATO_DUELO,
			"core": HatsuComponentLibrary.CoreType.STRIKE,
			"efeito_principal": HatsuComponentLibrary.EffectType.AURA_DRAIN,
			"objetivo": HatsuData.ObjetivoPrincipal.CONTROLE,
			"forma": HatsuData.Forma.TOQUE,
			"alvo": HatsuData.Alvo.INIMIGO_UNICO,
			"elemento": HatsuData.Elemento.NEN_PURO,
			"efeitos_secundarios": [HatsuComponentLibrary.EffectType.STAT_MOD, HatsuComponentLibrary.EffectType.STUN],
			"condicoes": [HatsuData.Condicao.CURTO_ALCANCE_EXTREMO],
			"restricoes": [HatsuComponentLibrary.RestrictionType.ANNOUNCE_ABILITY, HatsuComponentLibrary.RestrictionType.TOUCH_REQUIRED],
			"preparation_steps": [
				{"id": "step_contract", "description": "Declarar o contrato de dívida ao alvo", "action_required": "DECLARACAO", "time_required": 0.0, "credit_value": 35.0}
			],
			"custom_vow_sugerido": "Ao tocar o alvo, imponho uma dívida de aura que cresce com juros até a falência do Nen.",
			"opcoes_funcionamento": {
				"juros": ["Baixos (seguro)", "Médios", "Extremos (falência rápida)"],
				"gatilho_falencia": ["Aura zerada", "HP crítico", "Tempo esgotado"]
			},
			"desc": "Emite um contrato de aura: o oponente acumula 'dívida' até colapsar. Força alta = votos duros."
		},

		# 21. FUMAÇA & SOLDADOS
		{
			"id": PresetId.FUMACA_SOLDADOS,
			"slug": "fumaca_soldados",
			"nome": "🌫️ Fumaça & Soldados",
			"titulo_conceito": "Constructos de Fumaça Emitida",
			"categoria": HatsuData.Categoria.EMISSAO,
			"arquetipo": HatsuData.Arquetipo.SIMPLES,
			"core": HatsuComponentLibrary.CoreType.SUMMON,
			"efeito_principal": HatsuComponentLibrary.EffectType.DAMAGE,
			"objetivo": HatsuData.ObjetivoPrincipal.CONTROLE,
			"forma": HatsuData.Forma.AREA,
			"alvo": HatsuData.Alvo.AREA,
			"elemento": HatsuData.Elemento.VENENO,
			"efeitos_secundarios": [HatsuComponentLibrary.EffectType.SLOW, HatsuComponentLibrary.EffectType.SHIELD],
			"condicoes": [HatsuData.Condicao.PARADO_CANALIZACAO],
			"restricoes": [HatsuComponentLibrary.RestrictionType.IMMOBILE_DURING_USE],
			"custom_vow_sugerido": "Preciso permanecer imóvel soprando fumaça para manter os soldados ativos.",
			"opcoes_funcionamento": {
				"quantidade": ["2 soldados", "4 soldados", "Nuvem densa (controle de área)"]
			},
			"desc": "Emite constructos semi-autônomos de fumaça. Controle e dano escalam com a força pedida."
		},

		# 22. MARCA REMOTA
		{
			"id": PresetId.MARCA_REMOTA,
			"slug": "marca_remota",
			"nome": "🏷️ Marca Remota",
			"titulo_conceito": "Marcação & Detonação à Distância",
			"categoria": HatsuData.Categoria.EMISSAO,
			"arquetipo": HatsuData.Arquetipo.MARCA_TAG,
			"core": HatsuComponentLibrary.CoreType.PROJECTILE,
			"efeito_principal": HatsuComponentLibrary.EffectType.DAMAGE,
			"objetivo": HatsuData.ObjetivoPrincipal.DANO,
			"forma": HatsuData.Forma.PROJETIL,
			"alvo": HatsuData.Alvo.INIMIGO_UNICO,
			"elemento": HatsuData.Elemento.NEN_PURO,
			"efeitos_secundarios": [HatsuComponentLibrary.EffectType.TRACKING],
			"condicoes": [],
			"restricoes": [HatsuComponentLibrary.RestrictionType.SINGLE_TARGET_LOCK],
			"custom_vow_sugerido": "Só posso detonar marcas que eu mesmo apliquei; marcas erradas voltam contra mim.",
			"opcoes_funcionamento": {
				"modo": ["Detonação manual", "Contagem regressiva", "Gatilho por proximidade"]
			},
			"desc": "Planta marcas de aura e explode à distância. Ideal para caçadores de longo alcance."
		},

		# 23. GOMA ELÁSTICA
		{
			"id": PresetId.GOMA_ELASTICA,
			"slug": "goma_elastica",
			"nome": "🎴 Goma Elástica",
			"titulo_conceito": "Aura com Elasticidade & Aderência",
			"categoria": HatsuData.Categoria.TRANSFORMACAO,
			"arquetipo": HatsuData.Arquetipo.SIMPLES,
			"core": HatsuComponentLibrary.CoreType.TRANSFORMATION,
			"efeito_principal": HatsuComponentLibrary.EffectType.DAMAGE,
			"objetivo": HatsuData.ObjetivoPrincipal.CONTROLE,
			"forma": HatsuData.Forma.TOQUE,
			"alvo": HatsuData.Alvo.INIMIGO_UNICO,
			"elemento": HatsuData.Elemento.NEN_PURO,
			"efeitos_secundarios": [HatsuComponentLibrary.EffectType.SLOW, HatsuComponentLibrary.EffectType.KNOCKBACK],
			"condicoes": [],
			"restricoes": [],
			"custom_vow_sugerido": "Transmuto minha aura em goma adesiva: gruda, estica e rebate.",
			"opcoes_funcionamento": {
				"uso": ["Armadilha no chão", "Projétil retrátil", "Revestimento corporal"]
			},
			"desc": "Transmutação clássica de propriedades físicas. Força lendária ainda exige votos — nada é de graça."
		},

		# 24. LÂMINAS NOS DEDOS
		{
			"id": PresetId.LAMINAS_DEDOS,
			"slug": "laminas_dedos",
			"nome": "✂️ Lâminas nos Dedos",
			"titulo_conceito": "Aura Afiada em Forma de Lâmina",
			"categoria": HatsuData.Categoria.TRANSFORMACAO,
			"arquetipo": HatsuData.Arquetipo.SIMPLES,
			"core": HatsuComponentLibrary.CoreType.STRIKE,
			"efeito_principal": HatsuComponentLibrary.EffectType.DAMAGE,
			"objetivo": HatsuData.ObjetivoPrincipal.DANO,
			"forma": HatsuData.Forma.TOQUE,
			"alvo": HatsuData.Alvo.INIMIGO_UNICO,
			"elemento": HatsuData.Elemento.NEN_PURO,
			"efeitos_secundarios": [HatsuComponentLibrary.EffectType.PIERCING],
			"condicoes": [],
			"restricoes": [],
			"custom_vow_sugerido": "Transmuto os dedos em lâminas de aura: alto corte, baixo alcance.",
			"opcoes_funcionamento": {
				"perfil": ["Corte rápido", "Perfuração profunda", "Combo de fatiamento"]
			},
			"desc": "Transforma aura em fio cortante. Efetividade total só com afinidade de Transformação natal."
		},

		# 25. EXPLOSÃO DE DOR
		{
			"id": PresetId.EXPLOSAO_DOR,
			"slug": "explosao_dor",
			"nome": "🔥 Explosão de Dor",
			"titulo_conceito": "Conversão de Dor em Rajada de Aura",
			"categoria": HatsuData.Categoria.TRANSFORMACAO,
			"arquetipo": HatsuData.Arquetipo.SIMPLES,
			"core": HatsuComponentLibrary.CoreType.ZONE,
			"efeito_principal": HatsuComponentLibrary.EffectType.DAMAGE,
			"objetivo": HatsuData.ObjetivoPrincipal.DANO,
			"forma": HatsuData.Forma.AREA,
			"alvo": HatsuData.Alvo.AREA,
			"elemento": HatsuData.Elemento.FOGO,
			"efeitos_secundarios": [HatsuComponentLibrary.EffectType.KNOCKBACK, HatsuComponentLibrary.EffectType.STUN],
			"condicoes": [HatsuData.Condicao.HP_ABAIXO_50],
			"restricoes": [HatsuComponentLibrary.RestrictionType.SACRIFICE_HP],
			"custom_vow_sugerido": "Só libero a explosão após acumular dor real; quanto mais ferido, mais devastador.",
			"opcoes_funcionamento": {
				"gatilho": ["HP < 50%", "HP < 30%", "Após receber 3 golpes"]
			},
			"desc": "Converte dano sofrido em detonação. Pedir força 200+ força votos extremos de sacrifício."
		},

		# 26. ESTÁTUA DE ORAÇÃO
		{
			"id": PresetId.ESTATUA_ORACAO,
			"slug": "estatua_oracao",
			"nome": "🙏 Estátua de Oração",
			"titulo_conceito": "Conjuração Ritual de Estátua Multi-Braços",
			"categoria": HatsuData.Categoria.CONJURACAO,
			"arquetipo": HatsuData.Arquetipo.SIMPLES,
			"core": HatsuComponentLibrary.CoreType.SUMMON,
			"efeito_principal": HatsuComponentLibrary.EffectType.DAMAGE,
			"objetivo": HatsuData.ObjetivoPrincipal.DANO,
			"forma": HatsuData.Forma.PESSOAL,
			"alvo": HatsuData.Alvo.INIMIGO_UNICO,
			"elemento": HatsuData.Elemento.LUZ,
			"efeitos_secundarios": [HatsuComponentLibrary.EffectType.STAT_MOD, HatsuComponentLibrary.EffectType.MOVEMENT_DASH],
			"condicoes": [HatsuData.Condicao.PARADO_CANALIZACAO],
			"restricoes": [HatsuComponentLibrary.RestrictionType.ANNOUNCE_ABILITY],
			"preparation_steps": [
				{"id": "step_pray", "description": "Completar ciclo de gratidão/oração", "action_required": "ORACAO", "time_required": 1.0, "credit_value": 40.0}
			],
			"custom_vow_sugerido": "Só manifesto a estátua após o ritual de gratidão; sem oração, sem poder.",
			"opcoes_funcionamento": {
				"modo": ["Rajada de palmas", "Barreira de braços", "Combo ultrarrápido"]
			},
			"desc": "Conjura uma estátua ritual de Nen. Intensificadores nativos sofrem eficiência reduzida (hexágono)."
		},

		# 27. ASPIRADOR DE NEN
		{
			"id": PresetId.ASPIRADOR_NEN,
			"slug": "aspirador_nen",
			"nome": "🧹 Aspirador de Nen",
			"titulo_conceito": "Objeto Conjurado que Consome Matéria/Aura",
			"categoria": HatsuData.Categoria.CONJURACAO,
			"arquetipo": HatsuData.Arquetipo.SIMPLES,
			"core": HatsuComponentLibrary.CoreType.SUMMON,
			"efeito_principal": HatsuComponentLibrary.EffectType.AURA_DRAIN,
			"objetivo": HatsuData.ObjetivoPrincipal.CONTROLE,
			"forma": HatsuData.Forma.TOQUE,
			"alvo": HatsuData.Alvo.INIMIGO_UNICO,
			"elemento": HatsuData.Elemento.SOMBRA,
			"efeitos_secundarios": [HatsuComponentLibrary.EffectType.SLOW],
			"condicoes": [],
			"restricoes": [HatsuComponentLibrary.RestrictionType.CANNOT_USE_OTHER_HATSU],
			"custom_vow_sugerido": "Enquanto o aspirador existir, não posso conjurar outro objeto.",
			"opcoes_funcionamento": {
				"alvo_consumo": ["Aura do oponente", "Projéteis inimigos", "Objetos do cenário"]
			},
			"desc": "Materializa um aparato que engole aura e matéria. Versátil, mas caro em créditos se forçado."
		},

		# 28. CARTAS DO DESTINO
		{
			"id": PresetId.CARTAS_DESTINO,
			"slug": "cartas_destino",
			"nome": "🃏 Cartas do Destino",
			"titulo_conceito": "Baralho Conjurado de Efeitos Variados",
			"categoria": HatsuData.Categoria.CONJURACAO,
			"arquetipo": HatsuData.Arquetipo.ARSENAL_ROLETA,
			"core": HatsuComponentLibrary.CoreType.SUMMON,
			"efeito_principal": HatsuComponentLibrary.EffectType.DAMAGE,
			"objetivo": HatsuData.ObjetivoPrincipal.DANO,
			"forma": HatsuData.Forma.PROJETIL,
			"alvo": HatsuData.Alvo.INIMIGO_UNICO,
			"elemento": HatsuData.Elemento.NEN_PURO,
			"efeitos_secundarios": [HatsuComponentLibrary.EffectType.STUN, HatsuComponentLibrary.EffectType.SHIELD],
			"condicoes": [],
			"restricoes": [],
			"custom_vow_sugerido": "Cada carta sorteada define o efeito; não posso escolher o resultado.",
			"opcoes_funcionamento": {
				"baralho": ["Ofensivo", "Suporte", "Misto (maior risco/recompensa)"]
			},
			"desc": "Conjura um baralho cujos efeitos mudam por carta. Liberdade total de força + votos."
		},

		# 29. FIOS DE COSTURA
		{
			"id": PresetId.FIOS_COSTURA,
			"slug": "fios_costura",
			"nome": "🧵 Fios de Costura",
			"titulo_conceito": "Fios Conjurados de Sutura & Controle",
			"categoria": HatsuData.Categoria.CONJURACAO,
			"arquetipo": HatsuData.Arquetipo.SIMPLES,
			"core": HatsuComponentLibrary.CoreType.SUMMON,
			"efeito_principal": HatsuComponentLibrary.EffectType.HEALING,
			"objetivo": HatsuData.ObjetivoPrincipal.SUPORTE,
			"forma": HatsuData.Forma.TOQUE,
			"alvo": HatsuData.Alvo.ALIADO,
			"elemento": HatsuData.Elemento.NEN_PURO,
			"efeitos_secundarios": [HatsuComponentLibrary.EffectType.STUN, HatsuComponentLibrary.EffectType.STAT_MOD],
			"condicoes": [HatsuData.Condicao.CURTO_ALCANCE_EXTREMO],
			"restricoes": [HatsuComponentLibrary.RestrictionType.TOUCH_REQUIRED],
			"custom_vow_sugerido": "Os fios só funcionam se eu suturar com as próprias mãos.",
			"opcoes_funcionamento": {
				"uso": ["Sutura de feridas", "Imobilizar alvo", "Reforçar tecido/armadura"]
			},
			"desc": "Conjura fios de Nen para curar ou prender. Eficácia plena para conjuradores nativos."
		},

		# 30. AGULHAS MARIONETE
		{
			"id": PresetId.AGULHAS_MARIONETE,
			"slug": "agulhas_marionete",
			"nome": "🪡 Agulhas Marionete",
			"titulo_conceito": "Manipulação por Agulhas de Nen",
			"categoria": HatsuData.Categoria.MANIPULACAO,
			"arquetipo": HatsuData.Arquetipo.SIMPLES,
			"core": HatsuComponentLibrary.CoreType.STRIKE,
			"efeito_principal": HatsuComponentLibrary.EffectType.STUN,
			"objetivo": HatsuData.ObjetivoPrincipal.CONTROLE,
			"forma": HatsuData.Forma.PROJETIL,
			"alvo": HatsuData.Alvo.INIMIGO_UNICO,
			"elemento": HatsuData.Elemento.VENENO,
			"efeitos_secundarios": [HatsuComponentLibrary.EffectType.STAT_MOD, HatsuComponentLibrary.EffectType.SLOW],
			"condicoes": [],
			"restricoes": [HatsuComponentLibrary.RestrictionType.SINGLE_TARGET_LOCK],
			"custom_vow_sugerido": "Preciso cravar a agulha; sem contato inicial, o controle falha.",
			"opcoes_funcionamento": {
				"grau_controle": ["Lentidão", "Ações forçadas", "Marionete total (votos extremos)"]
			},
			"desc": "Manipula o alvo via agulhas. Controle total do mundo é possível — se você pagar os votos."
		},

		# 31. DISPOSITIVO AUTO
		{
			"id": PresetId.DISPOSITIVO_AUTO,
			"slug": "dispositivo_auto",
			"nome": "📱 Dispositivo Auto",
			"titulo_conceito": "Manipulação Remota por Dispositivo",
			"categoria": HatsuData.Categoria.MANIPULACAO,
			"arquetipo": HatsuData.Arquetipo.SIMPLES,
			"core": HatsuComponentLibrary.CoreType.PROJECTILE,
			"efeito_principal": HatsuComponentLibrary.EffectType.STAT_MOD,
			"objetivo": HatsuData.ObjetivoPrincipal.CONTROLE,
			"forma": HatsuData.Forma.PROJETIL,
			"alvo": HatsuData.Alvo.INIMIGO_UNICO,
			"elemento": HatsuData.Elemento.NEN_PURO,
			"efeitos_secundarios": [HatsuComponentLibrary.EffectType.TRACKING],
			"condicoes": [],
			"restricoes": [HatsuComponentLibrary.RestrictionType.ANNOUNCE_ABILITY],
			"custom_vow_sugerido": "O controle exige um dispositivo conjugado/emitido ativo; se destruído, perco o link.",
			"opcoes_funcionamento": {
				"modo": ["Aliado autopilotado", "Inimigo sob ordem", "Objeto do cenário"]
			},
			"desc": "Manipulação via aparelho remoto. Força alta sem restrições gera déficit de créditos."
		},

		# 32. BALA DE MEMÓRIA
		{
			"id": PresetId.BALA_MEMORIA,
			"slug": "bala_memoria",
			"nome": "🧠 Bala de Memória",
			"titulo_conceito": "Extração & Disparo de Memórias",
			"categoria": HatsuData.Categoria.ESPECIALIZACAO,
			"arquetipo": HatsuData.Arquetipo.SIMPLES,
			"core": HatsuComponentLibrary.CoreType.PROJECTILE,
			"efeito_principal": HatsuComponentLibrary.EffectType.INFORMATION,
			"objetivo": HatsuData.ObjetivoPrincipal.SUPORTE,
			"forma": HatsuData.Forma.PROJETIL,
			"alvo": HatsuData.Alvo.ALIADO,
			"elemento": HatsuData.Elemento.NEN_PURO,
			"efeitos_secundarios": [HatsuComponentLibrary.EffectType.STUN],
			"condicoes": [HatsuData.Condicao.CURTO_ALCANCE_EXTREMO],
			"restricoes": [HatsuComponentLibrary.RestrictionType.TOUCH_REQUIRED, HatsuComponentLibrary.RestrictionType.ANNOUNCE_ABILITY],
			"custom_vow_sugerido": "Só extraio memórias de quem tocar; transferir exige disparar a bala no receptor.",
			"opcoes_funcionamento": {
				"conteudo": ["Memória tática", "Segredo de Hatsu", "Emocão traumática (debuff)"]
			},
			"desc": "Especialização de informação: ler/transferir memórias. Fora do tipo natal = 40% de eficiência."
		},

		# 33. ORAÇÃO DE COMBATE
		{
			"id": PresetId.ORACAO_COMBATE,
			"slug": "oracao_combate",
			"nome": "⚔️ Oração de Combate",
			"titulo_conceito": "Ritual que Acelera Reflexos & Golpes",
			"categoria": HatsuData.Categoria.CONJURACAO,
			"arquetipo": HatsuData.Arquetipo.SIMPLES,
			"core": HatsuComponentLibrary.CoreType.TRANSFORMATION,
			"efeito_principal": HatsuComponentLibrary.EffectType.STAT_MOD,
			"objetivo": HatsuData.ObjetivoPrincipal.MOBILIDADE,
			"forma": HatsuData.Forma.PESSOAL,
			"alvo": HatsuData.Alvo.PROPRIO_USUARIO,
			"elemento": HatsuData.Elemento.LUZ,
			"efeitos_secundarios": [HatsuComponentLibrary.EffectType.MOVEMENT_DASH, HatsuComponentLibrary.EffectType.DAMAGE],
			"condicoes": [HatsuData.Condicao.PARADO_CANALIZACAO],
			"restricoes": [HatsuComponentLibrary.RestrictionType.ANNOUNCE_ABILITY],
			"custom_vow_sugerido": "Sem completar a oração, o modo de combate não ativa.",
			"opcoes_funcionamento": {
				"foco": ["Velocidade de ataque", "Esquiva", "Combo ritual"]
			},
			"desc": "Modo ritual de combate conjurado. Combine com o slider de força e pague com votos."
		},


		# 34. CRIAR DO ZERO (Blank Canvas)
		{
			"id": PresetId.CRIAR_DO_ZERO,
			"slug": "criar_do_zero",
			"nome": "✨ Criar do Zero",
			"titulo_conceito": "Criação Livre & Personalizada",
			"categoria": HatsuData.Categoria.INTENSIFICACAO,
			"arquetipo": HatsuData.Arquetipo.SIMPLES,
			"core": HatsuComponentLibrary.CoreType.STRIKE,
			"efeito_principal": HatsuComponentLibrary.EffectType.DAMAGE,
			"objetivo": HatsuData.ObjetivoPrincipal.DANO,
			"forma": HatsuData.Forma.TOQUE,
			"alvo": HatsuData.Alvo.INIMIGO_UNICO,
			"elemento": HatsuData.Elemento.NEN_PURO,
			"efeitos_secundarios": [],
			"condicoes": [],
			"restricoes": [],
			"custom_vow_sugerido": "",
			"opcoes_funcionamento": {},
			"desc": "Tela em branco para jogadores que preferem definir cada parâmetro e efeito livremente do início ao fim."
		}
	]


static func obter_presets_por_categoria(categoria: HatsuData.Categoria) -> Array[Dictionary]:
	var todos = obter_todos_presets()
	var lista: Array[Dictionary] = []
	for p in todos:
		if p["id"] == PresetId.CRIAR_DO_ZERO:
			continue
		if p["categoria"] == categoria:
			lista.append(p)
	return lista


static func obter_presets_exceto_categoria(categoria: HatsuData.Categoria) -> Array[Dictionary]:
	## Catálogo amplo: todos os conceitos fora da categoria atual (com aviso de afinidade na UI).
	var todos = obter_todos_presets()
	var lista: Array[Dictionary] = []
	for p in todos:
		if p["id"] == PresetId.CRIAR_DO_ZERO:
			continue
		if p["categoria"] != categoria:
			lista.append(p)
	return lista


static func obter_presets_especiais() -> Array[Dictionary]:
	## Modo Especial: mostra o catálogo completo (liberdade total; afinidade só afeta eficiência).
	var todos = obter_todos_presets()
	var lista: Array[Dictionary] = []
	for p in todos:
		if p["id"] == PresetId.CRIAR_DO_ZERO:
			continue
		lista.append(p)
	return lista


static func obter_preset(preset_id: PresetId) -> Dictionary:
	var todos = obter_todos_presets()
	for p in todos:
		if p["id"] == preset_id:
			return p
	return obter_todos_presets()[0]


static func obter_preset_por_slug(slug: String) -> Dictionary:
	var todos = obter_todos_presets()
	for p in todos:
		if p["slug"] == slug:
			return p
	return obter_todos_presets()[0]
