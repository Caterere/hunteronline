# HUNTER ONLINE — TASKS 2026-09-11
**Foco:** fechar residual + multiplayer LAN entre máquinas (caminho para host/VPS)

---

## Residual roadmap
- [x] Retune Jenny/loot early-game (já merged PR #8)
- [x] PvP async Arena (já merged PR #9)
- [x] Densidade Yorknew/Kukuroo + PixelLab phases

## Multiplayer LAN (máquinas na mesma rede)
- [x] Reparar `config/server_config.json` (JSON inválido / BOM)
- [x] Alias `session.peers` + `obter_latencia` + nickname→name
- [x] Spawn de `NetworkPlayer` no join / snapshot mundo
- [x] Poll de `LanDiscoveryListener` no menu
- [x] Cliente dedicado: intents only (sem snapshot absoluto)
- [x] Reconciliação local leve a partir do snapshot do servidor
- [x] Tick fixo 20 TPS no `ServerWorldCoordinator`
- [x] Launchers portáteis: `iniciar_servidor_lan.bat` + `iniciar_servidor_lan.sh`
- [x] Campos VPS-ready: `bind_address`, `public_host`, `enable_lan_discovery`, `--no-lan-discovery`
- [x] Smoke K-LAN estendido + smoke 2 processos localhost
- [x] Wire combate cliente → `rpc_solicitar_ataque_servidor` + `combat_hits_confirmed`
- [x] Proxies visuais de inimigos (`NetworkEnemyProxy`) + seed demo no servidor
- [x] WorldSpawner silenciado em sessão multiplayer (evita AI local vs proxy)
- [x] Dano inimigo→jogador autoritativo + RPC `rpc_aplicar_dano_jogador`
- [x] Recompensas XP/Jenny via `entity_died` → `rpc_recompensa_kill`
- [x] Polish visual dos proxies (sprites por `enemy_id`)

## Próximo
1. [ ] Quando contratar host: abrir UDP 7777, set `public_host`, `--no-lan-discovery`
2. [ ] Morte/respawn multiplayer + sync de aura/Nen no dano sofrido
