extends Node

# ============================================================
# B9 — SUÍTE CORREIO + LISTA DE CAÇADORES
# ============================================================

var _passed: int = 0
var _total: int = 0


func _ready() -> void:
	print("\n================================================================")
	print("📬 SUÍTE B9: CORREIO DA ASSOCIAÇÃO + LISTA DE CAÇADORES")
	print("================================================================")
	_test_mail_system()
	_test_friends_system()
	_test_persistence()
	print("\n----------------------------------------------------------------")
	print("RESULTADO: %d/%d" % [_passed, _total])
	if _passed == _total:
		print("✅ B9 MAIL + FRIENDS SUITE PASSED")
	else:
		printerr("❌ B9 MAIL + FRIENDS SUITE FAILED")
	print("================================================================\n")
	get_tree().quit(0 if _passed == _total else 1)


func _ok(cond: bool, label: String) -> void:
	_total += 1
	if cond:
		_passed += 1
		print("  ✅ [PASS] ", label)
	else:
		print("  ❌ [FAIL] ", label)


func _test_mail_system() -> void:
	print("\n[1] AssociationMailSystem...")
	_ok(AssociationMailSystem != null, "autoload AssociationMailSystem")
	AssociationMailSystem.inbox.clear()
	var mid := AssociationMailSystem.enviar_aviso_associacao(
		"Contrato S-Rank",
		"Um Blacklist foi avistado em Yorknew.",
		{"jenny": 1500}
	)
	_ok(not mid.is_empty(), "aviso associação entregue")
	_ok(AssociationMailSystem.contar_nao_lidos() >= 1, "contador não lidos")
	_ok(AssociationMailSystem.marcar_lido(mid), "marcar lido")
	_ok(AssociationMailSystem.contar_nao_lidos() == 0, "inbox zerada após leitura")
	var gold_before := Economy.obter_gold() if Economy != null else 0
	var claim := AssociationMailSystem.reivindicar_anexos(mid)
	_ok(bool(claim.get("ok", false)), "reivindicar anexos jenny")
	if Economy != null:
		_ok(Economy.obter_gold() >= gold_before + 1500, "jenny creditada no Economy")
	var pid := AssociationMailSystem.enviar_de_jogador("peer_2", "Killua", "player", "Ei", "Bora dungeon?", {})
	_ok(not pid.is_empty(), "mail de jogador entregue")
	_ok(AssociationMailSystem.deletar_mail(pid), "deletar mail")


func _test_friends_system() -> void:
	print("\n[2] HunterFriendsSystem...")
	_ok(HunterFriendsSystem != null, "autoload HunterFriendsSystem")
	HunterFriendsSystem.friends.clear()
	HunterFriendsSystem.incoming_requests.clear()
	HunterFriendsSystem.outgoing_requests.clear()
	var req := HunterFriendsSystem.receber_pedido("gon_freecss", "Gon Freecss")
	_ok(bool(req.get("ok", false)), "pedido recebido")
	_ok(HunterFriendsSystem.incoming_requests.has("gon_freecss"), "pedido na inbox social")
	var acc := HunterFriendsSystem.aceitar_pedido("gon_freecss")
	_ok(bool(acc.get("ok", false)), "pedido aceito")
	_ok(HunterFriendsSystem.eh_amigo("gon_freecss"), "Gon na lista de amigos")
	_ok(HunterFriendsSystem.definir_nota("gon_freecss", "Parceiro de exame"), "nota de amigo")
	var send := HunterFriendsSystem.enviar_pedido("killua_zoldyck", "Killua")
	_ok(bool(send.get("ok", false)), "pedido enviado")
	_ok(HunterFriendsSystem.outgoing_requests.has("killua_zoldyck"), "pedido outgoing")
	_ok(HunterFriendsSystem.remover_amigo("gon_freecss"), "remover amigo")
	_ok(not HunterFriendsSystem.eh_amigo("gon_freecss"), "amigo removido")


func _test_persistence() -> void:
	print("\n[3] Persistência save/load...")
	HunterFriendsSystem.receber_pedido("kurapika", "Kurapika")
	HunterFriendsSystem.aceitar_pedido("kurapika")
	AssociationMailSystem.enviar_aviso_associacao("Save Test", "Persistência B9", {"jenny": 10})
	var mail_data := AssociationMailSystem.salvar_dados()
	var friends_data := HunterFriendsSystem.salvar_dados()
	_ok(mail_data.get("inbox", []).size() >= 1, "mail serializado")
	_ok(friends_data.get("friends", {}).has("kurapika"), "friends serializado")
	AssociationMailSystem.inbox.clear()
	HunterFriendsSystem.friends.clear()
	AssociationMailSystem.carregar_dados(mail_data)
	HunterFriendsSystem.carregar_dados(friends_data)
	_ok(AssociationMailSystem.inbox.size() >= 1, "mail restaurado")
	_ok(HunterFriendsSystem.eh_amigo("kurapika"), "friends restaurado")
