class_name NenBeastSystem
extends Node2D

# ============================================================
# HUNTER ONLINE - NEN BEAST SYSTEM (COMPANION)
# ============================================================
#
# Gerencia a Besta de Nen companheira do jogador.
# Segue o personagem no mapa 2D, aplica buffs passivos e
# aciona efeitos especiais (Fúria Berserker, Drenagem, Fênix).
#
# ============================================================

signal besta_equipada(besta: NenBeastData)
signal efeito_besta_acionado(tipo: String, mensagem: String)

const ComicBalloon = preload("res://scripts/ui/ComicBalloon.gd")

var owner_body: CharacterBody2D = null
var sprite_besta: Sprite2D = null
var besta_atual: NenBeastData = null

# Estado dos efeitos
var berserker_ativo: bool = false
var tempo_flutuacao: float = 0.0


func _ready() -> void:
	add_to_group("nen_beast_system")
	_criar_sprite_companheiro()


func setup(body: CharacterBody2D) -> void:
	owner_body = body
	# Verificar se o jogador tem besta equipada ou desbloqueada no PlayerData
	if PlayerData.besta_nen_equipada != null:
		equipar_besta(PlayerData.besta_nen_equipada)
	elif PlayerData.besta_nen_desbloqueada:
		var besta_default = NenBeastManager.gerar_besta_aleatoria()
		equipar_besta(besta_default)


func _criar_sprite_companheiro() -> void:
	sprite_besta = Sprite2D.new()
	var tex = load("res://assets/sprites/characters/nen_beast_kakin.png") as Texture2D
	if tex != null:
		sprite_besta.texture = tex
	sprite_besta.centered = true
	sprite_besta.modulate = Color(1.0, 1.0, 1.0, 0.92)
	sprite_besta.scale = Vector2(0.32, 0.32)
	sprite_besta.z_index = 2 # Fica levemente sobreposto ao cenário/personagem
	sprite_besta.visible = false
	add_child(sprite_besta)


func equipar_besta(besta: NenBeastData) -> void:
	besta_atual = besta
	PlayerData.besta_nen_equipada = besta
	
	if sprite_besta != null and besta_atual != null:
		# Tom espectral sutil baseado na cor da aura da Besta
		var cor_base = besta_atual.cor_aura
		sprite_besta.modulate = Color(
			lerp(1.0, cor_base.r, 0.25),
			lerp(1.0, cor_base.g, 0.25),
			lerp(1.0, cor_base.b, 0.25),
			0.92
		)
		sprite_besta.visible = true
		
	besta_equipada.emit(besta_atual)
	print("[NenBeastSystem] Besta Guardiã de Nen ATIVADA: ", besta_atual.nome_besta)


func _process(delta: float) -> void:
	if owner_body == null or besta_atual == null or not PlayerData.besta_nen_desbloqueada:
		if sprite_besta != null:
			sprite_besta.visible = false
		return
		
	_atualizar_movimento_companheiro(delta)
	_processar_efeitos_passivos(delta)


func _atualizar_movimento_companheiro(delta: float) -> void:
	if sprite_besta == null:
		return
		
	tempo_flutuacao += delta * 3.0
	
	# Determinar lado de flutuação baseado na direção que o jogador olha
	var virado_esquerda: bool = false
	if owner_body.has_node("Sprite2D"):
		var p_sprite = owner_body.get_node("Sprite2D") as Sprite2D
		if p_sprite != null and p_sprite.flip_h:
			virado_esquerda = true

	# Posição orbital acima do ombro (Nunca sobreposto ao corpo)
	# Quando olha para direita, fica à esquerda/trás (-28px, -28px).
	# Quando olha para esquerda, fica à direita/trás (+28px, -28px).
	var lado_x: float = 28.0 if virado_esquerda else -28.0
	var bobbing_y: float = sin(tempo_flutuacao) * 3.0
	var offset_orbital := Vector2(lado_x, -28.0 + bobbing_y)
	var alvo_pos: Vector2 = owner_body.global_position + offset_orbital
	
	# Se a besta estiver muito longe (ex: após teleporte/spawn), teleporta para perto
	if sprite_besta.global_position.distance_to(owner_body.global_position) > 140.0:
		sprite_besta.global_position = alvo_pos
	else:
		# Movimento responsivo e sem atraso excessivo (lerp 12.0)
		sprite_besta.global_position = sprite_besta.global_position.lerp(alvo_pos, delta * 12.0)
	
	# Garantir distância mínima de segurança: nunca fica colada ou em cima do tronco do jogador
	var dist_jogador: float = sprite_besta.global_position.distance_to(owner_body.global_position)
	if dist_jogador < 22.0:
		var dir_repulsao = (sprite_besta.global_position - owner_body.global_position).normalized()
		if dir_repulsao.length_squared() < 0.01:
			dir_repulsao = Vector2(-1, -1).normalized()
		sprite_besta.global_position = owner_body.global_position + (dir_repulsao * 24.0)

	# Respiração sutil de escala
	var pulse: float = 0.32 + (sin(tempo_flutuacao * 2.0) * 0.015)
	sprite_besta.scale = Vector2(pulse, pulse)
	
	# Virar a Besta para olhar na mesma direção do jogador
	sprite_besta.flip_h = virado_esquerda
	sprite_besta.z_index = 1



# ============================================================
# PROCESSAMENTO DE BUFFS & EFEITOS PASSIVOS
# ============================================================

func _processar_efeitos_passivos(delta: float) -> void:
	if besta_atual == null:
		return
		
	# Reduzir timer do Fênix se houver
	if besta_atual.fenix_cooldown_timer > 0.0:
		besta_atual.fenix_cooldown_timer -= delta
		
	match besta_atual.tipo_habilidade:
		NenBeastData.TipoHabilidade.FURIA_BERSERKER:
			_processar_furia_berserker()
		NenBeastData.TipoHabilidade.AURA_INFINITA:
			_processar_aura_infinita(delta)


func _processar_furia_berserker() -> void:
	var hp: float = float(PlayerData.attributes["vida"])
	var hp_max: float = float(PlayerData.attributes["vida_max"])
	
	if (hp / hp_max) <= 0.30:
		if not berserker_ativo:
			berserker_ativo = true
			efeito_besta_acionado.emit("BERSERKER", "Fúria da Besta ativada! +50% Força!")
			ComicBalloon.mostrar(sprite_besta if sprite_besta != null else self, "🐉 RWOOOAR! MODO BERSERKER!", 2.2, -28.0)
			print("[NenBeast] FÚRIA BERSERKER ATIVADA!")
	else:
		berserker_ativo = false


func _processar_aura_infinita(delta: float) -> void:
	var aura: float = float(PlayerData.attributes["aura"])
	var aura_max: float = float(PlayerData.attributes["aura_max"])
	
	if aura < aura_max:
		PlayerData.attributes["aura"] = min(aura_max, aura + (5.0 * delta * besta_atual.potencial_iv))


# ============================================================
# INTERCEPÇÃO DE DANO FATAL (REGENERAÇÃO FÊNIX)
# ============================================================

func verificar_morte_fatal() -> bool:
	# Retorna TRUE se a besta evitou a morte do jogador
	if besta_atual == null:
		return false
		
	if besta_atual.tipo_habilidade == NenBeastData.TipoHabilidade.REGENERACAO_FENIX:
		if besta_atual.fenix_cooldown_timer <= 0.0:
			besta_atual.fenix_cooldown_timer = 120.0 # 2 minutos de recarga
			var hp_max: int = int(PlayerData.attributes["vida_max"])
			PlayerData.attributes["vida"] = hp_max
			efeito_besta_acionado.emit("FENIX", "Fênix Renascida! Sua vida foi 100% restaurada!")
			ComicBalloon.mostrar(sprite_besta if sprite_besta != null else self, "✨ RESSURREIÇÃO FÊNIX! HP 100%!", 2.5, -28.0)
			print("=================================")
			print("[NenBeast] RESSURREIÇÃO FÊNIX ACIONADA! HP 100%")
			print("=================================")
			return true
			
	return false


# ============================================================
# DRENAGEM VAMPÍRICA AO CAUSAR DANO
# ============================================================

func ao_causar_dano(dano_causado: int) -> void:
	if besta_atual == null:
		return
		
	if besta_atual.tipo_habilidade == NenBeastData.TipoHabilidade.DRENAGEM_VAMPIRICA:
		var cura: int = max(1, int(dano_causado * 0.20 * besta_atual.potencial_iv))
		var hp: int = int(PlayerData.attributes["vida"])
		var hp_max: int = int(PlayerData.attributes["vida_max"])
		PlayerData.attributes["vida"] = min(hp_max, hp + cura)
		print("[NenBeast] Drenou +", cura, " HP do inimigo!")
