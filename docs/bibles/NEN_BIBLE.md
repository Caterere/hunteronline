# NEN SYSTEM BIBLE
## HUNTER ONLINE — DEFINITIVE GAMEPLAY DIRECTION

---

## 1. A ESTRUTURA CANÔNICA DE NEN (HÍBRIDA DEFINITIVA)

O sistema de Nen no Hunter Online é formalmente dividido em **Duas Camadas**:

```text
                                NEN SYSTEM
                                    │
                  ┌─────────────────┴─────────────────┐
                  │                                   │
         5 TÉCNICAS PASSIVAS                 3 TÉCNICAS ATIVAS
        (Modificadores Contínuos)            (Toggles com InputMap)
                  │                                   │
        ┌─────────┼─────────┐               ┌─────────┼─────────┐
        │         │         │               │         │         │
       Ten       Ren       Shu            Zetsu       En       Gyo
        │         │
       Ko        Ryu
```

---

## 2. AS 5 TÉCNICAS PASSIVAS (PROGRESSÃO CONTÍNUA)

As técnicas passivas **NÃO** exigem botões de ativação manual nem causam drenagem desnecessária de aura no combate básico. O personagem as domina através da **Nen Skill Tree**:

### 1. 🛡️ TEN (Envolver)
- **Natureza:** Passivo Permanente.
- **Efeito:** Mantém a aura contida nos limites corporais.
- **Benefícios Contínuos:**
  - Mitigação percentual contínua de dano físico recebido (calculado em `CombatEngine`).
  - Estabilidade de postura e resistência a interrupção/stagger.
  - O bônus defensivo cresce conforme o investimento no Ramo de Ten da Skill Tree.

### 2. 🔥 REN (Expandir)
- **Natureza:** Passivo Permanente.
- **Efeito:** Aumenta a capacidade de produção e densidade de aura.
- **Benefícios Contínuos:**
  - Multiplicador de dano em todos os ataques básicos.
  - Aumento da capacidade máxima de Aura (`aura_max`).
  - Redução no tempo de preparação de habilidades de Hatsu.

### 3. ⚔️ SHU (Imbuir)
- **Natureza:** Passivo Permanente.
- **Efeito:** Estende o manto de aura para armas e armaduras empunhadas.
- **Benefícios Contínuos:**
  - Converte ataques físicos com armas em dano reforçado de Nen.
  - Ignora frações da armadura natural de monstros e chefes.

### 4. 💎 KO (Concentrar)
- **Natureza:** Modificador Ofensivo Passivo.
- **Efeito:** Concentração extrema de aura no ponto de contato.
- **Benefícios Contínuos:**
  - Concede bônus de dano de impacto destrutivo (Burst Damage) especificamente no golpe finalizador do combo básico de ataque.

### 5. ⚖️ RYU (Fluxo)
- **Natureza:** Modificador Tático Passivo.
- **Efeito:** Distribuição balanceada de aura entre defesa e ataque.
- **Benefícios Contínuos:**
  - Especialização escolhida na Skill Tree (Ofensiva 70/30, Defensiva 30/70 ou Equilibrada 50/50), fornecendo bônus constantes de poder ou resistência.

---

## 3. AS 3 TÉCNICAS ATIVAS ESPECIAIS (TOGGLES ON/OFF)

Estas 3 técnicas possuem botões dedicados de acionamento via `InputMap`, estados de jogo e mecânicas próprias:

### 1. 🍃 ZETSU (Silenciar) — MECÂNICA DE STEALTH
- **Input:** Configurado no InputMap (`nen_zetsu`, Tecla `Z`).
- **Estado:** Toggle ON / OFF.
- **Função Principal:** **FURTIVIDADE REAL (STEALTH)**.
- **Fórmula de Detecção de Inimigos:**
  $$\text{Raio Efetivo de Detecção} = \text{Raio Base} \times (1.0 - \text{Fator Stealth Zetsu})$$
- **Progressão na Skill Tree:**
  - *Zetsu Lv. 1:* Redução de 20% no raio de detecção inimiga.
  - *Zetsu Lv. 2:* Redução de 35% no raio de detecção.
  - *Zetsu Lv. 3:* Redução de 50% no raio de detecção.
  - *Zetsu Lv. 4:* Redução de 65% no raio de detecção.
  - *Zetsu Lv. 5 (Mestre da Ocultação):* Redução de 80% no raio de detecção.
- **Regras de Combate (Quebra de Stealth):**
  - Se o jogador atacar (`basic_attack` ou Hatsu) ou receber qualquer dano, **o Zetsu é cancelado imediatamente**, revelando a presença do Hunter.
  - Fora de combate com Zetsu ativo, a regeneração natural de HP e Aura é acelerada (+150%).

### 2. 🌐 EN (Círculo) — DETECÇÃO + INTIMIDAÇÃO
- **Input:** Configurado no InputMap (`nen_en`, Tecla `X`).
- **Estado:** Toggle ON / OFF.
- **Função Principal:** **DETECÇÃO ESPACIAL + DEBUFF DE INTIMIDAÇÃO**.
- **Comportamento em Jogo:**
  - O jogador projeta uma cúpula visível de aura ao seu redor.
  - Todos os inimigos dentro do raio são detectados e sofrem o efeito de **Intimidação**:
    - Redução na Defesa dos inimigos (`en_defense_reduction`).
    - Hesitação e penalidade de velocidade de ataque.
- **Progressão na Skill Tree:**
  - *En Lv. 1:* Raio 120px | -5% de Defesa Inimiga.
  - *En Lv. 2:* Raio 180px | -10% de Defesa Inimiga.
  - *En Lv. 3:* Raio 260px | -15% de Defesa Inimiga.
  - *En Lv. 4:* Raio 340px | -20% de Defesa Inimiga.
  - *En Lv. 5 (Cúpula Soberana):* Raio 450px | -30% de Defesa Inimiga.
- **Custo:** Leve dreno contínuo de Aura por segundo enquanto mantido ativo.

### 3. 👁️ GYO (Focar) — PERCEPÇÃO / DESCOBERTA OCULTA
- **Input:** Configurado no InputMap (`nen_gyo`, Tecla `G`).
- **Estado:** Toggle ON / OFF.
- **Função Principal:** **PERCEPÇÃO / REVELAÇÃO DE SEGREDOS NO MUNDO**.
- **Níveis de Percepção (Evitando o erro de "Highlight Everything"):**
  - O mundo possui objetos, pistas, baús e passagens marcados com níveis de segredo (`nivel_gyo_minimo`):
    - *Tier 1 (Fácil):* Pistas simples de pegadas e marcas residuais de aura.
    - *Tier 2 (Intermediário):* Baús ocultos, inscrições antigas e caminhos camuflados.
    - *Tier 3 (Avançado):* Passagens secretas em paredes sólidas, runas de portais e itens lendários.
- **Progressão na Skill Tree:**
  - *Gyo Lv. 1:* Nível de Percepção 1 | +3% Esquiva.
  - *Gyo Lv. 2:* Nível de Percepção 2 | +6% Esquiva.
  - *Gyo Lv. 3:* Nível de Percepção 3 | +5% Crítico.
  - *Gyo Lv. 4:* Nível de Percepção 4 | +10% Crítico.
  - *Gyo Lv. 5 (Olhar da Verdade):* Nível de Percepção 5 | Revela 100% dos segredos do mapa.

---

## 4. MATRIZ CANÔNICA DE CONFLITOS ENTRE TÉCNICAS ATIVAS

| Técnica Ativa | Com Zetsu | Com En | Com Gyo |
| :--- | :--- | :--- | :--- |
| **ZETSU** | — | ❌ **Incompatível** (Desliga En) | ❌ **Incompatível** (Desliga Gyo) |
| **EN** | ❌ **Incompatível** (Desliga Zetsu) | — | ✅ **Compatível** (Leve custo extra de concentração) |
| **GYO** | ❌ **Incompatível** (Desliga Zetsu) | ✅ **Compatível** | — |

- **Zetsu vs En:** Zetsu extingue a presença; En a expande a centenas de metros. Ao ligar Zetsu, En desliga imediatamente (e vice-versa).
- **Zetsu vs Gyo:** Zetsu fecha todos os nós corporais; Gyo exige fluxo de aura concentrado nos olhos. São mutualmente exclusivos.
- **En + Gyo:** O caçador pode manter sua cúpula de En e ao mesmo tempo usar Gyo para inspecionar um alvo, pagando o custo de aura de ambas.
