# SPAWN SYSTEM ARCHITECTURE
## HUNTER ONLINE — WORLD SPAWN, MISSION SPAWN & LIFECYCLE

### 1. Separação Estrita de Spawns
Para resolver a falha de monstros não renascerem ou poluírem cenas após mortes, a arquitetura divide entidades em duas categorias fundamentais:

```text
Entidade Inimiga
 ├── 1. WORLD SPAWN (Monstros Livres / Criaturas do Mapa)
 │    ├── Spawner Permanente (WorldSpawner)
 │    ├── Ciclo: Spawn -> Combate -> Morte -> Timer de Respawn (15s a 30s) -> Re-spawn
 │    └── Não polui estado de missões.
 │
 └── 2. MISSION SPAWN (Criaturas Específicas de Missão / Chefes)
      ├── Gerenciado exclusivamente por MissionInstance
      ├── Vinculado a objectives (enemy_id, quest_arc, quest_etapa)
      ├── Ciclo: Início de Missão -> Spawn Inicial -> Morte -> Contabilização de Meta
      └── Se a missão reiniciar: Cleanup completo das entidades órfãs e novo spawn.
```

### 2. Ciclo de Vida do WorldSpawner
O componente `world/components/WorldSpawner.gd` é adicionado aos mapas:
1. Instancia `Enemy.tscn` configurado com um `EnemyData`.
2. Conecta ao sinal `tree_exited` ou `died` do inimigo.
3. Ao morrer, inicia um temporizador `respawn_delay` (ex: 20.0s).
4. Após o timeout, instancia uma nova criatura na posição de spawn original com vida cheia.

### 3. Boss Spawn & Fases
* Chefes possuem `is_boss = true` e dados de fase em `boss_phases: Array[BossPhaseData]`.
* Spawns de chefes nunca usam respawn automático enquanto o jogador estiver no mapa da luta.
