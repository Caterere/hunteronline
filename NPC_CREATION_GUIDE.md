# GUIA DE CRIAÇÃO DE NPCS E ARCOS NARRATIVOS — NPC CREATION GUIDE

> **Manual de Criação de NPCs, Memória Episódica e Arcos Pessoais no Hunter MMORPG**
> **Versão:** 1.0 (Fase L) | **Engine:** Godot 4.6 Stable

---

## 1. MEMÓRIA EPISÓDICA (NPCMemorySystem)

Ao contrário de diálogos estáticos baseados apenas em flags binárias de quest, o Hunter MMORPG utiliza o NPCMemorySystem (es://scripts/systems/npc/NPCMemorySystem.gd) para registrar a história pessoal do jogador com cada NPC.

### 1.1 Gravando e Consultando Memórias:
`gdscript
# Registrar um evento com metadados opcionais
NPCMemorySystem.record_event( guia_moro, ajudou_no_acampamento, {recompensa: pocao})

# Verificar se a memória existe
if NPCMemorySystem.has_memory(guia_moro, ajudou_no_acampamento):
    print(Moro lembra que você o ajudou!)

# Consultar frequência do evento
var repeticoes = NPCMemorySystem.get_memory_count(guia_moro, falou_sobre_reliquia)
`

---

## 2. ARCOS DE HISTÓRIA DE NPCS (NPCStoryArc)

Personagens centrais e secundários relevantes possuem arcos narrativos com múltiplos estágios modelados em NPCStoryArc (es://scripts/systems/npc/NPCStoryArc.gd).

### 2.1 Exemplo de Construção em GDScript:
`gdscript
var arco := NPCStoryArc.new(
    &arco_kane_redencao, 
    kane, 
    O Passado Sombrio de Kane, 
    Kane busca expiar sua traição passada.
)

arco.stages = [
    {
        stage: 1,
        title: Primeiro Contato no Posto,
        required_memory: ajudou_com_remedios,
        next_encounter_scene: res://world/maps/posto_avancado.tscn
    },
    {
        stage: 2,
        title: O Teste de Lealdade,
        required_memory: venceu_duelo,
        consequences: [
            {type: reputation, faction: sociedade_expedicao, value: 150}
        ]
    }
]

# Avanço de Estágio com Validação de Memória
if arco.can_advance_stage(NPCMemorySystem):
    arco.advance_stage()
`

---

## 3. O QUE ESTÁ IMPLEMENTADO

* **NPCMemorySystem Autoload:** Armazena memórias por ID de NPC com persistência total no save (Schema v2.4).
* **Frequência e Timestamps:** Cada memória registra a quantidade de ocorrências e momento do registro.
* **NPCStoryArc:** Gerencia progressão de estágios sequenciais com base em eventos e memórias.
* **Integração com StoryGatingEvaluator:** Permite bloquear missões até que um NPC tenha desenvolvido relação prévia com o caçador.

---

## 4. O QUE ESTÁ PLANEJADO

1. **Diálogos Ramificados Dinâmicos:** Caixas de diálogo adaptando falas e saudações conforme o nível de amizade ou ressentimento registrado no NPCMemorySystem.
2. **Rotinas Diárias com Base no Tempo (Day/Night Schedule):** NPCs transitando entre postos de dia e tavernas à noite com base no TimeManager.
3. **NPCs Acompanhantes Temporários (Companion NPCs):** NPCs que lutam ao lado do jogador em capítulos específicos de seus arcos.

---

## 5. O QUE É FUTURO

1. **Memória Cruzada entre NPCs (Fofocas e Rede Social):** O NPC A reagindo a uma traição cometida pelo jogador contra o NPC B através do RumorSystem.
2. **Decisões Irreversíveis de NPCs:** Mortes canônicas ou partidas definitivas de NPCs importantes dependendo do desfecho do arco.
