class_name AudioSynth
extends RefCounted

# ============================================================
# HUNTER ONLINE — PROCEDURAL AUDIO SYNTHESIZER (HIGH QUALITY SFX)
# ============================================================
#
# Gera AudioStreamWAV em memória com síntese matemática de ondas
# (senoide, ruído branco, onda dente-de-serra, triângulo e modulação FM/AM)
# com envelopes ADSR para feedback imediato e sem dependências de arquivos.
#
# ============================================================

static var _cache_sfx: Dictionary = {}

static func obter_sfx(tipo: String, variante: int = 0) -> AudioStreamWAV:
	var chave := "%s_%d" % [tipo, variante]
	if _cache_sfx.has(chave) and _cache_sfx[chave] != null:
		return _cache_sfx[chave]

	var stream: AudioStreamWAV = null
	match tipo:
		"hit_light":
			stream = _gerar_hit_fisico(120.0, 45.0, 0.08, 0.4)
		"hit_heavy":
			stream = _gerar_hit_fisico(90.0, 30.0, 0.14, 0.7)
		"hit_crit":
			stream = _gerar_hit_critico(160.0, 40.0, 0.22)
		"slash":
			stream = _gerar_whoosh(380.0, 120.0, 0.12)
		"dodge":
			stream = _gerar_whoosh(450.0, 200.0, 0.15)
		"perfect_dodge":
			stream = _gerar_sino_cristalino([880.0, 1320.0, 1760.0, 2640.0], 0.35)
		"stagger_break":
			stream = _gerar_quebra_postura(0.30)
		"nen_ten":
			stream = _gerar_hum_aura(110.0, 0.30)
		"nen_ren":
			stream = _gerar_explosao_ren(180.0, 80.0, 0.40)
		"nen_ko":
			stream = _gerar_foco_ko(520.0, 0.28)
		"nen_gyo":
			stream = _gerar_bip_sonar(740.0, 0.20)
		"gyo_detect":
			stream = _gerar_sino_cristalino([740.0, 1110.0, 1480.0], 0.28)
		"nen_zetsu":
			stream = _gerar_silencio_zetsu(0.25)
		"hatsu_cast":
			stream = _gerar_disparo_energia(320.0, 140.0, 0.25)
		"level_up":
			stream = _gerar_fanfarra_arpeggio([392.0, 523.25, 659.25, 783.99, 1046.50], 0.60)
		"quest_complete":
			stream = _gerar_fanfarra_arpeggio([523.25, 659.25, 783.99, 1046.50], 0.45)
		"ui_click":
			stream = _gerar_click_ui(800.0, 0.04)
		"ui_confirm":
			stream = _gerar_click_ui(1200.0, 0.06)
		"ui_error":
			stream = _gerar_ui_error(0.18)
		"item_pickup":
			stream = _gerar_shimmer_item([659.25, 987.77, 1318.51], 0.20)
		"footstep_grass":
			stream = _gerar_passo(75.0, 0.06, 0.45)
		"footstep_stone":
			stream = _gerar_passo(160.0, 0.04, 0.20)
		"hurt":
			stream = _gerar_hurt(130.0, 55.0, 0.16)
		"block":
			stream = _gerar_bloqueio(310.0, 0.16)
		"boss_intro":
			stream = _gerar_boss_intro()
		"boss_phase":
			stream = _gerar_boss_phase()
		"hatsu_enhancer":
			stream = _gerar_explosao_enhancer()
		"hatsu_transmuter":
			stream = _gerar_crackle_transmuter()
		"hatsu_emitter":
			stream = _gerar_whoosh_emitter()
		"hatsu_manipulator":
			stream = _gerar_whistle_manipulator()
		"hatsu_conjurer":
			stream = _gerar_chain_conjurer()
		"hatsu_specialist":
			stream = _gerar_chord_specialist()
		# --- PILAR 3: identidade sonora de mobs / ambiente / diálogo ---
		"mob_growl_beast":
			stream = _gerar_mob_voz(85.0, 55.0, 0.28, 0.55, false)
		"mob_hurt_beast":
			stream = _gerar_mob_voz(140.0, 70.0, 0.16, 0.40, true)
		"mob_death_beast":
			stream = _gerar_mob_voz(95.0, 35.0, 0.42, 0.65, true)
		"mob_growl_insect":
			stream = _gerar_mob_voz(420.0, 280.0, 0.18, 0.25, false)
		"mob_hurt_insect":
			stream = _gerar_mob_voz(520.0, 300.0, 0.12, 0.20, true)
		"mob_death_insect":
			stream = _gerar_mob_voz(380.0, 90.0, 0.30, 0.35, true)
		"mob_growl_humanoid":
			stream = _gerar_mob_voz(160.0, 110.0, 0.20, 0.15, false)
		"mob_hurt_humanoid":
			stream = _gerar_mob_voz(210.0, 100.0, 0.14, 0.22, true)
		"mob_death_humanoid":
			stream = _gerar_mob_voz(130.0, 55.0, 0.36, 0.30, true)
		"mob_growl_construct":
			stream = _gerar_mob_voz(70.0, 45.0, 0.26, 0.70, false)
		"mob_hurt_construct":
			stream = _gerar_mob_voz(95.0, 50.0, 0.15, 0.55, true)
		"mob_death_construct":
			stream = _gerar_quebra_postura(0.34)
		"hit_flesh":
			stream = _gerar_hit_fisico(150.0, 55.0, 0.10, 0.55)
		"hit_aura":
			stream = _gerar_sino_cristalino([330.0, 495.0, 660.0], 0.18)
		"dialogue_murmur":
			stream = _gerar_dialogue_murmur(variante)
		"ambient_forest":
			stream = _gerar_ambient_loop("forest")
		"ambient_ruins":
			stream = _gerar_ambient_loop("ruins")
		"ambient_city":
			stream = _gerar_ambient_loop("city")
		"ambient_dungeon":
			stream = _gerar_ambient_loop("dungeon")
		"ambient_arena":
			stream = _gerar_ambient_loop("arena")
		"quest_stinger":
			stream = _gerar_fanfarra_arpeggio([392.0, 523.25, 659.25], 0.32)
		_:
			stream = _gerar_hit_fisico(120.0, 50.0, 0.08, 0.3)

	_cache_sfx[chave] = stream
	return stream


# --- SÍNTESE DE ONDAS BÁSICAS ---

static func _criar_wav_buffer(amostras: PackedByteArray, sample_rate: int = 22050) -> AudioStreamWAV:
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = sample_rate
	wav.stereo = false
	wav.data = amostras
	return wav


static func _gerar_hit_fisico(freq_inicial: float, freq_final: float, duracao: float, punch_noise: float) -> AudioStreamWAV:
	var sample_rate: int = 22050
	var total_samples: int = int(duracao * sample_rate)
	var buffer := PackedByteArray()
	buffer.resize(total_samples * 2)

	var phase: float = 0.0
	for i in range(total_samples):
		var t: float = float(i) / float(total_samples)
		var freq: float = lerp(freq_inicial, freq_final, t * t)
		phase += (freq * TAU) / float(sample_rate)

		var env: float = pow(1.0 - t, 2.5)
		var onda: float = sin(phase) * (1.0 - punch_noise)
		var noise: float = (randf() * 2.0 - 1.0) * punch_noise * env
		var sample_val: float = clampf((onda + noise) * env * 0.85, -1.0, 1.0)

		var val_16bit: int = int(sample_val * 32767.0)
		buffer.encode_s16(i * 2, val_16bit)

	return _criar_wav_buffer(buffer, sample_rate)


static func _gerar_hit_critico(freq_inicial: float, freq_final: float, duracao: float) -> AudioStreamWAV:
	var sample_rate: int = 22050
	var total_samples: int = int(duracao * sample_rate)
	var buffer := PackedByteArray()
	buffer.resize(total_samples * 2)

	var phase1: float = 0.0
	var phase2: float = 0.0
	for i in range(total_samples):
		var t: float = float(i) / float(total_samples)
		var freq: float = lerp(freq_inicial, freq_final, t)
		phase1 += (freq * TAU) / float(sample_rate)
		phase2 += ((freq * 1.5) * TAU) / float(sample_rate)

		var env: float = pow(1.0 - t, 2.0)
		var onda: float = (sin(phase1) * 0.6 + sin(phase2) * 0.4)
		var crackle: float = (randf() * 2.0 - 1.0) * 0.35 * env if t < 0.25 else 0.0
		var sample_val: float = clampf((onda + crackle) * env * 0.95, -1.0, 1.0)

		var val_16bit: int = int(sample_val * 32767.0)
		buffer.encode_s16(i * 2, val_16bit)

	return _criar_wav_buffer(buffer, sample_rate)


static func _gerar_whoosh(freq_start: float, freq_end: float, duracao: float) -> AudioStreamWAV:
	var sample_rate: int = 22050
	var total_samples: int = int(duracao * sample_rate)
	var buffer := PackedByteArray()
	buffer.resize(total_samples * 2)

	var phase: float = 0.0
	for i in range(total_samples):
		var t: float = float(i) / float(total_samples)
		var freq: float = lerp(freq_start, freq_end, sin(t * PI))
		phase += (freq * TAU) / float(sample_rate)

		var env: float = sin(t * PI)
		var noise: float = (randf() * 2.0 - 1.0) * 0.6
		var sample_val: float = clampf((sin(phase) * 0.4 + noise) * env * 0.70, -1.0, 1.0)

		var val_16bit: int = int(sample_val * 32767.0)
		buffer.encode_s16(i * 2, val_16bit)

	return _criar_wav_buffer(buffer, sample_rate)


static func _gerar_sino_cristalino(freqs: Array, duracao: float) -> AudioStreamWAV:
	var sample_rate: int = 22050
	var total_samples: int = int(duracao * sample_rate)
	var buffer := PackedByteArray()
	buffer.resize(total_samples * 2)

	var phases := []
	for _f in freqs:
		phases.append(0.0)

	for i in range(total_samples):
		var t: float = float(i) / float(total_samples)
		var env: float = pow(1.0 - t, 1.8)
		var soma: float = 0.0

		for k in range(freqs.size()):
			var f: float = float(freqs[k])
			phases[k] += (f * TAU) / float(sample_rate)
			soma += sin(phases[k]) * (1.0 / float(k + 1))

		var sample_val: float = clampf(soma * env * 0.50, -1.0, 1.0)
		var val_16bit: int = int(sample_val * 32767.0)
		buffer.encode_s16(i * 2, val_16bit)

	return _criar_wav_buffer(buffer, sample_rate)


static func _gerar_quebra_postura(duracao: float) -> AudioStreamWAV:
	var sample_rate: int = 22050
	var total_samples: int = int(duracao * sample_rate)
	var buffer := PackedByteArray()
	buffer.resize(total_samples * 2)

	var phase: float = 0.0
	for i in range(total_samples):
		var t: float = float(i) / float(total_samples)
		var env: float = pow(1.0 - t, 3.0)
		phase += (60.0 * TAU) / float(sample_rate)

		var shatter: float = (randf() * 2.0 - 1.0) * (1.0 if t < 0.15 else env)
		var sub_bass: float = sin(phase) * 0.7 * env
		var sample_val: float = clampf((shatter * 0.7 + sub_bass) * env * 0.90, -1.0, 1.0)

		var val_16bit: int = int(sample_val * 32767.0)
		buffer.encode_s16(i * 2, val_16bit)

	return _criar_wav_buffer(buffer, sample_rate)


static func _gerar_hum_aura(freq: float, duracao: float) -> AudioStreamWAV:
	var sample_rate: int = 22050
	var total_samples: int = int(duracao * sample_rate)
	var buffer := PackedByteArray()
	buffer.resize(total_samples * 2)

	var phase1: float = 0.0
	var phase2: float = 0.0
	for i in range(total_samples):
		var t: float = float(i) / float(total_samples)
		phase1 += (freq * TAU) / float(sample_rate)
		phase2 += ((freq * 2.01) * TAU) / float(sample_rate)

		var env: float = sin(t * PI)
		var sample_val: float = clampf((sin(phase1) * 0.6 + sin(phase2) * 0.4) * env * 0.75, -1.0, 1.0)

		var val_16bit: int = int(sample_val * 32767.0)
		buffer.encode_s16(i * 2, val_16bit)

	return _criar_wav_buffer(buffer, sample_rate)


static func _gerar_explosao_ren(freq_start: float, freq_end: float, duracao: float) -> AudioStreamWAV:
	var sample_rate: int = 22050
	var total_samples: int = int(duracao * sample_rate)
	var buffer := PackedByteArray()
	buffer.resize(total_samples * 2)

	var phase: float = 0.0
	for i in range(total_samples):
		var t: float = float(i) / float(total_samples)
		var freq: float = lerp(freq_start, freq_end, t)
		phase += (freq * TAU) / float(sample_rate)

		var env: float = pow(1.0 - t, 1.5)
		var roar: float = (randf() * 2.0 - 1.0) * 0.45 * env
		var sample_val: float = clampf((sin(phase) * 0.55 + roar) * env * 0.85, -1.0, 1.0)

		var val_16bit: int = int(sample_val * 32767.0)
		buffer.encode_s16(i * 2, val_16bit)

	return _criar_wav_buffer(buffer, sample_rate)


static func _gerar_foco_ko(freq: float, duracao: float) -> AudioStreamWAV:
	var sample_rate: int = 22050
	var total_samples: int = int(duracao * sample_rate)
	var buffer := PackedByteArray()
	buffer.resize(total_samples * 2)

	var phase: float = 0.0
	for i in range(total_samples):
		var t: float = float(i) / float(total_samples)
		var f: float = freq * (1.0 + t * 0.5)
		phase += (f * TAU) / float(sample_rate)

		var env: float = sin(t * PI)
		var sample_val: float = clampf(sin(phase) * env * 0.80, -1.0, 1.0)

		var val_16bit: int = int(sample_val * 32767.0)
		buffer.encode_s16(i * 2, val_16bit)

	return _criar_wav_buffer(buffer, sample_rate)


static func _gerar_bip_sonar(freq: float, duracao: float) -> AudioStreamWAV:
	var sample_rate: int = 22050
	var total_samples: int = int(duracao * sample_rate)
	var buffer := PackedByteArray()
	buffer.resize(total_samples * 2)

	var phase: float = 0.0
	for i in range(total_samples):
		var t: float = float(i) / float(total_samples)
		phase += (freq * TAU) / float(sample_rate)
		var env: float = pow(1.0 - t, 2.0)
		var sample_val: float = clampf(sin(phase) * env * 0.70, -1.0, 1.0)
		buffer.encode_s16(i * 2, int(sample_val * 32767.0))

	return _criar_wav_buffer(buffer, sample_rate)


static func _gerar_silencio_zetsu(duracao: float) -> AudioStreamWAV:
	var sample_rate: int = 22050
	var total_samples: int = int(duracao * sample_rate)
	var buffer := PackedByteArray()
	buffer.resize(total_samples * 2)

	for i in range(total_samples):
		var t: float = float(i) / float(total_samples)
		var env: float = pow(1.0 - t, 2.0)
		var breath: float = (randf() * 2.0 - 1.0) * 0.25 * env
		buffer.encode_s16(i * 2, int(breath * 32767.0))

	return _criar_wav_buffer(buffer, sample_rate)


static func _gerar_disparo_energia(freq_start: float, freq_end: float, duracao: float) -> AudioStreamWAV:
	var sample_rate: int = 22050
	var total_samples: int = int(duracao * sample_rate)
	var buffer := PackedByteArray()
	buffer.resize(total_samples * 2)

	var phase: float = 0.0
	for i in range(total_samples):
		var t: float = float(i) / float(total_samples)
		var freq: float = lerp(freq_start, freq_end, t * t)
		phase += (freq * TAU) / float(sample_rate)
		var env: float = pow(1.0 - t, 1.6)
		var sample_val: float = clampf((sin(phase) * 0.7 + (randf() * 2.0 - 1.0) * 0.3) * env * 0.85, -1.0, 1.0)
		buffer.encode_s16(i * 2, int(sample_val * 32767.0))

	return _criar_wav_buffer(buffer, sample_rate)


static func _gerar_fanfarra_arpeggio(notas: Array, duracao_total: float) -> AudioStreamWAV:
	var sample_rate: int = 22050
	var total_samples: int = int(duracao_total * sample_rate)
	var buffer := PackedByteArray()
	buffer.resize(total_samples * 2)

	var samples_por_nota: int = total_samples / max(1, notas.size())
	var phase: float = 0.0

	for i in range(total_samples):
		var idx_nota: int = mini(i / samples_por_nota, notas.size() - 1)
		var freq: float = float(notas[idx_nota])
		phase += (freq * TAU) / float(sample_rate)

		var t_global: float = float(i) / float(total_samples)
		var t_local: float = float(i % samples_por_nota) / float(samples_por_nota)
		var env: float = (1.0 - t_local * 0.6) * (1.0 - t_global * 0.3)
		var sample_val: float = clampf(sin(phase) * env * 0.60, -1.0, 1.0)
		buffer.encode_s16(i * 2, int(sample_val * 32767.0))

	return _criar_wav_buffer(buffer, sample_rate)


static func _gerar_click_ui(freq: float, duracao: float) -> AudioStreamWAV:
	var sample_rate: int = 22050
	var total_samples: int = int(duracao * sample_rate)
	var buffer := PackedByteArray()
	buffer.resize(total_samples * 2)

	var phase: float = 0.0
	for i in range(total_samples):
		var t: float = float(i) / float(total_samples)
		phase += (freq * TAU) / float(sample_rate)
		var env: float = pow(1.0 - t, 3.0)
		var sample_val: float = clampf(sin(phase) * env * 0.40, -1.0, 1.0)
		buffer.encode_s16(i * 2, int(sample_val * 32767.0))

	return _criar_wav_buffer(buffer, sample_rate)


static func _gerar_shimmer_item(freqs: Array, duracao: float) -> AudioStreamWAV:
	var sample_rate: int = 22050
	var total_samples: int = int(duracao * sample_rate)
	var buffer := PackedByteArray()
	buffer.resize(total_samples * 2)

	var samples_por_etapa: int = total_samples / max(1, freqs.size())
	var phase: float = 0.0

	for i in range(total_samples):
		var idx: int = mini(i / samples_por_etapa, freqs.size() - 1)
		var freq: float = float(freqs[idx])
		phase += (freq * TAU) / float(sample_rate)

		var t_global: float = float(i) / float(total_samples)
		var env: float = pow(1.0 - t_global, 1.5)
		var sample_val: float = clampf(sin(phase) * env * 0.50, -1.0, 1.0)
		buffer.encode_s16(i * 2, int(sample_val * 32767.0))

	return _criar_wav_buffer(buffer, sample_rate)


static func _gerar_passo(freq: float, duracao: float, noise_amt: float) -> AudioStreamWAV:
	var sample_rate: int = 22050
	var total_samples: int = int(duracao * sample_rate)
	var buffer := PackedByteArray()
	buffer.resize(total_samples * 2)
	var phase: float = 0.0
	for i in range(total_samples):
		var t: float = float(i) / float(total_samples)
		phase += (freq * (1.0 - t * 0.5) * TAU) / float(sample_rate)
		var env: float = pow(1.0 - t, 4.0)
		var s: float = (sin(phase) * (1.0 - noise_amt) + (randf() * 2.0 - 1.0) * noise_amt) * env * 0.35
		buffer.encode_s16(i * 2, int(clampf(s, -1.0, 1.0) * 32767.0))
	return _criar_wav_buffer(buffer, sample_rate)


static func _gerar_hurt(freq_start: float, freq_end: float, duracao: float) -> AudioStreamWAV:
	var sample_rate: int = 22050
	var total_samples: int = int(duracao * sample_rate)
	var buffer := PackedByteArray()
	buffer.resize(total_samples * 2)
	var phase: float = 0.0
	for i in range(total_samples):
		var t: float = float(i) / float(total_samples)
		var freq: float = lerp(freq_start, freq_end, t * t)
		phase += (freq * TAU) / float(sample_rate)
		var env: float = sin(t * PI) * pow(1.0 - t, 1.2)
		var n: float = (randf() * 2.0 - 1.0) * 0.25
		var s: float = (sin(phase) * 0.75 + n) * env * 0.65
		buffer.encode_s16(i * 2, int(clampf(s, -1.0, 1.0) * 32767.0))
	return _criar_wav_buffer(buffer, sample_rate)


static func _gerar_bloqueio(freq: float, duracao: float) -> AudioStreamWAV:
	var sample_rate: int = 22050
	var total_samples: int = int(duracao * sample_rate)
	var buffer := PackedByteArray()
	buffer.resize(total_samples * 2)
	var phase1: float = 0.0
	var phase2: float = 0.0
	for i in range(total_samples):
		var t: float = float(i) / float(total_samples)
		phase1 += (freq * TAU) / float(sample_rate)
		phase2 += ((freq * 2.41) * TAU) / float(sample_rate)
		var env: float = pow(1.0 - t, 2.8)
		var s: float = (sin(phase1) * 0.6 + sin(phase2) * 0.4) * env * 0.75
		buffer.encode_s16(i * 2, int(clampf(s, -1.0, 1.0) * 32767.0))
	return _criar_wav_buffer(buffer, sample_rate)


static func _gerar_ui_error(duracao: float) -> AudioStreamWAV:
	var sample_rate: int = 22050
	var total_samples: int = int(duracao * sample_rate)
	var buffer := PackedByteArray()
	buffer.resize(total_samples * 2)
	var phase: float = 0.0
	for i in range(total_samples):
		var t: float = float(i) / float(total_samples)
		var freq: float = 160.0 if t < 0.5 else 130.0
		phase += (freq * TAU) / float(sample_rate)
		var env: float = (1.0 - (t if t < 0.5 else (t - 0.5) * 2.0))
		var sq: float = 1.0 if sin(phase) > 0.0 else -1.0
		var s: float = sq * env * 0.45
		buffer.encode_s16(i * 2, int(clampf(s, -1.0, 1.0) * 32767.0))
	return _criar_wav_buffer(buffer, sample_rate)


static func _gerar_boss_intro() -> AudioStreamWAV:
	var sample_rate: int = 22050
	var duracao: float = 0.85
	var total_samples: int = int(duracao * sample_rate)
	var buffer := PackedByteArray()
	buffer.resize(total_samples * 2)
	var freqs: Array[float] = [130.81, 164.81, 196.00, 261.63]
	var phase: Array[float] = [0.0, 0.0, 0.0, 0.0]
	for i in range(total_samples):
		var t: float = float(i) / float(total_samples)
		var s: float = 0.0
		for j in range(freqs.size()):
			phase[j] += (freqs[j] * TAU) / float(sample_rate)
			var harmonic: float = sin(phase[j]) + sin(phase[j] * 2.0) * 0.3
			s += harmonic * 0.25
		var env: float = sin(minf(t * 3.0, 1.0) * PI * 0.5) * pow(1.0 - t, 0.9)
		buffer.encode_s16(i * 2, int(clampf(s * env * 0.85, -1.0, 1.0) * 32767.0))
	return _criar_wav_buffer(buffer, sample_rate)


static func _gerar_boss_phase() -> AudioStreamWAV:
	var sample_rate: int = 22050
	var duracao: float = 0.55
	var total_samples: int = int(duracao * sample_rate)
	var buffer := PackedByteArray()
	buffer.resize(total_samples * 2)
	var phase: float = 0.0
	for i in range(total_samples):
		var t: float = float(i) / float(total_samples)
		var freq: float = lerp(220.0, 50.0, t * t)
		phase += (freq * TAU) / float(sample_rate)
		var env: float = pow(1.0 - t, 1.4)
		var noise: float = (randf() * 2.0 - 1.0) * 0.35 * env
		var s: float = (sin(phase) + noise) * env * 0.80
		buffer.encode_s16(i * 2, int(clampf(s, -1.0, 1.0) * 32767.0))
	return _criar_wav_buffer(buffer, sample_rate)


static func _gerar_explosao_enhancer() -> AudioStreamWAV:
	return _gerar_hit_fisico(240.0, 50.0, 0.28, 0.6)


static func _gerar_crackle_transmuter() -> AudioStreamWAV:
	var sample_rate: int = 22050
	var duracao: float = 0.24
	var total_samples: int = int(duracao * sample_rate)
	var buffer := PackedByteArray()
	buffer.resize(total_samples * 2)
	var phase: float = 0.0
	for i in range(total_samples):
		var t: float = float(i) / float(total_samples)
		var freq: float = 550.0 + sin(t * 80.0) * 200.0
		phase += (freq * TAU) / float(sample_rate)
		var spark: float = (randf() * 2.0 - 1.0) * 0.45 if randf() < 0.3 else 0.0
		var env: float = pow(1.0 - t, 1.8)
		var s: float = (sin(phase) * 0.55 + spark) * env * 0.70
		buffer.encode_s16(i * 2, int(clampf(s, -1.0, 1.0) * 32767.0))
	return _criar_wav_buffer(buffer, sample_rate)


static func _gerar_whoosh_emitter() -> AudioStreamWAV:
	return _gerar_whoosh(600.0, 180.0, 0.22)


static func _gerar_whistle_manipulator() -> AudioStreamWAV:
	var sample_rate: int = 22050
	var duracao: float = 0.30
	var total_samples: int = int(duracao * sample_rate)
	var buffer := PackedByteArray()
	buffer.resize(total_samples * 2)
	var phase: float = 0.0
	for i in range(total_samples):
		var t: float = float(i) / float(total_samples)
		var freq: float = 880.0 + sin(t * 30.0) * 60.0
		phase += (freq * TAU) / float(sample_rate)
		var env: float = sin(t * PI)
		var s: float = sin(phase) * env * 0.50
		buffer.encode_s16(i * 2, int(clampf(s, -1.0, 1.0) * 32767.0))
	return _criar_wav_buffer(buffer, sample_rate)


static func _gerar_chain_conjurer() -> AudioStreamWAV:
	return _gerar_sino_cristalino([700.0, 1050.0, 1400.0, 2100.0], 0.32)


static func _gerar_chord_specialist() -> AudioStreamWAV:
	return _gerar_shimmer_item([220.0, 261.63, 311.13, 392.00], 0.45)


## Vocalização curta de mob (growl / hurt / death) por faixa de frequência.
static func _gerar_mob_voz(freq_ini: float, freq_fim: float, duracao: float, noise_amt: float, descendente: bool) -> AudioStreamWAV:
	var sample_rate: int = 22050
	var total_samples: int = int(duracao * sample_rate)
	var buffer := PackedByteArray()
	buffer.resize(total_samples * 2)
	var phase: float = 0.0
	var phase2: float = 0.0
	for i in range(total_samples):
		var t: float = float(i) / float(total_samples)
		var curve: float = t * t if descendente else (1.0 - (1.0 - t) * (1.0 - t))
		var freq: float = lerp(freq_ini, freq_fim, curve)
		phase += (freq * TAU) / float(sample_rate)
		phase2 += (freq * 1.5 * TAU) / float(sample_rate)
		var env: float = sin(minf(t * 4.0, 1.0) * PI * 0.5) * pow(1.0 - t, 1.3)
		var growl: float = sin(phase) * 0.55 + sin(phase2) * 0.25
		growl = tanh(growl * 1.8)
		var noise: float = (randf() * 2.0 - 1.0) * noise_amt * env
		var s: float = (growl + noise) * env * 0.72
		buffer.encode_s16(i * 2, int(clampf(s, -1.0, 1.0) * 32767.0))
	return _criar_wav_buffer(buffer, sample_rate)


## Murmúrio estilo Animal Crossing / Zelda — tom curto por variante de fala.
static func _gerar_dialogue_murmur(variante: int = 0) -> AudioStreamWAV:
	var sample_rate: int = 22050
	var duracao: float = 0.09 + float(variante % 3) * 0.02
	var total_samples: int = int(duracao * sample_rate)
	var buffer := PackedByteArray()
	buffer.resize(total_samples * 2)
	var base_freq: float = 280.0 + float((variante * 37) % 120)
	var phase: float = 0.0
	for i in range(total_samples):
		var t: float = float(i) / float(total_samples)
		var freq: float = base_freq + sin(t * PI * 2.0) * 35.0
		phase += (freq * TAU) / float(sample_rate)
		var env: float = sin(t * PI)
		var s: float = sin(phase) * env * 0.28
		buffer.encode_s16(i * 2, int(clampf(s, -1.0, 1.0) * 32767.0))
	return _criar_wav_buffer(buffer, sample_rate)


## Ambient loop contínuo por bioma (volume baixo sob a OST).
static func _gerar_ambient_loop(bioma: String) -> AudioStreamWAV:
	var sample_rate: int = 22050
	var duracao: float = 4.0
	var total_samples: int = int(duracao * sample_rate)
	var buffer := PackedByteArray()
	buffer.resize(total_samples * 2)

	var bed_freq: float = 55.0
	var noise_level: float = 0.08
	var chirp: bool = false
	var drip: bool = false
	var murmur_city: bool = false
	match bioma:
		"forest":
			bed_freq = 48.0
			noise_level = 0.12
			chirp = true
		"ruins":
			bed_freq = 40.0
			noise_level = 0.18
			drip = true
		"city":
			bed_freq = 65.0
			noise_level = 0.10
			murmur_city = true
		"dungeon":
			bed_freq = 36.0
			noise_level = 0.22
			drip = true
		"arena":
			bed_freq = 70.0
			noise_level = 0.06
		_:
			bed_freq = 50.0

	var phase: float = 0.0
	var phase_h: float = 0.0
	for i in range(total_samples):
		var t: float = float(i) / float(sample_rate)
		phase += (bed_freq * TAU) / float(sample_rate)
		phase_h += (bed_freq * 2.0 * TAU) / float(sample_rate)
		var s: float = sin(phase) * 0.18 + sin(phase_h) * 0.08
		s += (randf() * 2.0 - 1.0) * noise_level * 0.35
		if chirp and int(t * 2.0) % 3 == 0 and fmod(t, 0.5) < 0.05:
			s += sin(t * 2800.0) * 0.08 * (1.0 - fmod(t, 0.5) / 0.05)
		if drip and fmod(t * 1.7, 1.0) < 0.02:
			s += sin(t * 1800.0) * 0.12 * (1.0 - fmod(t * 1.7, 1.0) / 0.02)
		if murmur_city and fmod(t * 0.9, 1.0) < 0.15:
			s += sin(t * 220.0 + sin(t * 11.0)) * 0.05
		var edge: float = minf(t / 0.15, (duracao - t) / 0.15)
		edge = clampf(edge, 0.0, 1.0)
		s *= edge * 0.55
		buffer.encode_s16(i * 2, int(clampf(s, -1.0, 1.0) * 32767.0))

	var wav := _criar_wav_buffer(buffer, sample_rate)
	wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
	wav.loop_begin = 0
	wav.loop_end = total_samples
	return wav


## Resolve arquétipo sonoro a partir do enemy_id / nome.
static func resolver_archetipo_mob(enemy_id: String) -> String:
	var e: String = enemy_id.to_lower()
	if "slime" in e or "besouro" in e or "formiga" in e or "insect" in e or "inseto" in e or "serpente" in e:
		return "insect"
	if "golem" in e or "pedra" in e or "sentinela" in e or "construct" in e or "estatua" in e:
		return "construct"
	if "bandido" in e or "ladrao" in e or "hunter" in e or "humano" in e or "guarda" in e or "assassino" in e or "candidato" in e:
		return "humanoid"
	if "lobo" in e or "urso" in e or "javali" in e or "fera" in e or "best" in e or "cao" in e or "mike" in e:
		return "beast"
	return "beast"
