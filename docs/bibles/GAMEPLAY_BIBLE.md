# GAMEPLAY DESIGN BIBLE
## HUNTER ONLINE — DEFINITIVE GAMEPLAY DIRECTION

---

## 1. PILARES DE GAMEPLAY

O jogo é estruturado como um **2D RPG/MMORPG clássico** com exploração de mapa, combate de ação em tempo real, progressão profunda e desenvolvimento de identidade de Hunter.

### O Loop Principal de Gameplay:
```text
Spawn no Hub World (Lobby)
      │
      ├── Diálogos & NPCs
      ├── Side Quests & Contratos
      ├── Lojas & Economia
      ├── Gestão de Facções & Reputação
      └── Story Gateway NPC
            │
            ▼
      Continuação da História a partir do Checkpoint
            │
            ▼
      Exploração & Combate
      ├── Ataque Básico (Cooldown por Velocidade)
      ├── 4 Skills Ativas de Hatsu (Custo de Aura)
      └── Efeitos Passivos Contínuos de Nen (Skill Tree)
            │
            ▼
      Level Up (+1 Nen Skill Point)
            │
            ▼
      Investimento na Nen Skill Tree (Modificadores Permanentes)
            │
            ▼
      Retorno ao Hub World & Salvamento Atômico
```

---

## 2. FILOSOFIA DE COMBATE

1. **Ataque Básico:**
   - Realizado com tecla de Ataque (Espaço ou Clique).
   - Não consome Aura.
   - Possui cooldown ditado pelo atributo `Velocidade`.
   - Pode encadear pequenos combos com multiplicadores escalonados (1.0x, 1.25x, 1.80x).
2. **Hatsu como Skills Ativas (1, 2, 3, 4):**
   - Disparados pelas teclas de ação rápida de Hatsu (1, 2, 3, 4).
   - Consomem Aura máxima/atual.
   - Sujeitos a recarga (cooldown) e alcance.
   - Respeitam a categoria de afinidade e juramentos de Nen.
3. **Nen como Buffs Passivos:**
   - O jogador **NÃO** precisa ficar segurando ou ativando botões manuais de Ten, Ren ou Zetsu em combate.
   - O domínio dessas técnicas é concedido passivamente através da **Skill Tree**.

---

## 3. IDENTIDADE DO JOGADOR

- O jogador é o protagonista de sua própria jornada.
- A experiência se afasta de modelos de "reencenação passiva de anime": o mundo é vivo, persistente e reage à reputação e escolhas do Hunter.
