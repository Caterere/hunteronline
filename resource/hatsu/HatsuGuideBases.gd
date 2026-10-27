class_name HatsuGuideBases
extends RefCounted

# ============================================================
# Bases guiadas do Hatsu Creator (inspiradas no cânone, SEM nomes)
# ============================================================
# O jogador usa como ponto de partida e pode modificar passos/poder.
# Menos restrições → teto de poder menor (anti-abuso).
# ============================================================

enum Tier {
	FRACO,    ## Iniciante — seguro spam / utilidade
	MEDIANO,  ## Combate padrão
	FORTE,    ## Decisivo / charge / controle pesado
	LENDARIO  ## Quase único — vows pesados + nível alto
}


static func obter_todas() -> Array[Dictionary]:
	return [
		{
			"id": "punho_concentrado",
			"nome": "Punho Concentrado",
			"inspiracao": "golpe Ko canalizado (estilo Pedra)",
			"tier": Tier.MEDIANO,
			"min_nivel": 1,
			"afinidade": HatsuData.Categoria.INTENSIFICACAO,
			"categoria": HatsuData.Categoria.INTENSIFICACAO,
			"objetivo": HatsuData.ObjetivoPrincipal.DANO,
			"forma": HatsuData.Forma.TOQUE,
			"activation_type": HatsuData.ActivationType.CHARGED,
			"poder_base": 120.0,
			"custo_aura": 40.0,
			"cooldown": 12.0,
			"alcance": 40.0,
			"preparation_steps_base": 1,
			"steal_conditions_base": [],
			"condicoes": [HatsuData.Condicao.PARADO_CANALIZACAO],
			"restricoes": [HatsuComponentLibrary.RestrictionType.IMMOBILE_DURING_USE],
			"tags": ["guide", "charged", "melee"],
			"desc": "Concentra aura no punho. Segure para carregar — soltar cedo = menos dano.",
			"tradeoff_hint": "Remover imobilidade → teto de dano cai ~25%."
		},
		{
			"id": "lamina_de_aura",
			"nome": "Lâmina de Aura",
			"inspiracao": "aura transformada em corte (estilo Tesoura)",
			"tier": Tier.FRACO,
			"min_nivel": 1,
			"afinidade": HatsuData.Categoria.TRANSFORMACAO,
			"categoria": HatsuData.Categoria.TRANSFORMACAO,
			"objetivo": HatsuData.ObjetivoPrincipal.DANO,
			"forma": HatsuData.Forma.TOQUE,
			"activation_type": HatsuData.ActivationType.INSTANT,
			"poder_base": 70.0,
			"custo_aura": 24.0,
			"cooldown": 7.0,
			"alcance": 48.0,
			"preparation_steps_base": 0,
			"steal_conditions_base": [],
			"condicoes": [],
			"restricoes": [],
			"tags": ["guide", "blade", "slash"],
			"desc": "Transmuta aura nos dedos em lâmina rápida. Bom DPS médio.",
			"tradeoff_hint": "Adicionar piercing sobe demanda — pague com CD ou aura."
		},
		{
			"id": "palma_projetada",
			"nome": "Palma Projetada",
			"inspiracao": "projétil de emissão (estilo Papel)",
			"tier": Tier.FRACO,
			"min_nivel": 5,
			"afinidade": HatsuData.Categoria.EMISSAO,
			"categoria": HatsuData.Categoria.EMISSAO,
			"objetivo": HatsuData.ObjetivoPrincipal.DANO,
			"forma": HatsuData.Forma.PROJETIL,
			"activation_type": HatsuData.ActivationType.INSTANT,
			"poder_base": 55.0,
			"custo_aura": 20.0,
			"cooldown": 5.5,
			"alcance": 170.0,
			"preparation_steps_base": 0,
			"steal_conditions_base": [],
			"condicoes": [],
			"restricoes": [],
			"tags": ["guide", "projectile", "ranged"],
			"desc": "Disparo de aura da palma. Alcance alto, dano moderado.",
			"tradeoff_hint": "Mais alcance = mais créditos exigidos."
		},
		{
			"id": "corrente_neural",
			"nome": "Corrente Neural",
			"inspiracao": "modo de velocidade elétrica (estilo Godspeed)",
			"tier": Tier.FORTE,
			"min_nivel": 25,
			"afinidade": HatsuData.Categoria.TRANSFORMACAO,
			"categoria": HatsuData.Categoria.TRANSFORMACAO,
			"objetivo": HatsuData.ObjetivoPrincipal.MOBILIDADE,
			"forma": HatsuData.Forma.PESSOAL,
			"activation_type": HatsuData.ActivationType.TRANSFORMATION,
			"poder_base": 55.0,
			"custo_aura": 32.0,
			"cooldown": 14.0,
			"duracao": 8.0,
			"alcance": 0.0,
			"preparation_steps_base": 0,
			"steal_conditions_base": [],
			"condicoes": [],
			"restricoes": [HatsuComponentLibrary.RestrictionType.CANNOT_USE_OTHER_HATSU],
			"tags": ["guide", "speed", "transformation_mode"],
			"exclusive_group": "transformation_mode",
			"desc": "Reprograma reflexos com aura. Drena aura por segundo e por golpe.",
			"tradeoff_hint": "Sem trava de outros Hatsus → duração/poder limitados."
		},
		{
			"id": "elastico_adesivo",
			"nome": "Elástico Adesivo",
			"inspiracao": "aura com borracha e goma (estilo Bungee)",
			"tier": Tier.MEDIANO,
			"min_nivel": 15,
			"afinidade": HatsuData.Categoria.TRANSFORMACAO,
			"categoria": HatsuData.Categoria.TRANSFORMACAO,
			"objetivo": HatsuData.ObjetivoPrincipal.CONTROLE,
			"forma": HatsuData.Forma.PROJETIL,
			"activation_type": HatsuData.ActivationType.INSTANT,
			"poder_base": 40.0,
			"custo_aura": 22.0,
			"cooldown": 7.0,
			"alcance": 150.0,
			"preparation_steps_base": 0,
			"steal_conditions_base": [],
			"condicoes": [],
			"restricoes": [],
			"tags": ["guide", "bungee", "pull", "sticky"],
			"desc": "Projétil que gruda e puxa. Dano secundário — controle primeiro.",
			"tradeoff_hint": "Subir dano sem CD/aura → classificação sobe e pode travar no seu nível."
		},
		{
			"id": "contrato_de_corrente",
			"nome": "Contrato de Corrente",
			"inspiracao": "prisão + Zetsu (estilo Chain Jail)",
			"tier": Tier.FORTE,
			"min_nivel": 30,
			"afinidade": HatsuData.Categoria.CONJURACAO,
			"categoria": HatsuData.Categoria.CONJURACAO,
			"objetivo": HatsuData.ObjetivoPrincipal.CONTROLE,
			"forma": HatsuData.Forma.TOQUE,
			"activation_type": HatsuData.ActivationType.INSTANT,
			"poder_base": 40.0,
			"custo_aura": 38.0,
			"cooldown": 14.0,
			"alcance": 55.0,
			"preparation_steps_base": 0,
			"steal_conditions_base": [],
			"condicoes": [HatsuData.Condicao.ALVO_ELITE_BOSS],
			"restricoes": [HatsuComponentLibrary.RestrictionType.ONCE_PER_COMBAT],
			"tags": ["guide", "control", "zetsu_force"],
			"desc": "Correntes que forçam Zetsu em elite/boss. Pouco dano, muito controle.",
			"tradeoff_hint": "Tirar restrição de elite → poder de controle cai pela metade."
		},
		{
			"id": "grimorio_do_colecionador",
			"nome": "Grimório do Colecionador",
			"inspiracao": "livro que guarda técnicas (estilo Skill Hunter)",
			"tier": Tier.LENDARIO,
			"min_nivel": 45,
			"afinidade": HatsuData.Categoria.ESPECIALIZACAO,
			"categoria": HatsuData.Categoria.ESPECIALIZACAO,
			"objetivo": HatsuData.ObjetivoPrincipal.SUPORTE,
			"forma": HatsuData.Forma.PESSOAL,
			"activation_type": HatsuData.ActivationType.OVERRIDE_LIBRARY,
			"poder_base": 60.0,
			"custo_aura": 48.0,
			"cooldown": 16.0,
			"alcance": 0.0,
			"preparation_steps_base": 4,
			"steal_conditions_base": ["OBSERVE_GYO", "TARGET_EXPLAINS", "TOUCH_REQUIRED", "WITHIN_ONE_HOUR"],
			"condicoes": [],
			"restricoes": [HatsuComponentLibrary.RestrictionType.ANNOUNCE_ABILITY],
			"arquetipo": HatsuData.Arquetipo.LIVRO_COLECAO,
			"is_storage_hatsu": true,
			"tags": ["guide", "library", "steal"],
			"desc": "Livro de Nen. Base com 4 passos. Remover 1 passo deixa a técnica mais fraca (exemplo do relatório).",
			"tradeoff_hint": "3 passos → teto FORTE no máximo. 2 passos → teto MEDIANO. 4 passos → pode chegar a LENDÁRIO."
		},
		{
			"id": "sintese_predatoria",
			"nome": "Síntese Predatória",
			"inspiracao": "absorção permanente (estilo Devour)",
			"tier": Tier.LENDARIO,
			"min_nivel": 50,
			"afinidade": HatsuData.Categoria.ESPECIALIZACAO,
			"categoria": HatsuData.Categoria.ESPECIALIZACAO,
			"objetivo": HatsuData.ObjetivoPrincipal.SUPORTE,
			"forma": HatsuData.Forma.TOQUE,
			"activation_type": HatsuData.ActivationType.INSTANT,
			"poder_base": 50.0,
			"custo_aura": 45.0,
			"cooldown": 18.0,
			"alcance": 40.0,
			"preparation_steps_base": 1,
			"steal_conditions_base": [],
			"condicoes": [HatsuData.Condicao.CURTO_ALCANCE_EXTREMO],
			"restricoes": [HatsuComponentLibrary.RestrictionType.TOUCH_REQUIRED],
			"core_component": HatsuComponentLibrary.CoreType.ABSORPTION,
			"tags": ["guide", "absorb", "permanent_growth"],
			"desc": "Absorve fração permanente após abate. Rendimento decrescente anti-farm.",
			"tradeoff_hint": "Sem toque obrigatório → taxa de absorção cortada no juiz."
		},
		{
			"id": "cirurgia_imovel",
			"nome": "Cirurgia Imóvel",
			"inspiracao": "cura massiva canalizada (estilo Doctor Blythe)",
			"tier": Tier.FORTE,
			"min_nivel": 35,
			"afinidade": HatsuData.Categoria.CONJURACAO,
			"categoria": HatsuData.Categoria.CONJURACAO,
			"objetivo": HatsuData.ObjetivoPrincipal.CURA,
			"forma": HatsuData.Forma.PESSOAL,
			"activation_type": HatsuData.ActivationType.CHANNELED,
			"poder_base": 40.0,
			"cura_base": 100.0,
			"custo_aura": 42.0,
			"cooldown": 16.0,
			"alcance": 0.0,
			"preparation_steps_base": 0,
			"steal_conditions_base": [],
			"condicoes": [HatsuData.Condicao.IMOVEL_DURANTE_USO],
			"restricoes": [HatsuComponentLibrary.RestrictionType.IMMOBILE_DURING_USE],
			"tags": ["guide", "heal", "rooted"],
			"desc": "Cura médico-nível. Exige ficar imóvel — risco alto, reward alto.",
			"tradeoff_hint": "Remover imóvel → cura máxima cai para faixa MEDIANA."
		},
		{
			"id": "eficiencia_absoluta",
			"nome": "Eficiência Absoluta",
			"inspiracao": "100% em todas as categorias (estilo Emperor Time)",
			"tier": Tier.LENDARIO,
			"min_nivel": 55,
			"afinidade": HatsuData.Categoria.ESPECIALIZACAO,
			"categoria": HatsuData.Categoria.ESPECIALIZACAO,
			"objetivo": HatsuData.ObjetivoPrincipal.SUPORTE,
			"forma": HatsuData.Forma.PESSOAL,
			"activation_type": HatsuData.ActivationType.TRANSFORMATION,
			"poder_base": 70.0,
			"custo_aura": 40.0,
			"cooldown": 40.0,
			"duracao": 60.0,
			"alcance": 0.0,
			"preparation_steps_base": 0,
			"steal_conditions_base": [],
			"condicoes": [HatsuData.Condicao.AUTO_DANO],
			"restricoes": [HatsuComponentLibrary.RestrictionType.CANNOT_USE_OTHER_HATSU],
			"tags": ["guide", "emperor_time", "lifespan"],
			"exclusive_group": "transformation_mode",
			"desc": "100% eficiência temporária. Consome Esperança de Vida / auto-dano.",
			"tradeoff_hint": "Sem auto-dano → duração máxima 20s e tier FORTE no teto."
		},
		{
			"id": "estatua_de_bracos",
			"nome": "Estátua de Braços",
			"inspiracao": "invocação de barragem (estilo Guanyin)",
			"tier": Tier.LENDARIO,
			"min_nivel": 60,
			"afinidade": HatsuData.Categoria.CONJURACAO,
			"categoria": HatsuData.Categoria.CONJURACAO,
			"objetivo": HatsuData.ObjetivoPrincipal.DANO,
			"forma": HatsuData.Forma.PESSOAL,
			"activation_type": HatsuData.ActivationType.TRANSFORMATION,
			"poder_base": 90.0,
			"custo_aura": 42.0,
			"cooldown": 18.0,
			"duracao": 10.0,
			"alcance": 0.0,
			"preparation_steps_base": 1,
			"steal_conditions_base": [],
			"condicoes": [HatsuData.Condicao.ORACAO_GRATIDAO],
			"restricoes": [HatsuComponentLibrary.RestrictionType.IMMOBILE_DURING_USE],
			"tags": ["guide", "summon", "barrage"],
			"exclusive_group": "transformation_mode",
			"desc": "Manifesta aura em forma de estátua e barragem. Ritual curto + imóvel.",
			"tradeoff_hint": "Sem oração → perde exclusividade lendária (teto FORTE)."
		},
	]


static func obter_por_id(base_id: String) -> Dictionary:
	for b in obter_todas():
		if str(b.get("id", "")) == base_id:
			return b
	return {}


static func obter_desbloqueadas_para_jogador() -> Array[Dictionary]:
	var nivel: int = 1
	if PlayerData != null:
		nivel = int(PlayerData.attributes.get("nivel", 1))
	var out: Array[Dictionary] = []
	for b in obter_todas():
		if nivel >= int(b.get("min_nivel", 1)):
			out.append(b)
	return out


static func tier_nome(t: int) -> String:
	match t:
		Tier.FRACO: return "Fraco"
		Tier.MEDIANO: return "Mediano"
		Tier.FORTE: return "Forte"
		Tier.LENDARIO: return "Lendário"
		_: return "—"


static func aplicar_base_em_hatsu(base: Dictionary, hatsu: HatsuData) -> void:
	if hatsu == null or base.is_empty():
		return
	hatsu.nome = str(base.get("nome", "Nova Técnica"))
	hatsu.categoria = base.get("categoria", HatsuData.Categoria.INTENSIFICACAO)
	hatsu.objetivo = base.get("objetivo", HatsuData.ObjetivoPrincipal.DANO)
	hatsu.forma = base.get("forma", HatsuData.Forma.TOQUE)
	hatsu.activation_type = base.get("activation_type", HatsuData.ActivationType.INSTANT)
	hatsu.poder_base = float(base.get("poder_base", 50.0))
	hatsu.custo_aura_base = float(base.get("custo_aura", 25.0))
	hatsu.cooldown_base = float(base.get("cooldown", 8.0))
	hatsu.alcance = float(base.get("alcance", 60.0))
	hatsu.duracao = float(base.get("duracao", 0.0))
	hatsu.cura_base = float(base.get("cura_base", 0.0))
	if base.has("arquetipo"):
		hatsu.arquetipo = base["arquetipo"]
	if base.has("core_component"):
		hatsu.core_component = base["core_component"]
	if base.has("exclusive_group"):
		hatsu.exclusive_group = str(base["exclusive_group"])
	hatsu.is_storage_hatsu = bool(base.get("is_storage_hatsu", false))
	var typed_c: Array[HatsuData.Condicao] = []
	for c in base.get("condicoes", []):
		typed_c.append(c as HatsuData.Condicao)
	hatsu.condicoes = typed_c
	var typed_r: Array = []
	for r in base.get("restricoes", []):
		typed_r.append(r)
	hatsu.modular_restrictions.clear()
	for r in typed_r:
		hatsu.modular_restrictions.append(r as HatsuComponentLibrary.RestrictionType)
	var typed_sc: Array[String] = []
	for sc in base.get("steal_conditions_base", []):
		typed_sc.append(str(sc))
	hatsu.steal_conditions = typed_sc
	hatsu.preparation_steps.clear()
	var n_steps: int = int(base.get("preparation_steps_base", 0))
	for i in range(n_steps):
		hatsu.preparation_steps.append({
			"id": "guide_step_%d" % (i + 1),
			"description": "Passo de preparação %d (editável)" % (i + 1),
			"action_required": "PREP",
			"time_required": 0.0,
			"credit_value": 25.0
		})
	var tags: Array[String] = []
	for t in base.get("tags", []):
		tags.append(str(t))
	tags.append("guide_base:%s" % str(base.get("id", "")))
	hatsu.tags = tags
