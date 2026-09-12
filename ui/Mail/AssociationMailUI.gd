extends Control

# UI leve do Correio da Associação (B9)

@onready var list: ItemList = $Panel/VBox/HBox/InboxList
@onready var subject_lbl: Label = $Panel/VBox/HBox/Detail/Subject
@onready var body_lbl: RichTextLabel = $Panel/VBox/HBox/Detail/Body
@onready var unread_lbl: Label = $Panel/VBox/Header/Unread

var _selected_id: String = ""


func _ready() -> void:
	visible = false
	if AssociationMailSystem != null and not AssociationMailSystem.inbox_changed.is_connected(_refresh):
		AssociationMailSystem.inbox_changed.connect(_refresh)
	$Panel/VBox/Header/CloseBtn.pressed.connect(fechar)
	$Panel/VBox/HBox/InboxList.item_selected.connect(_on_inbox_item_selected)
	$Panel/VBox/HBox/Detail/Actions/ClaimBtn.pressed.connect(_on_claim_pressed)
	$Panel/VBox/HBox/Detail/Actions/DeleteBtn.pressed.connect(_on_delete_pressed)
	_refresh()


func abrir() -> void:
	visible = true
	_refresh()


func fechar() -> void:
	visible = false


func _refresh() -> void:
	if list == null or AssociationMailSystem == null:
		return
	list.clear()
	unread_lbl.text = "Não lidos: %d" % AssociationMailSystem.contar_nao_lidos()
	for m in AssociationMailSystem.listar_inbox():
		var flag := "" if bool(m.get("read", false)) else "• "
		list.add_item("%s%s — %s" % [flag, str(m.get("from", "")), str(m.get("subject", ""))])
		list.set_item_metadata(list.item_count - 1, str(m.get("id", "")))


func _on_inbox_item_selected(index: int) -> void:
	_selected_id = str(list.get_item_metadata(index))
	var mail := AssociationMailSystem.obter_mail(_selected_id)
	subject_lbl.text = str(mail.get("subject", ""))
	body_lbl.text = "[b]%s[/b]\n\n%s" % [str(mail.get("from", "")), str(mail.get("body", ""))]
	AssociationMailSystem.marcar_lido(_selected_id)


func _on_claim_pressed() -> void:
	if _selected_id.is_empty():
		return
	AssociationMailSystem.reivindicar_anexos(_selected_id)
	_refresh()


func _on_delete_pressed() -> void:
	if _selected_id.is_empty():
		return
	AssociationMailSystem.deletar_mail(_selected_id)
	_selected_id = ""
	subject_lbl.text = ""
	body_lbl.text = ""
	_refresh()


func _on_close_pressed() -> void:
	fechar()
