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

---

## 7. ATTACK LUNGE & DESLOCAMENTO FÍSICO DE GOLPE

O combate físico não deve parecer fixo no lugar nem patinar no gelo:
- **Avanço Físico (Lunge):** Ao iniciar o golpe, o corpo do Hunter projeta-se à frente na direção do ataque com velocidade inicial de $260\,\text{px/s}$ ao longo de $0.14\,\text{s}$ (deslocamento útil de $\approx 24\,\text{px}$).
- **Curva Cinética:** Desaceleração não-linear ($1.0 - \text{progresso} \times 0.75$), entregando ímpeto no impacto e firmeza de pés na recuperação.
- **Colisão com Paredes:** Desliza organicamente contra cantos e obstáculos sem atravessar ou travar a animação.

---

## 8. ONDA DE PRESSÃO DE AR (AIR PRESSURE WAVE / CORTE DE VENTO)

- **Natureza:** Arco cortante de ar comprimido translúcido com núcleo de brilho nítido e linhas de velocidade.
- **Alinhamento 8-Direcional:** Disparado rigorosamente no vetor de ataque (`dir.angle()`), ajustando escala de $0.85\times$ a $1.30\times$ em $0.16\,\text{s}$.
- **Reação a Técnicas de Nen:**
  - Padrão: Translúcido ciano/branco com brilho puro.
  - Ko Ativo: Ampliação do arco para $36\,\text{px}$ com cor dourada radiante.
  - Ren Ativo: Halo de aura concentrado ciano.
  - Kanmuru (Godspeed): Arco elétrico de alta voltagem.
- **Ciclo de Vida:** Limpeza estrita com `queue_free()` em $0.16\,\text{s}$ (zero vazamento de memória).

---

## 9. TRAÇÃO DOS PÉS & DUST PUFF (IMPACTO COM O SOLO)

- **DashDustPuff:** Partículas de poeira são geradas no solo ($Y=+3\,\text{px}$) opostas ao vetor de deslocamento.
- **Animação:** 4 frames procedurais de dispersão de poeira ao longo de $0.20\,\text{s}$.
- **Baseline Alinhado:** Garante a sensação tátil de atrito com a terra e pedra do cenário.

