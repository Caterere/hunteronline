# TECHNICAL ARCHITECTURE BIBLE
## HUNTER ONLINE — ENGINE STANDARDS, PATTERNS & CODE GOVERNANCE

---

## 1. PRINCÍPIOS FUNDAMENTAIS DE ENGENHARIA

1. **Single Source of Truth (SSOT):** Cada dado do jogo possui um único dono com autoridade de escrita (`PlayerData` para atributos/progresso, `StoryManager` para sagas/checkpoints, `ReputationSystem` para facções). Nenhum outro nó pode alterar variáveis diretamente por atribuição cega.
2. **Desacoplamento via EventBus:** Módulos de interface, áudio, câmera e telemetria escutam sinais tipados no barramento global `EventBus`, nunca segurando referências diretas a nós específicos de cenas voláteis.
3. **Persistência Atômica & Segura:** Salvamentos gravam arquivos temporários (`.tmp`) antes de renomear para o arquivo final, prevenindo corrupção de save caso o jogo seja interrompido.
4. **Sem Hardcode de Teclas:** Todo controle de gameplay utiliza ações do `InputMap` (`basic_attack`, `nen_zetsu`, `nen_en`, `nen_gyo`, `hatsu_slot_1..4`).
5. **Prevenção de Fugas de Memória (Memory Leaks):** Conexões de sinais entre nós temporários devem ser desconectadas no `queue_free()` ou gerenciadas com `Callable.CONNECT_ONE_SHOT` onde aplicável.

---

## 2. MAPEAMENTO DE AUTORIDADES

| Domínio | Classe / Autoload Autoritativo | Responsabilidade |
| :--- | :--- | :--- |
| **Atributos & Build** | `PlayerData` | Vida, Aura, Nível, XP, Modificadores e nós da Skill Tree. |
| **História & Checkpoints**| `StoryManager` | Sagas, Capítulos, Flags de lore, catálogo de checkpoints e transições. |
| **Combate & Cálculos** | `CombatEngine` | Fórmulas de dano, mitigação de Ten, fraquezas, hit stop e quebra de Zetsu. |
| **Percepção & Sentidos** | `PerceptionSystem` | Raio de detecção de monstros, stealth de Zetsu, cúpula de En e visibilidade de Gyo. |
| **Técnicas de Nen** | `NenSystem` | Delegação para `PassiveNenController` e `ActiveNenController`, controle de aura. |
| **Habilidades de Hatsu**| `HatsuSystem` | Slots 1 a 4, custos de aura, recargas e execução de efeitos. |
| **Economia & Facções** | `ReputationSystem` | Reputação nas 6 facções, bônus e descontos em comércio. |
| **Persistência de Dados**| `SaveManager` | Serialização e desserialização completa de slots em JSON com versionamento. |
