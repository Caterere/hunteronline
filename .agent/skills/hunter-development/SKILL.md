---
name: hunter-development
description: Desenvolver, diagnosticar ou revisar o projeto Hunter Online em Godot, preservando os sistemas canônicos e aplicando as Bibles relevantes para Nen, Hatsu, combate, Skill Tree, quests, mundo, UI e persistência.
---

# Skill de Desenvolvimento do Hunter Online

Use esta skill para alterações e revisões do projeto Godot. Desenvolva em incrementos pequenos e compatíveis, mantendo um RPG estratégico, persistente e expansível.

## Fonte de verdade

1. Pedido atual do usuário.
2. Bibles em `docs/bibles/` (canônicas) e `.agent/docs/bibles/` (agent), começando por `00_BIBLE_INDEX.md`.
3. Implementação, cenas e recursos existentes.
4. Decisões razoáveis de implementação.

Quando uma Bible divergir do código, investigue e comunique o conflito antes de uma reescrita ampla.

Índice do repositório: `docs/README.md` · `README.md` na raiz.

## Investigação obrigatória

Antes de alterar código ou cenas:

1. Leia scripts, cenas, recursos, sinais, grupos, autoloads e chamadas relacionadas.
2. Leia somente as Bibles que governam a tarefa; em trabalho entre sistemas, inclua Arquitetura, Schema e Testes.
3. Identifique o dono canônico de cada estado e regra. Reutilize-o, sem criar estado ou sistemas paralelos.
4. Faça a menor alteração que atende ao pedido.

## Donos canônicos

- `PlayerData`: progressão, dados persistentes e pipeline de `StatModifier`.
- `CombatEngine`: cálculo compartilhado de dano e mitigação.
- `NenSystem`: aura, técnicas, estados de Nen e progressão de Nen.
- `QuestSystem`/`QuestManager`: objetivos, transições, conclusão e recompensas.
- `SaveManager`: ciclo de persistência e compatibilidade.
- UI: apenas apresentação do estado canônico, nunca dona da lógica de gameplay.
- Arte 2D e Sprites: governados estritamente pela `16_PIXEL_ART_STYLE_BIBLE.md`. Runtime: `assets/sprites/characters/player.png`. Style lock: `assets/reference/player(3).png` (48x48, baixa densidade, 20-22px altura, pés em Y=42).
- Persistência: use **`SaveManager`** (o autoload `GameState` foi removido).
- NPCs, diálogos, Hatsu, transições, spawns e eventos: reutilize os sistemas existentes quando a responsabilidade já existir.

Não renomeie casualmente campos persistentes, autoloads, scripts, cenas ou recursos. Mudanças de schema exigem compatibilidade com saves antigos.

## Regras de implementação

- Prefira Nodes, Scenes, Signals, Resources, Groups e Autoloads nativos da Godot.
- Mantenha responsabilidades separadas; não transforme `Player.gd` ou controles de UI em arquivos centralizadores.
- Centralize constantes de gameplay no sistema ou recurso responsável.
- Hatsu deve permanecer orientado a dados; custo de aura, cooldown, restrições, afinidade, tags e condições devem ser reais.
- Condições usam `GameplayCondition` e tags usam `GameplayTags`; não consulte IDs de Hatsu ou nós de cena espalhados.
- Passivas usam `StatModifier` no `PlayerData`; não crie classes privadas de modificador.
- Portais, GPS, diálogo e quests consultam o estado canônico de progressão.
- Geração ou importação de sprites de personagens exige frame 48x48, escala ~20-22px de altura, pés em Y=42 e validação prévia com `tools/validate_sprite_style.gd`.
- **Todo inimigo, NPC, prop ou cenário NOVO exige arte nova via PixelLab MCP** (`https://api.pixellab.ai/mcp`, docs `https://api.pixellab.ai/mcp/docs`), seguindo o Style Lock (`docs/bibles/PIXEL_ART_STYLE_BIBLE.md`) e o padrão Hunter x Hunter. Personagens/inimigos: folha `_8dir.png` + `_walk_8x8.png` (inimigos com prefixo `enemy_<id>_` para o bind em `EnemySystem._vincular_textura_inimigo()`); props em `assets/sprites/objects/`; tilesets via `create_topdown_tileset` em `assets/sprites/tilesets/pixellab/`. Nunca deixe conteúdo novo usando `player.png`/placeholder como asset final. Registre em `docs/systems/ASSET_REGISTRY.md`. Fluxo e tools em `docs/systems/PIXELLAB_MCP.md`. Se o MCP não estiver disponível (token em `.cursor/mcp.json`, gitignored), use o fallback REST `scripts/tools/pixellab_*` ou sinalize que a etapa de sprite ficou pendente.
- Não esconda defeitos com guards arbitrários, chamadas duplicadas, delays sem explicação ou funcionalidades desativadas.

## Validação e entrega

Após cada alteração, revise caminhos de recursos e nós, sinais, tipos e consumidores dependentes. Execute o teste Godot, de sistema ou gameplay mais específico disponível. Para mudanças de progressão, verifique save/load quando possível.

Informe exatamente o que foi alterado, validado e o que não pôde ser testado. Atualize a documentação quando uma decisão arquitetural ou persistente mudar.
