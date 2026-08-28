extends Node

# ============================================================
# TEST SUITE — AUDITORIA E VALIDAÇÃO DE LAYOUT DA UI (640x360)
# ============================================================

var testes_passados: int = 0
var testes_totais: int = 0


func _ready() -> void:
	print("\n============================================================")
	print("🧪 INICIANDO SUÍTE DE TESTES: AUDITORIA DE UI (640x360)")
	print("============================================================\n")

	await _executar_teste("1. Validação Estrutural do StatusMenu", _teste_status_menu)
	await _executar_teste("2. Validação Estrutural da DialogueBox", _teste_dialogue_box)
	await _executar_teste("3. Validação Estrutural do ComicBalloon", _teste_comic_balloon)
	await _executar_teste("4. Validação Estrutural do PlayerHUD e Quadrantes", _teste_player_hud)
	await _executar_teste("5. Validação Estrutural do QuestHUD", _teste_quest_hud)
	await _executar_teste("6. Validação Estrutural do NenQuickActionBar", _teste_nen_quick_action_bar)
	await _executar_teste("7. Validação de Menus Modais (Inventory, Nen, Pause, Shop)", _teste_menus_modais)

	print("\n============================================================")
	print("📊 RESULTADO FINAL DA AUDITORIA DE UI:")
	print("Passou em: %d / %d testes" % [testes_passados, testes_totais])
	print("============================================================\n")

	if testes_passados == testes_totais:
		print("🎉 TODOS OS TESTES DE UI PASSARAM COM SUCESSO!")
	else:
		push_error("❌ ALGUNS TESTES DE UI FALHARAM!")

	get_tree().quit(0 if testes_passados == testes_totais else 1)


func _executar_teste(nome: String, metodo: Callable) -> void:
	testes_totais += 1
	print("▶ Teste %d: %s" % [testes_totais, nome])
	var ok: bool = await metodo.call()
	if ok:
		testes_passados += 1
		print("  ✅ PASSOU: %s\n" % nome)
	else:
		print("  ❌ FALHOU: %s\n" % nome)


func _teste_status_menu() -> bool:
	var scn = load("res://ui/StatusMenu/StatusMenu.tscn")
	if scn == null:
		print("  Erro: Cena StatusMenu.tscn não encontrada")
		return false

	var menu = scn.instantiate()
	add_child(menu)

	var panel = menu.find_child("PanelContainer", true, false)
	var margin = menu.find_child("MarginContainer", true, false)
	var vbox = menu.find_child("VBoxContainer", true, false)
	var titulo = menu.find_child("TituloLabel", true, false)
	var hp = menu.find_child("HPLabel", true, false)
	var forca = menu.find_child("ForcaLabel", true, false)
	var defesa = menu.find_child("DefesaLabel", true, false)
	var aura = menu.find_child("AuraLabel", true, false)

	if panel == null or margin == null or vbox == null:
		print("  Erro: Estrutura de containers do StatusMenu incorreta")
		menu.queue_free()
		return false

	if titulo == null or hp == null or forca == null or defesa == null or aura == null:
		print("  Erro: Labels essenciais do StatusMenu ausentes")
		menu.queue_free()
		return false

	if menu.has_method("alternar_menu"):
		menu.alternar_menu()
		if not menu.visible:
			print("  Erro: alternar_menu não tornou visível")
			menu.queue_free()
			return false

	menu.queue_free()
	return true


func _teste_dialogue_box() -> bool:
	var scn = load("res://ui/dialogue/DialogueBox.tscn")
	if scn == null:
		print("  Erro: Cena DialogueBox.tscn não encontrada")
		return false

	var box = scn.instantiate()
	add_child(box)

	var name_lbl = box.find_child("NameLabel", true, false)
	var diag_lbl = box.find_child("DialogueLabel", true, false)
	var choices = box.find_child("ChoicesContainer", true, false)
	var indicator = box.find_child("ContinueIndicator", true, false)

	if name_lbl == null or diag_lbl == null or choices == null:
		print("  Erro: Elementos da DialogueBox ausentes")
		box.queue_free()
		return false

	box.show_dialogue("Wing", "Teste de diálogo formatado para 640x360.")
	if not box.visible:
		print("  Erro: show_dialogue não exibiu a caixa")
		box.queue_free()
		return false

	if name_lbl.text.is_empty() or diag_lbl.text.is_empty():
		print("  Erro: Texto de diálogo não atualizado")
		box.queue_free()
		return false

	box.queue_free()
	return true


func _teste_comic_balloon() -> bool:
	var dummy := Node2D.new()
	dummy.position = Vector2(320, 180)
	add_child(dummy)

	var balloon = ComicBalloon.mostrar(dummy, "Olá Hunter!", 1.0)
	if balloon == null:
		print("  Erro: ComicBalloon.mostrar retornou nulo")
		dummy.queue_free()
		return false

	if not is_instance_valid(balloon):
		print("  Erro: Instância do ComicBalloon inválida")
		dummy.queue_free()
		return false

	dummy.queue_free()
	return true


func _teste_player_hud() -> bool:
	var scn = load("res://ui/hud/HUD.tscn")
	if scn == null:
		print("  Erro: HUD.tscn não encontrada")
		return false

	var hud = scn.instantiate()
	add_child(hud)

	if hud.player_card_panel == null:
		print("  Erro: player_card_panel não instanciado no PlayerHUD")
		hud.queue_free()
		return false

	if hud.boss_bar_panel == null:
		print("  Erro: boss_bar_panel não instanciado no PlayerHUD")
		hud.queue_free()
		return false

	if hud.hatsu_slots_container == null:
		print("  Erro: hatsu_slots_container não instanciado no PlayerHUD")
		hud.queue_free()
		return false

	hud.notificar_boss_status("Hisoka", 500, 1000)
	if not hud.boss_bar_panel.visible:
		print("  Erro: notificar_boss_status não exibiu boss_bar_panel")
		hud.queue_free()
		return false

	hud.queue_free()
	return true


func _teste_quest_hud() -> bool:
	var scn = load("res://ui/hud/QuestHUD.tscn")
	if scn == null:
		print("  Erro: QuestHUD.tscn não encontrada")
		return false

	var quest_hud = scn.instantiate()
	add_child(quest_hud)

	if quest_hud.lbl_arco == null or quest_hud.lbl_quest_nome == null:
		print("  Erro: Labels de missão não construídas no QuestHUD")
		quest_hud.queue_free()
		return false

	quest_hud.queue_free()
	return true


func _teste_nen_quick_action_bar() -> bool:
	var bar := NenQuickActionBar.new()
	add_child(bar)

	if bar.container_tecnicas == null or bar.lbl_instrucao == null:
		print("  Erro: NenQuickActionBar não construiu container de técnicas")
		bar.queue_free()
		return false

	bar.queue_free()
	return true


func _teste_menus_modais() -> bool:
	# Inventory
	var inv_scn = load("res://ui/inventory/InventoryUI.tscn")
	if inv_scn != null:
		var inv = inv_scn.instantiate()
		add_child(inv)
		if inv.panel_main == null:
			print("  Erro: InventoryUI panel_main nulo")
			inv.queue_free()
			return false
		inv.queue_free()

	# NenMenu
	var nen_scn = load("res://ui/NenMenu/NenMenu.tscn")
	if nen_scn != null:
		var nen = nen_scn.instantiate()
		add_child(nen)
		var titulo = nen.find_child("TituloLabel", true, false)
		if titulo == null:
			print("  Erro: NenMenu TituloLabel nulo")
			nen.queue_free()
			return false
		nen.queue_free()

	# PauseMenu
	var pause := PauseMenuUI.new()
	add_child(pause)
	if pause.painel_principal == null:
		print("  Erro: PauseMenuUI painel_principal nulo")
		pause.queue_free()
		return false
	pause.queue_free()

	# ShopUI
	var shop_scn = load("res://ui/Shop/ShopUI.tscn")
	if shop_scn != null:
		var shop = shop_scn.instantiate()
		add_child(shop)
		if shop.panel_main == null:
			print("  Erro: ShopUI panel_main nulo")
			shop.queue_free()
			return false
		shop.queue_free()

	return true
