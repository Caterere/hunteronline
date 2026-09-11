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

## Próximo (após LAN estável)
1. [ ] Wire combate de cena → `rpc_solicitar_ataque_servidor`
2. [ ] Proxies visuais de inimigos a partir do snapshot
3. [ ] Quando contratar host: abrir UDP 7777, set `public_host`, `--no-lan-discovery`
