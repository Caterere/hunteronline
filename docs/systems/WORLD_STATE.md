# WORLD STATE ARCHITECTURE
## HUNTER ONLINE — PERSISTENT WORLD FLAGS & TRANSIENT MAP STATE

### 1. Separação de Estados do Mundo
A arquitetura distingue com precisão o que deve ser gravado permanentemente e o que é efêmero durante a sessão:

```text
ESTADO DO MUNDO
 ├── 1. PERSISTENT WORLD STATE (WorldState)
 │    ├── Baús abertos (baus_abertos: Dictionary[String, bool])
 │    ├── Portas desbloqueadas com chave
 │    ├── Puzzles ambientais solucionados
 │    └── NPCs que mudaram de localização permanentemente
 │
 └── 2. TRANSIENT MAP STATE (Map Instance)
      ├── Posição exata de monstros em combate
      ├── Projéteis e efeitos visuais
      ├── Partículas e timers de hitstop
      └── Instâncias temporárias de combate
```

### 2. Sincronização na Troca de Cenas
* Ao entrar em uma cena, o mapa consulta o `WorldState` para restaurar o estado de objetos interativos (ex: baú já aberto não permite novo loot).
* Ao sair da cena, apenas flags permanentes são enviadas ao `SaveManager`.
