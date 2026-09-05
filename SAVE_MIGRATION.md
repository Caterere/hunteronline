# MIGRAÇÃO DE SAVES E COMPATIBILIDADE — SAVE MIGRATION

> **Arquitetura de Preservação de Dados, Retrocompatibilidade e Migração Automática para o Schema v2.4**
> **Versão:** 1.0 (Fase L) | **Engine:** Godot 4.6 Stable

---

## 1. HISTÓRICO DE SCHEMAS DE SAVE DO PROJETO

* **Schema v2.0 (Fase G):** Estrutura inicial com PlayerData, inventário básico, level e gold.
* **Schema v2.1 (Fase H):** Adicionado suporte a world_state, flags de mapa e time.
* **Schema v2.2 (Fase I):** Adicionado suporte a progressão de Nível 1000, 4 slots de Hatsu, títulos e conquistas de endgame.
* **Schema v2.3 (Fase K):** Adicionado suporte a multiplayer, estatísticas co-op e histórico de sessões.
* **Schema v2.4 (Fase L - ATUAL):** Adicionado suporte a collections (Códex), 
pc_memories (Memória de NPCs), live_events (Eventos ao vivo) e unlocked_routes (Rotas de viagem inter-regionais).

---

## 2. REGRAS ABSOLUTAS DE MIGRAÇÃO

1. **Zero Data Loss (Perda Zero de Dados):** Nenhum atributo, item de inventário, nível, XP ou gold do jogador é resetado ou alterado durante a migração.
2. **Execução Automática e Silenciosa:** A migração ocorre na função de desserialização antes do PlayerData ser populado.
3. **Idempotência:** Migrar um save que já está na versão 2.4 resulta em um save inalterado.
4. **Atualização Atômica de Arquivo:** Ao salvar novamente o jogo, o novo schema v2.4 é gravado no disco com backup do arquivo anterior.

---

## 3. IMPLEMENTAÇÃO DO MOTOR DE MIGRAÇÃO (ContentVersionConfig)

Localizado em es://scripts/core/ContentVersionConfig.gd:
`gdscript
static func migrate_save_data(save_data: Dictionary) -> Dictionary:
    var version = str(save_data.get( version, 2.0))
    
    # Migração progressiva incremental
    if version == 2.0 or version == 2.1 or version == 2.2 or version == 2.3:
        print([SaveMigration] 🔄 Iniciando migração de Save Schema: v%s -> v2.4 % version)
        
        # Injeção de novas chaves com valores padrão seguros
        if not save_data.has(collections):
            save_data[collections] = {}
        if not save_data.has(npc_memories):
            save_data[npc_memories] = {}
        if not save_data.has(live_events):
            save_data[live_events] = {completed_events: [], active_events: []}
        if not save_data.has(unlocked_routes):
            save_data[unlocked_routes] = []
            
        save_data[version] = SAVE_VERSION # 2.4
        print([SaveMigration] ✅ Migração para v2.4 concluída com sucesso sem perda de dados!)

    return save_data
`

---

## 4. O QUE ESTÁ IMPLEMENTADO

* **Migração Automática no SaveManager.gd:** Saves com versão <= 2.3 chamam ContentVersionConfig.migrate_save_data() antes de distribuir os dados para os autoloads.
* **Preservação de Todas as Chaves Legadas:** Nível, atributos, Nen, Hatsu, quests, equipamentos, gold e posições de mapa são 100% preservados.
* **Testes Automatizados de Regressão:** Validação em suíte de teste garantindo integridade de saves simulados de versões anteriores.

---

## 5. O QUE ESTÁ PLANEJADO

1. **Sistema de Backup Rotativo (.bak):** Armazenamento dos últimos 3 saves antes de cada migração em diretório seguro user://backups/.
2. **Checksum SHA-256 de Validação:** Verificação de hash criptográfico no cabeçalho do save para detectar corrupção de disco.
3. **Migrador de Inventário para Itens Obsoletos:** Tabela de substituição automática para itens renomeados ou descontinuados entre atualizações.

---

## 6. O QUE É FUTURO

1. **Cloud Save com Resolução de Conflitos:** Sincronização entre múltiplos dispositivos com detecção de timestamp mais recente e opção de seleção manual de slot conflitante.
