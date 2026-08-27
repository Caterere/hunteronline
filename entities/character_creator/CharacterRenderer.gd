class_name CharacterRenderer
extends Node2D

const CharacterAppearance = preload("res://entities/character_creator/CharacterAppearance.gd")
const CharacterAssetDatabase = preload("res://entities/character_creator/CharacterAssetDatabase.gd")


# ============================================================
# HUNTER ONLINE - MODULAR CHARACTER RENDERER (12 CAMADAS)
# ============================================================
#
# Renderizador multi-camada com sincronização frame-a-frame de:
# 1. Shadow (Sombra)
# 2. HairBack (Cabelo longo atrás)
# 3. BaseSkin (Corpo e Tom de Pele)
# 4. Eyes (Olhos e Cor)
# 5. Pants (Calças / Shorts)
# 6. Shoes (Calçados / Botas)
# 7. Shirt (Camisas / Regatas)
# 8. Jacket (Jaquetas / Coletes)
# 9. HairFront (Franja / Cabelo Frontal)
# 10. Accessory (Óculos / Licença Hunter / Bandanas)
# 11. Weapon (Armas / Varas de Pesca)
# 12. EffectAura (Aura de Nen / Efeitos)
#
# ============================================================

signal animacao_finalizada(nome_anim: String)

enum Direction {
	DOWN,
	UP,
	LEFT,
	RIGHT
}

@export var current_direction: Direction = Direction.DOWN
@export var current_animation: String = "idle"
@export var animation_speed: float = 8.0 # Frames por segundo

# Referência de dados de aparência
var appearance: CharacterAppearance = null

# Nós das camadas de renderização
var layers: Dictionary = {}
var frame_timer: float = 0.0
var current_frame_index: int = 0
var max_frames_for_anim: int = 6

const TEXTURE_BASE_PLAYER = "res://assets/sprites/characters/player.png"

func _ready() -> void:
	_construir_camadas_renderizacao()
	if appearance == null:
		appearance = CharacterAssetDatabase.obter_preset("GON")
	atualizar_aparencia_completa()


func _construir_camadas_renderizacao() -> void:
	# Limpar camadas anteriores se existirem
	for child in get_children():
		child.queue_free()
	layers.clear()
	
	var nomes_camadas = [
		"Shadow",
		"HairBack",
		"BaseSkin",
		"Eyes",
		"Pants",
		"Shoes",
		"Shirt",
		"Jacket",
		"HairFront",
		"Accessory",
		"Weapon",
		"EffectAura"
	]
	
	var base_tex = load(TEXTURE_BASE_PLAYER) as Texture2D
	
	for i in range(nomes_camadas.size()):
		var nome = nomes_camadas[i]
		var sp = Sprite2D.new()
		sp.name = nome
		sp.z_index = i
		sp.position = Vector2(-0.5, -17) # Alinhamento canônico do Player.tscn
		sp.texture = base_tex
		sp.hframes = 6
		sp.vframes = 10
		add_child(sp)
		layers[nome] = sp


func _process(delta: float) -> void:
	_processar_sincronizacao_frames(delta)


func _processar_sincronizacao_frames(delta: float) -> void:
	frame_timer += delta * animation_speed
	if frame_timer >= 1.0:
		frame_timer = 0.0
		current_frame_index = (current_frame_index + 1) % max_frames_for_anim
		_atualizar_frames_todas_camadas()


func _atualizar_frames_todas_camadas() -> void:
	var base_row: int = 0
	
	# Mapeamento de linhas na spritesheet canônica (hframes=6, vframes=10)
	match current_animation:
		"idle":
			match current_direction:
				Direction.DOWN: base_row = 0
				Direction.RIGHT: base_row = 1
				Direction.UP: base_row = 2
				Direction.LEFT: base_row = 1 # Flip H
		"walk", "run":
			match current_direction:
				Direction.DOWN: base_row = 3
				Direction.RIGHT: base_row = 4
				Direction.UP: base_row = 5
				Direction.LEFT: base_row = 4 # Flip H
		"attack":
			match current_direction:
				Direction.DOWN: base_row = 6
				Direction.RIGHT: base_row = 7
				Direction.UP: base_row = 8
				Direction.LEFT: base_row = 7
				
	var target_frame = base_row * 6 + (current_frame_index % 6)
	var deve_flip = (current_direction == Direction.LEFT)
	
	for nome in layers.keys():
		var sp: Sprite2D = layers[nome]
		if sp != null and is_instance_valid(sp):
			sp.frame = target_frame
			sp.flip_h = deve_flip


# ============================================================
# API DE CONTROLE DE APARÊNCIA
# ============================================================

func set_appearance(nova_aparencia: CharacterAppearance) -> void:
	appearance = nova_aparencia
	atualizar_aparencia_completa()


func atualizar_aparencia_completa() -> void:
	if appearance == null:
		return
		
	# 1. Tom de Pele
	if layers.has("BaseSkin"):
		layers["BaseSkin"].modulate = appearance.skin_tone
		
	# 2. Cor do Cabelo
	if layers.has("HairFront"):
		layers["HairFront"].modulate = appearance.hair_color
	if layers.has("HairBack"):
		layers["HairBack"].modulate = appearance.hair_color * 0.85 # Sombra sutil atrás
		
	# 3. Cor da Camisa
	if layers.has("Shirt"):
		layers["Shirt"].modulate = appearance.shirt_color
		
	# 4. Cor das Calças
	if layers.has("Pants"):
		layers["Pants"].modulate = appearance.pants_color
		
	# 5. Cor dos Calçados
	if layers.has("Shoes"):
		layers["Shoes"].modulate = appearance.shoes_color
		
	# 6. Acessório
	if layers.has("Accessory"):
		layers["Accessory"].visible = (appearance.accessory_id != "none")
		layers["Accessory"].modulate = appearance.accessory_color
		
	# 7. Aura de Nen
	if layers.has("EffectAura"):
		layers["EffectAura"].visible = (appearance.effect_id != "none")
		layers["EffectAura"].modulate = appearance.effect_color
		
	_atualizar_frames_todas_camadas()


func play_animation(nome_anim: String) -> void:
	if current_animation != nome_anim:
		current_animation = nome_anim
		current_frame_index = 0
		frame_timer = 0.0
		_atualizar_frames_todas_camadas()


func set_direction(dir: Direction) -> void:
	if current_direction != dir:
		current_direction = dir
		_atualizar_frames_todas_camadas()


func set_direction_vector(vetor: Vector2) -> void:
	if abs(vetor.x) > abs(vetor.y):
		if vetor.x > 0:
			set_direction(Direction.RIGHT)
		else:
			set_direction(Direction.LEFT)
	else:
		if vetor.y > 0:
			set_direction(Direction.DOWN)
		elif vetor.y < 0:
			set_direction(Direction.UP)
