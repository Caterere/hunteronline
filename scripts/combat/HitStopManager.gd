class_name HitStopManager
extends RefCounted

# ============================================================
# HUNTER ONLINE — HIT REACTION & HITSTOP FRAMEWORK (EPIC 1)
# ============================================================
#
# Controla micro-pausas cinéticas de impacto (hitstop/hit-freeze),
# recuo físico (knockback/knockdown) e impulsos direcionais de tela (screen-shake).
# Calibração Canônica:
# - Ataque Básico: 30ms - 50ms
# - Ataque Pesado / Combo Finisher: 100ms - 150ms
# - Hatsu Crítico / Boss Slam: 180ms - 250ms
# ============================================================

enum HitIntensity {
	LIGHT,
	MEDIUM,
	HEAVY,
	HATSU,
	LETHAL
}

const HITSTOP_DURATIONS: Dictionary = {
	HitIntensity.LIGHT: 0.04,   # 40ms
	HitIntensity.MEDIUM: 0.08,  # 80ms
	HitIntensity.HEAVY: 0.12,   # 120ms
	HitIntensity.HATSU: 0.18,   # 180ms
	HitIntensity.LETHAL: 0.25   # 250ms
}

const KNOCKBACK_FORCE: Dictionary = {
	HitIntensity.LIGHT: 120.0,
	HitIntensity.MEDIUM: 220.0,
	HitIntensity.HEAVY: 360.0,
	HitIntensity.HATSU: 480.0,
	HitIntensity.LETHAL: 650.0
}

static var screen_shake_enabled: bool = true
static var screen_shake_intensity_multiplier: float = 1.0


# Dispara hitstop proporcional à intensidade do golpe
static func aplicar_hitstop(intensidade: HitIntensity = HitIntensity.MEDIUM, duracao_override: float = 0.0) -> void:
	var duracao: float = duracao_override if duracao_override > 0.0 else float(HITSTOP_DURATIONS.get(intensidade, 0.05))
	var main_loop = Engine.get_main_loop()
	var root = main_loop.root if main_loop is SceneTree else null
	var event_bus = root.get_node_or_null("EventBus") if root != null else null
	if event_bus != null and event_bus.has_method("emit_hitstop"):
		event_bus.emit_hitstop(duracao)


# Dispara screen-shake direcional calibrado
static func aplicar_screen_shake(intensidade: float = 0.5, _direcao: Vector2 = Vector2.ZERO) -> void:
	if not screen_shake_enabled or intensidade <= 0.0:
		return
	var final_intensity: float = intensidade * screen_shake_intensity_multiplier
	var main_loop = Engine.get_main_loop()
	var root = main_loop.root if main_loop is SceneTree else null
	var event_bus = root.get_node_or_null("EventBus") if root != null else null
	if event_bus != null and event_bus.has_signal("camera_shake_requested"):
		event_bus.camera_shake_requested.emit(final_intensity)


# Calcula vetor de recuo com decaimento físico e resistência do alvo
static func calcular_knockback(origem: Vector2, destino: Vector2, intensidade: HitIntensity, resistencia: float = 0.0) -> Vector2:
	var direcao := (destino - origem).normalized()
	if direcao == Vector2.ZERO:
		direcao = Vector2.RIGHT
	var base_force: float = float(KNOCKBACK_FORCE.get(intensidade, 200.0))
	var forca_final: float = maxf(0.0, base_force * (1.0 - clampf(resistencia, 0.0, 0.95)))
	return direcao * forca_final
