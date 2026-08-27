# INTEGRAÇÃO DE QUESTS - GUIA DE TESTE

## Alterações Realizadas

### 1. **ItemResource** (Novo)
- Arquivo: `resource/ItemResource.gd`
- Define estrutura de items reutilizável
- Propriedades: item_id, item_name, description, max_stack, rarity

### 2. **EnemyData** (Modificado)
- Adicionado campo `enemy_id: StringName`
- Identifica tipo de inimigo para quests KILL
- Exemplo: "slime", "skeleton", etc

### 3. **EnemySystem** (Modificado)
- Sinal `died()` agora passa `enemy_id`
- Conecta-se automaticamente a `QuestSystem.register_enemy_kill()`
- Fluxo: Inimigo morre → emite enemy_id → QuestSystem processa

### 4. **QuestManager** (Modificado)
- Novo método: `register_enemy_kill(enemy_type: StringName)`
  - Verifica objetivos KILL ativos
  - Incrementa progresso se tipo combina
  - Checa conclusão da quest

- Novo método: `register_item_collected(item_id: StringName, amount: int)`
  - Verifica objetivos COLLECT ativos
  - Incrementa progresso
  - Checa conclusão

### 5. **PlayerData** (Modificado)
- Adicionado dicionário `inventory: Dictionary`
- Novo método: `adicionar_item(item_id, quantidade)`
- Novo método: `remover_item(item_id, quantidade) -> bool`
- Novo método: `obter_item_quantidade(item_id) -> int`
- Novo método: `tem_item(item_id, quantidade) -> bool`

### 6. **QuestManager.tscn** (Novo)
- Cena para autoload do QuestSystem
- Node: QuestSystem (com script QuestManager.gd)

### 7. **Quests de Teste** (Novo)
- `derrota_3_slimes.tres`: Quest para derrotar 3 slimes
  - Objetivo: KILL "slime" x3
  - Recompensa: 500 XP
  - Auto-completa ao atingir objetivo

---

## Como Testar

### Teste 1: Objetivo VISIT (já existente)
1. Entrar no jogo
2. Falar com Wing
3. Quest "Conheça Wing" inicia
4. Objetivo completado automaticamente
5. Recebe 10000 XP

### Teste 2: Objetivo KILL (novo)
1. **Preparação**: Adicionar quest "Derrota 3 Slimes" à cena do jogo
2. Iniciar quest (via comando ou NPC)
3. Derrotar 3 inimigos do tipo "slime"
4. Ao derrotar o 3º, quest completa automaticamente
5. Recebe 500 XP

**Para iniciar via código (em um NPC ou teste):**
```gdscript
QuestSystem.start_quest(load("res://data/quests/derrota_3_slimes.tres"))
```

### Teste 3: Objetivo COLLECT (pronto, mas sem items ainda)
1. Item pode ser coletado via:
```gdscript
PlayerData.adicionar_item(&"moca_slime", 1)
QuestSystem.register_item_collected(&"moca_slime", 1)
```
2. Quest progressão é rastreada automaticamente

---

## Verificação de Funcionalidade

- ✅ EnemySystem emite enemy_id ao morrer
- ✅ QuestManager conecta-se ao sinal
- ✅ register_enemy_kill verifica objetivos KILL
- ✅ Progresso é atualizado em PlayerData
- ✅ Quest completa automaticamente se auto_complete = true
- ✅ Recompensa XP é entregue
- ✅ Inventário pronto para COLLECT
- ✅ PlayerData armazena estado de quest

---

## Próximos Passos (Opcional)

1. Criar sistema de drop de itens ao derrotar inimigos
2. Implementar interface de objetivo visível no HUD
3. Adicionar notificação de quest completada
4. Criar missões com múltiplos tipos de objetivos combinados
5. Implementar sistema de recompensas de items em quests
