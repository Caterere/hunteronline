class_name SecretBossManagerClass
extends Node

# ============================================================
# HUNTER ONLINE — SECRET BOSS & ORGANIC EXPLORATION SYSTEM
# ============================================================
#
# Gerencia encontros com Chefes Secretos de Alto Nível (Lv 800 - 1000):
# 1. AUSÊNCIA DE GPS: Nunca exibe marcadores, setas ou waypoints na HUD.
# 2. DESCOBERTA POR PISTAS: Rumores, tabuletas antigas, itens raros.
# 3. CONDIÇÕES ORGÂNICAS:
#    - Ativação de Gyo em altares específicos
#    - Manutenção de Zetsu silencioso em clareiras de miasma
#    - Posse de relíquias e itens ancestrais
#    - Horário específico (meia-noite / chuva de Nen)
# ============================================================

signal chefe_secreto_descoberto(id_chefe: String, nome_chefe: String)
signal pista_secreta_encontrada(id_pista: String, titulo: String, texto: String)

const SECRET_BOSS_CATALOG: Dictionary = {
	"maha_zoldyck_sombra": {
		"id": "maha_zoldyck_sombra",
		"nome": "A Sombra de Maha Zoldyck",
		"nivel": 920,
		"regiao": "montanha_kukuroo",
		"role": "tactician",
		"pista_id": "pista_maha_zoldyck",
		"pista_titulo": "Testamento da Cripta Zoldyck",
		"pista_texto": "Somente aqueles que enxergam a aura oculta (Gyo) no mausoléu ancestral despertarão o patriarca lendário.",
		"requer_gyo": true,
		"requer_item": "reliquia_cacador_antigo",
		"requer_zetsu": false,
		"derrotado": false
	},
	"calamidade_brion_esporo": {
		"id": "calamidade_brion_esporo",
		"nome": "Esporo da Calamidade Brion",
		"nivel": 980,
		"regiao": "continente_negro",
		"role": "boss",
		"pista_id": "pista_brion_esporo",
		"pista_titulo": "Aviso da Expedição Perdida",
		"pista_texto": "A planta carnívora gigante dorme na névoa tóxica. Ela só desperta quando todo o som e calor de aura se calam (Zetsu profundo).",
		"requer_gyo": false,
		"requer_item": "",
		"requer_zetsu": true,
		"derrotado": false
	},
	"mestre_shingen_ancestral": {
		"id": "mestre_shingen_ancestral",
		"nome": "Espírito Marcial Shingen-ryu",
		"nivel": 880,
		"regiao": "dungeon_ruinas_zaban",
		"role": "bruiser",
		"pista_id": "pista_shingen_ancestral",
		"pista_titulo": "Tabuleta dos Antigos Discípulos",
		"pista_texto": "O santuário ancestral responde à expansão do En de um verdadeiro mestre que já forjou seu Hatsu supremo.",
		"requer_gyo": false,
		"requer_item": "fragmento_lore_tabuleta",
		"requer_zetsu": false,
		"requer_en": true,
		"derrotado": false
	}
}

var pistas_descobertas: Array[String] = []
var chefes_derrotados: Array[String] = []

func _ready() -> void:
	add_to_group("secret_boss_manager")
	print("=================================")
	print("[SecretBossManager] SISTEMA DE CHEFES SECRETOS (SEM GPS) ATIVO")
	print("=================================")


## Avalia se as condições contextuais para o despertar de um chefe secreto foram satisfeitas
func avaliar_despertar(id_chefe: String, contexto: Dictionary) -> bool:
	if not SECRET_BOSS_CATALOG.has(id_chefe):
		return false
	if chefes_derrotados.has(id_chefe):
		return false

	var dados = SECRET_BOSS_CATALOG[id_chefe]

	# 1. Checagem de Região
	var regiao_atual = contexto.get("regiao", "")
	if not regiao_atual.is_empty() and regiao_atual != dados["regiao"]:
		return false

	# 2. Checagem de Gyo
	if dados.get("requer_gyo", false):
		var gyo_on = bool(contexto.get("gyo_ativo", false))
		if not gyo_on and PlayerData != null:
			var nen = _obter_nen_player()
			gyo_on = nen != null and nen.has_method("esta_em_gyo") and nen.esta_em_gyo()
		if not gyo_on:
			return false

	# 3. Checagem de Zetsu
	if dados.get("requer_zetsu", false):
		var zetsu_on = bool(contexto.get("zetsu_ativo", false))
		if not zetsu_on and PlayerData != null:
			var nen = _obter_nen_player()
			zetsu_on = nen != null and nen.has_method("esta_em_zetsu") and nen.esta_em_zetsu()
		if not zetsu_on:
			return false

	# 4. Checagem de En
	if dados.get("requer_en", false):
		var en_on = bool(contexto.get("en_ativo", false))
		if not en_on and PlayerData != null:
			var nen = _obter_nen_player()
			en_on = nen != null and nen.has_method("esta_em_en") and nen.esta_em_en()
		if not en_on:
			return false

	# 5. Checagem de Item no Inventário
	var item_req = dados.get("requer_item", "")
	if not item_req.is_empty():
		var tem_item = false
		if PlayerData != null and PlayerData.inventory != null:
			tem_item = PlayerData.inventory.has(item_req) or PlayerData.inventory.has(StringName(item_req))
		if not tem_item:
			return false

	return true


func registrar_pista_descoberta(id_pista: String) -> void:
	if not pistas_descobertas.has(id_pista):
		pistas_descobertas.append(id_pista)
		for c_id in SECRET_BOSS_CATALOG.keys():
			var dados = SECRET_BOSS_CATALOG[c_id]
			if dados["pista_id"] == id_pista:
				pista_secreta_encontrada.emit(id_pista, dados["pista_titulo"], dados["pista_texto"])
				if EventBus != null and EventBus.has_signal("toast_requested"):
					EventBus.emit_toast("📜 Pista Ancestral: %s" % dados["pista_titulo"], Color(1.0, 0.85, 0.3))
				break


func registrar_derrota_chefe_secreto(id_chefe: String) -> void:
	if not chefes_derrotados.has(id_chefe):
		chefes_derrotados.append(id_chefe)
		if PlayerData != null:
			PlayerData.registrar_estatistica("chefes_secretos_derrotados", 1)
		if EventBus != null and EventBus.has_signal("toast_requested"):
			EventBus.emit_toast("👑 Lenda Conquistada: Chefe Secreto Derrotado!", Color(1.0, 0.4, 0.9))


func criar_dados_chefe_secreto(id_chefe: String) -> EnemyData:
	if not SECRET_BOSS_CATALOG.has(id_chefe):
		return null
	var dados = SECRET_BOSS_CATALOG[id_chefe]
	var mob = EnemyData.new()
	mob.enemy_id = StringName(dados["id"])
	mob.enemy_name = dados["nome"]
	mob.role = dados["role"]
	mob.is_boss = true
	mob.npc_tier = EnemyData.NPCTier.TIER_4_QUEST_BOSS
	mob.escalonar_para_nivel(dados["nivel"])
	return mob


func _obter_nen_player() -> Node:
	if Engine.get_main_loop() == null:
		return null
	var tree = Engine.get_main_loop() as SceneTree
	if tree == null:
		return null
	var p = tree.get_first_node_in_group("player")
	if p != null:
		return p.get_node_or_null("NenSystem")
	return null


# ============================================================
# PERSISTÊNCIA (INTEGRAÇÃO SAVE MANAGER SCHEMA 2.3)
# ============================================================

func salvar_dados() -> Dictionary:
	return {
		"pistas_descobertas": pistas_descobertas.duplicate(),
		"chefes_derrotados": chefes_derrotados.duplicate()
	}


func carregar_dados(dados: Dictionary) -> void:
	if dados.has("pistas_descobertas") and dados["pistas_descobertas"] is Array:
		pistas_descobertas.clear()
		for p in dados["pistas_descobertas"]:
			pistas_descobertas.append(str(p))
	if dados.has("chefes_derrotados") and dados["chefes_derrotados"] is Array:
		chefes_derrotados.clear()
		for c in dados["chefes_derrotados"]:
			chefes_derrotados.append(str(c))
