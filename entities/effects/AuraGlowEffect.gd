class_name AuraGlowEffect
extends Node2D

# ============================================================
# HUNTER ONLINE - AURA GLOW EFFECT (VISUAL DE NEN)
# ============================================================
#
# Efeito de brilho de Aura pulsante e partículas em volta do
# jogador quando ativa Ten, Ren, Ko ou Escudo de Hatsu.
#
# ============================================================

var sprite_aura: Sprite2D
var tempo_pulsacao: float = 0.0
var cor_aura_atual: Color = Color(0.3, 0.7, 1.0, 0.4)


func _ready() -> void:
	z_index = -1
	_criar_visual_aura()


func _criar_visual_aura() -> void:
	sprite_aura = Sprite2D.new()
	var img := Image.create(32, 32, false, Image.FORMAT_RGBA8)
	
	# Criar um círculo de gradiente radiante para a aura
	for x in range(32):
		for y in range(32):
			var dist: float = Vector2(x - 16, y - 16).length()
			if dist <= 16.0:
				var alpha: float = (1.0 - (dist / 16.0)) * 0.6
				img.set_pixel(x, y, Color(1, 1, 1, alpha))
				
	var tex := ImageTexture.create_from_image(img)
	sprite_aura.texture = tex
	sprite_aura.modulate = cor_aura_atual
	sprite_aura.visible = false
	add_child(sprite_aura)


func atualizar_aura(ativa: bool, cor: Color = Color(0.3, 0.7, 1.0, 0.4)) -> void:
	if sprite_aura == null:
		return
	cor_aura_atual = cor
	sprite_aura.modulate = cor_aura_atual
	sprite_aura.visible = ativa


func _process(delta: float) -> void:
	if sprite_aura == null or not sprite_aura.visible:
		return
		
	tempo_pulsacao += delta * 6.0
	var escala: float = 1.0 + (sin(tempo_pulsacao) * 0.15)
	sprite_aura.scale = Vector2(escala, escala)
