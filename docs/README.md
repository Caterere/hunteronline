# Documentação — Hunter Online

Índice da documentação. **Fonte de verdade de design:** `docs/bibles/`.  
Código e cenas vencem docs desatualizados quando houver conflito — reporte o conflito.

## Mapa de pastas

| Pasta | Uso |
|---|---|
| [bibles/](bibles/) | Regras canônicas de design (Nen, Hatsu, combate, mundo, UI…) |
| [architecture/](architecture/) | ADRs (decisões técnicas) |
| [systems/](systems/) | Descrição de sistemas implementados |
| [guides/](guides/) | Como criar conteúdo (NPC, boss, região, saga, quest…) |
| [multiplayer/](multiplayer/) | Rede, LAN, protocolo, segurança |
| [roadmap/](roadmap/) | Roadmap e pipelines de produção |
| [audits/](audits/) | Auditorias e playtests (histórico) |
| [archive/](archive/) | Material legado / dumps |

## Começar por aqui

1. [bibles/GAME_MASTER_BIBLE.md](bibles/GAME_MASTER_BIBLE.md) — visão geral dos pilares
2. [bibles/ART_PIPELINE_CANON.md](bibles/ART_PIPELINE_CANON.md) — união das regras de pixel art / PixelLab
3. [architecture/ADR-001-NEN-ARCHITECTURE.md](architecture/ADR-001-NEN-ARCHITECTURE.md) — Nen híbrido
4. [roadmap/NEXT_PRODUCTION_ROADMAP.md](roadmap/NEXT_PRODUCTION_ROADMAP.md) — o que fazer agora
5. [roadmap/MMO_SYSTEMS_BACKLOG.md](roadmap/MMO_SYSTEMS_BACKLOG.md) — backlog MMO (Tier S/A/B + PREREQ rede)
6. [systems/SAVE_SYSTEM.md](systems/SAVE_SYSTEM.md) — persistência (`SaveManager`)
7. [systems/PIXELLAB_MCP.md](systems/PIXELLAB_MCP.md) — PixelLab (MCP vs scripts)
8. [guides/PIXELLAB_PROMPT_LIBRARY.md](guides/PIXELLAB_PROMPT_LIBRARY.md) — prompts por categoria

## Agente Cursor

As bibles numeradas em `.agent/docs/bibles/` orientam o agente.  
Skill: `.agent/skills/hunter-development/SKILL.md`  
Em conflito, preferir `docs/bibles/` + código existente.

## Persistência

Não existe mais o autoload `GameState`. Use `SaveManager` para save/load/slots.
