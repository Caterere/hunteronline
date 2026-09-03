# GAME FEEL DESIGN BIBLE
## HUNTER ONLINE — COMBAT JUICE & SENSORY FEEDBACK

---

## 1. O PRINCÍPIO DO IMPACTO

> **"Quando o jogador ataca, ele precisa SENTIR o peso físico e a densidade da aura no acerto."**

Um combate mecanicamente correto mas sem feedback tátil parece flutuante e desinteressante. Cada ação possui uma assinatura audiovisual e cinética imediata.

---

## 2. PILARES DE GAME FEEL

```text
                           COMBAT JUICE
                                │
        ┌───────────────┬───────┴───────┬───────────────┐
        │               │               │               │
     HIT STOP     SCREEN SHAKE     HIT FEEDBACK    ÁUDIO & SFX
 (Micro-Freeze)   (Trauma-Based)  (Flash/Partícula) (Camadas)
```

---

## 3. HIT STOP (MICRO-FREEZE CINÉTICO)

O Hit Stop congela momentaneamente os quadros de animação do atacante e do defensor no momento exato do impacto antes de aplicar o empurrão:

| Tipo de Golpe | Duração do Hit Stop | Propósito |
| :--- | :--- | :--- |
| **Ataque Básico 1 e 2** | 0.04s (2–3 frames) | Ritmo ágil sem truncar fluidez |
| **Finalizador de Combo (3º Golpe)** | 0.08s (5 frames) | Sensação de impacto conclusivo |
| **Golpe com Ko (Burst)** | 0.12s (7 frames) | Sensação de quebra de osso / cratera |
| **Hatsu Especial / Supremo** | 0.15s (9 frames) | Momento dramático de liberação de aura |
| **Golpe Crítico** | 0.09s (6 frames) | Destaque tático de dano amplificado |

---

## 4. SCREEN SHAKE BASEADO EM TRAUMA

Hunter Online utiliza o modelo moderno de **Trauma Não-Linear**:
- `Trauma` varia de 0.0 a 1.0.
- `Shake Offset` = $\text{Trauma}^2 \times \text{MaxOffset}$ (crescimento exponencial, evitando trepidação constante e irritante).
- **Valores Padronizados:**
  - Golpe normal: Trauma 0.15 | Duração 0.12s.
  - Finalizador de Combo: Trauma 0.35 | Duração 0.20s.
  - Hatsu Pesado / Explosão: Trauma 0.60 | Duração 0.35s.
  - Impacto de Chefe: Trauma 0.85 | Duração 0.50s.

---

## 5. NÚMEROS DE DANO & FEEDBACK VISUAL

- **Cores Padronizadas:**
  - Branco: Dano físico normal.
  - Amarelo Ouro: Golpe Crítico.
  - Azul Elétrico: Dano elemental / Nen.
  - Vermelho Sangue: Fraqueza elemental explorada (+50% dano).
  - Cinza Translúcido: Dano mitigado / resistido por Ten (-50% dano).
  - Texto "IMUNE": Nulo por anulação de dano.
- **Movimento dos Números:** Efeito de arco pop-up com gravidade suave, nunca cobrindo o centro do personagem.

---

## 6. REAÇÕES DE INIMIGOS (STAGGER & KNOCKBACK)

- **Flinch (Contração):** O sprite do monstro pisca em branco por 0.08s e recua 4px.
- **Knockback Direcional:** O finalizador do combo arremessa o inimigo 24px na direção oposta ao golpe.
- **Knockdown (Queda):** Golpes com Ko derrubam monstros normais, exigindo 0.8s para recuperação de postura.
- **Morte:** Dissipação com partículas de aura que se extinguem no ar, deixando o loot no chão de forma clara.
