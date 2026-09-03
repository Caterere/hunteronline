# DIALOGUE & INTERACTION SYSTEM ARCHITECTURE
## HUNTER ONLINE — UNIFIED DIALOGUE PIPELINE & NPC BEHAVIOR

### 1. Visão Geral
O sistema de diálogo unifica a comunicação diegética do universo de Hunter x Hunter:
* **Balões Rápidos em Nuvem (Overhead):** Falas ambientais de 1 linha sem pausar o jogo (`falar_balao`).
* **Diálogo Visual (CanvasLayer Modal):** Sequências narrativas de história, escolhas e instruções com avatar do interlocutor (`VisualDialogueUI`).
* **Cinemáticas Dramáticas:** Câmera controlada e diálogos de conclusão de arco (`StoryCutsceneManager`).

### 2. Fluxo de Interação com NPC
```text
Jogador Pressiona [E] próximo ao NPC
                  │
                  ▼
         InteractionComponent
                  │
                  ▼
         NPC._on_interacted(player)
                  │
                  ├── Consulta QuestSystem / StoryManager (Single Source of Truth)
                  │     └─► Ex: Se etapa de quest ativa exige falar com este NPC:
                  │           Registra visita e avança objetivo.
                  │
                  ├── Monta Array[Dictionary] de falas contextuais
                  │
                  ▼
         VisualDialogueUI.exibir_sequencia_falas(falas)
                  │
                  └─► Ao concluir: Emite sinal `dialogo_concluido` e destrava o jogador.
```

### 3. Regras de Resiliência de Diálogo
* A flag `_interacao_em_processamento` nunca deve ser deixada presa em `true`. Se nenhuma fala for exibida, a flag é imediatamente resetada.
* Timeout de segurança (fallback de 5s) garante que o jogador nunca fique travado caso um diálogo falhe em instanciar.
