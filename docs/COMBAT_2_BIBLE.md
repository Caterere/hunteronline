# ============================================================
# HUNTER ONLINE — COMBAT 2.0 BIBLE (FASE F)
# ============================================================
# Motor de Combate Tático, Ataques Pesados, Postura e IA Inimiga
# Godot 4.4 / GDScript Estritamente Tipado
# ============================================================

## 1. Visão Geral e Filosofia de Combate
O combate em *Hunter x Hunter* é brutal, cerebral e técnico. Uma única brecha na defesa ou um erro de cálculo de distância pode resultar em derrota instantânea.

O **Combat 2.0** preserva a total passividade da Nen Skill Tree (sem botões manuais de toggle de Ten/Ren/Ken), ao mesmo tempo em que enriquece os inputs ativos do jogador com ataques normais fluidos, ataques pesados de quebra de postura, esquivas precisas com i-frames e inimigos inteligentes que utilizam habilidades canônicas de Hatsu.

---

## 2. Taxonomia de Status de Implementação
- **IMPLEMENTED**: Totalmente funcional, integrado à engine e testado na suíte.
- **PARTIAL**: Mecânica ativa que receberá expansões de física ou animação.
- **PLANNED**: Arquitetado para chefes de raid ou eventos posteriores.
- **DEFERRED**: Ideias rejeitadas por quebrar a identidade de ação em tempo real.
- **LEGACY**: Fórmulas antigas de dano simplista descartadas.

---

## 3. Matriz de Mecânicas de Combate 2.0

| Mecânica | Status | Implementação | Descrição |
|---|---|---|---|
| **Ataques Normais Fluidos** | `IMPLEMENTED` | `HunterCombatSystem.gd` | Cadeia de golpes leves responsivos com hitbox dinâmica. |
| **Ataque Pesado (Heavy Attack)** | `IMPLEMENTED` | `tentar_ataque_pesado()` | Multiplicador 2.4x de dano, 360px de knockback, 45 de dano de postura. |
| **Input de Ataque Pesado** | `IMPLEMENTED` | `Player.gd` | Disparado via Botão Direito do Mouse ou segurando Ataque por >0.35s. |
| **Game Feel: Hitstop e Shake** | `IMPLEMENTED` | `aplicar_hitstop(0.12s)` / Shake 0.65 | Sensação de peso e impacto físico visceral em cada golpe pesado. |
| **Esquiva Tática com I-Frames** | `IMPLEMENTED` | `esquivar()` | Dash rápido consumindo stamina/aura com 0.2s de invulnerabilidade. |
| **Dano de Postura e Quebra (Stagger)** | `IMPLEMENTED` | `aplicar_dano_postura()` | Dano à postura do alvo; postura zerada resulta em atordoamento crítico. |
| **Inimigos com Hatsu Modular** | `IMPLEMENTED` | `_executar_hatsu_modular()` | Inimigos executam recursos reais de `HatsuData` unificados com a engine do jogador. |
| **6 Arquétipos de IA Inimiga** | `IMPLEMENTED` | `EnemyAI.gd` | Comportamentos distintos: `brute`, `assassin`, `ranged`, `tactician`, `nen_user`, `boss`. |
| **Combos Aéreos e Wall Bounce** | `PARTIAL` | `CombatEngine.gd` | Lançamento vertical implementado; quique em paredes em polimento de física. |
| **Formações Táticas de Emboscada (Zetsu)** | `PLANNED` | `EnemyFlockingManager` | Inimigos que coordenam cerco flanqueando com Zetsu silencioso. |
| **Combate em Turnos** | `DEFERRED` | N/A | Totalmente descartado; o jogo é estritamente combate de ação em tempo real. |
| **Dano Direto sem Mitigação** | `LEGACY` | Antigo `subtrair_vida()` | Substituído pelo pipeline do `CombatEngine` com defesa, armadura e postura. |

---

## 4. Pipeline Unificado de Hatsu
Tanto o jogador quanto os inimigos compartilham exatamente a mesma autoridade de dados:
```
[Entidade] ---> Carrega HatsuData (Resource)
                   ├── custo_aura
                   ├── cooldown
                   ├── tipo_dano (FISICO / NEN / ELEMENTAL)
                   ├── status_efeito (STUN, POISON, BURN, etc.)
                   └── multiplicador_dano
                     │
                     ▼
             [CombatEngine]
                   ├── Valida requisitos e custos
                   ├── Calcula reduções de Defesa e Postura
                   ├── Aplica mitigação passiva da Skill Tree
                   └── Despacha eventos visuais e sonoros
```

---

## 5. Arquétipos de Inteligência Artificial (`EnemyAI`)

1. **`brute`**: Avança incansavelmente em linha reta, desfere ataques pesados com alta resistência a knockback.
2. **`assassin`**: Circunda o jogador, utiliza passos silenciosos e ataca pelas costas (backstab) em momentos de recuperação.
3. **`ranged`**: Mantém distância tática de 220px a 340px, disparando projéteis e recuando se o jogador se aproximar.
4. **`tactician`**: Analisa padrões, finta ataques e antecipa golpes com esquivas e contra-ataques precisos.
5. **`nen_user`**: Alterna entre ataque físico e conjuração de técnicas de Nen/Hatsu em intervalos estratégicos.
6. **`boss`**: Imunidade parcial a controle de grupo, rotação complexa de fases, rajadas de área (AoE) e telemetria de pressão.
