class_name NenBeastData
extends Resource

# ============================================================
# HUNTER ONLINE - NEN BEAST DATA RESOURCE
# ============================================================
#
# Define os atributos, tipo de habilidade passiva, potencial (IV)
# e estatísticas da Besta de Nen do jogador.
#
# ============================================================

enum TipoHabilidade {
	FURIA_BERSERKER,   # +50% Força quando HP < 30%
	DRENAGEM_VAMPIRICA, # Drena vida dos inimigos próximos ao atacar
	REGENERACAO_FENIX, # Restaura 100% de HP ao receber dano fatal (cooldown de 120s)
	AURA_INFINITA,     # Regenera aura continuamente e aumenta dano de Hatsu em +30%
	GUARDIAN_SHIELD    # Absorve 25% de todo dano recebido passivamente
}

@export var nome_besta: String = "Besta Espiritual"
@export var tipo_habilidade: TipoHabilidade = TipoHabilidade.FURIA_BERSERKER
@export var nivel: int = 1
@export var xp: int = 0
@export var max_xp: int = 100
@export var potencial_iv: float = 1.0 # 0.8 a 1.5 (potencial aleatório)

@export var cor_aura: Color = Color(0.8, 0.2, 1.0, 1.0)
@export var sprite_texture_path: String = "res://assets/sprites/characters/nen_beast_kakin.png"

# Cooldown interno para efeitos como Fênix
var fenix_cooldown_timer: float = 0.0


func obter_nome_tipo() -> String:
	match tipo_habilidade:
		TipoHabilidade.FURIA_BERSERKER: return "Fúria Berserker (+50% Força Low HP)"
		TipoHabilidade.DRENAGEM_VAMPIRICA: return "Drenagem Vampírica (Roubo de Vida)"
		TipoHabilidade.REGENERACAO_FENIX: return "Regeneração Fênix (Ressurreição 100% HP)"
		TipoHabilidade.AURA_INFINITA: return "Aura Infinita (+Aura & +Hatsu)"
		TipoHabilidade.GUARDIAN_SHIELD: return "Guardião de Aura (Redução de Dano)"
	return "Desconhecido"


func obter_descricao() -> String:
	match tipo_habilidade:
		TipoHabilidade.FURIA_BERSERKER:
			return "Concede um impulso devastador de +50% de Força quando sua vida cai abaixo de 30%."
		TipoHabilidade.DRENAGEM_VAMPIRICA:
			return "Drena os pontos de vida dos inimigos próximos, restaurando seu HP a cada golpe."
		TipoHabilidade.REGENERACAO_FENIX:
			return "Se seu HP chegar a 0, a Besta restaura 100% do seu HP instantaneamente (Cooldown 120s)."
		TipoHabilidade.AURA_INFINITA:
			return "Acelera a regeneração de aura e aumenta o poder de todos os seus Hatsus."
		TipoHabilidade.GUARDIAN_SHIELD:
			return "Cria um campo de força passivo que reduz todo o dano recebido em 25%."
	return ""
