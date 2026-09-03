# ADR-002: CHECKPOINTS AUTORITATIVOS DE HISTÓRIA

## Contexto
O carregamento de jogos salvos em fases avançadas de missões ou arenas de combate causava problemas de orfandade de nós, dessincronização de flags e perda de contexto narrativo.

## Decisão
1. `StoryManager` é o único detentor da autoridade sobre o progresso de Sagas e Capítulos.
2. Cada marco relevante na história registra um `checkpoint_id` no catálogo `CATALOGO_CHECKPOINTS`.
3. Carregar um jogo salvo nunca instancia o jogador no meio de uma arena isolada, mas sim no Hub World, delegando a transição de retorno ao `StoryGatewayNPC`.

## Consequências
- Fim de softlocks ao carregar arquivos salvos.
- Rastreamento inequívoco de requisitos pendentes para atravessar `StoryGate`.
