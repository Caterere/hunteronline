# WORLD EVENTS DESIGN BIBLE — HUNTER MMORPG
## SISTEMA DE EVENTOS DINÂMICOS, CRISES E SIMULAÇÃO AUTÔNOMA

---

## 1. O MUNDO CONTINUA QUANDO VOCÊ NÃO ESTÁ OLHANDO
O mundo do Hunter MMORPG não espera passivamente pelo jogador. Através do `WorldEventManager`, crises e oportunidades surgem e se resolvem dinamicamente:

```text
       Sorteio Orgânico (Tempo / Segurança)
                      │
                      ▼
               [EVENTO ATIVADO]
             (Ex: Invasão de Feras)
                      │
         ┌────────────┴────────────┐
         │                         │
  [INTERVENÇÃO JOGADOR]     [RESOLUÇÃO AUTÔNOMA]
  • Jogador enfrenta crise  • Tempo limite esgota
  • +100 Reputação Civis    • Checa Segurança Regional
  • +15 Prosperidade Vila   • Sucesso: Guardas vencem (+5 Seg)
  • Rumor de heroísmo       • Falha: Crise não contida (-15 Seg, -15 Prosp)
```

---

## 2. EVENTOS MUNDIAIS CANÔNICOS DE PADOKIA

### 1. Invasão de Feras da Floresta (`iniciar_evento_invasao_feras`)
- **Gatilho:** Falha de patrulha florestal ou queda da segurança abaixo de 40.
- **Manifestação:** Bestas da floresta invadem a estrada real. Spawna o **Líder da Matilha Quimera** (Miniboss Tier 3).
- **Duração:** 8 horas de tempo de jogo.
- **Dificuldade Autônoma:** 55.
- **Consequência do Sucesso:** Restaura segurança da estrada, civis agradecem nas falas de rotina.

### 2. Mercador Ambulante em Apuros (`iniciar_evento_mercador_apuros`)
- **Gatilho:** Horário do crepúsculo/noite na Estrada Real.
- **Manifestação:** Grupo de salteadores cerca a caravana de suprimentos na ponte de pedra.
- **Duração:** 6 horas de tempo de jogo.
- **Dificuldade Autônoma:** 45.
- **Consequência do Sucesso:** Descontos exclusivos no Empório de Padokia e aumento de prosperidade comercial.

---

## 3. INTEGRAÇÃO COM NPC BEHAVIOR & RUMOR SYSTEM
- Quando um evento mundial tem início na região do NPC, `LivingNPCBehavior._on_world_event_started()` exibe alertas visuais via `ComicBalloon` alertando a população.
- Ao término do evento, o `RumorSystem` propaga boatos sobre a bravura do jogador ou a incompetência das patrulhas.
