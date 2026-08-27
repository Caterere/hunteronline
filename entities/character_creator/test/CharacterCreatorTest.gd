class_name CharacterCreatorTest
extends Node2D

# ============================================================
# HUNTER ONLINE - CHARACTER CREATOR TEST SCENE
# ============================================================
#
# Demonstração e teste interativo do sistema modular de personagens:
# [1/2] Cabelo   [3/4] Camisa   [5/6] Calça   [7/8] Acessório
# [Q/E] Direção  [SPACE] Animação Idle/Walk   [R] Randomizar
# [G] Gon  [K] Killua  [P] Kurapika  [L] Leorio
#
# ============================================================

const CharacterAssetDatabase = preload("res://entities/character_creator/CharacterAssetDatabase.gd")
const CharacterRenderer = preload("res://entities/character_creator/CharacterRenderer.gd")

@onready var renderer: CharacterRenderer = get_node_or_null("CharacterRenderer") as CharacterRenderer
@onready var lbl_info: Label = get_node_or_null("UI/InfoLabel") as Label

var appearance: Resource = null

var idx_hair: int = 0
var idx_shirt: int = 0
var idx_pants: int = 0
var idx_acc: int = 0
var idx_skin: int = 0

func _ready() -> void:
	print("============================================================")
	print("[CHARACTER CREATOR TEST]")
	print("Iniciando protótipo modular de criação de personagens...")
	print("============================================================")
	
	appearance = CharacterAssetDatabase.obter_preset("GON")
	if renderer != null and appearance != null:
		renderer.set_appearance(appearance)
		
	_atualizar_interface()


func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey) or not event.pressed or event.is_echo():
		return
		
	var key = event.keycode
	
	match key:
		KEY_1:
			idx_hair = (idx_hair - 1 + CharacterAssetDatabase.HAIR_STYLES.size()) % CharacterAssetDatabase.HAIR_STYLES.size()
			_aplicar_cabelo()
		KEY_2:
			idx_hair = (idx_hair + 1) % CharacterAssetDatabase.HAIR_STYLES.size()
			_aplicar_cabelo()
			
		KEY_3:
			idx_shirt = (idx_shirt - 1 + CharacterAssetDatabase.SHIRT_STYLES.size()) % CharacterAssetDatabase.SHIRT_STYLES.size()
			_aplicar_camisa()
		KEY_4:
			idx_shirt = (idx_shirt + 1) % CharacterAssetDatabase.SHIRT_STYLES.size()
			_aplicar_camisa()
			
		KEY_5:
			idx_pants = (idx_pants - 1 + CharacterAssetDatabase.PANTS_STYLES.size()) % CharacterAssetDatabase.PANTS_STYLES.size()
			_aplicar_calca()
		KEY_6:
			idx_pants = (idx_pants + 1) % CharacterAssetDatabase.PANTS_STYLES.size()
			_aplicar_calca()
			
		KEY_7:
			idx_acc = (idx_acc - 1 + CharacterAssetDatabase.ACCESSORY_STYLES.size()) % CharacterAssetDatabase.ACCESSORY_STYLES.size()
			_aplicar_acessorio()
		KEY_8:
			idx_acc = (idx_acc + 1) % CharacterAssetDatabase.ACCESSORY_STYLES.size()
			_aplicar_acessorio()
			
		KEY_Q:
			var nova_dir = (int(renderer.current_direction) - 1 + 4) % 4
			renderer.set_direction(nova_dir as CharacterRenderer.Direction)
			_atualizar_interface()
		KEY_E:
			var nova_dir = (int(renderer.current_direction) + 1) % 4
			renderer.set_direction(nova_dir as CharacterRenderer.Direction)
			_atualizar_interface()
			
		KEY_SPACE:
			if renderer.current_animation == "idle":
				renderer.play_animation("walk")
			else:
				renderer.play_animation("idle")
			_atualizar_interface()
			
		KEY_R:
			appearance = CharacterAssetDatabase.gerar_aparencia_aleatoria()
			renderer.set_appearance(appearance)
			_atualizar_interface()
			
		KEY_G:
			appearance = CharacterAssetDatabase.obter_preset("GON")
			renderer.set_appearance(appearance)
			_atualizar_interface()
		KEY_K:
			appearance = CharacterAssetDatabase.obter_preset("KILLUA")
			renderer.set_appearance(appearance)
			_atualizar_interface()
		KEY_P:
			appearance = CharacterAssetDatabase.obter_preset("KURAPIKA")
			renderer.set_appearance(appearance)
			_atualizar_interface()
		KEY_L:
			appearance = CharacterAssetDatabase.obter_preset("LEORIO")
			renderer.set_appearance(appearance)
			_atualizar_interface()


func _aplicar_cabelo() -> void:
	var h = CharacterAssetDatabase.HAIR_STYLES[idx_hair]
	appearance.hair_id = h["id"]
	appearance.hair_color = h.get("color", Color.WHITE)
	renderer.atualizar_aparencia_completa()
	_atualizar_interface()


func _aplicar_camisa() -> void:
	var s = CharacterAssetDatabase.SHIRT_STYLES[idx_shirt]
	appearance.shirt_id = s["id"]
	appearance.shirt_color = s.get("color", Color.WHITE)
	renderer.atualizar_aparencia_completa()
	_atualizar_interface()


func _aplicar_calca() -> void:
	var p = CharacterAssetDatabase.PANTS_STYLES[idx_pants]
	appearance.pants_id = p["id"]
	appearance.pants_color = p.get("color", Color.WHITE)
	renderer.atualizar_aparencia_completa()
	_atualizar_interface()


func _aplicar_acessorio() -> void:
	var a = CharacterAssetDatabase.ACCESSORY_STYLES[idx_acc]
	appearance.accessory_id = a["id"]
	appearance.accessory_color = a.get("color", Color.WHITE)
	renderer.atualizar_aparencia_completa()
	_atualizar_interface()


func _atualizar_interface() -> void:
	if lbl_info == null or appearance == null:
		return
		
	var dir_nome = ["DOWN (Frente)", "UP (Costas)", "LEFT (Esquerda)", "RIGHT (Direita)"][int(renderer.current_direction)]
	
	var txt = "=== CHARACTER CREATOR & MODULAR RENDERER ===\n"
	txt += "Nome: %s\n" % appearance.name
	txt += "[1/2] Cabelo: %s\n" % appearance.hair_id
	txt += "[3/4] Camisa: %s\n" % appearance.shirt_id
	txt += "[5/6] Calça: %s\n" % appearance.pants_id
	txt += "[7/8] Acessório: %s\n" % appearance.accessory_id
	txt += "--------------------------------------------\n"
	txt += "[Q/E] Direção: %s | [SPACE] Animação: %s\n" % [dir_nome, renderer.current_animation.to_upper()]
	txt += "[R] Randomizar | [G] Gon | [K] Killua | [P] Kurapika | [L] Leorio\n"
	
	lbl_info.text = txt
