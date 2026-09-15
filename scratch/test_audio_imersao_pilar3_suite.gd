extends Node

# ============================================================
# Suite: Áudio Pilar 3 — mob SFX, ambient bioma, murmur, posicional
# ============================================================

const AudioSynthScript = preload("res://autoload/AudioSynth.gd")

var _passed: int = 0
var _failed: int = 0


func _ready() -> void:
	print("\n========== TEST AUDIO IMERSAO PILAR3 ==========")
	await get_tree().process_frame
	_teste_pack_mob_sfx()
	_teste_archetipos()
	_teste_ambient_loops()
	_teste_dialogue_murmur()
	_teste_audio_manager_api()
	_teste_ambient_por_cena()
	print("========== RESULTADO: %d ok / %d fail ==========" % [_passed, _failed])
	if _failed > 0:
		get_tree().quit(1)
	else:
		get_tree().quit(0)


func _assert(cond: bool, msg: String) -> void:
	if cond:
		_passed += 1
		print("  PASS: ", msg)
	else:
		_failed += 1
		print("  FAIL: ", msg)


func _teste_pack_mob_sfx() -> void:
	print("\n[1] Pack SFX de mobs")
	for arch in ["beast", "insect", "humanoid", "construct"]:
		for acao in ["growl", "hurt", "death"]:
			var id: String = "mob_%s_%s" % [acao, arch]
			var wav: AudioStreamWAV = AudioSynthScript.obter_sfx(id)
			_assert(wav != null and wav.data.size() > 64, "gera %s" % id)


func _teste_archetipos() -> void:
	print("\n[2] Resolucao de arquétipo")
	_assert(AudioSynthScript.resolver_archetipo_mob("lobo_selvagem") == "beast", "lobo -> beast")
	_assert(AudioSynthScript.resolver_archetipo_mob("besouro_blindado") == "insect", "besouro -> insect")
	_assert(AudioSynthScript.resolver_archetipo_mob("bandido_renegado") == "humanoid", "bandido -> humanoid")
	_assert(AudioSynthScript.resolver_archetipo_mob("golem_pedra") == "construct", "golem -> construct")
	_assert(AudioSynthScript.resolver_archetipo_mob("slime") == "insect", "slime -> insect")


func _teste_ambient_loops() -> void:
	print("\n[3] Ambient loops com loop_mode")
	for bioma in ["ambient_forest", "ambient_ruins", "ambient_city", "ambient_dungeon", "ambient_arena"]:
		var wav: AudioStreamWAV = AudioSynthScript.obter_sfx(bioma)
		_assert(wav != null, "gera %s" % bioma)
		if wav != null:
			_assert(wav.loop_mode == AudioStreamWAV.LOOP_FORWARD, "%s tem loop" % bioma)
			_assert(wav.data.size() > 1000, "%s tem dados" % bioma)


func _teste_dialogue_murmur() -> void:
	print("\n[4] Dialogue murmur variantes")
	var a: AudioStreamWAV = AudioSynthScript.obter_sfx("dialogue_murmur", 0)
	var b: AudioStreamWAV = AudioSynthScript.obter_sfx("dialogue_murmur", 3)
	_assert(a != null and b != null, "murmur variantes geradas")
	_assert(AudioSynthScript.obter_sfx("hit_flesh") != null, "hit_flesh")
	_assert(AudioSynthScript.obter_sfx("quest_stinger") != null, "quest_stinger")


func _teste_audio_manager_api() -> void:
	print("\n[5] AudioManager API")
	_assert(AudioManager != null, "AudioManager existe")
	_assert(AudioManager.has_method("tocar_mob_voz"), "tocar_mob_voz")
	_assert(AudioManager.has_method("tocar_ambient"), "tocar_ambient")
	_assert(AudioManager.has_method("tocar_ambient_por_cena"), "tocar_ambient_por_cena")
	_assert(AudioManager.has_method("tocar_murmur_dialogo"), "tocar_murmur_dialogo")
	_assert(AudioManager.has_method("tocar_sfx_posicional"), "tocar_sfx_posicional")
	_assert(AudioManager.ambient_player != null, "ambient_player criado")
	AudioManager.tocar_mob_voz("growl", "lobo_selvagem")
	AudioManager.tocar_murmur_dialogo(1)
	AudioManager.tocar_sfx_posicional("hit_flesh", Vector2(10, 10), 0.5)
	_assert(true, "chamadas SFX nao crasharam")


func _teste_ambient_por_cena() -> void:
	print("\n[6] Ambient por cena")
	AudioManager.tocar_ambient_por_cena("res://world/lobby.tscn")
	_assert(AudioManager.current_ambient_id == "ambient_city", "lobby -> city ambient")
	AudioManager.tocar_ambient_por_cena("res://world/maps/montanha_kukuroo.tscn")
	_assert(AudioManager.current_ambient_id == "ambient_forest", "kukuroo -> forest")
	AudioManager.tocar_ambient_por_cena("res://world/maps/dungeon_ruinas_zaban.tscn")
	_assert(AudioManager.current_ambient_id == "ambient_ruins", "zaban -> ruins")
	AudioManager.tocar_ambient_por_cena("res://world/maps/arena_celestial.tscn")
	_assert(AudioManager.current_ambient_id == "ambient_arena", "arena -> arena")
	# Cache hit
	var before: String = AudioManager.current_ambient_id
	AudioManager.tocar_ambient("ambient_arena")
	_assert(AudioManager.current_ambient_id == before, "nao reinicia ambient igual")
