# CHARACTER PROGRESSION BIBLE
## HUNTER ONLINE — DEFINITIVE GAMEPLAY DIRECTION & SSOT
### CANONICAL PROGRESSION ARCHITECTURE — LEVEL CAP 1000 & BASE STAT GROWTH

---

## 1. ATRIBUTOS FUNDAMENTAIS

Cada personagem possui uma base tradicional de atributos que evoluem de forma determinística e contínua:

- **Vida Máxima (HP):** Pontos de vida máximos (`vida_max`). Determina a sobrevivência contra impactos físicos e habilidades destrutivas.
- **Força:** Dano base de combate físico, escala de socos e armas empunhadas em `CombatEngine`.
- **Defesa:** Atenuação direta de dano recebido antes da mitigação passiva de aura (`CombatEngine`).
- **Velocidade:** Velocidade de corrida e cadência do ataque básico (reduz o intervalo entre golpes de 0.50s até 0.20s).
- **Aura Máxima:** Reserva máxima de energia vital (`aura_max`). Consumida exclusivamente ao conjurar habilidades ativas de Hatsu e técnicas ativas.

---

## 2. O MODELO MULTIDIMENSIONAL DE PROGRESSÃO

A progressão do caçador opera em quatro dimensões rigorosamente desacopladas:

```text
       ┌────────────────────────────────────────────────────────┐
       │                PROGRESSÃO TOTAL DO HUNTER              │
       └────────────────────────────────────────────────────────┘
                                   │
       ┌───────────────────────────┼───────────────────────────┬───────────────────────────┐
       ▼                           ▼                           ▼                           ▼
1. NÍVEL DO PERSONAGEM      2. SKILL POINTS             3. MAESTRIA DE NEN          4. MAESTRIA DE HATSU
   (Level 1 a 1000)            (Especialização)            (Técnicas 1 a 9)            (Habilidades Ativas)
   • Vida / Vida Máxima        • Nen Skill Tree            • Ten, Ren, Shu, Ko, Ryu    • Nível de Evolução (1-10)
   • Força / Defesa            • Stealth de Zetsu (20-85%) • Zetsu, En, Gyo            • Redução de Custo de Aura
   • Velocidade de Movimento   • Raio de En (120-500px)    • Prática / Treinamento     • Multiplicador de Dano
   • Aura Máxima Base          • Tiers de Gyo (1 a 5)      • Refino Contínuo           • Juramentos & Votos
   • +1 SP Concedido / Nível   • Modificadores Passivos    • Desacoplado do Level      • Desacoplado do Level
```

### Regra Canônica de Ouro:
> **LEVEL = PODER FUNDAMENTAL DO PERSONAGEM**
> **SKILL POINTS = ESPECIALIZAÇÃO DO PERSONAGEM**
> **NEN MASTERY = DESENVOLVIMENTO DE TÉCNICAS DE NEN**
> **HATSU MASTERY = DESENVOLVIMENTO DE HABILIDADES**

Um jogador que atinge o Nível 100 ou 1000 e gasta ZERO Skill Points **deve ser naturalmente e substancialmente mais forte** que um jogador de nível inferior. Subir de nível jamais pode parecer inútil por falta de alocação de pontos.

---

## 3. LEVEL CAP = 1000 & PROGRESSION CONFIG

O teto máximo oficial de longo prazo é:
```text
MAX_LEVEL = 1000
```

Todas as regras, curvas e constantes estão centralizadas no Autoload canônico:
`autoload/ProgressionConfig.gd` (`ProgressionConfig`).

É estritamente proibido espalhar verificações pontuais como `if level >= 100` pelo código.

---

## 4. AS QUATRO FAIXAS DE PROGRESSÃO (BRACKETS)

Para evitar números astronômicos incontroláveis ou física de jogo quebrada, o crescimento segue 4 faixas balanceadas:

1. **Early Progression (Níveis 1 – 80):**
   - Cobre o 287º Exame Hunter (Saga 1).
   - Crescimento rápido e altamente perceptível a cada nível conquistado.
2. **Mid Progression (Níveis 81 – 300):**
   - Cobre Montanha Kukuroo, Arena Celestial, Yorknew City e Greed Island (Sagas 2 a 5).
   - O despertar do Nen torna-se vital; os atributos escalam solidamente nas centenas e milhares.
3. **Late Progression (Níveis 301 – 700):**
   - Cobre Formigas Chimera, Eleição Hunter e Expedição do Continente Negro (Sagas 6 a 8).
   - Domínio de mestria avançada, crescimento controlado por retornos decrescentes suaves.
4. **Endgame Progression (Níveis 701 – 1000):**
   - Cobre a Guerra de Sucessão Kakin e futuras sagas de expansão (Saga 9+).
   - O ápice lendário de poder humano e de Nen no universo Hunter.

---

## 5. FÓRMULAS MATEMÁTICAS DETERMINÍSTICAS DE ATRIBUTOS BASE

Cada atributo base é calculado pela fórmula contínua de Power-Law:

$$\text{Stat}(L) = \text{Base} + (\text{Target}_{1000} - \text{Base}) \times \left(\frac{L - 1}{999}\right)^p$$

Onde $L$ é o nível atual ($1 \le L \le 1000$), e os expoentes $p$ governam a curvatura:

| Atributo | Base (Nv. 1) | Alvo (Nv. 1000) | Expoente $p$ | Comportamento |
| :--- | :---: | :---: | :---: | :--- |
| **Vida Máxima (HP)** | 100 | 50.000 | 0.90 | Robusta, cresce todo nível sem estourar 32-bit int |
| **Força** | 10 | 5.500 | 0.95 | Escala linear-suave de dano físico letal |
| **Defesa** | 10 | 5.000 | 0.95 | Mitigação direta consistente em `CombatEngine` |
| **Velocidade** | 10 | 160 | 0.65 | Sublinear controlada para manter física 2D perfeita |
| **Aura Máxima** | 100 | 75.000 | 0.92 | Suporta custos táticos de Hatsu de alto nível |

### Tabela de Marcos Canônicos (Milestones):

| Nível | HP Base | Força Base | Defesa Base | Velocidade Base | Aura Máxima Base |
| :---: | :---: | :---: | :---: | :---: | :---: |
| **1** | 100 | 10 | 10 | 10 | 100 |
| **10** | 820 | 73 | 67 | 17 | 1.084 |
| **50** | 3.409 | 323 | 295 | 31 | 4.776 |
| **100** | 6.331 | 621 | 565 | 43 | 9.030 |
| **250** | 14.391 | 1.477 | 1.343 | 71 | 20.963 |
| **500** | 26.817 | 2.849 | 2.591 | 106 | 39.649 |
| **750** | 38.606 | 4.186 | 3.806 | 134 | 57.565 |
| **1000** | 50.000 | 5.500 | 5.000 | 160 | 75.000 |

*Nota: Valores de HP, Força, Defesa e Aura têm crescimento inteiro garantido a CADA nível subido.*

---

## 6. CURVA DE EXPERIÊNCIA (XP NORMAL)

O XP necessário para alcançar o próximo nível é calculado por:

$$\text{XP\_Necessário}(L) = \text{XP\_Base} \times L^{\text{XP\_Growth}} = 300 \times L^{1.6}$$

- Nível 1 → 2: 300 XP
- Nível 10 → 11: ~11.900 XP
- Nível 100 → 101: ~475.000 XP
- Nível 999 → 1000: ~18.900.000 XP
- No nível 1000, o sistema trava no teto máximo com indicador visual de `XP: MÁXIMO`.

---

## 7. SKILL TREE = ESPECIALIZAÇÃO EXCLUSIVA (CONSTELAÇÃO DE 400+ NÓS)

Os Skill Points (concedidos à razão de +1 SP por nível, totalizando 999 pontos no Nível 1000) **não concedem poder base bruto obrigatório**, mas sim personalização profunda através da **Constelação do Nen** (consulte `SKILL_TREE_BIBLE.md` para documentação exaustiva):

- **10 Regiões Temáticas:** Body, Warrior, Nen, Hatsu, Speed, Critical, Vitality, Aura, Specialization e Master.
- **Hierarquia de 4 Patamares:** Small Nodes (1 rank), Medium Nodes (1 a 3 ranks), Major Nodes (especializações de 8-18%) e Keystones (mudança de regras de combate com tradeoffs).
- **Atributos Secundários:** Chance/Dano Crítico, Life Steal, Evasão, Bloqueio, Regeneração de Vida/Aura e Redução de Dano.
- **Especializações Canônicas:** Zetsu furtivo (20% a 85%), En sensorial (120px a 500px, debuff -5% a -35%), Gyo perceptual (Tiers 1 a 5) e Modos de Ryu exclusivos.
- **Reset Total com Reembolso:** Respec que devolve 100% dos pontos sem resetar Nível, XP, atributos base ou Hatsu.

---

## 8. ESCALONAMENTO DE SAGAS BASEADO EM DADOS (DATA-DRIVEN)

As sagas não possuem limites arbitrários no código. Suas faixas recomendadas são dados declarativos consultados através de `ProgressionConfig.obter_faixa_saga(id)` e `StoryManager.obter_faixa_nivel_saga(id)`:

```text
Saga 1 (287º Exame Hunter):             Nível 1 – 80
Saga 2 (Montanha Kukuroo):              Nível 70 – 150
Saga 3 (Arena Celestial):               Nível 130 – 250
Saga 4 (Yorknew City & Trupe):          Nível 220 – 380
Saga 5 (Greed Island):                  Nível 350 – 520
Saga 6 (Formigas Chimera):              Nível 500 – 720
Saga 7 (Eleição Hunter & Alluka):       Nível 680 – 800
Saga 8 (Continente Negro Expedição):    Nível 780 – 900
Saga 9 (Guerra de Sucessão Kakin):      Nível 880 – 1000
Saga 10+ (Novas Sagas de Expansão):     Registradas dinamicamente via StoryManager.registrar_saga()
```

---

## 9. FLUXO AUTORITATIVO DE DADOS NA UI / HUD

Para impedir qualquer discrepância de nível exibido na interface:

```text
PlayerData (attributes["nivel"])
      │
      ▼
ProgressionConfig (MAX_LEVEL, fórmulas determinísticas)
      │
      ▼
SaveManager (carregar_jogo valida e recalcula todos os atributos)
      │
      ▼
Player Instance (obter_nivel(), sincronizar_progresso())
      │
      ▼
PlayerHUD (lbl_player_level_badge "★ Nv. X" + LevelLabel em HUD.tscn)
```

O valor exibido na HUD reflete invariavelmente o estado autoritativo persistido e sincronizado do Caçador.

---

## 10. EVOLUÇÃO CANÔNICA DOS 4 HATSU SLOTS (DEPENDÊNCIA EM CADEIA)

Os 4 Hatsu Slots NÃO são concedidos como simples desbloqueios por nível. Eles representam a **evolução na história narrativa e o domínio espiritual da aura**:

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

### Regras de Ouro e Proteção Anti-Bypass:
1. **Dependência em Cadeia Estrita**: O nível do jogador sozinho **NUNCA** desbloqueia um slot.
   - Nível 600 sem Slot 1 = **Slot 2 LOCKED**.
   - Nível 800 sem Slot 2 = **Slot 3 LOCKED**.
   - Nível 1000 sem Slot 3 = **Slot 4 LOCKED**.
2. **Single Source of Truth**: A autoridade central `HatsuProgressionManager` gerencia e revalida todos os desbloqueios em runtime e no carregamento de saves.
3. **Sem Teto Artificial de Level**: Nível 1000 é o requisito do Slot 4, mas níveis 1001, 1100, 1500, 2000+ continuam operando normalmente sem bloqueios.

---

## 11. SISTEMA DE HATSU MASTERY, ARCHIVE E ANTI-FARM

O Hatsu em Hunter Online segue a filosofia de especialização profunda: uma habilidade recém-forjada nasce rudimentar e alcança seu ápice através do uso repetido em combate real.

### Curva de Maestria (0 a 100):
- **Poder Inicial:** $30\%$ do dano/efeito base configurado.
- **Poder Máximo (Mastery 100):** $100\%$ do dano/efeito base ($+70\%$ ganho ao longo da jornada).
- **Eficiência de Aura:** Redução linear até $-20\%$ de custo de Nen.
- **Cadência / Cooldown:** Redução linear até $-20\%$ de tempo de recarga.
- **Alcance / Projétil:** Aumento linear de até $+20\%$ de alcance efetivo.
- **Status Ápice:** Ao atingir 100 de Mastery, recebe o selo visual e de prestígio `★ MASTERED`.

### Curva de XP de Maestria:
$$\text{XP Necessário}(m) = 100 + 40 \times m + 1.2 \times m^{1.8}$$
- Total de XP para atingir Maestria 100: $\approx 23.360\text{ XP}$.

### Proteção Anti-Farm e Bônus por Tipo de Inimigo:
1. **Diferença de Nível ($\Delta L = \text{Player Level} - \text{Target Level}$):**
   - $\Delta L \le 10$: $100\%$ do ganho de XP de Maestria.
   - $10 < \Delta L \le 20$: Penalidade linear ($1.0 \rightarrow 0.5$, isto é, $-5\%$ por nível acima de 10).
   - $20 < \Delta L < 30$: Penalidade severa ($0.5 \rightarrow 0.0$, isto é, $-5\%$ por nível acima de 20).
   - $\Delta L \ge 30$: **$0\%$ XP (Zero absoluto de ganho)**. Caçar mobs fracos não concede domínio de Hatsu.
2. **Multiplicadores de Ameaça:**
   - Mob Comum: $1.0\times$
   - Mob Elite: $1.5\times$
   - Chefe de Masmorra / Mundo: $2.5\times$

### Archive de Hatsu (12 Slots):
- Repositório desacoplado dos 4 slots ativos, permitindo até 12 Hatsus arquivados (`MAX_ARCHIVE_SLOTS = 12`).
- A Maestria e XP acumulados pertencem à instância do Hatsu e são preservados integralmente ao ser desequipado ou guardado.
- Cooldown de Criação de 30 minutos (`1800.0s`) e Custo de 5.000 Jenny para forja de novos Hatsus.
- Cooldown de Troca nos slots ativos de 10 minutos (`600.0s`) para impedir trocas oportunistas pré-chefe.
- Exclusão permitida apenas para Hatsus que não estejam equipados em nenhum slot de combate.

