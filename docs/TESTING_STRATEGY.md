# TESTING STRATEGY & QA MATRIX
## HUNTER ONLINE — AUTOMATED REGRESSION & VERIFICATION PIPELINE

### 1. Metodologia de Testes
O projeto utiliza um pipeline de testes automatizados headless executado diretamente no console oficial do Godot 4.4:
```powershell
& "Godot_v4.4-stable_win64_console.exe" --headless res://scratch/test_master_rebuild_suite.tscn
```

### 2. Matriz de Cobertura Obrigatória
1. **Save / Load Persistence Cycle:**
   - Criação de novo personagem -> Save atômico -> Reset total de memória -> Carregamento de save -> Validação de 100% dos atributos, nós da árvore, SP e histórico de missões.
2. **Story Mode & Anti-Bypass Gates:**
   - Validação de que portais impedem travessia para mapas futuros sem cumprir os requisitos de `StoryGate`.
   - Validação de que ao concluir todas as etapas do arco o portal é desbloqueado e exibe o diálogo de vitória.
3. **Spawn & Respawn Lifecycle:**
   - Morte de monstro de mundo livre dispara timer de respawn e recria a entidade na posição correta.
   - Monstros de missão são devidamente limpos sem deixar nós fantasmas na árvore.
4. **Tutorial & NPC Dialogue Flow:**
   - Interação com Elena em todas as 8 etapas sem ocorrência de loop ou deadlock.
   - Conversa com Mestre Wing no 200º Andar da Arena Celestial e conclusão do Teste da Água (`teste_agua_wing`).
   - Forja de Hatsu com Biscuit Krueger durante a saga de Greed Island.
5. **Combate, Nen & Damage Numbers:**
   - Disparo de ataques físicos, acertos críticos, esquiva e mitigação de Ten gerando Floating Combat Text sem erros de runtime.
