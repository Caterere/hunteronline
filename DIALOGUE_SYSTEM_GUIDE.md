# SISTEMA DE DIÁLOGO COM RAMIFICAÇÕES

## 📋 Estrutura

### 1. **DialogueBranch** (`scripts/dialogue/DialogueBranch.gd`)
- Representa uma escolha/opção do jogador
- Propriedades:
  - `choice_text`: Texto da opção (ex: "Sim, quero aprender")
  - `next_node_id`: Para qual nó ir após escolher
  - `has_condition`: Se tem pré-requisitos
  - `condition_type`: Tipo ("level", "nen_level", "quest_completed")
  - `condition_value`: Valor para verificar
  - `unlock_technique`: Técnica de Nen a desbloquear
  - `start_quest`: Quest a iniciar
  - `reward_xp`: XP ao escolher

### 2. **DialogueNode** (`scripts/dialogue/DialogueNode.gd`)
- Um ponto no diálogo
- Propriedades:
  - `node_id`: ID único (ex: &"wing_start")
  - `speaker_name`: Quem fala
  - `dialogue_text`: O que dizer
  - `branches`: Array de DialogueBranch (escolhas)
  - `auto_end`: Encerrar após mostrar
  - `unlock_technique_on_enter`: Desbloquear ao entrar neste nó
  - `start_quest_on_enter`: Iniciar quest ao entrar

### 3. **DialogueTree** (`scripts/dialogue/DialogueTree.gd`)
- Árvore completa de diálogo
- Propriedades:
  - `tree_id`: ID da árvore (ex: &"wing_dialogue")
  - `npc_name`: Nome do NPC
  - `npc_id`: ID do NPC
  - `nodes`: Dicionário de DialogueNodes
  - `root_node_id`: Nó inicial

### 4. **DialogueSystem** (`scripts/dialogue/DialogueSystem.gd`)
- Gerencia o fluxo de diálogo
- Métodos:
  - `start_dialogue(tree: DialogueTree)`: Iniciar diálogo
  - `choose_branch(branch: DialogueBranch)`: Jogador faz escolha
  - `_show_node(node: DialogueNode)`: Mostrar nó
  - `_end_dialogue()`: Finalizar

### 5. **DialogueBox** (`ui/dialogue/DialogueBox.gd`)
- UI que mostra diálogos e escolhas
- Métodos:
  - `show_dialogue(speaker, text)`: Mostrar fala
  - `show_choices(branches)`: Mostrar botões de escolha

---

## 🎮 Como Usar

### Criar uma Árvore de Diálogo

1. Criar um recurso `.tres` do tipo `DialogueTree`
2. Preencher:
   - `tree_id`: ID único
   - `npc_name`: Nome do NPC
   - `npc_id`: ID do NPC
   - `root_node_id`: Qual nó começa

3. Criar `DialogueNodes` (cada um é um recurso `DialogueNode`)
   - `node_id`: ID único
   - `speaker_name`: Quem fala
   - `dialogue_text`: Fala
   - `branches`: Adicionar ramificações (DialogueBranch)

4. Criar `DialogueBranches` (cada ramificação é um `DialogueBranch`)
   - `choice_text`: Opção do jogador
   - `next_node_id`: Para qual nó ir

### Conectar ao NPC

```gdscript
# No script do NPC (ex: Wing.gd)
@export var dialogue_tree: DialogueTree

func _on_interacted(_player: CharacterBody2D) -> void:
    if dialogue_tree != null:
        var dialogue_system = get_tree().get_first_node_in_group("dialogue_system")
        if dialogue_system != null:
            dialogue_system.start_dialogue(dialogue_tree)
```

---

## 🔓 Desbloquear Técnicas

### Via Diálogo

Na `DialogueBranch`:
- `unlock_technique`: Técnica a desbloquear (ex: &"ten")

Ou no `DialogueNode`:
- `unlock_technique_on_enter`: Desbloquear ao entrar neste nó

### Via Código

```gdscript
var nen_system = player.get_node("NenSystem")
nen_system.desbloquear_tecnica(&"ten")

# Verificar se está desbloqueada
if nen_system.esta_desbloqueada(&"ten"):
    print("TEN está disponível!")
```

---

## 📜 Quests em Diálogos

Na `DialogueBranch`:
```
start_quest: [Referência para a Quest]
```

Quando jogador escolhe essa opção, a quest inicia automaticamente.

---

## ⚡ Exemplo: Árvore Wing

Veja `data/dialogues/wing_dialogue_tree.tres` para exemplo completo:

```
wing_start (Boas-vindas)
├─ [Opção: Sim] → desbloqueia TEN → wing_teach
│                                    └─ [Continuar] → wing_final
└─ [Opção: Não] → fim do diálogo
```

---

## 🎯 Próximos NPCs

### Biscuit (Trainer de Nen)

Criar árvore com 8 nós (um para cada técnica):

```
biscuit_menu (Qual técnica treinar?)
├─ [TEN] → desbloqueia TEN → quest "Domine TEN"
├─ [REN] → desbloqueia REN → quest "Domine REN"
├─ [GYO] → desbloqueia GYO → quest "Domine GYO"
├─ [KO]  → desbloqueia KO  → quest "Domine KO"
├─ [ZETSU] → desbloqueia ZETSU → quest
├─ [SHU] → desbloqueia SHU → quest
├─ [EN] → desbloqueia EN → quest
└─ [RYU] → desbloqueia RYU → quest
```

---

## 🔧 Condições

Cada `DialogueBranch` pode ter condições:

- `has_condition`: true
- `condition_type`: "level" | "nen_level" | "quest_completed"
- `condition_value`: valor para comparar

Exemplo:
- Só mostrar opção se jogador tiver Nen Lv.2
  - `condition_type`: "nen_level"
  - `condition_value`: 2

---

## 📝 Notas

- DialogueBox está no grupo "dialogue_box"
- DialogueSystem está no grupo "dialogue_system"
- Ambos são encontrados automaticamente
- Diálogos podem iniciar/desbloquear quests e técnicas
- Sistema pronto para expansão (más escolhas, recordação de diálogos, etc.)
