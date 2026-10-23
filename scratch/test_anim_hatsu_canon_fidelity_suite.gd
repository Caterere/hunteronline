extends Node2D

## Animação do player + Hatsus canônicos (fidelidade anime/mangá).

const SignatureKit = preload("res://scripts/systems/hatsu/HatsuSignatureKit.gd")

var total: int = 0
var passed: int = 0
var failed: int = 0


func _ready() -> void:
	print("\n=== ANIM + HATSU CANON FIDELITY ===")
	await _test_player_animation_tree()
	_test_canon_catalog_affinities()
	_test_jajanken_trinity()
	_test_godspeed_and_guanyin_mutex()
	_test_kurapika_chains()
	_test_hisoka_bungee()
	_test_signature_cast_pipeline()
	_test_hatsu_creator_unlock_biscuit()
	_test_equip_visual_profile()
	print("----------------------------------------------------------------")
	print("Resultado: %d/%d | falhas %d" % [passed, total, failed])
	await get_tree().create_timer(0.05).timeout
	get_tree().quit(0 if failed == 0 else 1)


func _ok(cond: bool, label: String) -> void:
	total += 1
	if cond:
		passed += 1
		print("  ✅ %s" % label)
	else:
		failed += 1
		print("  ❌ %s" % label)


func _test_player_animation_tree() -> void:
	print("\n[1] Player AnimationTree idle/walk/attack")
	var scn: PackedScene = load("res://entities/Player/Player.tscn")
	_ok(scn != null, "Player.tscn carrega")
	if scn == null:
		return
	var player: CharacterBody2D = scn.instantiate() as CharacterBody2D
	add_child(player)
	await get_tree().process_frame

	var tree: AnimationTree = player.get_node_or_null("AnimationTree") as AnimationTree
	var anim: AnimationPlayer = player.get_node_or_null("Animation") as AnimationPlayer
	var spr: Sprite2D = player.get_node_or_null("Sprite2D") as Sprite2D
	_ok(tree != null and anim != null and spr != null, "nós AnimationTree/Animation/Sprite2D")
	_ok(tree != null and tree.active, "AnimationTree.active = true no _ready")
	_ok(spr != null and spr.hframes == 6 and spr.vframes == 10, "spritesheet 6x10")

	var sm = tree["parameters/playback"] if tree != null else null
	_ok(sm != null, "playback state machine")

	# Idle
	if sm != null:
		sm.travel("idle")
	tree["parameters/idle/blend_position"] = Vector2(0, 1)
	await get_tree().process_frame
	await get_tree().create_timer(0.08).timeout
	var frame_idle := spr.frame if spr != null else -1
	_ok(frame_idle >= 0 and frame_idle < 6, "idle_down usa frames 0-5 (got %d)" % frame_idle)

	# Walk
	if sm != null:
		sm.travel("walk")
	tree["parameters/walk/blend_position"] = Vector2(0, 1)
	player.velocity = Vector2(0, 80)
	if player.has_method("_animate"):
		player._animate()
	await get_tree().process_frame
	await get_tree().create_timer(0.12).timeout
	var frame_walk := spr.frame if spr != null else -1
	_ok(frame_walk >= 18 and frame_walk < 24, "walk_down usa frames 18-23 (got %d)" % frame_walk)

	# Attack: AnimationTree manda; desativa tree só para provar keys do library
	if tree != null:
		tree.active = false
	if anim != null and anim.has_animation("attack_right"):
		anim.play("attack_right")
	await get_tree().process_frame
	await get_tree().create_timer(0.12).timeout
	var frame_atk := spr.frame if spr != null else -1
	_ok(frame_atk >= 42 and frame_atk <= 45, "attack_right usa frames 42-45 (got %d)" % frame_atk)
	if tree != null:
		tree.active = true
		if sm != null:
			sm.travel("idle")

	# Animações obrigatórias no library
	for nome in ["idle_down", "walk_down", "attack_down", "death"]:
		_ok(anim.has_animation(nome), "library tem '%s'" % nome)

	player.queue_free()
	await get_tree().process_frame


func _test_canon_catalog_affinities() -> void:
	print("\n[2] Catálogo canônico — afinidades anime")
	var catalog: Array = CanonHatsuCatalog.obter_hatsus_canonicos()
	_ok(catalog.size() >= 12, "catálogo tem >= 12 hatsus (%d)" % catalog.size())

	var by_id := {}
	for info in catalog:
		by_id[str(info.get("id", ""))] = info

	var expectations := [
		{"id": "gon_jajanken_pedra", "cat": HatsuData.Categoria.INTENSIFICACAO, "user": "Gon"},
		{"id": "gon_jajanken_tesoura", "cat": HatsuData.Categoria.TRANSFORMACAO, "user": "Gon"},
		{"id": "gon_jajanken_papel", "cat": HatsuData.Categoria.EMISSAO, "user": "Gon"},
		{"id": "killua_kanmuru", "cat": HatsuData.Categoria.TRANSFORMACAO, "user": "Killua"},
		{"id": "netero_guanyin", "cat": HatsuData.Categoria.CONJURACAO, "user": "Netero"},
		{"id": "kurapika_chain_jail", "cat": HatsuData.Categoria.CONJURACAO, "user": "Kurapika"},
		{"id": "kurapika_emperor_time", "cat": HatsuData.Categoria.ESPECIALIZACAO, "user": "Kurapika"},
		{"id": "hisoka_bungee_gum", "cat": HatsuData.Categoria.TRANSFORMACAO, "user": "Hisoka"},
		{"id": "chrollo_skill_hunter", "cat": HatsuData.Categoria.ESPECIALIZACAO, "user": "Chrollo"},
	]
	for e in expectations:
		var info = by_id.get(e["id"], null)
		_ok(info != null, "existe %s" % e["id"])
		if info == null:
			continue
		_ok(int(info.get("categoria", -1)) == int(e["cat"]), "%s categoria canônica" % e["id"])
		_ok(str(e["user"]).to_lower() in str(info.get("usuario", "")).to_lower(), "%s usuário %s" % [e["id"], e["user"]])


func _test_jajanken_trinity() -> void:
	print("\n[3] Jajanken Pedra/Tesoura/Papel")
	var pedra = HatsuManager.create_hatsu_template("jajanken_pedra")
	var tesoura = HatsuManager.create_hatsu_template("jajanken_tesoura")
	var papel = HatsuManager.create_hatsu_template("jajanken_papel")
	_ok(pedra != null and pedra.categoria == HatsuData.Categoria.INTENSIFICACAO, "Pedra = Intensificação")
	_ok(tesoura != null and tesoura.categoria == HatsuData.Categoria.TRANSFORMACAO, "Tesoura = Transformação")
	_ok(papel != null and papel.categoria == HatsuData.Categoria.EMISSAO and papel.forma == HatsuData.Forma.PROJETIL, "Papel = Emissão projétil")
	_ok(pedra.poder_base >= 140.0 or pedra.custom_damage >= 140.0, "Pedra ~15x ataque básico (~150)")
	_ok(papel.alcance > pedra.alcance or papel.custom_range > pedra.custom_range, "Papel alcance > Pedra (anime: ranged)")
	_ok(pedra.activation_type == HatsuData.ActivationType.CHARGED, "Pedra canaliza (charged)")


func _test_godspeed_and_guanyin_mutex() -> void:
	print("\n[4] Godspeed ↔ Guanyin (modo transformação exclusivo)")
	var gs = HatsuManager.create_hatsu_template("godspeed")
	var gy = HatsuManager.create_hatsu_template("netero_guanyin")
	_ok(gs != null and (("electricity" in gs.tags) or ("speed" in gs.tags)), "Godspeed tags elétricas")
	_ok(gs.exclusive_group == "transformation_mode", "Godspeed exclusive_group")
	_ok(gy != null and gy.exclusive_group == "transformation_mode", "Guanyin exclusive_group")
	_ok(not gs.concurrent_allowed and not gy.concurrent_allowed, "não concorrentes (mutex)")
	# Runtime: ativar Godspeed no HatsuSystem
	PlayerData.reset()
	PlayerData.despertou_nen = true
	PlayerData.desbloquear_hatsu_creator()
	PlayerData.attributes["aura"] = 500.0
	PlayerData.attributes["aura_max"] = 500.0
	var body := CharacterBody2D.new()
	add_child(body)
	var hs := HatsuSystem.new()
	add_child(hs)
	hs.setup(body)
	# Simula ativação Godspeed via caminho de transformação
	hs.godspeed_timer = 5.0
	PlayerData.quest_states["godspeed_ativo"] = true
	_ok(hs.esta_godspeed(), "esta_godspeed() true")
	hs.godspeed_timer = 0.0
	_ok(not hs.esta_godspeed(), "esta_godspeed() false após timer")
	body.queue_free()
	hs.queue_free()


func _test_kurapika_chains() -> void:
	print("\n[5] Correntes de Kurapika")
	var jail = HatsuManager.obter_hatsu_canonico("kurapika_chain_jail")
	_ok(jail != null, "Chain Jail no catálogo")
	if jail != null:
		_ok(jail.categoria == HatsuData.Categoria.CONJURACAO, "Chain Jail = Conjuração")
		var has_elite := false
		for c in jail.condicoes:
			if int(c) == int(HatsuData.Condicao.ALVO_ELITE_BOSS):
				has_elite = true
		_ok(has_elite, "Chain Jail restrito a elite/boss (juramento Spiders)")
	var emp = HatsuManager.obter_hatsu_canonico("kurapika_emperor_time")
	_ok(emp != null and emp.categoria == HatsuData.Categoria.ESPECIALIZACAO, "Emperor Time = Especialização")
	var holy = HatsuManager.obter_hatsu_canonico("kurapika_holy_chain")
	_ok(holy != null and holy.objetivo == HatsuData.ObjetivoPrincipal.CURA, "Holy Chain cura")


func _test_hisoka_bungee() -> void:
	print("\n[6] Bungee Gum (Hisoka)")
	var bg = HatsuManager.obter_hatsu_canonico("hisoka_bungee_gum")
	_ok(bg != null, "Bungee Gum no catálogo")
	if bg != null:
		_ok(bg.categoria == HatsuData.Categoria.TRANSFORMACAO, "Bungee = Transformação (borracha+goma)")
		_ok(bg.forma == HatsuData.Forma.PROJETIL or bg.objetivo == HatsuData.ObjetivoPrincipal.CONTROLE, "forma controle/projétil")
	var ai_src := FileAccess.get_file_as_string("res://scripts/systems/EnemySystem/EnemyAI.gd")
	_ok("Bungee Gum" in ai_src and "BungeeGumTether" in ai_src, "EnemyAI tem tether Bungee Gum")


func _test_signature_cast_pipeline() -> void:
	print("\n[7] Assinaturas ultimate (Chrollo/Meruem/Pitou)")
	var hunter = HatsuManager.obter_hatsu_canonico("chrollo_skill_hunter")
	var devour = HatsuManager.obter_hatsu_canonico("meruem_aura_devour")
	var terp = HatsuManager.obter_hatsu_canonico("pitou_terpsichora")
	var blythe = HatsuManager.obter_hatsu_canonico("pitou_doctor_blythe")
	_ok(SignatureKit.detect_kind(hunter) == SignatureKit.Kind.SKILL_HUNTER, "detect Skill Hunter")
	_ok(SignatureKit.detect_kind(devour) == SignatureKit.Kind.DEVOUR, "detect Devour")
	_ok(SignatureKit.detect_kind(terp) == SignatureKit.Kind.TERPSICHORA, "detect Terpsichora")
	_ok(SignatureKit.detect_kind(blythe) == SignatureKit.Kind.DOCTOR_BLYTHE, "detect Doctor Blythe")
	SignatureKit.play_for_hatsu(hunter, self, self)
	SignatureKit.play_for_hatsu(devour, self, self)
	_ok(true, "play_for_hatsu sem crash")


func _test_hatsu_creator_unlock_biscuit() -> void:
	print("\n[8] Biscuit desbloqueia Hatsu Creator")
	PlayerData.reset()
	PlayerData.despertou_nen = true
	PlayerData.arco_atual = 5
	PlayerData.max_arco_desbloqueado = 5
	# Ainda na saga 5 = não concluída
	_ok(not PlayerData.is_greed_island_concluida(), "arco 5 sozinho ≠ GI concluída")
	PlayerData.desbloquear_hatsu_creator()
	_ok(PlayerData.hatsu_creation_unlocked and PlayerData.hatsu_desbloqueado, "flags creator true")
	_ok(HatsuProgressionManager == null or HatsuProgressionManager.is_slot_unlocked(1), "slot 1 desbloqueado")

	var biscuit_scn = load("res://entities/npc/biscuit/Biscuit.tscn")
	_ok(biscuit_scn != null, "Biscuit.tscn")
	if biscuit_scn == null:
		return
	var biscuit = biscuit_scn.instantiate()
	add_child(biscuit)
	var dummy := CharacterBody2D.new()
	add_child(dummy)
	biscuit._on_interacted(dummy)
	_ok(biscuit.modal_menu != null, "Biscuit abre menu após creator unlock")
	if biscuit.modal_menu != null:
		biscuit._fechar_menu_interacao()
	biscuit.queue_free()
	dummy.queue_free()


func _test_equip_visual_profile() -> void:
	print("\n[9] Equip + VisualProfile")
	PlayerData.reset()
	PlayerData.despertou_nen = true
	PlayerData.desbloquear_hatsu_creator()
	# Forja exige Jenny (economia canônica)
	if Economy != null:
		Economy.adicionar_gold(5000)
	elif PlayerData.attributes.has("gold"):
		PlayerData.attributes["gold"] = 5000
	var h := HatsuData.new()
	h.nome = "Aura Teste Visual"
	h.categoria = HatsuData.Categoria.EMISSAO
	h.forma = HatsuData.Forma.PROJETIL
	var vp := VisualProfile.new()
	vp.visual_scale = 1.4
	vp.glow_intensity = 0.7
	h.visual_profile = vp
	# adicionar_hatsu já auto-equipa; SWITCH_COOLDOWN pode falhar no 2º equip — o slot deve ficar preenchido
	var idx := PlayerData.adicionar_hatsu(h)
	_ok(idx >= 0, "adicionar_hatsu após unlock + Jenny (idx=%d)" % idx)
	var got := PlayerData.obter_hatsu_slot(0)
	_ok(got != null, "obter_hatsu_slot(0) retorna hatsu")
	if got != null and got.has_method("obter_visual_profile"):
		var gvp = got.obter_visual_profile()
		_ok(gvp != null and is_equal_approx(gvp.visual_scale, 1.4), "visual_profile preservado")
	elif got != null and got.visual_profile != null:
		_ok(is_equal_approx(got.visual_profile.visual_scale, 1.4), "visual_profile campo direto")
	else:
		_ok(false, "visual_profile acessível")
