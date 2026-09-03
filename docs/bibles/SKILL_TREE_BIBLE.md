# SKILL TREE SYSTEM BIBLE
## HUNTER ONLINE — DEFINITIVE GAMEPLAY DIRECTION

---

## 1. O NÚCLEO DE PROGRESSÃO: NEN SKILL TREE

A **Nen Skill Tree** é o sistema central onde o jogador molda a identidade e o estilo de combate do seu Hunter.

```text
XP Ganho em Combate & Missões
              │
              ▼
          Level Up
              │
              ▼
      +1 Nen Skill Point
              │
              ▼
   Investimento na Skill Tree
              │
              ▼
    Aplicação Imediata de:
    ├── Modificadores Passivos (Ten, Ren, Shu, Ko, Ryu)
    └── Parâmetros de Técnicas Ativas (Zetsu, En, Gyo)
```

---

## 2. OS RAMOS DA ÁRVORE DE HABILIDADES

A árvore organiza os talentos em categorias claras:

### 1. Ramo de Defesa Passiva (Ten)
- Redução percentual direta de dano físico (`defesa`).
- Estabilidade de postura contra repulsão e atordoamento.

### 2. Ramo de Potência Ofensiva Passiva (Ren)
- Multiplicador de dano de ataques físicos (`dano_fisico`).
- Expansão de Aura Máxima (`aura_max`).

### 3. Ramo de Equipamentos (Shu)
- Dano e penetração de armadura ao usar armas empunhadas (`dano_arma`).

### 4. Ramo de Finalizadores (Ko)
- Bônus de Burst Damage no terceiro golpe do ataque básico (`ko_burst`).

### 5. Ramo de Distribuição de Fluxo (Ryu)
- Escolha de postura de maestria: Ryu Ofensivo (70/30), Defensivo (30/70) ou Equilibrado (50/50).

### 6. Ramo de Furtividade Ativa (Zetsu)
- Aumento do `zetsu_stealth` (20% até 80%), encurtando dramaticamente a distância em que monstros conseguem detectar o jogador.
- Aceleração da recuperação de HP e Aura fora de perigo.

### 7. Ramo de Domínio Espacial Ativo (En)
- Aumento do `raio_en` (120px até 450px).
- Aumento do poder de Intimidação: redução de defesa em inimigos na cúpula (-5% até -30%).

### 8. Ramo de Percepção Oculta Ativa (Gyo)
- Desbloqueio dos Tiers de Percepção (1 a 5), permitindo detectar segredos de dificuldade fácil, média e lendária.
- Bônus adicionais de Esquiva e Golpe Crítico.

---

## 3. AUTORIDADE DO SISTEMA VS UI

- A interface (HUD, Árvore Visual) é meramente uma camada de apresentação e envio de comandos.
- A autoridade de validação (pontos disponíveis, pré-requisitos, limite de nível) reside exclusivamente na classe `NenSkillTree.gd`.
- Ao investir um ponto:
  - `NenSkillTree` deduz o ponto em `PlayerData.nen_skill_points`.
  - Atualiza o registro em `PlayerData.nen_skill_tree_progress`.
  - Aplica o modificador correspondente em `PlayerData.adicionar_modificador()`.
  - Recalcula imediatamente todos os stats de combate, stealth e detecção.
