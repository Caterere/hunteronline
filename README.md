# Hunter Online

RPG 2D top-down (Godot **4.6** Forward Plus) inspirado em Hunter x Hunter.
Viewport interno: **640×360**. Cena inicial: `ui/CharacterSelection/CharacterSelectionUI.tscn`.

## Estrutura do repositório

| Pasta | Conteúdo |
|---|---|
| `autoload/` | Singletons globais (PlayerData, SaveManager, CombatEngine, …) |
| `entities/` | Player, NPCs, efeitos, inimigos |
| `world/` | Mapas, componentes de mundo, geradores |
| `ui/` | HUD, menus, criadores (Hatsu, personagem) |
| `scripts/` | Sistemas de gameplay (missions, combat, nen, network, …) |
| `resource/` | Resources `.gd` / `.tres` (quests, hatsu, status, …) |
| `data/` | Dados estáticos (itens, catálogos JSON) |
| `assets/` | Sprites, tilesets, fontes; `assets/reference/` = âncoras de estilo |
| `osts/` | Trilha sonora |
| `server/` | Entrada do servidor dedicado |
| `scratch/` | Suites de teste / runners (não ship) |
| `docs/` | Documentação — ver `docs/README.md` |
| `.agent/` | Skill e bibles para o agente Cursor |

## Documentação

Ponto de entrada: **[docs/README.md](docs/README.md)**

- **Bibles canônicas:** `docs/bibles/`
- **ADRs:** `docs/architecture/`
- **Guias de conteúdo:** `docs/guides/`
- **Sistemas:** `docs/systems/`
- **Multiplayer:** `docs/multiplayer/`
- **Roadmap:** `docs/roadmap/PRODUCTION_ROADMAP.md`
- **Backlog MMO:** `docs/roadmap/MMO_FEATURES_BACKLOG.md`
- **Auditorias históricas:** `docs/archive/audits/`
- **Roadmap ativo:** `docs/roadmap/PRODUCTION_ROADMAP.md`
- **Backlog MMO:** `docs/roadmap/MMO_FEATURES_BACKLOG.md`

Bibles numeradas do agente: `.agent/docs/bibles/` (**pontes** para a SSOT; design canônico = `docs/bibles/`).

## Persistência

Use **`SaveManager`** diretamente. O antigo wrapper `GameState` (autoload) foi removido.

## Autoloads

Definidos em `project.godot`. Preferência: não criar novos singletons se um existente já cobre a responsabilidade.

## Rodar

1. Abrir a pasta no Godot 4.6+
2. F5 / Play a partir da cena principal
3. Servidor LAN: `iniciar_servidor_lan.bat` (ver `docs/multiplayer/`)
