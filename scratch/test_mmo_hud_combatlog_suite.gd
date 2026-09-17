extends Node

# godot --headless --path . res://scratch/test_mmo_hud_combatlog_suite.tscn

const ChatScript = preload("res://ui/chat/MultiplayerChatHUD.gd")
const StyleScript = preload("res://ui/theme/HunterUIStyle.gd")
const NameplateScript = preload("res://entities/components/EnemyNameplate.gd")

var _pass := 0
var _fail := 0


func assert_test(cond: bool, msg: String) -> void:
	if cond:
		_pass += 1
		print("  PASS: ", msg)
	else:
		_fail += 1
		print("  FAIL: ", msg)


func _ready() -> void:
	print("=== test_mmo_hud_combatlog_suite ===")
	_test_viewport_and_glass()
	_test_chat_api()
	await _test_eventbus_combat_lines()
	print("=== RESULT: %d pass, %d fail ===" % [_pass, _fail])
	await get_tree().create_timer(0.05).timeout
	get_tree().quit(0 if _fail == 0 else 1)


func _test_viewport_and_glass() -> void:
	print("-- viewport & glass --")
	var w: int = ProjectSettings.get_setting("display/window/size/viewport_width", 0)
	var h: int = ProjectSettings.get_setting("display/window/size/viewport_height", 0)
	assert_test(w == 960 and h == 540, "viewport 960x540 (got %dx%d)" % [w, h])
	assert_test("criar_style_glass_panel" in StyleScript, "criar_style_glass_panel exists")
	var panel := StyleScript.criar_style_glass_panel()
	assert_test(panel != null and panel.bg_color == StyleScript.COLOR_GLASS_BG, "glass panel bg color")
	assert_test(ResourceLoader.exists("res://entities/components/EnemyNameplate.gd"), "EnemyNameplate script loads")
	assert_test(NameplateScript != null, "EnemyNameplate preloaded")


func _test_chat_api() -> void:
	print("-- chat api --")
	var chat := ChatScript.new()
	add_child(chat)
	await get_tree().process_frame
	assert_test("combat" in chat.canais, "combat channel in canais")
	assert_test(chat.has_method("adicionar_sistema"), "adicionar_sistema method")
	chat.adicionar_sistema("Gained 10 XP", ChatScript.COLOR_COMBAT_XP)
	await get_tree().process_frame
	var lines := 0
	var vbox = chat.vbox_log
	if vbox != null:
		lines = vbox.get_child_count()
	assert_test(lines >= 1, "combat line appended to log")
	chat.queue_free()


func _test_eventbus_combat_lines() -> void:
	print("-- eventbus combat --")
	if EventBus == null:
		assert_test(false, "EventBus autoload")
		return
	var chat := ChatScript.new()
	add_child(chat)
	await get_tree().process_frame
	var before: int = chat.vbox_log.get_child_count() if chat.vbox_log != null else 0
	EventBus.jenny_changed.emit(500, 25)
	EventBus.item_obtained.emit("gosma_slime", 2)
	await get_tree().process_frame
	var after: int = chat.vbox_log.get_child_count() if chat.vbox_log != null else 0
	assert_test(after >= before + 2, "jenny + item lines in chat (before=%d after=%d)" % [before, after])
	chat.queue_free()
