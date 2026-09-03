# ENEMY AI DESIGN BIBLE
## HUNTER ONLINE — TACTICAL COMBAT & BEHAVIOR SYSTEM

---

## 1. PRINCÍPIOS DE COMPORTAMENTO DE INIMIGOS

Os inimigos em Hunter Online não são alvos estáticos nem esponjas de dano sem cérebro. Eles reagem a postura, distância, técnicas ativas de Nen e nível de ameaça:

```text
                  ENEMY AI ARCHITECTURE
                            │
      ┌─────────────────────┼─────────────────────┐
      │                     │                     │
MAQUINA DE ESTADOS    TABELA DE AMEACA       INTEGRAÇÃO NEN
 (FSM Parametrizada)   (Aggro Dinâmico)    (Perception & En/Zetsu)
```

---

## 2. A MÁQUINA DE ESTADOS CANÔNICA (FSM)

A IA opera sobre uma FSM clara com transições limpas:

```text
[IDLE] ──(Alvo detectado)──> [ALERT] ──(Em alcance)──> [CHASE]
  ▲                                                       │
  │                                                (Distância <= Attack)
  │                                                       ▼
[RETURN] <──(Perdeu rastro)── [SEARCH] <──(Recuperação)── [PREPARE / ATTACK]
```

### Detalhamento dos Estados:
1. **IDLE:** Vigilância passiva no ponto de origem ou início de patrulha.
2. **PATROL:** Deslocamento cíclico entre waypoints predefinidos.
3. **SUSPICIOUS:** Parada momentânea voltada para ruídos ou presença tênue.
4. **ALERT:** Telegrafia visual ("❗") indicando que o alvo foi identificado.
5. **CHASE:** Aproximação dinâmica contornando obstáculos até a distância de golpe (`attack_range`).
6. **PREPARE_ATTACK (Windup):** Telegrafia visual do golpe (círculo vermelho / flash amarelo) durante 0.3s a 0.6s. Permite esquiva perfeita (Perfect Dodge) do jogador.
7. **ATTACK:** Disparo do golpe ou Hatsu canônico.
8. **RECOVERY:** Intervalo pós-ataque onde o inimigo fica vulnerável a contra-ataques.
9. **SEARCH:** Procura tática quando o jogador usa Zetsu para ocultar sua presença.
10. **RETURN:** Retorno desarmado à rota original com regeneração lenta de vida.
11. **FLEE:** Recuo tático ativado em monstros covardes ou com vida baixa (<20%).

---

## 3. ARQUÉTIPOS DE INIMIGOS

- **Melee (Combatente Próximo):** Alta defesa física, investidas diretas, uso de Ten para absorver dano.
- **Ranged (Atirador / Emissor):** Mantém distância média (`kite`), dispara projéteis de aura e recua se o jogador aproximar.
- **Stealth-Sensitive (Feras com Faro/Audição):** Possuem redução menor ao Zetsu básico, exigindo Zetsu Lv 3+ para aproximação segura.
- **Aura-Sensitive (Especialistas em Nen):** Sentem imediatamente o uso de Ren e Hatsu mesmo fora do campo de visão direto.
- **Pack AI (Matilha):** Inimigos que comunicam aggro entre si. Ao atacar um, membros do grupo no raio de 200px entram em ALERT coletivo.
- **Boss / Chefes:** Possuem fases parametrizadas (`BossPhaseData` a 50% e 25% de HP), invocação de lacaios, arenas travadas e quebra de postura.

---

## 4. TABELA DE AMEAÇA (AGGRO SYSTEM)

Em cenários com múltiplos aliados, bichos de Nen ou pets:
- O dano causado gera pontos diretos de ameaça (`threat_table[atacante] += dano`).
- A ameaça sofre decaimento natural contínuo por segundo.
- O uso de **Zetsu** reduz imediatamente a ameaça acumulada em **90%**, forçando o inimigo a perder o foco.
