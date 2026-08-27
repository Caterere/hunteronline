class_name LootDrop
extends Area2D

# ============================================================
# HUNTER ONLINE - LOOT DROP (MOEDAS DE JENNY & ITENS DO CHÃO)
# ============================================================
#
# Item físico/moeda que cai do monstro ao morrer no chão 2D.
# Coletado ao passar por cima.
#
# ============================================================

enum TipoLoot {
	JENNY,
	POCAO_HP,
	ELIXIR_AURA
}

@export var tipo: TipoLoot = TipoLoot.JENNY
@export var valor_gold: int = 50
@export var item_id: String = "pocao_hp"

var sprite: Sprite2D
var tempo_vida: float = 0.0


func setup_gold(qtd: int) -> void:
	tipo = TipoLoot.JENNY
	valor_gold = qtd
	_criar_visual(Color(1.0, 0.85, 0.2, 1.0)) # Dourado


func setup_item(id: String) -> void:
	tipo = TipoLoot.POCAO_HP
	item_id = id
	_criar_visual(Color(0.2, 0.9, 0.4, 1.0)) # Verde


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _criar_visual(cor: Color) -> void:
	sprite = Sprite2D.new()
	var img := Image.create(8, 8, false, Image.FORMAT_RGBA8)
	for x in range(8):
		for y in range(8):
			var dist: float = Vector2(x - 4, y - 4).length()
			if dist <= 4.0:
				img.set_pixel(x, y, Color(1, 1, 1, 0.9))
				
	var tex := ImageTexture.create_from_image(img)
	sprite.texture = tex
	sprite.modulate = cor
	add_child(sprite)
	
	var col := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 8.0
	col.shape = circle
	add_child(col)


func _process(delta: float) -> void:
	tempo_vida += delta
	# Flutuação leve em Y
	if sprite != null:
		sprite.position.y = sin(tempo_vida * 5.0) * 2.0


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		if tipo == TipoLoot.JENNY:
			Economy.adicionar_gold(valor_gold)
			print("[LootDrop] Coletou +", valor_gold, " Jenny!")
		else:
			PlayerData.adicionar_item(item_id, 1)
			print("[LootDrop] Coletou item: ", item_id)
			
		queue_free()
