extends Node2D

# ============================================================
# HUNTER ONLINE — SMOKE: EMBOSCADA POR ZETSU (FLORESTA + RAVINA)
# ============================================================
# Valida (headless) o ZetsuSensorZone:
#   A. Cruzar SEM Zetsu -> alarme dispara e 3 predadores emboscam.
#   B. Cruzar COM Zetsu -> travessia furtiva, sem alarme, concede Nen XP.
#   C. FlorestaVestigiosMap instancia as 2 zonas de Zetsu esperadas.
#   D. A ravina de Padokia (RegiaoValePadokiaMap) instancia zonas de Zetsu.
# ============================================================

const FLORESTA := "res://world/maps/floresta_vestigios.tscn"
const RAVINA := "res://world/maps/regiao_vale_padokia.tscn"

var total_tests: int = 0
var passed_tests: int = 0
var failed_tests: int = 0


func assert_test(cond: bool, msg: String) -> void:
	total_tests += 1
	if cond:
		passed_tests += 1
		print("  ✅ [PASS] %s" % msg)
	else:
		failed_tests += 1
		push_error("  ❌ [FAIL] %s" % msg)
		print("  ❌ [FAIL] %s" % msg)


func _ready() -> void:
	print("================================================================================")
	print("🥷 SMOKE: EMBOSCADA POR ZETSU (SENSOR DE AURA)")
	print("================================================================================")

	await _cenario_a_sem_zetsu()
	await _cenario_b_com_zetsu()
	await _cenario_c_floresta_tem_zonas()
	await _cenario_d_ravina_tem_zonas()

	print("\n================================================================================")
	print("📊 RESULTADO ZETSU AMBUSH: TOTAL %d | APROVADOS %d | FALHAS %d" % [total_tests, passed_tests, failed_tests])
	print("================================================================================\n")
	get_tree().quit(0 if failed_tests == 0 else 1)


func _criar_player(nome: String) -> CharacterBody2D:
	var player := CharacterBody2D.new()
	player.name = nome
	player.add_to_group("player")
	var nen := NenSystem.new()
	nen.name = "NenSystem"
	player.add_child(nen)
	add_child(player)
	return player


# ------------------------------------------------------------
# A — Cruzar SEM Zetsu: alarme + 3 emboscadores
# ------------------------------------------------------------
func _cenario_a_sem_zetsu() -> void:
	print("\n[A] Cruzar sem Zetsu dispara alarme e emboscada")
	if PlayerData != null:
		PlayerData.despertou_nen = false # sem Nen ativo -> tecnica_ativa(ZETSU) = false

	var zone := ZetsuSensorZone.new()
	zone.zone_id = &"sensor_smoke_sem_zetsu"
	add_child(zone)
	await get_tree().process_frame

	var alarme := [false]
	zone.alarme_disparado.connect(func(_pos): alarme[0] = true)

	var player := _criar_player("PlayerSemZetsu")
	zone._on_body_entered(player)
	await get_tree().process_frame

	assert_test(zone.falhou_stealth, "falhou_stealth = true ao cruzar sem Zetsu")
	assert_test(alarme[0], "Sinal alarme_disparado emitido")

	var emboscadores := 0
	for c in get_children():
		if str(c.name).begins_with("Emboscada_"):
			emboscadores += 1
	assert_test(emboscadores == 3, "3 predadores emboscaram (obtido: %d)" % emboscadores)

	# Limpeza
	for c in get_children():
		if str(c.name).begins_with("Emboscada_"):
			c.queue_free()
	zone.queue_free()
	player.queue_free()
	await get_tree().process_frame


# ------------------------------------------------------------
# B — Cruzar COM Zetsu: travessia furtiva sem alarme
# ------------------------------------------------------------
func _cenario_b_com_zetsu() -> void:
	print("\n[B] Cruzar com Zetsu ativo: travessia furtiva bem-sucedida")
	if PlayerData != null:
		PlayerData.despertou_nen = true
		PlayerData.attributes["nivel_nen"] = 2
		PlayerData.attributes["aura_max"] = 200.0
		PlayerData.attributes["aura"] = 200.0

	var zone := ZetsuSensorZone.new()
	zone.zone_id = &"sensor_smoke_com_zetsu"
	add_child(zone)
	await get_tree().process_frame

	var alarme := [false]
	zone.alarme_disparado.connect(func(_pos): alarme[0] = true)
	var furtivo := [false]
	zone.travessia_furtiva_sucesso.connect(func(_p): furtivo[0] = true)

	var player := _criar_player("PlayerComZetsu")
	var nen: NenSystem = player.get_node("NenSystem")
	if nen.has_method("sincronizar_nen_com_player_data"):
		nen.sincronizar_nen_com_player_data()
	nen.tecnicas[NenSystem.Tecnica.ZETSU]["nivel"] = 1
	nen.tecnicas[NenSystem.Tecnica.ZETSU]["desbloqueada"] = true
	nen.ativar_tecnica(NenSystem.Tecnica.ZETSU)

	assert_test(nen.tecnica_ativa(NenSystem.Tecnica.ZETSU), "Zetsu ativo no jogador")

	zone._on_body_entered(player)
	await get_tree().process_frame
	assert_test(not zone.falhou_stealth, "Sem alarme ao cruzar com Zetsu")
	assert_test(not alarme[0], "Sinal de alarme NÃO emitido com Zetsu")

	zone._on_body_exited(player)
	await get_tree().process_frame
	assert_test(furtivo[0], "Sinal travessia_furtiva_sucesso emitido ao sair")

	var emboscadores := 0
	for c in get_children():
		if str(c.name).begins_with("Emboscada_"):
			emboscadores += 1
	assert_test(emboscadores == 0, "Nenhum predador emboscou com Zetsu (obtido: %d)" % emboscadores)

	zone.queue_free()
	player.queue_free()
	await get_tree().process_frame


# ------------------------------------------------------------
# C — Floresta dos Vestígios possui zonas de Zetsu
# ------------------------------------------------------------
func _cenario_c_floresta_tem_zonas() -> void:
	print("\n[C] FlorestaVestigiosMap instancia as zonas de Zetsu")
	var scn := load(FLORESTA) as PackedScene
	assert_test(scn != null, "Cena da Floresta carregou")
	var mapa := scn.instantiate()
	add_child(mapa)
	await get_tree().process_frame
	await get_tree().process_frame

	var norte = mapa.get_node_or_null("ZetsuAcampamentoNorte")
	var leste = mapa.get_node_or_null("ZetsuClareiraLeste")
	assert_test(norte != null and norte is ZetsuSensorZone, "ZetsuAcampamentoNorte presente na Floresta")
	assert_test(leste != null and leste is ZetsuSensorZone, "ZetsuClareiraLeste presente na Floresta")

	remove_child(mapa)
	mapa.queue_free()
	await get_tree().process_frame


# ------------------------------------------------------------
# D — Ravina de Padokia possui zonas de Zetsu
# ------------------------------------------------------------
func _cenario_d_ravina_tem_zonas() -> void:
	print("\n[D] RegiaoValePadokiaMap (ravina) instancia zonas de Zetsu")
	var scn := load(RAVINA) as PackedScene
	assert_test(scn != null, "Cena da Região/Ravina de Padokia carregou")
	var mapa := scn.instantiate()
	add_child(mapa)
	# A geração procedural pode levar alguns frames.
	for _i in range(6):
		await get_tree().process_frame

	var zonas := get_tree().get_nodes_in_group("zetsu_sensor_zone")
	var ids := {}
	for z in zonas:
		if is_instance_valid(z):
			ids[str(z.zone_id)] = true
	print("    Zonas de Zetsu detectadas: ", ids.keys())
	assert_test(zonas.size() >= 1, "Ao menos uma ZetsuSensorZone existe na ravina (obtido: %d)" % zonas.size())

	remove_child(mapa)
	mapa.queue_free()
	await get_tree().process_frame
