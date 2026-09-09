# PLAYER DATA ARCHITECTURE
## HUNTER ONLINE — MODEL / CONTROLLER / VIEW SEPARATION

### 1. Separação Estrita de Responsabilidades
O nó visual e físico do jogador (`entities/Player/Player.tscn`) **NÃO É A FONTE DA VERDADE DOS DADOS**. A arquitetura separa explicitamente:

```text
┌─────────────────────────────────────────────────────────────┐
│                        MODEL (Dados)                        │
│ PlayerData (Autoload)                                       │
│ - character_id, nome, afinidade natal                       │
│ - Atributos básicos (vida, vida_max, forca, defesa, vel)    │
│ - Nen stats (nivel_nen, xp_nen, skill_points)               │
│ - Inventário, Jenny, Licença Hunter, Estatísticas           │
└──────────────────────────────┬──────────────────────────────┘
                               │ (Notifica alterações)
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                    CONTROLLER (Lógica)                      │
│ Player.gd + CombatSystem.gd + NenSystem.gd                  │
│ - Movimentação física (velocity, move_and_slide)            │
│ - Input handling (WASD, J, K, Q, Shift)                     │
│ - Animações (AnimationTree StateMachine)                    │
│ - Fórmulas de mitigação de dano                             │
└──────────────────────────────┬──────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                      VIEW (Apresentação)                    │
│ PlayerHUD + StatusMenu + Sprite2D / Shader                  │
│ - Barras visuais de HP e Aura                               │
│ - Ícones de condições ativas (ConditionTrackerUI)           │
│ - Floating Combat Text (DamageNumberSystem)                 │
└─────────────────────────────────────────────────────────────┘
```

### 2. Regra de Ouro da Persistência
* O Player pode ser instanciado, destruído e recriado em qualquer mapa ou cena sem perda de nenhum dado de progressão, pois o `PlayerData` sobrevive de forma autônoma na memória do autoload e no disco.
