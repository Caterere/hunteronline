# LIVE CONTENT PIPELINE — HUNTER MMORPG

> **Arquitetura de Expansão Contínua, Live Operations e Ciclo de Vida de Conteúdo**
> **Versão:** 1.0 (Fase L) | **Engine:** Godot 4.6 Stable

---

## 1. VISÃO GERAL DO PIPELINE

O **Live Content Pipeline** do Hunter MMORPG transforma a estrutura do jogo de uma campanha linear e fixa em uma **plataforma modular orientada a dados (Data-Driven)**. Todas as sagas, capítulos, regiões, chefes, eventos temporários e segredos são instanciados e consumidos via recursos (Resource) e dicionários declarativos, dispensando qualquer edição ou recompilação no código-fonte do motor (StoryManager, SaveManager, EnemySystem).

### Princípios Cardeais:
1. **Autonomia Offline Preservada (0ms Latência):** O single-player offline permanece 100% funcional e autônomo.
2. **Compatibilidade Co-op (Fase K):** Todos os pacotes de conteúdo trazem sinalizações explícitas de suporte a grupos (coop, solo, server_authoritative).
3. **Persistência Incremental e Segura (Schema v2.4):** Novas variáveis e estados de sagas e eventos são migrados de forma retrocompatível sem perda de progresso de versões legadas (v2.0 a v2.3).
4. **Validação Automática Pré-Publicação:** O validador estático e dinâmico (ContentValidator) assegura a integridade de referências antes do carregamento em runtime.

---

## 2. O QUE ESTÁ IMPLEMENTADO

### 2.1 Módulos Centrais
* **SagaDefinition (es://resource/saga/SagaDefinition.gd):** Recurso declarativo para definição de arcos narrativos com ordem, faixa de nível recomendada, nível de perigo, capítulos associados, regiões, NPCs, chefes e recompensas de finalização.
* **ChapterDefinition (es://resource/saga/ChapterDefinition.gd):** Estrutura modular de capítulo com missões principais, secundárias, chefes de clímax, cutscenes e avaliação condicional de gating.
* **StoryGatingEvaluator (es://scripts/systems/story/StoryGatingEvaluator.gd):** Motor de avaliação condicional sem hardcode que valida nível, missões completadas, encontros de NPCs, reputação, itens de inventário, status de Nen, escolhas prévias, flags de mundo e clima.
* **StoryManager (es://autoload/StoryManager.gd):** Suporte nativo a egistrar_saga_definition(), obter_saga_definition(), valiar_gating_capitulo() e rastreamento de sagas customizadas sem alterar as 9 sagas canônicas existentes.
* **NPCMemorySystem (es://scripts/systems/npc/NPCMemorySystem.gd - Autoload):** Memória episódica por NPC gravando interações, decisões, frequência e timestamps.
* **NPCStoryArc (es://scripts/systems/npc/NPCStoryArc.gd):** Máquina de estados declarativa de arcos pessoais de NPCs com múltiplos estágios vinculados a memórias e missões.
* **RegionPackage (es://resource/region/RegionPackage.gd):** Pacote isolado com iluminação ambiente, áudio, clima, POIs, segredos e conexões de viagem.
* **TravelSystem (es://scripts/systems/travel/TravelSystem.gd - Autoload):** Hub de trânsito inter-regional (a pé, barco, dirigível, mestres de viagem) com custos, autorizações e desbloqueios.
* **LiveEventManager (es://autoload/LiveEventManager.gd - Autoload):** Agendamento e ciclo de vida de eventos temporários no mundo com controle horário, spawns dedicados e recompensas anti-duplicação.
* **BossDefinition (es://resource/boss/BossDefinition.gd):** Pipeline declarativo para chefes com transição de fases, loot tables e parâmetros de ameaça cooperativa.
* **CollectionManager (es://scripts/systems/collections/CollectionManager.gd - Autoload):** Códex do Caçador para registro de 8 categorias de descobertas e segredos.
* **ContentValidator (es://scripts/systems/content/ContentValidator.gd):** Validador estático de consistência de IDs, rotas, tabelas de recompensas e arquivos de mapa.
* **ContentVersionConfig (es://scripts/core/ContentVersionConfig.gd):** Tripla-versão (GAME_VERSION, CONTENT_VERSION, SAVE_VERSION) e pipeline de migração v2.3 -> v2.4.

---

## 3. O QUE ESTÁ PLANEJADO

1. **Hot-Reloading de Recursos em Tempo Real:** Recarregar pacotes .tres de sagas e eventos via menu de debug sem reiniciar a sessão do jogador.
2. **Download Dinâmico de Pacotes (Patching Client):** Verificação de checksum remoto de pacotes e sincronização de assets adicionais (sprites, áudios) para clientes multiplayer.
3. **Gerenciador de Modding Seguro:** Carregamento de sagas comunitárias em sandbox com limites rígidos de execução para prevenir injeção de scripts não seguros.

---

## 4. O QUE É FUTURO

1. **Editor Visual de Sagas Integrado à Engine:** Ferramenta gráfica in-engine baseada em GraphEdit para conectar nós de capítulos, condições de gating e desfechos ramificados.
2. **Eventos Globais Sincronizados via Backend Central:** Servidor mestre de calendário acionando invasões e eventos comemorativos em tempo real para todos os shards de mundo.
3. **Temporadas Competitivas com Ranking:** Ligas de caçada com reset parcial de códex e recompensas cosméticas exclusivas.
