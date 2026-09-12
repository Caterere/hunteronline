extends Node

# ============================================================
# HATSU BUILD GALLERY — compartilhar conceito (não poder max).
# Rate limit local; cópia exige re-pagar votos do destinatário.
# ============================================================

signal gallery_updated

const MAX_POSTS_PER_HOUR := 3
const MAX_GALLERY_SIZE := 40

var _posts: Array[Dictionary] = []
var _post_timestamps: Array[int] = []


func publicar_conceito(hatsu: HatsuData, author: String = "") -> Dictionary:
	if hatsu == null:
		return {"ok": false, "reason": "Hatsu inválido"}
	_prune_rate_window()
	if _post_timestamps.size() >= MAX_POSTS_PER_HOUR:
		return {"ok": false, "reason": "Rate limit: no máx. %d posts/hora" % MAX_POSTS_PER_HOUR}
	var autor := author if not author.is_empty() else str(PlayerData.get("player_name") if PlayerData else "Hunter")
	var entry := {
		"id": "build_%d_%d" % [Time.get_unix_time_from_system(), randi() % 10000],
		"author": autor,
		"nome": hatsu.nome,
		"categoria": int(hatsu.categoria),
		"conceito": str(hatsu.parametros_conceito.get("titulo_conceito", hatsu.nome)),
		"playstyle_tags": hatsu.get_meta("playstyle_tags", []),
		"composition": hatsu.get_meta("composition", {}),
		"support_modifiers": hatsu.get_meta("support_modifiers", []),
		"custom_damage_ref": hatsu.custom_damage, # referência — cópia NÃO herda poder pago
		"created_at": Time.get_unix_time_from_system(),
		"likes": 0
	}
	_posts.push_front(entry)
	_post_timestamps.append(Time.get_unix_time_from_system())
	while _posts.size() > MAX_GALLERY_SIZE:
		_posts.pop_back()
	gallery_updated.emit()
	return {"ok": true, "entry": entry}


func listar(limite: int = 20) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for i in range(mini(limite, _posts.size())):
		out.append(_posts[i])
	return out


func copiar_conceito(entry_id: String) -> Dictionary:
	## Copia só o conceito/tags/composição — força e votos zerados para re-pagar.
	for e in _posts:
		if str(e.get("id", "")) == entry_id:
			return {
				"ok": true,
				"nome": str(e.get("nome", "Hatsu Copiado")),
				"categoria": int(e.get("categoria", 0)),
				"conceito": e.get("conceito", ""),
				"playstyle_tags": e.get("playstyle_tags", []),
				"composition": e.get("composition", {}),
				"support_modifiers": e.get("support_modifiers", []),
				"suggested_damage": float(e.get("custom_damage_ref", 40.0)),
				"note": "Conceito copiado. Você deve escolher a força e pagar os votos de novo."
			}
	return {"ok": false, "reason": "Build não encontrada"}


func curtir(entry_id: String) -> void:
	for e in _posts:
		if str(e.get("id", "")) == entry_id:
			e["likes"] = int(e.get("likes", 0)) + 1
			gallery_updated.emit()
			return


func _prune_rate_window() -> void:
	var now := Time.get_unix_time_from_system()
	var kept: Array[int] = []
	for ts in _post_timestamps:
		if now - ts <= 3600:
			kept.append(ts)
	_post_timestamps = kept
