class_name HatsuCreationPolish
extends RefCounted

# ============================================================
# HATSU CREATION POLISH — glossário HxH, atos, eixos, preview,
# composição modular, tags de playstyle e modificadores de Nen.
# ============================================================

enum AtoUI {
	IDENTIDADE, # Tipo + Conceito + Nome
	PODER,      # Funcionamento + Efeitos + Força + Composição
	PRECO       # Condições + Restrições/Juramentos + Custos + Resumo
}

enum PlaystyleTag {
	ASSASSINO,
	TANK_AURA,
	CONTROLLER,
	BATTERY,
	BURST,
	SUPORTE,
	MOBILIDADE,
	CAÇADOR
}

enum SupportModifier {
	TRACKING,
	PIERCING,
	AREA,
	LINGERING,
	QUICK_CAST,
	ARMOR_BREAK
}


static func obter_ato_da_etapa(etapa: int) -> AtoUI:
	# 0..2 Identidade | 3..5 Poder | 6..9 Preço
	if etapa <= 2:
		return AtoUI.IDENTIDADE
	if etapa <= 5:
		return AtoUI.PODER
	return AtoUI.PRECO


static func obter_nome_ato(ato: AtoUI) -> String:
	match ato:
		AtoUI.IDENTIDADE:
			return "I · IDENTIDADE"
		AtoUI.PODER:
			return "II · PODER"
		AtoUI.PRECO:
			return "III · PREÇO"
	return "?"


static func obter_desc_ato(ato: AtoUI) -> String:
	match ato:
		AtoUI.IDENTIDADE:
			return "Quem você é no Nen: tipo, conceito e nome."
		AtoUI.PODER:
			return "O que o Hatsu faz e quão forte você quer que seja."
		AtoUI.PRECO:
			return "Como você paga: condições, restrições e juramentos."
	return ""


static func glossario_condicao() -> String:
	return "CONDIÇÃO = quando pode ativar (gatilho / requisito de uso)."


static func glossario_restricao() -> String:
	return "RESTRIÇÃO = o que você se proíbe enquanto o Hatsu existir."


static func glossario_juramento() -> String:
	return "JURAMENTO = punição se quebrar a restrição (Zetsu, perda, morte)."


static func glossario_preparacao() -> String:
	return "PREPARAÇÃO = passos antes do golpe (como carregar Ko / ritual)."


## Curva: força pedida empurra aura, CD e setup (estilo Jajanken).
static func calcular_eixos_custo(custom_damage: float, consumo: int = 1) -> Dictionary:
	var dmg: float = clampf(custom_damage, 15.0, 250.0)
	var t: float = (dmg - 15.0) / 235.0 # 0..1
	var aura: float = lerpf(12.0, 95.0, t * t)
	var cd: float = lerpf(2.5, 22.0, t * t)
	var setup: float = lerpf(0.0, 3.2, t * t)
	# Consumo desejado ajusta levemente
	match consumo:
		0: # BAIXO
			aura *= 0.85
			cd *= 1.1
		2: # ALTO
			aura *= 1.2
			cd *= 0.9
			setup *= 0.85
	return {
		"aura_cost": snappedf(aura, 0.1),
		"cooldown": snappedf(cd, 0.1),
		"setup_time": snappedf(setup, 0.05),
		"tier": _tier_label(dmg)
	}


static func _tier_label(dmg: float) -> String:
	if dmg < 30.0:
		return "Fraco"
	if dmg < 60.0:
		return "Médio"
	if dmg < 110.0:
		return "Forte"
	if dmg < 170.0:
		return "Absurdo"
	return "Lendário"


## Preview estilo trial/tooltip antes de forjar.
static func gerar_preview_combate(
	custom_damage: float,
	eficiencia_afinidade: float,
	eixos: Dictionary,
	credit_deficit: float,
	vow_risk: float = 0.0
) -> Dictionary:
	var pedido: float = custom_damage
	var efetivo: float = custom_damage * clampf(eficiencia_afinidade, 0.4, 1.0)
	var setup: float = float(eixos.get("setup_time", 0.0))
	var cd: float = float(eixos.get("cooldown", 5.0))
	var cast_window: float = maxf(0.35, setup)
	var cycle: float = maxf(0.8, cd + cast_window)
	var uptime: float = clampf(cast_window / cycle, 0.05, 0.95)
	var dps_efetivo: float = (efetivo / cycle) if cycle > 0.0 else efetivo
	var risco: float = clampf(vow_risk + (credit_deficit / 400.0), 0.0, 1.0)
	var risco_txt := "Baixo"
	if risco >= 0.75:
		risco_txt = "Extremo (quebra → Zetsu / perda)"
	elif risco >= 0.45:
		risco_txt = "Alto"
	elif risco >= 0.25:
		risco_txt = "Moderado"
	return {
		"dano_pedido": int(pedido),
		"dano_efetivo": int(efetivo),
		"eficiencia_pct": int(eficiencia_afinidade * 100.0),
		"uptime_pct": int(uptime * 100.0),
		"dps_efetivo": snappedf(dps_efetivo, 0.1),
		"aura_por_uso": float(eixos.get("aura_cost", 0.0)),
		"cooldown": cd,
		"setup": setup,
		"risco_voto": risco,
		"risco_texto": risco_txt
	}


static func obter_composicao_por_categoria(categoria: int) -> Dictionary:
	## Sandbox modular por tipo (PoE/Magicka × HxH).
	match categoria:
		0: # INTENSIFICACAO
			return {
				"titulo": "Foco de Intensificação",
				"modo": "single",
				"opcoes": [
					{"id": "ko_punch", "nome": "Ko no Punho", "desc": "Máximo impacto em um ponto."},
					{"id": "body_armor", "nome": "Couraça Corporal", "desc": "Aura como armadura viva."},
					{"id": "heal_cell", "nome": "Cura Celular", "desc": "Regeneração por contato."}
				]
			}
		1: # TRANSFORMACAO
			return {
				"titulo": "Propriedades (A + B)",
				"modo": "dual",
				"opcoes": [
					{"id": "rubber", "nome": "Elasticidade", "desc": "Estica e rebate."},
					{"id": "gum", "nome": "Adesividade", "desc": "Gruda e prende."},
					{"id": "electric", "nome": "Eletricidade", "desc": "Choque e velocidade neural."},
					{"id": "heat", "nome": "Calor", "desc": "Queima contínua."},
					{"id": "blade", "nome": "Fio Cortante", "desc": "Aura como lâmina."},
					{"id": "poison", "nome": "Toxicidade", "desc": "Enfraquece ao contato."}
				],
				"max_pick": 2
			}
		2: # EMISSAO
			return {
				"titulo": "Alcance ↔ Densidade",
				"modo": "slider_pair",
				"eixo_a": {"id": "range", "nome": "Alcance", "min": 0.0, "max": 1.0},
				"eixo_b": {"id": "density", "nome": "Densidade", "min": 0.0, "max": 1.0},
				"hint": "Mais alcance = menos densidade (e vice-versa). Soma ≈ 1.0"
			}
		3: # CONJURACAO
			return {
				"titulo": "Clareza da Imagem Mental",
				"modo": "clarity",
				"opcoes": [
					{"id": "sketch", "nome": "Esboço (60%)", "valor": 0.6, "desc": "Objeto instável, barato."},
					{"id": "detailed", "nome": "Detalhado (85%)", "valor": 0.85, "desc": "Bom equilíbrio."},
					{"id": "perfect", "nome": "Perfeito (100%)", "valor": 1.0, "desc": "Máxima estabilidade — mais créditos."}
				]
			}
		4: # MANIPULACAO
			return {
				"titulo": "Meio de Controle",
				"modo": "single",
				"opcoes": [
					{"id": "needle", "nome": "Agulha / Marca", "desc": "Contato inicial obrigatório."},
					{"id": "device", "nome": "Dispositivo", "desc": "Link remoto via objeto."},
					{"id": "voice", "nome": "Comando Vocal", "desc": "Ordem clara; alvo deve ouvir."},
					{"id": "puppet", "nome": "Marionete", "desc": "Controle total, votos pesados."}
				]
			}
		_: # ESPECIALIZACAO / outros
			return {
				"titulo": "Regra Especial",
				"modo": "single",
				"opcoes": [
					{"id": "steal", "nome": "Roubo / Cópia", "desc": "Extrai técnica sob condições."},
					{"id": "book", "nome": "Arquivo / Livro", "desc": "Armazena habilidades."},
					{"id": "fate", "nome": "Regra do Destino", "desc": "Impose leis locais."}
				]
			}


static func obter_tags_playstyle() -> Array[Dictionary]:
	return [
		{"id": PlaystyleTag.ASSASSINO, "nome": "Assassino", "desc": "Burst furtivo, setup curto."},
		{"id": PlaystyleTag.TANK_AURA, "nome": "Tank de Aura", "desc": "Sobrevivência e Ten/Ken."},
		{"id": PlaystyleTag.CONTROLLER, "nome": "Controller", "desc": "CC, marcas, zonas."},
		{"id": PlaystyleTag.BATTERY, "nome": "Battery", "desc": "Aura drain/gain, sustentação."},
		{"id": PlaystyleTag.BURST, "nome": "Burst", "desc": "Pico de dano, CD longo."},
		{"id": PlaystyleTag.SUPORTE, "nome": "Suporte", "desc": "Cura, escudo, buff de aliado."},
		{"id": PlaystyleTag.MOBILIDADE, "nome": "Mobilidade", "desc": "Dash, reposicionamento."},
		{"id": PlaystyleTag.CAÇADOR, "nome": "Caçador", "desc": "Tracking, mark, execute."}
	]


static func obter_support_modifiers() -> Array[Dictionary]:
	## Até 2 plugáveis — cada um sobe demanda de crédito.
	return [
		{"id": SupportModifier.TRACKING, "nome": "Tracking", "credito": 28.0, "desc": "Projétil/efeito busca o alvo."},
		{"id": SupportModifier.PIERCING, "nome": "Piercing", "credito": 24.0, "desc": "Ignora parte de Ten/armadura."},
		{"id": SupportModifier.AREA, "nome": "Área", "credito": 32.0, "desc": "Expande para AoE."},
		{"id": SupportModifier.LINGERING, "nome": "Lingering", "credito": 26.0, "desc": "Dano/efeito residual."},
		{"id": SupportModifier.QUICK_CAST, "nome": "Quick Cast", "credito": 30.0, "desc": "Reduz setup; sobe aura."},
		{"id": SupportModifier.ARMOR_BREAK, "nome": "Armor Break", "credito": 34.0, "desc": "Quebra defesa após acertos."}
	]


static func credito_modifiers(mods: Array) -> float:
	var total := 0.0
	var catalog := obter_support_modifiers()
	for m in mods:
		for c in catalog:
			if int(c["id"]) == int(m) or str(c["id"]) == str(m):
				total += float(c["credito"])
				break
	return total


static func camadas_mastery() -> Array[Dictionary]:
	## Crescimento pós-forja estilo Godspeed/Rock.
	return [
		{"rank": 1, "mastery_min": 0.0, "nome": "Despertar", "desc": "Forma básica (~30% do potencial)."},
		{"rank": 2, "mastery_min": 20.0, "nome": "Controle", "desc": "Menor custo / timing estável."},
		{"rank": 3, "mastery_min": 40.0, "nome": "Aplicação", "desc": "Desbloqueia efeito secundário."},
		{"rank": 4, "mastery_min": 60.0, "nome": "Domínio", "desc": "Morphs PvE/PvP liberados."},
		{"rank": 5, "mastery_min": 80.0, "nome": "Transcendência", "desc": "Camada final / modo extremo."},
		{"rank": 6, "mastery_min": 100.0, "nome": "Maestria Absoluta", "desc": "100% do poder pedido + bônus."}
	]


static func camada_atual(mastery: float) -> Dictionary:
	var best: Dictionary = camadas_mastery()[0]
	for c in camadas_mastery():
		if mastery >= float(c["mastery_min"]):
			best = c
	return best
