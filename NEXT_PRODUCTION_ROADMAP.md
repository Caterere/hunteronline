# HUNTER ONLINE — NEXT PRODUCTION ROADMAP (PLANO DE EVOLUÇÃO)

## Diretriz Permanente (AGENTS.md)
* **GAMEPLAY QUALITY > SYSTEM COUNT**
* **NÃO criar novos sistemas quando os existentes resolvem a necessidade.**
* **Foco em: COMBATE + NEN + HATSU + PROGRESSÃO.**

---

## 0. MILESTONES RECENTEMENTE CONCLUÍDOS ✅
1. **Estrutura de Mundo Contínuo & Sistema de Spawns**:
   * Implementação do `SpawnPoint.gd` com auto-registro em `WorldProgressionManager`.
   * Transições de tela via `SceneTransition` com suporte a `target_spawn_id`.
   * Portão Sul de saída física do Lobby para o Exame Hunter (`exame_maratona.tscn`).
   * Desativação de teletransportes cegos por menu no Portal Hunter, transformando-o em Guia de Expedição.
2. **Interface do HunterMenuUI (Aba Hatsu)**:
   * 4 slots de combate ativos com visualização de cards e tags de afinidade.
   * Inventário completo de técnicas forjadas e atalhos rápidos de equipar `[1][2][3][4]`.
3. **Rebalanceamento da Economia de Hatsu v2.0**:
   * Capacidade inata reduzida de 65 para 15 créditos básicos.
   * Curva não-linear de demanda funcional em 4 faixas de poder.
   * Calibragem proporcional de juramentos severos e proteção anti-oneshot com diminishing returns.

---

## 1. IMMEDIATE (Próxima Iteração Prioritária)
1. **Alimentar Sensores de Nen no Mundo Semiaberto**:
   * Instanciar 3 novas pistas de aura investigativas (`GyoInspectable`) na Floresta dos Vestígios e Ruínas de Zaban.
   * Instanciar 2 paredes/rochas rachadas (`KoObstacle`) bloqueando atalhos e baús secretos de Padokia.
   * Instanciar 2 zonas com sensores furtivos (`ZetsuSensorZone`) em acampamentos de salteadores.
2. **Variedade Visual de Criaturas Básicas**:
   * Configurar o arquétipo `fast` e `ambusher` nos monstros da Floresta com paleta e comportamento diferenciados do Slime básico.
3. **Refinamento de Feedback de Gyo**:
   * Conectar sinal de detecção ao `AudioManager` para dar feedback auditivo ao revelar segredos de Nen.

---

## 2. NEXT (Média Prioridade)
1. **Cadeias de Quests Secundárias Investigativas**:
   * Missão de investigação de assassinato/furto em Padokia usando rastreamento de Nen Gyo.
   * Missão de escolta de caravana na Estrada Real com emboscada dinâmica em horário noturno.
2. **Rotinas Dinâmicas de NPCs**:
   * Conectar o `TimeManager` para que o Ferreiro Duran e Mercador Zael alternem entre seus balcões e a Taverna durante a noite.
3. **Novos Eventos Dinâmicos de Facção**:
   * Disputa territorial entre a Associação Hunter e Salteadores nos arredores da Grande Ponte.

---

## 3. LATER (Longo Prazo / Pré-Multiplayer)
1. **Novas Regiões do Mundo**:
   * Cidade de Yorknew e Leilão Clandestino.
   * Montanha Kukuroo (Propriedade dos Zoldyck).
2. **Arena Celestial & PvP Assíncrono**:
   * Sistema de andares com lutas 1v1 contra outros usuários de Nen e Bestas de Nen.
3. **Sistemas Multiplayer Autoritativos**:
   * Sincronização de pacotes binários utilizando o `NetworkProtocol` já arquitetado.
