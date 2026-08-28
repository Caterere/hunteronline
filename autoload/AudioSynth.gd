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
		"item_pickup":
			stream = _gerar_shimmer_item([659.25, 987.77, 1318.51], 0.20)
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
