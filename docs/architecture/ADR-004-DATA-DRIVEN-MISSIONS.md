# ADR-004: MISSÕES ORIENTADAS A DADOS (DATA-DRIVEN MISSIONS)

## Contexto
O projeto precisará comportar 9 Sagas canônicas com cerca de 200 missões, além de caçadas, missões paralelas e contratos de facção. Codificar a lógica de cada missão diretamente em scripts embutidos na cena resulta em duplicação e alto risco de quebra.

## Decisão
1. Toda missão é definida como um recurso `MissionData` (ou derivado) contendo IDs, requisitos, listas de objetivos, NPCs envolvidos, recompensas e condições de falha.
2. O ciclo de vida e a contagem de monstros é gerenciado por instâncias de `MissionInstance.gd`.
3. Conclusões acionam `StoryManager` e `QuestManager` de forma padronizada.

## Consequências
- Criação e balanceamento de missões por designers sem necessidade de refatorar o motor.
- Facilidade de teste automatizado e serialização no save.
