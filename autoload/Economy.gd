extends Node

# ============================================================
# HUNTER ONLINE - ECONOMY MANAGER (AUTOLOAD)
# ============================================================
#
# Gerencia moedas (Jenny / Gold), compras, vendas e catálogo de loja.
# Em total conformidade com o GDD (Vol 5 & 8):
# - Sem poções de HP ou Aura (recuperação é por Zetsu/descanso).
# - Foco em Materiais de Forja, Equipamentos leves e Cosméticos.
#
# ============================================================

signal gold_alterado(novo_valor: int)

# Catálogo Canônico da Loja
const ITEM_CATALOGO := {
	"minerio_aco": {
		"nome": "Minério de Aço Especial",
		"categoria": "Material",
		"preco": 100,
		"descricao": "Material resistente para forja e aprimoramento de equipamentos no Ferreiro."
	},
	"couro_besta": {
		"nome": "Couro de Besta Mágica",
		"categoria": "Material",
		"preco": 150,
		"descricao": "Couro resistente de criaturas do Pantanal Numere. Usado para criar armaduras."
	},
	"tecido_reforcado": {
		"nome": "Tecido com Fibras de Nen",
		"categoria": "Material",
		"preco": 200,
		"descricao": "Tecido condutor de aura para confecção de capas e trajes leves."
	},
	"cristal_aura": {
		"nome": "Cristal de Aura Pura",
		"categoria": "Material",
		"preco": 500,
		"descricao": "Cristal raro capaz de canalizar Nen em armas e armaduras (+1 a +10)."
	},
	"anel_concentracao": {
		"nome": "Anel de Concentração",
		"categoria": "Acessório",
		"preco": 400,
		"descricao": "Acessório modesto (+2 Força). Complementa o treinamento de Nen."
	},
	"pingente_agilidade": {
		"nome": "Pingente de Agilidade",
		"categoria": "Acessório",
		"preco": 400,
		"descricao": "Acessório leve (+2 Velocidade). Auxilia na movimentação e esquiva."
	},
	"cinto_ten": {
		"nome": "Cinto Protetor de Ten",
		"categoria": "Acessório",
		"preco": 400,
		"descricao": "Acessório robusto (+2 Defesa). Auxilia na absorção de impacto físico."
	},
	"guia_hunter_lore": {
		"nome": "Guia Oficial de Sobrevivência Hunter",
		"categoria": "Colecionável",
		"preco": 250,
		"descricao": "Registro com dicas sobre o Exame, regras de Nen e biomas do mundo."
	},
	"gosma_slime": {
		"nome": "Gosma de Slime Viscosa",
		"categoria": "Material",
		"preco": 30,
		"descricao": "Fluido gelatinoso extraído de slimes. Usado como base para compostos de Nen."
	},
	"couro_lobo": {
		"nome": "Couro de Lobo Feroz",
		"categoria": "Material",
		"preco": 80,
		"descricao": "Pele espessa e resistente de lobos selvagens. Ótimo para vestimentas leves."
	},
	"carapaca_besouro": {
		"nome": "Carapaça de Besouro Blindado",
		"categoria": "Material",
		"preco": 120,
		"descricao": "Casca quitinosa ultra resistente de insetos gigantes das cavernas."
	},
	"presa_serpente": {
		"nome": "Presa Peçonhenta de Serpente",
		"categoria": "Material",
		"preco": 150,
		"descricao": "Dente afiado com glândulas de veneno paralisante de serpentes das sombras."
	},
	"carne_javali": {
		"nome": "Carne Nobre de Javali Selvagem",
		"categoria": "Material",
		"preco": 90,
		"descricao": "Alimento suculento apreciado por Hunters Gourmet como Menchi e Buhara."
	},
	"nucleo_golem": {
		"nome": "Núcleo Energético de Golem",
		"categoria": "Material",
		"preco": 350,
		"descricao": "Pedra mágica pulsando com aura primordial que animava construtos de pedra."
	},
	"ouro_roubado": {
		"nome": "Bolsa de Moedas de Salteador",
		"categoria": "Tesouro",
		"preco": 200,
		"descricao": "Bolsa com moedas recuperadas de bandidos e ladrões de estrada."
	},
	"gema_terra": {
		"nome": "Gema Bruta da Terra",
		"categoria": "Material",
		"preco": 280,
		"descricao": "Mineral denso com ressonância de Ten e endurecimento de Ko."
	},
	"veneno_concentrado": {
		"nome": "Extrato de Veneno Concentrado",
		"categoria": "Material",
		"preco": 220,
		"descricao": "Toxina purificada usada em treinamento de resistência biológica."
	},
	"cristal_sombra": {
		"nome": "Fragmento de Cristal Sombrio",
		"categoria": "Material",
		"preco": 400,
		"descricao": "Cristal condutor de Nen de Emissão e Ocultação com Zetsu."
	},
	"pele_urso": {
		"nome": "Pele de Urso das Cavernas",
		"categoria": "Material",
		"preco": 300,
		"descricao": "Pele densa e maciça com alta absorção contra impactos contundentes."
	},
	"olho_quimera": {
		"nome": "Olho Místico de Quimera",
		"categoria": "Material",
		"preco": 450,
		"descricao": "Órgão sensorial raro de feras quiméricas que aprimora a percepção de Gyo."
	}
}


var gold: int:
	get:
		return obter_gold()
	set(value):
		definir_gold(value)


func obter_gold() -> int:
	return int(PlayerData.attributes.get("gold", 1000))


func definir_gold(novo_valor: int) -> void:
	PlayerData.attributes["gold"] = max(0, novo_valor)
	gold_alterado.emit(PlayerData.attributes["gold"])


func tem_gold(quantidade: int) -> bool:
	return obter_gold() >= quantidade


func adicionar_gold(quantidade: int) -> void:
	if quantidade <= 0:
		return
	var atual: int = obter_gold()
	PlayerData.attributes["gold"] = atual + quantidade
	gold_alterado.emit(PlayerData.attributes["gold"])
	print("[Economy] Gold adicionado: +", quantidade, " | Total: ", PlayerData.attributes["gold"])


func adicionar_ouro(quantidade: int) -> void:
	adicionar_gold(quantidade)


func remover_gold(quantidade: int) -> bool:
	if quantidade <= 0:
		return false
	if not tem_gold(quantidade):
		print("[Economy] Gold insuficiente para a compra!")
		return false
		
	var atual: int = obter_gold()
	PlayerData.attributes["gold"] = atual - quantidade
	gold_alterado.emit(PlayerData.attributes["gold"])
	print("[Economy] Gold removido: -", quantidade, " | Restante: ", PlayerData.attributes["gold"])
	return true


func gastar_gold(quantidade: int) -> bool:
	return remover_gold(quantidade)


func remover_ouro(quantidade: int) -> bool:
	return remover_gold(quantidade)


func gastar_ouro(quantidade: int) -> bool:
	return remover_gold(quantidade)



func obter_modificador_preco_faccao(faccao_id: String = "") -> float:
	if faccao_id.is_empty():
		return 1.0
	
	var rep_val: int = 0
	if ReputationSystem != null and ReputationSystem.has_method("obter_reputacao_str"):
		rep_val = ReputationSystem.obter_reputacao_str(faccao_id)
		
	if rep_val >= 500:
		return 0.80 # 20% de Desconto (Reverenciado / Honrado)
	elif rep_val >= 200:
		return 0.90 # 10% de Desconto (Amigável)
	elif rep_val <= -200:
		return 1.50 # +50% de Sobretaxa (Hostil)
	return 1.0


func obter_modificador_preco_regiao(regiao_id: String) -> float:
	if regiao_id.is_empty() or WorldState == null:
		return 1.0
	var prosp: int = WorldState.obter_prosperidade_regional(regiao_id)
	if prosp >= 75:
		return 0.90 # Prosperidade alta: 10% de desconto
	elif prosp <= 25:
		return 1.20 # Escassez: +20% de sobretaxa
	return 1.0


func calcular_preco_compra(item_id: String, faccao_id: String = "", regiao_id: String = "") -> int:
	if not ITEM_CATALOGO.has(item_id):
		return 0
	var preco_base: int = ITEM_CATALOGO[item_id]["preco"]
	var mod: float = obter_modificador_preco_faccao(faccao_id) * obter_modificador_preco_regiao(regiao_id)
	return max(1, int(round(preco_base * mod)))


func calcular_preco_venda(item_id: String, faccao_id: String = "", regiao_id: String = "") -> int:
	if not ITEM_CATALOGO.has(item_id):
		return 0
	var preco_base: int = ITEM_CATALOGO[item_id]["preco"]
	var mod: float = obter_modificador_preco_faccao(faccao_id) * obter_modificador_preco_regiao(regiao_id)
	var taxa_venda: float = 0.50 # Venda padrão = 50% do valor
	if mod < 1.0:
		taxa_venda += (1.0 - mod) # Bônus de venda por boa reputação / prosperidade
	return max(1, int(round(preco_base * taxa_venda)))


func comprar_item(item_id: String, faccao_id: String = "") -> bool:
	if not ITEM_CATALOGO.has(item_id):
		return false
		
	var item_info: Dictionary = ITEM_CATALOGO[item_id]
	var preco: int = calcular_preco_compra(item_id, faccao_id)
	
	if remover_gold(preco):
		_aplicar_compra_item(item_id)
		print("[Economy] Item comprado (%s) por %d Jenny: %s" % [faccao_id if not faccao_id.is_empty() else "Padrão", preco, item_info["nome"]])
		return true
		
	return false


func vender_item(item_id: String, quantidade: int = 1, faccao_id: String = "") -> bool:
	if not PlayerData.tem_item(StringName(item_id), quantidade):
		return false
		
	var preco_unit: int = calcular_preco_venda(item_id, faccao_id)
	var ganho_total: int = preco_unit * quantidade
	
	if PlayerData.remover_item(StringName(item_id), quantidade):
		adicionar_gold(ganho_total)
		print("[Economy] Item vendido (+%d Jenny): %s x%d" % [ganho_total, item_id, quantidade])
		return true
		
	return false



func _aplicar_compra_item(item_id: String) -> void:
	PlayerData.adicionar_item(StringName(item_id), 1)
	
	# Efeitos passivos modestos de acessórios comprados
	match item_id:
		"anel_concentracao":
			PlayerData.attributes["forca"] = int(PlayerData.attributes.get("forca", 10)) + 2
		"pingente_agilidade":
			PlayerData.attributes["velocidade"] = int(PlayerData.attributes.get("velocidade", 10)) + 2
		"cinto_ten":
			PlayerData.attributes["defesa"] = int(PlayerData.attributes.get("defesa", 10)) + 2


func formatar_numero(val: int) -> String:
	if abs(val) >= 1000000:
		return "%.1fM" % (float(val) / 1000000.0)
	elif abs(val) >= 1000:
		return "%.1fk" % (float(val) / 1000.0)
	else:
		return str(val)
