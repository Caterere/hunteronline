# GAMEPLAY ALIGNMENT FINAL REPORT
## HUNTER ONLINE — DEFINITIVE NEN, COMBAT, STORY & WORLD AUDIT

---

| SYSTEM | CURRENT STATE | DESIRED STATE | GAP | SEVERITY | ACTION | RESULT |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Nen Architecture** | Nen tratado anteriormente como 100% passivo sem botões de ativação | Divisão canônica: 5 Passivos (Ten, Ren, Shu, Ko, Ryu) + 3 Ativos Especiais (Zetsu, En, Gyo) | Faltavam controladores dedicados para Ativos com toggles e cálculo de stealth/intimidação | P0 (Crítico) | Criar `PassiveNenController` e `ActiveNenController` integrados ao `NenSystem` | **ALIGNED** ✅ |
| **Input Architecture** | Apenas teclas básicas no project.godot | `nen_zetsu`, `nen_en`, `nen_gyo` e `basic_attack` mapeados oficialmente no InputMap | Ações de input não estavam no `project.godot` | P1 (Alto) | Registrar ações no `project.godot` e usar `event.is_action_pressed` | **ALIGNED** ✅ |
| **Zetsu System** | Regeneração passiva simples de aura | Mecânica ativa de Stealth real via toggle: reduz o raio de detecção de inimigos de acordo com a maestria | Inimigos não usavam fórmula real de stealth baseada nos nós de Zetsu | P0 (Crítico) | Implementar fórmula de raio efetivo em `EnemyAI.gd` e toggle em `ActiveNenController` | **ALIGNED** ✅ |
| **En System** | Ausência de cúpula ativa | Mecânica ativa de Detecção Espacial + Intimidação (redução de defesa em inimigos na cúpula) | En não possuía cúpula ativa nem debuff de inimigos | P0 (Crítico) | Criar pulso de Intimidação e raio escalonado via Skill Tree | **ALIGNED** ✅ |
| **Gyo System** | Flag binária de visibilidade | Sistema ativo de Percepção Multi-Tier (Tiers 1 a 5 de segredos, pistas e baús) | Pistas eram apenas binárias, sem tiers de percepção | P1 (Alto) | Atualizar `GyoInspectable.gd` com `nivel_gyo_minimo` e consulta a maestria | **ALIGNED** ✅ |
| **Active Conflict Matrix** | Inexistente | Regras estritas: Zetsu desliga En e Gyo; En e Gyo coexistem | Não havia checagem de exclusão mútua | P1 (Alto) | Implementar matriz de resolução de conflitos em `ActiveNenController` | **ALIGNED** ✅ |
| **Combat Pillars** | Ataque básico e Hatsu misturados conceitualmente | Dois pilares estritos: Ataque Básico confiável + Hatsu 1 a 4. Nen ativo NÃO ocupa slots de Hatsu | Zetsu/En/Gyo precisam estar totalmente fora dos 4 slots de Hatsu | P0 (Crítico) | Documentar e isolar os slots de Hatsu em `CombatEngine` e `HatsuSystem` | **ALIGNED** ✅ |
| **Skill Tree** | Faltavam nós de En e nós de Zetsu com stealth real | Nós para os 5 passivos e os 3 ativos com impacto real no gameplay | Categoria En não existia no enum da árvore | P0 (Crítico) | Adicionar `Categoria.EN` e nós de Zetsu, En e Gyo com modificadores reais | **ALIGNED** ✅ |
| **Story & Hub World** | Lobby já redirecionava save | Lobby persistente como Hub World jogável com Story Gateway NPC e checkpoints formais | Alinhado | P2 (Médio) | Preservar e validar na suíte de testes | **ALIGNED** ✅ |
| **Save & Persistence** | Persistência atômica funcional | Salva maestria de Zetsu, En, Gyo, Skill Tree, Checkpoints e Reputação de Facções | Alinhado | P1 (Alto) | Validar integridade e restauração no roundtrip | **ALIGNED** ✅ |
