extends Node

# ============================================================
# BOUNTY XP + MATCH — regressão do refino Steam
# ============================================================
# Verifica:
# 1) Match por enemy_id canônico (não substring de nome)
# 2) Exige contrato aceito
# 3) XP via XPSystem (não player_stat_changed morto)
# 4) Compat nome_alvo exato (suites legadas)
# ============================================================

var _ok_count: int = 0
var _fail_count: int = 0


func _ready() -> void:
	print("================================================================================")
	print("🧪 SUÍTE: Bounty XP + Match")
	print("================================================================================")
	_run()
	print("--------------------------------------------------------------------------------")
	print("RESULTADO: %d ok / %d fail" % [_ok_count, _fail_count])
	print("================================================================================")
	await get_tree().process_frame
	get_tree().quit(0 if _fail_count == 0 else 1)


func _assert(cond: bool, msg: String) -> void:
	if cond:
		_ok_count += 1
		print("  ✅ %s" % msg)
	else:
		_fail_count += 1
		print("  ❌ %s" % msg)


func _reset_contrato(cid: String) -> void:
	if not BountySystem.active_bounty_contracts.has(cid):
		return
	var c: Dictionary = BountySystem.active_bounty_contracts[cid]
	c["aceito"] = false
	c["concluido"] = false


func _run() -> void:
	_assert(BountySystem != null, "BountySystem autoload ativo")
	_assert(BountySystem.active_bounty_contracts.has("bounty_ladrao_padokia"), "Contrato Goran existe")
	_assert(
		str(BountySystem.active_bounty_contracts["bounty_ladrao_padokia"].get("enemy_id", "")) == "ladrao_estrada",
		"Contrato Goran tem enemy_id=ladrao_estrada"
	)

	# Stub XPSystem no tree (player não existe em headless mínimo)
	var xp_script = load("res://scripts/systems/XPSystem.gd")
	_assert(xp_script != null, "XPSystem.gd carregável")
	var xp_sys: Node = xp_script.new()
	add_child(xp_sys)
	_assert(xp_sys.is_in_group("xp_system"), "XPSystem stub no grupo xp_system")

	# Kill sem aceite → não conclui
	_reset_contrato("bounty_ladrao_padokia")
	BountySystem._on_enemy_defeated("ladrao_estrada", 50, 10)
	_assert(
		not bool(BountySystem.active_bounty_contracts["bounty_ladrao_padokia"].get("concluido", false)),
		"Kill sem aceite NÃO conclui contrato"
	)

	# Substring frágil NÃO deve casar (ex.: "a" in "Goran...")
	_reset_contrato("bounty_alfa_lobos")
	BountySystem.aceitar_contrato("bounty_alfa_lobos")
	BountySystem._on_enemy_defeated("lobo", 50, 10) # substring antiga casaria em "Lobo Alfa..."
	_assert(
		not bool(BountySystem.active_bounty_contracts["bounty_alfa_lobos"].get("concluido", false)),
		"Substring solta 'lobo' NÃO conclui bounty_alfa_lobos"
	)

	# Match canônico por enemy_id
	_reset_contrato("bounty_ladrao_padokia")
	BountySystem.aceitar_contrato("bounty_ladrao_padokia")
	var gold_antes: int = Economy.obter_gold() if Economy != null else 0
	var xp_antes: int = int(xp_sys.xp)
	BountySystem._on_enemy_defeated("ladrao_estrada", 50, 10)
	_assert(
		bool(BountySystem.active_bounty_contracts["bounty_ladrao_padokia"].get("concluido", false)),
		"enemy_id ladrao_estrada conclui bounty_ladrao_padokia"
	)
	if Economy != null:
		_assert(Economy.obter_gold() == gold_antes + 1500, "Jenny +1500 no resgate")
	_assert(int(xp_sys.xp) > xp_antes, "XPSystem recebeu XP do bounty")

	# Compat nome_alvo exato
	_reset_contrato("bounty_alfa_lobos")
	BountySystem.aceitar_contrato("bounty_alfa_lobos")
	BountySystem._on_enemy_defeated("Lobo Alfa das Planícies", 50, 10)
	_assert(
		bool(BountySystem.active_bounty_contracts["bounty_alfa_lobos"].get("concluido", false)),
		"Compat: nome_alvo exato ainda conclui"
	)

	# Alt enemy_ids
	_reset_contrato("bounty_alfa_lobos")
	BountySystem.aceitar_contrato("bounty_alfa_lobos")
	BountySystem._on_enemy_defeated("lobo_selvagem", 50, 10)
	_assert(
		bool(BountySystem.active_bounty_contracts["bounty_alfa_lobos"].get("concluido", false)),
		"enemy_ids alt lobo_selvagem conclui alfa"
	)

	# Helper público de correspondência
	var c_g: Dictionary = BountySystem.active_bounty_contracts["bounty_ladrao_padokia"]
	_assert(
		BountySystem._contrato_corresponde_ao_inimigo(c_g, "ladrao_estrada"),
		"_contrato_corresponde_ao_inimigo(ladrao_estrada)"
	)
	_assert(
		not BountySystem._contrato_corresponde_ao_inimigo(c_g, "slime"),
		"slime NÃO corresponde a Goran"
	)
