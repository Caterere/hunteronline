# ADR-003: HUB WORLD MANDATE (LOBBY COMO PONTO CENTRAL)

## Contexto
Jogos com arquitetura de instâncias precisam de um ponto de encontro estável que funcione como espaço social, comercial e de transição narrativa. Tratar o Lobby apenas como um menu estático enfraquece a sensação de RPG/MMORPG.

## Decisão
O mapa `world/lobby.tscn` é o **Hub World Mandatário**:
1. Todo `carregar_jogo()` em `SaveManager` força o spawn do jogador no Lobby.
2. No Lobby residem os NPCs centrais de treinamento, comércio, acesso a missões (`StoryGatewayNPC`) e interação com facções.
3. Transições para missões de história ocorrem através de portais contextualizados ou diálogos com despachantes.

## Consequências
- Experiência coesa de MMORPG 2D.
- Ciclo de vida previsível de cenas e gerenciamento seguro de memória.
