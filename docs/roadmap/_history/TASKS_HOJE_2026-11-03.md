# HUNTER ONLINE — TASKS HOJE 2026-11-03
**Trilha F — Intensidade jogável** (Saga + Combate/Feel + Hatsu)  
**Branch:** `cursor/refino-intensidade-48b6`  
**Regra:** MODIFY DON'T REBUILD · sem sistemas MMO novos · early→Arena

---

## Matriz review slice (Exame → Padokia → Floresta → Ruínas → Hatsu moment)

Scores 1–5 (pré-refino, código + bibles; G5 humano ainda pendente do Luiz).

| Beat | Legibilidade | TTK | Teach Nen/Hatsu | Climax | Dead time | Nota |
| :--- | :---: | :---: | :---: | :---: | :---: | :--- |
| Exame combate | 4 | 4 | 2 | 3 | 4 | Combo existe; anim sameness |
| Padokia Nen 3 beats | 4 | — | 4 | 3 | 4 | Gyo→Zetsu→Ko densificado |
| Floresta elites | 3 | 4 | 3 | 3 | 4 | Telegraph pouco afinidade-aware |
| Boss Ruínas 3 fases | 4 | 4 | 3 | 4 | 4 | Referência de climax; juice entrada/saída |
| Hub Skill Tree | 4 | — | 4 | 2 | 5 | Cluster identity ok |
| 1º Hatsu (Biscuit) | 3 | — | 3 | 3 | 4 | Cast→impact→residual raso |
| Arena Training Wing | 4 | — | 3 | 2 | 5 | Respiro ok |

**Corte do dia:** só beats que ↑ intensidade / profundidade / diversão na rota early→Arena.

---

## Ship checklist

### Bloco 2 — Combate / animações
- [x] Perfil hit1 / hit2 / finisher / heavy (hitstop+shake+VFX)
- [x] Vitória de postura (guard-break climax)
- [x] 3 cancel rules documentadas + tunadas
- [x] 1 elite early com telegraph por afinidade (Alfa Ninho Emissão)

### Bloco 3 — Hatsu
- [x] Jajanken Pedra — charge + residual crater
- [x] Jajanken Papel — trail emissão
- [x] Jajanken Tesoura — slash residual
- [x] Godspeed — trail elétrico nos basics
- [x] Bungee Gum — pull alvo **ou** self
- [x] Chain Jail → Judgement — visual + payoff mark
- [x] Crazy Slots — arma persiste N s (se tempo)
- [x] Fichas backlog Hatsus restantes (doc)

### Bloco 4 — Saga beats
- [x] Amarrar teach Nen / Hatsu moment / Ruínas ao feel novo
- [x] Companion chatter leve Kukuroo/Arena (anti toast-spam)

### Bloco 5 — Validação
- [x] Suites feel + hatsu fidelity (`test_hatsu_combat_feel` 29/29, `test_refino_intensidade` 18/18, fidelity 79/79, dash heavy 9/9)
- [x] Smoke early (steam early 58/60 pré-existente ORDEM + exit 134 leak)
- [x] ESTADO_ATUAL atualizado

---

## Cancel rules (canônicas — hoje)

1. **Dodge cancela recovery de ataque** — já em `tentar_esquivar`; manter; hitbox desliga.
2. **Heavy buffer no finisher** — se hold/RMB durante janela do hit3, enfileira pesado ao fim do recovery curto.
3. **Hatsu cancela ataque** — `cancelar_ataque_para_hatsu` permanece.

---

## Fora de escopo
VPS · PR #48 social · sprites PixelLab · raid Continente Negro · branching arcs 2–7 · wall-bounce/aerial expand.
