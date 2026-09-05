# QUEST & CONTENT DESIGN BIBLE — HUNTER MMORPG
## ESTRUTURAÇÃO DE MISSÕES, VARIABILIDADE E EXPLORAÇÃO ORGÂNICA

---

## 1. O PRINCÍPIO DO CONTEÚDO MEMORÁVEL
> **"10 missões com identidade, reatividade e mecânicas reais de Nen superam 100 missões genéricas de coleta vazia."**

O Hunter MMORPG elimina o modelo arcaico de "mate 10 javalis sem motivo". Toda missão possui contexto diegético, conexão com a lore dos Caçadores e consequências no mundo.

---

## 2. OS 6 TIPOS DE MISSÕES CANÔNICAS

| Tipo de Missão | Foco de Gameplay | Requisito Mecânico | Exemplo Canônico em Padokia |
|---|---|---|---|
| **1. Story / Principal** | Progressão de saga e mestria de Nen | Combate multifase, treino com mestre | "O Despertar da Aura & O Guardião de Zaban" |
| **2. Gathering / Herbalismo** | Economia e suporte da vila | Proteção contra predadores e coleta | "Ervas Medicinais da Floresta" (Vendedor) |
| **3. Crafting / Materiais** | Forja e aprimoramento com trade-offs | Derrota de construtos de pedra com Ko | "Minérios das Ruínas de Zaban" (Ferreiro Duran) |
| **4. Patrol / Escolta** | Segurança regional da estrada | Emboscada de bandidos e patrulha | "Segurança da Caravana Real" (Guarda da Vila) |
| **5. Combat Challenge** | Domínio de técnicas avançadas de Nen | Sustentação de Ten em zona de perigo | "Extermínio dos Predadores da Ravina" (Caçador) |
| **6. Segredo Orgânico** | Exploração pura e dedução visual | Gyo para ler pistas, Ko para romper selo | "O Enigma da Rocha Rachada" (Ermitão) |

---

## 3. REGRA CRÍTICA: SEM WAYPOINTS PARA SEGREDO ORGÂNICO
- Quests secretas e quebra-cabeças ambientais possuem a flag `is_secret = true`.
- O `MissionGPSIndicator` **NUNCA** projeta setas ou marcadores automáticos para missões secretas.
- O jogador descobre os segredos através de:
  1. Observação de anomalias no relevo (rocha fissurada, totem solitário).
  2. Uso de **Gyo** nos olhos para visualizar inscrições de aura invisíveis.
  3. Fofocas e rumores de taverna via `RumorSystem`.
  4. Alta confiança com NPCs via `RelationshipSystem`.

---

## 4. CICLO DE VIDA E TURN-IN DIEGÉTICO
- Quests principais e de desafio exigem **Turn-in Físico**: o jogador deve retornar ao NPC contratante para entregar a missão e receber diálogos reativos ao desfecho.
- Quests simples de apoio da comunidade podem utilizar `auto_complete = true`.
