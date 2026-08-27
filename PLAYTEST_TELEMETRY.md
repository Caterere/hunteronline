# HUNTER ONLINE — MANUAL DE PLAYTEST TELEMETRY & DEBUG OVERLAY

## 1. Visão Geral

O **Playtest Debug Overlay & Telemetry Engine** é uma suíte profissional de diagnóstico e medição em tempo real desenvolvida para *Hunter Online*.

Seu objetivo é permitir que desenvolvedores e playtesters avaliem o ritmo de jogo, a densidade do mundo semiaberto, a eficácia do combate e da IA, as interações de Nen e o comportamento de eventos dinâmicos **jogando normalmente**, sem alterar a lógica de gameplay, Hatsu ou SaveManager.

> [!IMPORTANT]
> **Zero Overhead em Produção**: O sistema é **DEBUG ONLY**. Quando `PlaytestTelemetry.debug_enabled = false` ou em builds finais, todos os processos visuais e coletas de dados tornam-se completamente inertes.

---

## 2. Atalhos de Teclado Globais

| Tecla | Ação | Descrição |
|---|---|---|
| **`F3`** | **Toggle Overlay** | Abre ou fecha o painel principal de telemetria na tela. |
| **`F4`** | **Toggle Heatmap** | Liga ou desliga o mapa de calor de densidade do mundo (16x16 setores). |
| **`F5`** | **Abrir Inspector** | Abre diretamente a aba do *Content Director Inspector* para avaliar coordenadas. |
| **`F6`** | **Toggle Sessão** | Inicia ou encerra a gravação da sessão atual de playtest. |

---

## 3. Estrutura das Abas e Métricas Exibidas

### Aba 1: Overview (Visão Geral & Performance)
* **Player Data**: Posição global `(X, Y)`, coordenadas de tile `(X/16, Y/16)`, mapa atual, nível normal e de Nen, HP atual e máximo (com %), Aura atual e máxima (com %), técnicas de Nen ativas, estado de combate (`NORMAL`, `ATACANDO`, `ESQUIVANDO`, `MORTO`), velocidade física (`px/s`), status de sprint (Shift) e quest ativa.
* **World Data**: Horário global (`HH:MM`), dia atual, fase solar (`DAWN`, `DAY`, `DUSK`, `NIGHT`), nome da zona de risco (`SAFE`, `LOW_RISK`, `MEDIUM_RISK`, `HIGH_RISK`, `DANGER`), coordenadas do Chunk atual e contagem de entidades no raio de 600px.
* **Performance**: FPS, tempo por quadro (`Frame Time` em ms), contagem total de nós na árvore (`Node Count`), objetos físicos 2D ativos e uso de memória estática em MB.

### Aba 2: Combat & NPC Intelligence
* **Live Combat**:
  * Nome do alvo mais próximo e distância (`px`).
  * Arquétipo do inimigo (`fast`, `tank`, `bruiser`, `ambusher`, `boss`).
  * Estado atual da máquina de estados da IA (`IDLE`, `CHASE`, `PREPARE_ATTACK`, `ATTACK`, `RECOVERY`, `RETURN`, `STAGGER`).
  * Timers de **Windup** (preparação de golpe) e **Cooldown de Ataque**.
  * Barra e valor numérico de **Postura / Stagger** (com aviso visual quando vulnerável).
  * Dano do último golpe desferido e do último dano recebido.
* **NPC Intelligence (< 300px)**:
  * Nome do NPC, facção e distância.
  * Nível de relacionamento e disposição moral (`Favorável`, `Neutro`, `Respeitado`, etc.).
  * Atividade e rotina de horário em execução (`walking`, `resting`, `patrol`).
  * **Contexto de IA ("Why NPC is doing this")**: Explicação em texto de por que o NPC está naquele local ou reagindo às ações do jogador (ex: reagindo à Licença Hunter, ferimentos ou técnicas de Nen).

### Aba 3: Nen & Discovery
* **Nen System**:
  * Técnica ativa (`TEN`, `REN`, `GYO`, `KO`, `ZETSU`, `EN`, `SHU`, `KEN`, `RYU`).
  * Taxa de consumo/regeneração de aura por segundo.
  * Efeitos ativos (ex: `%` de redução de dano, `%` de expansão de alcance, bônus de dano).
  * **Interações de Mundo Detectadas**:
    * Pistas de `GyoInspectable` reveladas no alcance.
    * Paredes destrutíveis com `KoObstacle`.
    * Sensores furtivos ignorados com `ZetsuSensorZone`.
    * Zonas de perigo mitigadas por `TenHazardZone`.
* **Discovery & POIs**:
  * Ponto de interesse mais próximo, distância e estado de descoberta.
  * Tier de segredo: `VISIBLE`, `HIDDEN`, `SECRET`, `VERY_SECRET`.
  * Requisito de condição para revelação/acesso.

### Aba 4: Content Director & Densidade
* **Métricas Espaciais**:
  * Entidades ativas: NPCs, Inimigos PvE, Eventos Dinâmicos, Encontros Ambientais e POIs.
  * Distância total percorrida e distância desde o último evento gerado.
  * Estimativa de pixels/passos até o próximo evento dinâmico.
  * Timers de cooldown de eventos e encontros.
* **Breakdown Regional (%)**:
  * `COMBAT %`: Participação de perigo/combate na região.
  * `NPC %`: Participação de vida urbana/população.
  * `EVENT %`: Frequência relativa de eventos dinâmicos.
  * `DISCOVERY %`: Presença de pontos notáveis e exploração.

### Aba 5: Content Director Inspector (Análise de Eventos Rejeitados)
Permite selecionar qualquer coordenada do mapa (ou usar a posição do jogador) para avaliar a geração de eventos.
* **Diagnóstico de Rejeição**: Para cada modelo de evento, exibe claramente o motivo de ter sido aceito ou recusado:
  * Exemplo: `✖ REJEITADO: Fera Quimera Noturna - Motivo: Condição de horário: Requer NOITE (Fase atual: DAY)`
  * Exemplo: `✖ REJEITADO: Duelo Tático - Motivo: Nível de Nen insuficiente (Requer Nen Lv 2, jogador tem Lv 0)`
  * Exemplo: `✖ REJEITADO: Emboscada de Salteadores - Motivo: Zona incompatível (Requer LOW_RISK, atual: SAFE)`

### Aba 6: History (Histórico de Ocorrências)
Buffer circular das últimas 20 ocorrências com timestamps do jogo (`HH:MM`):
* Inimigos avistados e derrotados.
* Golpes e danos críticos.
* Quests aceitas, atualizadas e concluídas.
* Eventos mundiais e encontros contextuais disparados.
* Técnicas de Nen ativadas.
* Descobertas e segredos encontrados.

### Aba 7: Session & Exportação JSON
* **Controle de Sessão**: Botões para Iniciar (`🔴 INICIAR NOVA SESSÃO`) e Finalizar (`⏹️ FINALIZAR SESSÃO`).
* **Métricas Acumuladas**: Duração em segundos, distância percorrida (px e tiles), abates, dano total, maior golpe único, ouro ganho/gasto, mortes e técnicas utilizadas.
* **Exportação**: Grava a sessão em `res://debug/playtest/playtest_session_TIMESTAMP.json` (com fallback automático para `user://debug/playtest/`).

### Aba 8: World Density Heatmap (Mapa de Calor)
* Divide o mapa 512x512 tiles em uma grade de 16x16 setores (cada setor = 32x32 tiles / 512x512 pixels).
* Permite alternar camadas de visualização:
  1. `🔥 Geral & Zonas Mortas`: Destaca áreas sem nenhum conteúdo (`💀 VAZIO`).
  2. `🔵 Densidade de NPCs`: Concentração de população urbana.
  3. `🔴 Densidade PvE`: Zonas de monstros e perigo.
  4. `🟡 Densidade de Eventos`: Hotspots de eventos dinâmicos.
  5. `🟢 Densidade de Descobertas`: Distribuição de baús, glifos Gyo e segredos.

---

## 4. Guia Rápido de Balanceamento e Diagnóstico

Ao rodar o jogo, utilize as seguintes perguntas-guia:

1. **"Por que esta área parece vazia?"**
   * Pressione `F4` para abrir o Heatmap no modo *Geral*. Se o setor estiver marcado como `💀 VAZIO`, verifique no Content Director o perfil de risco da zona.
2. **"Por que nenhum evento dinâmico está surgindo?"**
   * Abra o Inspector (`F5`) e clique em *Usar Posição do Player*. O sistema listará todos os eventos rejeitados e a causa exata (ex: cooldown ativo, distância anti-spam insuficiente ou requisito de Nen/horário não atingido).
3. **"Qual técnica de Nen é mais utilizada?"**
   * Abra a aba *Session & Export* após 10 minutos de jogo para verificar o tempo de uso de cada técnica (`TEN`, `REN`, `GYO`, `KO`, `ZETSU`).
4. **"Como estão os tempos de combate?"**
   * Na aba *Combat & NPC*, observe o tempo que os inimigos passam em `PREPARE_ATTACK` (Windup) e se o valor de Postura (Stagger) está sendo quebrado em tempo satisfatório.

---

## 5. Estrutura do Arquivo JSON Exportado

```json
{
  "session_id": "playtest_20260827T131624",
  "start_time_iso": "2026-08-27T13:16:24",
  "end_time_iso": "2026-08-27T13:26:24",
  "duration_seconds": 600.0,
  "distance_traveled_px": 8450.0,
  "distance_traveled_tiles": 528,
  "enemies_killed": 12,
  "enemy_kills_by_type": {
    "slime": 8,
    "criatura_pantanal": 4
  },
  "damage_dealt": 1840,
  "damage_received": 320,
  "max_single_hit": 185,
  "quests_completed": 2,
  "completed_quests_list": [
    "O Despertar da Aura & O Guardião de Zaban"
  ],
  "npcs_interacted": 5,
  "interacted_npcs_list": [
    "Mestre Wing",
    "Ferreiro Duran"
  ],
  "events_encountered": 3,
  "encountered_events_list": [
    "Feira Especial de Mercadores de Yorknew"
  ],
  "discoveries_found": 4,
  "found_discoveries_list": [
    "poi_vila_praca",
    "poi_ponte_rio"
  ],
  "nen_techniques_used": {
    "TEN_time_sec": 145.2,
    "REN_time_sec": 42.0,
    "GYO_time_sec": 88.5
  },
  "deaths": 0,
  "gold_gained": 3200,
  "gold_spent": 500
}
```
