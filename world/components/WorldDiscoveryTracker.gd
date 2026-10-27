class_name WorldDiscoveryTracker
extends Node

# ============================================================
# HUNTER ONLINE - DISCOVERY SYSTEM (FASES 14 & 15)
# ============================================================
#
# Rastreia a exploração e descobertas do jogador:
# - Categoria 1: VISÍVEL (Vilas, Ruínas, Pontes)
# - Categoria 2: ESCONDIDA (Clareiras secretas, Fogueiras)
# - Categoria 3: SECRETA (Cavernas de Minério acessíveis com KO)
# - Categoria 4: MUITO SECRETA (Runas antigas visíveis com GYO)
#
# ============================================================

enum DiscoveryTier {
	VISIVEL = 1,
	ESCONDIDA = 2,
	SECRETA = 3,
	MUITO_SECRETA = 4
}

const XP_POR_TIER := {
	DiscoveryTier.VISIVEL: 50,
	DiscoveryTier.ESCONDIDA: 120,
	DiscoveryTier.SECRETA: 250,
	DiscoveryTier.MUITO_SECRETA: 500
}


static func registrar_descoberta(id_ponto: String, nome_ponto: String, tier: DiscoveryTier = DiscoveryTier.VISIVEL) -> bool:
	var chave = "poi_descoberto_%s" % id_ponto
	if PlayerData.quest_states.get(chave, false):
		return false # Já descoberto

	PlayerData.quest_states[chave] = true
	var count = PlayerData.quest_states.get("total_descobertas", 0) + 1
	PlayerData.quest_states["total_descobertas"] = count

	var xp_ganho = XP_POR_TIER.get(tier, 50)

	# Ponte para o Códex (CollectionManager) — antes de signals para não perder discovery se UI falhar
	if CollectionManager != null and CollectionManager.has_method("register_discovery"):
		var cat := "regions"
		if tier >= DiscoveryTier.SECRETA:
			cat = "secrets"
		CollectionManager.register_discovery(cat, id_ponto)

	if EventBus != null:
		EventBus.emit_toast("🗺️ NOVA DESCOBERTA: %s (+%d XP)" % [nome_ponto, xp_ganho], Color(0.3, 0.9, 1.0))
	var xp_sys = Engine.get_main_loop().root.get_node_or_null("/root/XPSystem") if Engine.get_main_loop() else null
	if xp_sys != null and xp_sys.has_method("adicionar_xp"):
		xp_sys.adicionar_xp(xp_ganho, "Descoberta: %s" % nome_ponto)
	elif EventBus != null and EventBus.has_signal("player_xp_gained"):
		EventBus.player_xp_gained.emit(xp_ganho)

	if AchievementSystem != null and AchievementSystem.has_method("registrar_progresso"):
		AchievementSystem.registrar_progresso("explorador_padokia", 1)

	print("[DiscoverySystem] Ponto registrado: %s (%s) | Total descobertas: %d" % [nome_ponto, id_ponto, count])
	return true