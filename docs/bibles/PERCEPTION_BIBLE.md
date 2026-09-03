# PERCEPTION DESIGN BIBLE
## HUNTER ONLINE — DEFINITIVE SENSORY & AWARENESS LAYER

---

## 1. O PAPEL DA CAMADA DE PERCEPÇÃO

A percepção no Hunter Online não é um cálculo ad-hoc dentro de cada entidade. Ela é centralizada e padronizada pelo serviço unificado `PerceptionSystem`:

```text
                          PERCEPTIONSYSTEM
                                 │
         ┌───────────────────────┼───────────────────────┐
         │                       │                       │
     VISÃO & AUDIÇÃO       DETECÇÃO DE AURA       PERCEPÇÃO DE SEGREDOS
   (Linha de Visão/LOS)     (Ren, En, Hatsu)          (Gyo Multi-Tier)
         │                       │                       │
         ▼                       ▼                       ▼
     Monstros &             Monstros de             Caçador descobre
   Guardas Normais         Elite / Mestres          Segredos Ocultos
```

---

## 2. DETECÇÃO DE ALVOS & FÓRMULA DE STEALTH REAL (ZETSU)

### Regra Canônica:
Monstros possuem um **Raio de Detecção Base** (`detection_range`). A presença do alvo modifica este raio de acordo com sua técnica ativa de Nen:

$$\text{Raio Efetivo de Detecção} = \text{Raio Base} \times (1.0 - \text{Fator Stealth Zetsu})$$

1. **Sem Zetsu (Normal):** Fator Stealth = 0.0 $\rightarrow$ Raio Efetivo = 100% da base.
2. **Com Zetsu Ativo (Lv 1):** Fator Stealth = 0.20 $\rightarrow$ Raio Efetivo = 80% da base.
3. **Com Zetsu Ativo (Lv 5 - Mestre da Ocultação):** Fator Stealth = 0.80 $\rightarrow$ Raio Efetivo = 20% da base.
4. **Com Ren Ativo (Aura Expandida):** Fator = -0.30 $\rightarrow$ Raio Efetivo = 130% da base (monstros sentem a emanação de longe).
5. **Infâmia Elevada ($\ge 100$):** O caçador é procurado ativamente $\rightarrow$ Raio Efetivo multiplicado por 1.40.

---

## 3. ESTÁGIOS DE CONSCIÊNCIA DE INIMIGOS (AWARENESS STAGES)

A inteligência de inimigos reage progressivamente através da avaliação do `PerceptionSystem`:

```text
[0: IDLE]      Alvo fora do alcance sensorial. Monstro em repouso.
    │
    ▼ (Alvo entra no raio periférico ou gera ruído)
[1: SUSPICIOUS] Interrogação ("❓"). Monstro desacelera e investiga o ponto de origem.
    │
    ▼ (Alvo permanece na linha de visão direta por >0.4s)
[2: ALERT]      Exclamação ("❗"). Monstro assume postura de combate e adquire alvo.
    │
    ▼
[3: CHASE]      Perseguição ativa e cálculo de aproximação tática.
    │
    ▼ (Se o caçador ativar Zetsu e afastar-se além do raio efetivo reduzido)
[4: SEARCH]     "❓ A presença sumiu?!". Busca no último local conhecido por 3.0s.
    │
    ▼ (Se não reencontrar)
[5: RETURN]     Monstro retorna pacificado à sua rota ou ponto de spawn.
```

---

## 4. DETECÇÃO DE AURA ESPACIAL (EN)

Quando o caçador ativa **En**:
1. Projeta uma esfera de aura com raio calibrado pela Skill Tree (120px a 450px).
2. O `PerceptionSystem` registra todos os inimigos interceptados pela esfera.
3. Inimigos interceptados têm sua camuflagem quebrada e sofrem o pulso de **Intimidação**:
   - Redução imediata de Defesa (`en_intimidation_defense_reduction`).
   - Hesitação em ações ofensivas.

---

## 5. PERCEPÇÃO MULTI-TIER DE SEGREDOS (GYO)

Para evitar a falha de "highlight everything", os segredos do mapa possuem níveis mínimos de revelação:

- **Tier 1 (Fácil - Requer Gyo Lv 1):** Pistas básicas de missões, pegadas de monstros e vestígios de aura recente.
- **Tier 2 (Intermediário - Requer Gyo Lv 2):** Baús camuflados em vegetação e inscrições arcanas.
- **Tier 3 (Avançado - Requer Gyo Lv 3):** Passagens secretas falsificadas em paredes sólidas e runas de armadilhas.
- **Tier 4 (Mestre - Requer Gyo Lv 4):** Falsificações em leilões e resíduos de Hatsu de Especialização.
- **Tier 5 (Lendário - Requer Gyo Lv 5):** Selos milenares e portais ocultos da Dark Continent lore.
