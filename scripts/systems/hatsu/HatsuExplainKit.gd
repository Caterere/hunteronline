class_name HatsuExplainKit
extends RefCounted
## Gera explicações jogáveis por Hatsu e artigos do Guia Hunter.

static func gerar_explicacao(hatsu: HatsuData) -> String:
	if hatsu == null:
		return ""
	if not String(hatsu.descricao).is_empty():
		return String(hatsu.descricao)
	return _compor(hatsu)


static func garantir_descricao(hatsu: HatsuData) -> String:
	if hatsu == null:
		return ""
	if String(hatsu.descricao).is_empty():
		hatsu.descricao = _compor(hatsu)
	return hatsu.descricao


static func _compor(hatsu: HatsuData) -> String:
	var cat := _nome_categoria(hatsu.categoria)
	var obj := _nome_objetivo(hatsu.objetivo)
	var forma := _nome_forma(hatsu.forma)
	var partes: Array[String] = []
	partes.append("%s é um Hatsu de %s focado em %s (forma: %s)." % [hatsu.nome, cat, obj, forma])

	if hatsu.eh_canalizavel_feel():
		var t := hatsu.obter_tempo_conjuracao_final()
		match hatsu.obter_feel_modo():
			HatsuData.FeelMode.POWER:
				partes.append(
					"Aprimoramento canalizado: segure o slot para encher a barra de poder (até %.1fs). Quanto mais tempo, maior o dano." % t
				)
			HatsuData.FeelMode.RANGE_AIM:
				partes.append(
					"Emissão canalizada: segure para mirar e estender o alcance (até %.1fs); solte para disparar." % t
				)
			HatsuData.FeelMode.DURATION:
				partes.append(
					"Transformação canalizada: segure para prolongar a duração do buff/efeito (até %.1fs)." % t
				)
			HatsuData.FeelMode.MATERIALIZE:
				partes.append(
					"Conjuração canalizada: segure para materializar com mais tamanho e permanência (até %.1fs)." % t
				)
			HatsuData.FeelMode.CONTROL:
				partes.append(
					"Manipulação canalizada: segure para reforçar área e duração do controle (até %.1fs)." % t
				)
			HatsuData.FeelMode.RISK:
				partes.append(
					"Especialização canalizada: segure para escalar risco e poder — aura sobe com a barra (até %.1fs)." % t
				)
	elif hatsu.activation_type == HatsuData.ActivationType.CHARGED:
		partes.append("Requer canalização antes do impacto — solte no momento certo.")
	elif hatsu.activation_type == HatsuData.ActivationType.SUSTAINED:
		partes.append("Habilidade sustentada: ative e desative no mesmo slot.")

	match hatsu.categoria:
		HatsuData.Categoria.INTENSIFICACAO:
			partes.append("Intensificação reforça o corpo e o golpe físico — o poder nasce da aura concentrada no impacto.")
		HatsuData.Categoria.TRANSFORMACAO:
			partes.append("Transformação muda a propriedade da aura (lâmina, eletricidade, calor...) — a duração define quanto tempo a propriedade permanece.")
		HatsuData.Categoria.EMISSAO:
			partes.append("Emissão projeta aura à distância — alcance e precisão importam mais que força bruta.")
		HatsuData.Categoria.CONJURACAO:
			partes.append("Conjuração materializa algo concreto de Nen no mundo — tamanho e permanência vêm da canalização.")
		HatsuData.Categoria.MANIPULACAO:
			partes.append("Manipulação controla alvos, objetos ou regras de movimento — a canalização reforça o domínio.")
		HatsuData.Categoria.ESPECIALIZACAO:
			partes.append("Especialização quebra o hexágono — regra própria, risco próprio.")

	if not hatsu.condicoes.is_empty() or not hatsu.vow_custom_text.is_empty():
		partes.append("Juramentos/restrições amplificam o poder: quanto mais severo o voto, mais perigoso o Hatsu.")

	partes.append("Poder %.0f · Aura %.0f · CD %.1fs." % [
		hatsu.obter_poder_final(),
		hatsu.obter_custo_final(),
		hatsu.obter_cooldown_final(),
	])
	return " ".join(partes)


static func artigos_guia() -> Dictionary:
	return {
		"hatsu_conceito": {
			"titulo": "O que é Hatsu",
			"categoria": "Hatsu",
			"icone": "✨",
			"conteudo": "Hatsu é a expressão individual do Nen. Cada técnica reflete sua afinidade, votos e estilo. Equipe até 4 slots (teclas 1–4) e treine maestria em combate.",
		},
		"hatsu_criacao": {
			"titulo": "Forjar um Hatsu",
			"categoria": "Hatsu",
			"icone": "🛠️",
			"conteudo": "Com Biscuit você define tipo, forma, objetivo e restrições. Déficit de créditos exige mais limitações. O resultado vira sua assinatura de caçador.",
		},
		"hatsu_aprimoramento_carga": {
			"titulo": "Aprimoramento Canalizado",
			"categoria": "Hatsu",
			"icone": "💥",
			"conteudo": "Hatsus de Intensificação (dano) usam barra de conjuração: segure o slot, encha o poder e solte. Tempo cheio = dano máximo. Soltar cedo = golpe fraco e rápido.",
		},
		"hatsu_feel_por_tipo": {
			"titulo": "Feel por Tipo de Nen",
			"categoria": "Hatsu",
			"icone": "⬡",
			"conteudo": "Cada tipo canaliza um parâmetro diferente: Intensificação=poder, Emissão=mira/alcance, Transformação=duração, Conjuração=materialização, Manipulação=controle, Especialização=risco.",
		},
		"hatsu_slots_equip": {
			"titulo": "Slots e Archive",
			"categoria": "Hatsu",
			"icone": "📦",
			"conteudo": "Archive guarda até 12 técnicas. Slots 1–4 são combate ativo. Abra com [H] para inspecionar explicações, maestria e equipar.",
		},
	}


static func _nome_categoria(c: HatsuData.Categoria) -> String:
	match c:
		HatsuData.Categoria.INTENSIFICACAO: return "Intensificação"
		HatsuData.Categoria.TRANSFORMACAO: return "Transformação"
		HatsuData.Categoria.EMISSAO: return "Emissão"
		HatsuData.Categoria.CONJURACAO: return "Conjuração"
		HatsuData.Categoria.MANIPULACAO: return "Manipulação"
		HatsuData.Categoria.ESPECIALIZACAO: return "Especialização"
	return "Nen"


static func _nome_objetivo(o: HatsuData.ObjetivoPrincipal) -> String:
	match o:
		HatsuData.ObjetivoPrincipal.DANO: return "dano"
		HatsuData.ObjetivoPrincipal.DEFESA: return "defesa"
		HatsuData.ObjetivoPrincipal.CURA: return "cura"
		HatsuData.ObjetivoPrincipal.MOBILIDADE: return "mobilidade"
		HatsuData.ObjetivoPrincipal.CONTROLE: return "controle"
		HatsuData.ObjetivoPrincipal.SUPORTE: return "suporte"
	return "utilidade"


static func _nome_forma(f: HatsuData.Forma) -> String:
	match f:
		HatsuData.Forma.TOQUE: return "toque"
		HatsuData.Forma.PROJETIL: return "projétil"
		HatsuData.Forma.AREA: return "área"
		HatsuData.Forma.PESSOAL: return "pessoal"
		HatsuData.Forma.ZONA: return "zona"
	return "livre"
