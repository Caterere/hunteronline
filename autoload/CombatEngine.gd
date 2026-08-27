extends Node

# ============================================================
# HUNTER ONLINE - COMBAT ENGINE (CENTRAL DAMAGE PIPELINE)
# ============================================================
#
# Pipeline Oficial de Cálculo de Dano e Mitigações:
# INPUT -> TARGET -> ATTACK -> NEN MODS -> HATSU MODS -> DAMAGE ->
# DEFENSE SUBTRACTION -> TEN/KEN/RYU MITIGATION -> CRIT/STAGGER -> OUTPUT
#
# ============================================================

signal hit_processado(atacante: Node, defensor: Node, dano_final: int, is_crit: bool)

func calcular_dano(
	atacante: Variant,
	defensor: Variant = null,
	hatsu: Resource = null,
	is_ko: bool = false
) -> int:
	var forca: float = 10.0
	var dano_base: float = 10.0

	# 1. Obter Atributos do Atacante
	if atacante is Dictionary:
		forca = float(atacante.get("forca", 10.0))
		dano_base = float(atacante.get("dano_base", 10.0))
		if atacante.get("ren_ativo", false):
			forca *= float(atacante.get("ren_mult", 1.5))
		if is_ko or atacante.get("ko_ativo", false):
			forca *= float(atacante.get("ko_mult", 2.0))
	elif atacante != null and atacante is Node:
		var ply_data = PlayerData if atacante.is_in_group("player") else null
		if ply_data != null:
			forca = float(ply_data.attributes.get("forca", 10))
			if ply_data.quest_states.get("guanyin_bodhisattva_ativo", false):
				dano_base = 100.0
			elif ply_data.quest_states.get("godspeed_ativo", false):
				dano_base = 65.0
		elif "strength" in atacante:
			forca = float(atacante.strength)
		elif "forca" in atacante:
			forca = float(atacante.forca)

	var dano: float = dano_base + forca

	# 2. Multiplicadores de Hatsu
	if hatsu != null:
		var h_mult: float = 1.0
		if hatsu.has_method("get_multiplicador"):
			h_mult = hatsu.get_multiplicador()
		var compat: float = float(hatsu.get("compatibilidade")) if "compatibilidade" in hatsu and hatsu.get("compatibilidade") != null else 1.0
		dano *= (h_mult * compat)


	# 3. Reduções do Defensor
	var reducao_defesa: float = 0.0
	var reducao_ten: float = 0.0

	if defensor is Dictionary:
		reducao_defesa = float(defensor.get("defesa", 0.0)) * 0.5
		if defensor.get("ten_ativo", false):
			reducao_ten = float(defensor.get("aura", 0.0)) * 0.1
	elif defensor != null and defensor is Node:
		if defensor.is_in_group("player"):
			reducao_defesa = float(PlayerData.attributes.get("defesa", 10)) * 0.5
		elif "defense" in defensor:
			reducao_defesa = float(defensor.defense) * 0.5
		elif "defesa" in defensor:
			reducao_defesa = float(defensor.defesa) * 0.5

	var dano_final: float = max(1.0, dano - reducao_defesa - reducao_ten)
	return int(round(dano_final))

func calcular_dano_jogador(player_node: Node2D, nen_system: Node = null, inimigo_alvo: Node = null) -> int:
	var forca: float = float(PlayerData.attributes.get("forca", 10))
	var dano_base: float = 10.0

	if PlayerData.quest_states.get("guanyin_bodhisattva_ativo", false):
		dano_base = 100.0
	elif PlayerData.quest_states.get("godspeed_ativo", false):
		dano_base = 65.0

	var dano_fisico: float = dano_base + forca
	var dano_nen: float = 0.0

	if nen_system != null and nen_system.has_method("calcular_dano"):
		dano_nen = nen_system.calcular_dano(forca)

	var dano_final: float = dano_fisico + dano_nen

	if nen_system != null:
		if nen_system.has_method("aplicar_shu_no_dano"):
			dano_final = nen_system.aplicar_shu_no_dano(dano_final)
		if nen_system.has_method("aplicar_ryu_no_dano_ataque"):
			dano_final = nen_system.aplicar_ryu_no_dano_ataque(dano_final)
		if nen_system.has_method("tecnica_ativa"):
			if nen_system.tecnica_ativa(NenSystem.Tecnica.GYO):
				dano_final *= 1.35
			if nen_system.tecnica_ativa(NenSystem.Tecnica.ZETSU) and inimigo_alvo != null:
				dano_final *= 3.0

	if PlayerData.afinidade_nen == NenAffinityData.CategoriaAfinidade.ESPECIALIZACAO:
		dano_final *= 1.50

	return max(1, int(round(dano_final)))

func calcular_dano_sofrido_jogador(dano_bruto: int, nen_system: Node = null, hatsu_system: Node = null, atacante: Node = null) -> int:
	var dano_com_ten: float = float(dano_bruto)

	if nen_system != null:
		if nen_system.has_method("aplicar_ten_no_dano"):
			dano_com_ten = nen_system.aplicar_ten_no_dano(dano_com_ten)
		if nen_system.has_method("aplicar_ken_no_dano"):
			dano_com_ten = nen_system.aplicar_ken_no_dano(dano_com_ten)
		if nen_system.has_method("aplicar_ryu_no_dano_defesa"):
			dano_com_ten = nen_system.aplicar_ryu_no_dano_defesa(dano_com_ten)

	if PlayerData.afinidade_nen == NenAffinityData.CategoriaAfinidade.ESPECIALIZACAO:
		dano_com_ten *= 0.65

	var defesa: int = int(PlayerData.attributes.get("defesa", 10))
	var dano_final: int = max(int(round(dano_com_ten)) - defesa, 1)

	if hatsu_system != null:
		if hatsu_system.has_method("registrar_dano_sofrido_vow"):
			hatsu_system.registrar_dano_sofrido_vow(dano_final, atacante)
		if hatsu_system.has_method("absorver_dano_escudo"):
			dano_final = hatsu_system.absorver_dano_escudo(dano_final, atacante)

	return max(0, dano_final)
