# CHANGELOG — HUNTER ONLINE

## [v2.2.0] - Sistema Completo de Hatsu Mastery, Archive (12 Slots) & Economia de Criação

### Adicionado
- **Hatsu Mastery Escalonada (Nível 0 a 100)**:
  - Hatsu recém-criado nasce em estado imperfeito (30% do poder base).
  - Uso real em combate e treinamento eleva a Maestria até 100.
  - No nível 100 atinge: 100% do poder base, -20% de custo de Nen, -20% de tempo de recarga, +20% de alcance efetivo.
  - Status de ápice canônico `★ MASTERED` ao atingir nível 100.
- **Hatsu Archive Dedicado (Capacidade de 12 Slots)**:
  - Repositório central (`MAX_ARCHIVE_SLOTS = 12`) desacoplado dos 4 slots ativos de combate.
  - A Maestria e XP acumulados pertencem permanentemente à instância da habilidade.
  - Suporte completo a desequipar, reequipar e excluir do Archive (com trava de segurança para habilidades equipadas).
- **Economia e Cooldowns Anti-Abuso**:
  - Custo de 5.000 Jenny por criação de Hatsu com dedução atômica via `Economy.remover_gold()`.
  - Cooldown de 30 minutos (`1800.0s`) para criar novos Hatsus, persistido via timestamp Unix.
  - Cooldown de troca de 10 minutos (`600.0s`) ao equipar habilidades em slots ativos.
- **Proteção Anti-Farm e Multiplicadores de Inimigo**:
  - Ganho total (100%) contra mobs até 10 níveis abaixo do jogador.
  - Penalidade gradual entre 11 e 29 níveis abaixo.
  - Zero absoluto de XP (0%) contra inimigos 30 ou mais níveis abaixo.
  - Multiplicadores de perigo: Inimigos Elite concedem $1.5\times$ XP e Chefes concedem $2.5\times$ XP de Maestria.
- **Configuração Centralizada (`HatsuConfig.gd`)**:
  - Arquivo único de configuração contendo todos os valores de design marcados como balanceáveis.
- **UI de Hatsu & HUD Revitalizadas**:
  - `HatsuEquipUI`: Grade 3x4 do Archive de 12 slots, visualização de status dos 4 slots ativos, painel de inspeção de Maestria com barra de progresso, percentuais em tempo real, cronômetro de cooldown e botões contextuais.
  - `HatsuCreationUI`: Validação atômica de custo, cooldown e limite de slots do Archive com mensagens claras ao jogador.
  - `PlayerHUD` & `HunterMenuUI`: Exibição de badge `★` para habilidades dominadas.
- **Persistência Schema V3 & Migração Transparente**:
  - `SaveManager` salva `hatsu_system_version: 3`, serializando arquivo completo, timestamps e estados dos slots.
  - Migração retrocompatível automática de saves V1 e V2.
- **Suíte de Testes Automatizada Completa**:
  - Testes cobrindo 19 cenários exaustivos com 100% de sucesso.

## [v2.1.0] - Sistema Canônico de Hatsu Slots & Progressão Narrativa

### Adicionado
- **Hatsu Slots como Evolução Espiritual Narrativa**:
  - Personagem inicia sem nenhum Hatsu disponível ou equipado.
  - **Slot 1**: Conclusão da Saga de Greed Island (Arco 5) + Treino com Mestra Biscuit Krueger.
  - **Slot 2**: Slot 1 desbloqueado E Nível $\ge$ 600.
  - **Slot 3**: Slot 2 desbloqueado E Nível $\ge$ 800.
  - **Slot 4**: Slot 3 desbloqueado E Nível $\ge$ 1000 (Domínio Máximo dos 4 Slots).
- **Autoridade Central (`HatsuProgressionManager.gd` e `HatsuSlotData.gd`)**:
  - Single Source of Truth para consulta de requisitos, diagnóstico de pendências, desbloqueio e persistência.
  - Método `can_unlock_slot(slot_id)` retornando diagnósticos detalhados (`"OK"`, `"PREVIOUS_SLOT_LOCKED"`, `"REQUIRED_LEVEL"`, `"STORY_NOT_COMPLETED"`).
  - Método `revalidate_all_slots()` para sanitização e expurgo de slots ilegais no carregamento de saves.
  - Sinal `hatsu_slot_desbloqueado(slot_id)` e toast com banner estilizado.
- **Proteção Estrita Anti-Bypass em Toda a Codebase**:
  - Bloqueio completo na criação, forja, menus, atalhos (`[H]`, `[TAB]`), equipamento e disparo de combate se o slot não estiver desbloqueado.
  - Nível isolado NUNCA desbloqueia slots posteriores se a cadeia prévia não foi satisfeita.
  - Suporte irrestrito a níveis além de 1000 (1001, 1100, 1500, 2000+) sem tetos artificiais.
  - Estrutura modular data-driven preparada para futuros slots (Slot 5, 6...).
- **UI Progressiva com Diagnóstico de Requisitos**:
  - Em `HatsuEquipUI` e `HunterMenuUI`: Slots exibem estados explícitos (`LOCKED`, `UNLOCKED`, `EQUIPPED`).
  - Slots bloqueados exibem botão para inspecionar requisitos (slot prévio, nível atual vs exigido, saga).
  - Botões de equipamento desabilitados para slots bloqueados.
  - `PlayerHUD` exibe ícones de cadeado e estilo atenuado em slots travados.

## [v2.0.0] - Rework Profundo da Skill Tree & Progressão Level 1000

### Adicionado
- **Constelação de Habilidades (400+ Nós)**:
  - Criada a arquitetura data-driven `SkillTreeNodeData` e o catálogo central `SkillTreeDatabase` com mais de 400 nós organizados radialmente em 10 regiões temáticas:
    1. **Fortaleza Corpórea (Body)**: HP Máx, Defesa, Mitigação de Dano, Armadura Biológica.
    2. **Arte Marcial (Warrior)**: Dano Básico, Cadência, Combos, Força.
    3. **Fundamentos do Nen (Nen)**: Shingen-ryu (Ten, Ren, Zetsu, Gyo, Ko, Shu, Ryu).
    4. **Canalização de Hatsu (Hatsu)**: Dano de Hatsu, Cooldown Reduction (CDR), Custo, Área.
    5. **Mobilidade Fantasma (Speed)**: Velocidade de Movimento, Evasão, Esquiva.
    6. **Instinto Predatório & Crítico (Critical)**: Chance Crítica, Dano Crítico, Execução.
    7. **Sustentação Vital (Vitality)**: Regeneração de HP, Life Steal, Cura Recebida.
    8. **Reservatório Espiritual (Aura)**: Aura Máxima, Taxa de Regeneração de Aura.
    9. **Divergência de Especialização (Specialization)**: Keystones de regras alteradas e tradeoffs.
    10. **Círculo dos Mestres (Master)**: Ápice endgame no Level 1000+, conectando todas as disciplinas.
- **Hierarquia de 4 Patamares de Nós**: Small Nodes (1 rank), Medium Nodes (1–3 ranks), Major Nodes (especializações de 8–18%) e Keystones (mudança de regras de combate com tradeoffs).
- **Interface Estilo Mapa de ARPG (`NenSkillTreeUI`)**:
  - Navegação fluida com clique e arraste (Pan) e zoom contínuo no cursor (0.25x a 2.2x).
  - Culling de Viewport no `_draw()` garantindo 60+ FPS mesmo com centenas de nós e linhas.
  - Busca em tempo real por nome, stat ou tag (ex: "crit", "lifesteal", "defesa").
  - Dropdown com navegação instantânea para o centro de cada região.
  - Botões para centralizar no Nexus Inicial (0,0) ou no nó mais avançado do personagem.
  - Alternância para Modo Tela Cheia Imersiva.
  - Inspetor lateral com alocação e Tooltip flutuante instantâneo.
  - Botão de Reset da Árvore com confirmação modal.
- **Novos Atributos na Pipeline de Combate**:
  - Suporte completo a `crit_chance` (5% base), `crit_damage` (150% base), `life_steal`, `reducao_dano`, `esquiva`, `bloqueio`, `regen_hp`, `regen_aura`, `eficiencia_aura`, `reducao_custo_aura`.
  - Mecânica de Acerto Crítico e Drenagem Vital (Life Steal) no `CombatEngine`.
- **Versionamento e Migração V2 no SaveManager**:
  - Salva `nen_skill_tree_version: 2`, `nen_skill_points`, `nen_skill_tree_progress`, `nen_ryu_caminho`.
  - Migração transparente de saves V1 (preserva os 27 nós legados sem perda de pontos).

### Corrigido
- **Bug do Reset Sem Reembolso**: Corrigido em `NenSkillTree.resetar_arvore()`, que agora contabiliza e devolve 100% dos pontos gastos para `PlayerData.nen_skill_points`.
- **Dedução de Custos de Pontos**: Corrigida dedução em `investir_ponto()` para respeitar `def.custo_pontos` em vez de subtrair fixo `- 1`.
- **Escalonamento de Nós Multi-Rank**: Corrigido `_aplicar_modificadores_do_no()` para multiplicar o valor do bônus pelo rank do nó (`valor * rank`).
- **Clamping de Atributos Secundários**: Corrigido `PlayerData.obter_stat_calculado()` para não forçar `max(1.0, final_val)` em percentuais como `crit_chance`, `life_steal` e `esquiva`.
- **Falta de Camera/Pan/Zoom**: Substituída a UI estática de 440x230 por um mapa de navegação interativo com renderização vetorial de alta performance.
