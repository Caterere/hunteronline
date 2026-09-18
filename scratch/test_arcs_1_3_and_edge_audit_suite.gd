extends Node
var _passed:=0; var _total:=0; var _failures:PackedStringArray=[]
func _ready()->void:
	print("\n🧪 ARCS 1–3 + EDGE CASES AUDIT")
	await get_tree().process_frame
	await _audit(1, "res://world/maps/exame_maratona.tscn", 24)
	await _audit(2, "res://world/maps/montanha_kukuroo.tscn", 16)
	await _audit(3, "res://world/maps/arena_celestial.tscn", 26)
	await _edge_cases()
	print("🏆 RESULTADO: %d / %d" % [_passed,_total])
	for f in _failures: print("   ❌ ", f)
	get_tree().quit(0 if _passed==_total else 1)
func _ok(c:bool,l:String)->void:
	_total+=1
	if c: _passed+=1; print("  ✅ ",l)
	else: _failures.append(l); print("  ❌ ",l)
func _audit(arco:int, path:String, maxe:int)->void:
	print("\n========== ARCO %d ==========" % arco)
	PlayerData.despertou_nen=true; PlayerData.arco_atual=arco
	CanonQuestCatalog._quest_cache.clear()
	var packed=load(path) as PackedScene
	_ok(packed!=null, "cena carrega")
	if packed==null: return
	var mapa=packed.instantiate(); add_child(mapa)
	await get_tree().process_frame; await get_tree().process_frame
	var missing_v:PackedStringArray=[]; var missing_c:PackedStringArray=[]; var missing_z:PackedStringArray=[]
	var seen_v:={}; var seen_c:={}; var seen_z:={}
	for e in range(1,maxe+1):
		var q=CanonQuestCatalog.obter_quest_da_etapa(arco,e)
		if q==null: continue
		for obj in q.objectives:
			if obj==null: continue
			if obj.type==QuestObjective.Type.VISIT or obj.type==QuestObjective.Type.PERSUASION:
				var k=str(obj.target_npc_id)
				if seen_v.has(k): continue
				seen_v[k]=true
				if not _has_npc(mapa,obj): missing_v.append("%s@e%d"%[k,e])
			elif obj.type==QuestObjective.Type.INVESTIGATE:
				var k=str(obj.target_clue_id)
				if seen_c.has(k): continue
				seen_c[k]=true
				if _find_prop(mapa,"clue_id",obj.target_clue_id)=="": missing_c.append("%s@e%d"%[k,e])
			elif obj.type==QuestObjective.Type.STEALTH_PASS:
				var k=str(obj.target_zone_id)
				if seen_z.has(k): continue
				seen_z[k]=true
				if _find_prop(mapa,"zone_id",obj.target_zone_id)=="": missing_z.append("%s@e%d"%[k,e])
	_ok(missing_v.is_empty(), "arco%d visits/persu ok (missing=%s)"%[arco, ",".join(missing_v) if not missing_v.is_empty() else "-"])
	_ok(missing_c.is_empty(), "arco%d clues ok (missing=%s)"%[arco, ",".join(missing_c) if not missing_c.is_empty() else "-"])
	_ok(missing_z.is_empty(), "arco%d stealth ok (missing=%s)"%[arco, ",".join(missing_z) if not missing_z.is_empty() else "-"])
	mapa.queue_free(); await get_tree().process_frame
	PlayerData.despertou_nen=false; PlayerData.arco_atual=1
func _edge_cases()->void:
	print("\n========== EDGE LIVE ==========")
	PlayerData.despertou_nen=true
	# CN arvore_mundo + ging_topo persuasion
	PlayerData.arco_atual=8
	var cn=(load("res://world/maps/continente_negro.tscn") as PackedScene).instantiate()
	add_child(cn); await get_tree().process_frame; await get_tree().process_frame
	QuestSystem.active_quests.clear()
	var q=CanonQuestCatalog.obter_quest_da_etapa(8,15)
	QuestSystem.start_quest(q)
	var arv=cn.get_node_or_null("ArvoreMundo")
	var aname=str(arv.npc_name) if arv and "npc_name" in arv else ""
	var b=PlayerData.get_quest_objective_progress(q,0)
	QuestSystem.register_npc_visit(StringName(aname))
	_ok(PlayerData.get_quest_objective_progress(q,0)>b, "CN e15 arvore visit name='%s'"%aname)
	QuestSystem.active_quests.clear()
	var q19=CanonQuestCatalog.obter_quest_da_etapa(8,19)
	# find persuasion etapa for ging_topo
	for e in range(1,23):
		var qq=CanonQuestCatalog.obter_quest_da_etapa(8,e)
		if qq and not qq.objectives.is_empty() and qq.objectives[0].type==QuestObjective.Type.PERSUASION and str(qq.objectives[0].target_npc_id)=="ging_topo":
			q19=qq; break
	QuestSystem.start_quest(q19)
	var b19=PlayerData.get_quest_objective_progress(q19,0)
	QuestSystem.register_persuasion(StringName("Ging Freecss no Topo"))
	_ok(PlayerData.get_quest_objective_progress(q19,0)>b19, "CN ging_topo persuasion")
	cn.queue_free(); await get_tree().process_frame
	# NGL meruem visit
	PlayerData.arco_atual=6
	var ngl=(load("res://world/maps/ngl_formigas.tscn") as PackedScene).instantiate()
	add_child(ngl); await get_tree().process_frame; await get_tree().process_frame
	QuestSystem.active_quests.clear()
	var qm=CanonQuestCatalog.obter_quest_da_etapa(6,23)
	QuestSystem.start_quest(qm)
	var mer=ngl.get_node_or_null("MeruemReiNPC")
	var mname=str(mer.npc_name) if mer and "npc_name" in mer else ""
	var bm=PlayerData.get_quest_objective_progress(qm,0)
	QuestSystem.register_npc_visit(StringName(mname))
	_ok(PlayerData.get_quest_objective_progress(qm,0)>bm, "NGL e23 meruem visit name='%s'"%mname)
	# GI elena_greed
	ngl.queue_free(); await get_tree().process_frame
	PlayerData.arco_atual=5
	var gi=(load("res://world/maps/greed_island.tscn") as PackedScene).instantiate()
	add_child(gi); await get_tree().process_frame; await get_tree().process_frame
	QuestSystem.active_quests.clear()
	var qe=CanonQuestCatalog.obter_quest_da_etapa(5,34)
	QuestSystem.start_quest(qe)
	var el=gi.get_node_or_null("ElenaGreed")
	var ename=str(el.npc_name) if el and "npc_name" in el else ""
	var be=PlayerData.get_quest_objective_progress(qe,0)
	QuestSystem.register_npc_visit(StringName(ename))
	_ok(PlayerData.get_quest_objective_progress(qe,0)>be, "GI e34 elena visit name='%s'"%ename)
	gi.queue_free()
	PlayerData.despertou_nen=false; PlayerData.arco_atual=1
func _has_npc(mapa:Node, obj:QuestObjective)->bool:
	var nodes:Array=[]; _collect(mapa,nodes)
	for n in nodes:
		var display=str(n.name)
		if "npc_name" in n: display=str(n.npc_name)
		if MissionObjectiveResolver.npc_matches_objective(display.to_lower(), display.to_lower(), obj): return true
		if MissionObjectiveResolver.npc_matches_objective(str(n.name).to_lower(), display.to_lower(), obj): return true
	return false
func _collect(n:Node,out:Array)->void:
	if "npc_name" in n or n.is_in_group("npc") or n.is_in_group("npcs"): out.append(n)
	for c in n.get_children(): _collect(c,out)
func _find_prop(n:Node,prop:String,want:StringName)->String:
	if prop in n and str(n.get(prop))==str(want): return str(n.name)
	for c in n.get_children():
		var r=_find_prop(c,prop,want)
		if r!="": return r
	return ""
