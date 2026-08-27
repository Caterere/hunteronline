extends Node

# ============================================================
# HUNTER ONLINE - TIME MANAGER (DAY / NIGHT CYCLE)
# ============================================================
#
# Gerenciador global de tempo e ciclo solar:
# - Relógio de jogo contínuo (horas, minutos, dias)
# - Fases do dia: ALVORECER, DIA, CREPÚSCULO, NOITE
# - Modulação de luz ambiente para mapas abertos
# - Sincronização com rotinas de NPCs e eventos mundiais
#
# ============================================================

enum TimePhase {
	DAWN = 0,   # 05:00 às 08:00
	DAY = 1,    # 08:00 às 17:00
	DUSK = 2,   # 17:00 às 20:00
	NIGHT = 3   # 20:00 às 05:00
}

enum FaseSolar {
	DAWN = 0,
	DAY = 1,
	DUSK = 2,
	NIGHT = 3
}

signal time_ticked(hour: int, minute: int)
signal phase_changed(phase: int, phase_name: String)

# Configuração de Velocidade (1 segundo real = 1 minuto de jogo -> 24 min por dia completo)
@export var time_scale: float = 60.0

var current_hour: int = 8
var current_minute: int = 0
var current_day: int = 1
var accumulated_seconds: float = 0.0

var current_phase: int = TimePhase.DAY

var fase_solar: int:
	get:
		return current_phase
	set(v):
		current_phase = v



func _ready() -> void:
	print("=================================")
	print("[TimeManager] RELÓGIO GLOBAL & CICLO DIA/NOITE ATIVO")
	print("=================================")
	_atualizar_fase(true)


func _process(delta: float) -> void:
	accumulated_seconds += delta * time_scale
	
	if accumulated_seconds >= 60.0:
		var mins_to_add = int(accumulated_seconds / 60.0)
		accumulated_seconds = fmod(accumulated_seconds, 60.0)
		_adicionar_minutos(mins_to_add)


func _adicionar_minutos(mins: int) -> void:
	current_minute += mins
	while current_minute >= 60:
		current_minute -= 60
		current_hour += 1
		if current_hour >= 24:
			current_hour = 0
			current_day += 1
			
		time_ticked.emit(current_hour, current_minute)
		if EventBus:
			EventBus.time_hour_ticked.emit(current_hour, current_minute)
			
	_atualizar_fase(false)


func _atualizar_fase(force_emit: bool = false) -> void:
	var nova_fase: int = TimePhase.DAY
	
	if current_hour >= 5 and current_hour < 8:
		nova_fase = TimePhase.DAWN
	elif current_hour >= 8 and current_hour < 17:
		nova_fase = TimePhase.DAY
	elif current_hour >= 17 and current_hour < 20:
		nova_fase = TimePhase.DUSK
	else:
		nova_fase = TimePhase.NIGHT
		
	if nova_fase != current_phase or force_emit:
		current_phase = nova_fase
		var nome = get_phase_name()
		phase_changed.emit(current_phase, nome)
		if EventBus:
			EventBus.time_phase_changed.emit(nome)
		print("[TimeManager] Fase solar alterada: %s (Hora %02d:%02d)" % [nome, current_hour, current_minute])


func get_phase_name() -> String:
	match current_phase:
		TimePhase.DAWN: return "DAWN"
		TimePhase.DAY: return "DAY"
		TimePhase.DUSK: return "DUSK"
		TimePhase.NIGHT: return "NIGHT"
		_: return "DAY"


func get_ambient_light_color() -> Color:
	match current_phase:
		TimePhase.DAWN:
			return Color(1.05, 0.95, 0.85, 1.0)
		TimePhase.DAY:
			return Color(1.0, 1.0, 1.0, 1.0)
		TimePhase.DUSK:
			return Color(1.0, 0.78, 0.65, 1.0)
		TimePhase.NIGHT:
			return Color(0.45, 0.48, 0.70, 1.0)
		_:
			return Color.WHITE


func get_time_string() -> String:
	return "%02d:%02d - Dia %d (%s)" % [current_hour, current_minute, current_day, get_phase_name()]


func set_time(hour: int, minute: int) -> void:
	current_hour = clampi(hour, 0, 23)
	current_minute = clampi(minute, 0, 59)
	_atualizar_fase(true)

func definir_hora(hour: int, minute: int = 0) -> void:
	set_time(hour, minute)

func obter_hora() -> int:
	return current_hour

func obter_fase() -> int:
	return current_phase

