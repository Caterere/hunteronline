# CONTENT PRODUCTION PIPELINE
## HUNTER ONLINE — PIPELINE DE PRODUÇÃO DE CONTEÚDO EM ESCALA

---

## 1. O CICLO DE CONTEÚDO DE 7 PASSOS

Para escalar o jogo através das 9 Sagas (~200 Missões, centenas de NPCs, monstros e itens) sem quebrar a arquitetura existente:

```text
1. DESIGN ──> 2. DATA ──> 3. IMPLEMENT ──> 4. VALIDATE ──> 5. AUTO-TEST ──> 6. PLAYTEST ──> 7. APPROVAL
```

1. **DESIGN:**
   - Elaborar a ficha de design (documento conceitual, alinhamento com o mangá, requisitos e recompensas).
2. **DATA:**
   - Criar os recursos correspondentes (`MissionData`, `EnemyData`, `NPCData`, `HatsuData`) em `res://resource/`. Nunca hardcodar valores dentro de scripts.
3. **IMPLEMENTATION:**
   - Montar a cena visual ou prefab estendendo as classes base oficiais (`LivingNPCBehavior`, `EnemyAI`, `GyoInspectable`).
4. **VALIDATION:**
   - Checar conformidade com as Bibles de design correspondentes.
5. **AUTOMATED TEST:**
   - Criar ou estender teste automatizado na pasta `scratch/` validando spawn, objetivos, checkpoints e save/load.
6. **PLAYTEST:**
   - Executar a missão em ambiente interativo com telemetria ativa (`PlaytestTelemetry`), validando fluidez e clareza.
7. **APPROVAL:**
   - Registro no `DEVELOPMENT_LOG.md` e promoção para o branch principal de produção.
