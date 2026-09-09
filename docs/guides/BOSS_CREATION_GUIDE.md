# GUIA DE CRIAÇÃO DE CHEFES — BOSS CREATION GUIDE

> **Manual de Criação Declarativa de Chefes, Transição de Fases e Balanceamento no Hunter MMORPG**
> **Versão:** 1.0 (Fase L) | **Engine:** Godot 4.6 Stable

---

## 1. ESTRUTURA DECLARATIVA DE CHEFE (BossDefinition)

Novos chefes e chefes de clímax são construídos utilizando o recurso BossDefinition (es://resource/boss/BossDefinition.gd) e consumidos automaticamente pelo EnemySystem através de setup_from_boss_definition(boss_def).

### 1.1 Exemplo de Construção em GDScript:
`gdscript
var boss := BossDefinition.new(
    & gorila_rei_nen,
    Gorila Rei de Nen,
    Guardião Ancestral da Selva,
    Um primata gigante que despertou Nen naturalmente nas ruínas antigas.
)

boss.base_stats = {
    max_health: 25000,
    damage: 350,
    defense: 175,
    move_speed: 95.0,
    nen_defense: 120,
    knockback_resistance: 0.95,
    hit_invulnerability_time: 0.15,
    xp_reward: 8000,
    gold_reward: 20000
}

# Fases do Chefe (BossPhaseData)
var fase2 := BossPhaseData.new(
    2,
    Fúria Primitiva,
    0.50, # Ativa em 50% de HP
    Aura vermelha envolve o Gorila Rei aumentando sua velocidade e agressividade.
)
boss.phases.append(fase2)

# Tabela de Recompensas (Loot Table)
boss.loot_table = [
    {item_id: pele_gorila_nen, chance: 1.0, min: 2, max: 4},
    {item_id: nucleo_aura_primordial, chance: 0.35, min: 1, max: 1}
]

# Banner de Introdução
boss.intro_banner_theme = {
    title_color: Color(1.0, 0.2, 0.2, 1.0),
    subtitle: Calamidade das Ruínas
}
`

---

## 2. APLICAÇÃO NO EnemySystem

Ao instanciar a entidade do chefe na arena:
`gdscript
var enemy_sys: EnemySystem = boss_node.get_node(EnemySystem)
enemy_sys.setup_from_boss_definition(boss_def)
`
O método setup_from_boss_definition:
1. Configura atributos base (max_health, defense, orca, elocidade).
2. Seta is_boss = true e preenche loot_table.
3. Inicia na fase 1 e registra os limites percentuais de HP para disparo de transição de fases.

---

## 3. O QUE ESTÁ IMPLEMENTADO

* **BossDefinition Declarativo:** Elimina hardcode de atributos e regras de chefes em scripts GDScript individuais.
* **Transição de Fases por Limiar de HP:** Compatível com BossPhaseData e disparos visuais via BossIntroBanner.
* **Escala de Ameaça Cooperativa (coop_threat_multiplier):** Multiplica HP e tenacidade proporcionalmente ao tamanho do grupo co-op.
* **Validador de Integridade:** O ContentValidator.validate_boss() certifica que HP > 0 e que chances de loot estejam entre 0.01 e 1.0.

---

## 4. O QUE ESTÁ PLANEJADO

1. **Hatsus de Chefes Associados Automaticamente:** Injeção direta de HatsuData no pool de ataques especiais da IA do chefe sem intervenção manual na cena.
2. **Mecânicas de Enrage por Tempo:** Temporizador de combate que dobra o dano do chefe caso o grupo demore mais do que o tempo limite da raid.
3. **Arenas Dinâmicas Destrutíveis:** Pilares e plataformas que quebram com ataques de área do chefe durante a fase 2 ou 3.

---

## 5. O QUE É FUTURO

1. **Bosses Procedurais com Afixos (Rifts / Mapas Infinitos):** Chefes com combinações aleatórias de elementos e juramentos de Nen.
2. **IA de Adaptação Tática:** Chefe alternando entre foco em alvos de longo alcance ou tanques com base na análise de dano recebido em tempo real.
