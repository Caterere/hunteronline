# HATSU SYSTEM BIBLE
## HUNTER ONLINE — DEFINITIVE GAMEPLAY DIRECTION

---

## 1. NATUREZA DO HATSU: MAGIAS / SKILLS ATIVAS DE RPG

No Hunter Online, o Hatsu é a expressão máxima do poder sobrenatural do Caçador, operando conceitualmente como as **magias e habilidades ativas de classes em RPGs clássicos**:

```text
Ataque Básico (Cooldown por Velocidade)
      +
Hatsu 1 (Skill Ativa — Tecla 1)
Hatsu 2 (Skill Ativa — Tecla 2)
Hatsu 3 (Skill Ativa — Tecla 3)
Hatsu 4 (Skill Ativa — Tecla 4 / Ultimate)
```

Cada habilidade equipada possui:
- **Custo de Aura:** Quantidade de energia vital consumida no momento do lançamento.
- **Cooldown:** Tempo de recarga necessário antes de nova conjuração.
- **Alcance / Área:** Projétil, golpe corpo-a-corpo, aura de área (AoE) ou buff temporário.
- **Dano & Efeito:** Dano elemental/de choque, atordoamento, empurrão, sangramento, veneno ou criação de objetos/clones.
- **Mastery Própria (0 a 100):** Domínio individual daquela técnica em particular.

---

## 2. PROGRESSÃO CANÔNICA DOS 4 HATSU SLOTS (EVOLUÇÃO ESPIRITUAL)

O Caçador começa sua jornada **sem nenhum Hatsu disponível ou equipado**.
Os 4 Hatsu Slots NÃO são recompensas triviais por nível; eles representam a **evolução na história e o domínio progressivo da aura**:

```text
O PERSONAGEM COMEÇA SEM HATSU
            ↓
   SAGA DE GREED ISLAND (ARCO 5) CONCLUÍDA
            ↓
  Treinamento & Iniciação com Mestra Biscuit Krueger
            ↓
    [HATSU SLOT 1 DESBLOQUEADO]
            ↓
   Nível 600 + Slot 1 Desbloqueado
            ↓
    [HATSU SLOT 2 DESBLOQUEADO]
            ↓
   Nível 800 + Slot 2 Desbloqueado
            ↓
    [HATSU SLOT 3 DESBLOQUEADO]
            ↓
   Nível 1000 + Slot 3 Desbloqueado
            ↓
    [HATSU SLOT 4 DESBLOQUEADO] (Domínio Máximo dos 4 Slots)
```

### Regras de Ouro e Cadeia Obrigatória (Anti-Bypass):
1. **Dependência em Cadeia Estrita**: O nível do jogador sozinho **JAMAIS** desbloqueia um slot.
   - Nível 600 sem Slot 1 = **Slot 2 LOCKED**.
   - Nível 800 sem Slot 2 = **Slot 3 LOCKED**.
   - Nível 1000 sem Slot 3 = **Slot 4 LOCKED**.
2. **Greed Island é o Marco Divisor (Slot 1)**: O jogador não pode criar, forjar, equipar ou usar Hatsu antes de concluir Greed Island e treinar com Biscuit Krueger.
3. **Desacoplamento entre Desbloqueio e Equipamento**:
   - `LOCKED`: Requisitos não cumpridos.
   - `UNLOCKED`: Slot aberto e vazio (`[ Vazio ]`).
   - `EQUIPPED`: Slot com técnica ativa alocada.
4. **Sem Teto Artificial de Level**: Nível 1000 é apenas o requisito do Slot 4. Caçadores de Nível 1001, 1100, 1500, 2000+ continuam evoluindo com todos os 4 slots ativos.
5. **Extensibilidade Modular**: A estrutura data-driven (`HatsuSlotData`) suporta novos slots futuros (Slot 5, 6...) sem quebrar o código.

---

## 3. HATSU ARCHIVE (12 SLOTS) VS. SLOTS ATIVOS (4 SLOTS)

O sistema introduz uma separação clara entre habilidades conhecidas e habilidades ativas em combate:

```text
┌────────────────────────────────────────────────────────┐
│               HATSU ARCHIVE (1 a 12 Slots)             │
│  [1] Jajanken Pedra   [2] Kanmuru       [3] Bungee Gum │
│  [4] Dragon Head      [5] Chain Jail    [6] Black Voice│
│  [7] ...             [8] ...           [9] ...        │
│  [10] ...            [11] ...          [12] [ Vazio ]  │
└────────────────────────────────────────────────────────┘
                           │
       Até 4 Habilidades Equipadas Simultaneamente
                           ▼
┌────────────────────────────────────────────────────────┐
│               SLOTS ATIVOS DE COMBATE (1 a 4)          │
│  Slot 1: Jajanken Pedra (M: 87/100)                     │
│  Slot 2: Kanmuru (★ MASTERED)                          │
│  Slot 3: [ Vazio ]                                     │
│  Slot 4: 🔒 LOCKED (Requer Nível 1000)                 │
└────────────────────────────────────────────────────────┘
```

- **Capacidade do Archive:** Até 12 Hatsu armazenados (`HatsuConfig.MAX_ARCHIVE_SLOTS = 12`).
- **Slots Ativos:** Apenas 4 podem estar preparados nas teclas de atalho de combate.
- **Gerenciamento:** O jogador pode desequipar ou excluir habilidades do Archive (desde que não estejam equipadas em slot ativo) para abrir espaço para novas criações.

---

## 4. CRIAÇÃO DE HATSU, COOLDOWN PERSISTENTE & MONEY SINK

Criar um Hatsu é um ato solene de canalização de aura que molda a identidade do caçador:

1. **Cooldown de Criação (30 Minutos):**
   - Duração: 1800 segundos (`HatsuConfig.HATSU_CREATION_COOLDOWN`).
   - Baseado em timestamp Unix real (`Time.get_unix_time_from_system()`), resistente a reboots do jogo ou manipulações da UI.
2. **Custo em Jenny (Money Sink):**
   - Custo: 5.000 Jenny (`HatsuConfig.HATSU_CREATION_JENNY_COST`), deduzido via transação atômica em `Economy.gd`.
3. **Transação Atômica Segura:**
   - Valida requisitos (`can_create_hatsu()`) -> Deduz Jenny -> Gera UUID -> Registra no Archive com Mastery 0 -> Inicia timer de 30m -> Salva o jogo.

---

## 5. SISTEMA DE MASTERY (0 A 100) & STATUS ★ MASTERED

O Hatsu começa fraco e se desenvolve com o tempo e a prática:

- **Potencial Inicial:** No Nível 0 de Mastery, o Hatsu opera com **30% do seu poder base** (`INITIAL_POWER_RATIO = 0.30`).
- **Potencial Máximo:** No Nível 100 de Mastery, opera com **100% de seu potencial** e recebe a insígnia **★ MASTERED**.

### Bônus Multifacetados por Domínio:
Conforme a Mastery progride de 0 a 100, a técnica aprimora múltiplos vetores:
- **Poder Efetivo:** $+70\%$ (escala de 30% a 100%).
- **Eficiência de Aura:** Até $-20\%$ de consumo energético no Nível 100.
- **Redução de Cooldown:** Até $-20\%$ de tempo de recarga no Nível 100.
- **Alcance / Área:** Até $+20\%$ de projeção de aura no Nível 100.

---

## 6. ANTI-FARM & GANHO DE MASTERY XP EM COMBATE

A Mastery só avança através de **enfrentamentos reais e relevantes**:

```text
Dano Causado em Inimigo
          │
          ▼
Penalidade Anti-Farm:
├── Nível Alvo >= Player - 10 ────► 100% de XP
├── Nível Alvo entre Player - 10 e - 30 ─► Rendimento Decrescente (Linear)
└── Nível Alvo < Player - 30 ─────► 0 XP (Anti-Farm Absoluto)
          │
          ▼
Multiplicador de Alvo:
├── Inimigo Normal: 1.0x
├── Inimigo Elite:  1.5x
└── Chefe / Boss:   2.5x
```

---

## 7. COOLDOWN DE TROCA / ESTABILIZAÇÃO DE AURA (SWITCH COOLDOWN)

Para evitar que o jogador troque instantaneamente de Hatsu no meio de um combate ou imediatamente antes de um chefe específico:
- **Duração:** 10 minutos (`HatsuConfig.HATSU_SWITCH_COOLDOWN = 600.0`).
- Ao equipar uma nova habilidade em um slot ativo, aquele slot entra em estabilização, impedindo novas substituições até o término do timer.

---

## 8. DESIGN VALUES — INITIAL / BALANCEABLE

| Parâmetro de Design | Constante Central | Valor Inicial | Justificativa de Balanceamento |
| :--- | :--- | :---: | :--- |
| **Capacidade do Archive** | `MAX_ARCHIVE_SLOTS` | **12** | Permite 2 builds completas de 4 Hatsu + 4 slots de reserva. |
| **Cooldown de Criação** | `HATSU_CREATION_COOLDOWN` | **1800s** (30 min) | Incentiva apego e reflexão antes de descartar/recriar. |
| **Custo de Criação** | `HATSU_CREATION_JENNY_COST` | **5.000 Jenny** | Money sink proporcional aos ganhos pós-Greed Island. |
| **Potencial Inicial** | `INITIAL_POWER_RATIO` | **0.30** (30%) | Torna o Hatsu recém-nascido um rascunho a ser lapidado. |
| **Mastery Máxima** | `MAX_MASTERY` | **100.0** | Marco visual clássico de maestria (★ MASTERED). |
| **Eficiência de Aura Máx** | `MAX_AURA_EFFICIENCY_BONUS` | **0.20** (-20%) | Redução significativa sem quebrar o sistema de energia. |
| **Redução Cooldown Máx** | `MAX_COOLDOWN_REDUCTION_BONUS` | **0.20** (-20%) | Melhora o ritmo do combate de forma controlada. |
| **Bônus de Alcance Máx** | `MAX_RANGE_BONUS` | **0.20** (+20%) | Facilita acertar inimigos ágeis com técnicas lapidadas. |
| **Cooldown de Troca** | `HATSU_SWITCH_COOLDOWN` | **600s** (10 min) | Preserva a identidade da build durante expedições. |
| **Tolerância Anti-Farm** | `SAFE_LEVEL_DELTA` | **10 Níveis** | Permite jogar com margem tática sem perder XP. |
| **Corte Seco Anti-Farm** | `ZERO_XP_LEVEL_DELTA` | **30 Níveis** | Elimina completamente o farm de mobs iniciais. |

---

## 9. PERSISTÊNCIA & MIGRAÇÃO (SCHEMA V3)

O sistema de save armazena o Hatsu Archive completo com timestamps em formato compatível com JSON:
- Versão: `hatsu_system_version: 3`.
- Salva o array de 12 itens com dados de Mastery, XP e timestamps.
- **Migração Transparente:** Saves antigos (V1 e V2) têm seus arrays `hatsu_criados` migrados automaticamente para o Archive com inicialização segura de Mastery.

---

## 10. FUTURAS EXPANSÕES
A arquitetura modular desacoplada em `HatsuConfig`, `HatsuData` e `HatsuProgressionManager` foi projetada para receber expansões futuras:
- **Hatsu Awakening:** Desbloqueio de segundo efeito ao atingir Nível 100 de Mastery.
- **Hatsu Specializations / Mutations:** Ramificação de efeitos elementais na forja.
- **Hatsu Synergy:** Bônus passivos quando certos pares de Hatsu estão equipados juntos na Action Bar.
