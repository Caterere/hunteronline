# MISSION & QUEST DESIGN BIBLE
## HUNTER ONLINE — DEFINITIVE GAMEPLAY DIRECTION

---

## 1. CATEGORIAS DE MISSÕES

Para que o mundo exista muito além do corredor narrativo principal, as missões são divididas em 6 categorias independentes:

1. **Main Story Quests:**
   - Avançam as 9 Sagas canônicas.
   - Gerenciadas e despachadas através do `StoryManager` e do `StoryGatewayNPC`.
2. **Side Quests (Missões Secundárias):**
   - Oferecidas por cidadãos, viajantes e NPCs espalhados pelas cidades e rotas.
   - Fornecem contexto de mundo, gold, itens e reputação local.
   - Persistem no save game sem interferir no avanço da história principal.
3. **Faction Quests (Missões de Facção):**
   - Oferecidas por representantes das 6 grandes organizações (Associação Hunter, Trupe Fantasma, Zoldyck, Máfia, etc.).
   - Aumentam a reputação com a facção contratante e podem reduzir a reputação com facções rivais.
4. **Training Quests (Missões de Treinamento):**
   - Desafios ministrados por mestres como Wing, Biscuit e instrutores de combate.
   - Recompensam com Nen Skill Points, técnicas passivas e desbloqueios de Hatsu.
5. **Bounty Quests (Contratos da Lista Negra):**
   - Alvos criminosos e bestas perigosas com cartazes de procurado.
   - Gerenciadas pelo `BountySystem`.
6. **Daily / Repeatable Quests:**
   - Tarefas de patrulha e coleta diária com recompensas econômicas balanceadas.

---

## 2. ISOLAMENTO DE EXECUÇÃO (MISSION INSTANCE)

Cada missão ativa gera ou se conecta a uma `MissionInstance`:
- Rastreia entidades geradas exclusivamente para a missão (inimigos de evento, caixas de suprimento).
- Executa limpeza atômica (`cleanup()`) em caso de abandono ou derrota do jogador, prevenindo a persistência de nós fantasmas no mapa.

---

## 3. TABELA DE RECOMPENSAS

| Categoria | XP Base | Gold | Reputação | Itens / Desbloqueios |
| :--- | :--- | :--- | :--- | :--- |
| **Main Story** | Alta (Escala por Saga) | Alta | Neutra/Geral | Desbloqueio de novas áreas e sagas |
| **Side Quest** | Média | Moderada | +25 a +100 (Civis/Mercadores) | Consumíveis, anéis, cartas de Greed |
| **Faction** | Média-Alta | Alta | +150 (Facção) / -50 (Rival) | Ranks de Facção, cosméticos e perks |
| **Training** | Moderada | Baixa | +50 (Hunters) | +1 a +2 Nen Skill Points |
| **Bounty** | Alta | Muito Alta | +100 (Blacklist) | Títulos de Caçador de Recompensas |
