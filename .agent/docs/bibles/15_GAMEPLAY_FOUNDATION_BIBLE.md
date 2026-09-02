# Bible da Base de Gameplay

## Objetivo

Fornecer condições, tags e modificadores reutilizáveis para expressar regras de gameplay sem IDs de Hatsu fixos, lógica de combate duplicada ou cópias privadas de estado.

## Responsabilidades

### GameplayTags

Normaliza rótulos e responde consultas de tags. Não determina resultados de combate nem mantém um registro fechado. As tags continuam sendo strings extensíveis em `snake_case`, como `projectile`, `offensive`, `long_range`, `single_target`, `weapon` e `aura`.

### GameplayCondition

Armazena uma exigência declarativa e avalia um dicionário de contexto. Não consulta nós da cena, altera estado nem emite UI. O contexto pode incluir `player_hp_percent`, `seconds_since_damage`, `target_marked`, `nearby_enemy_count`, `target_hp_percent`, `player_in_en`, `player_stealth`, `active_hatsu_ids`, `unlocked_skill_ids`, `target_states`, `target_weak_point_revealed` e `hatsu_tags`.

`evaluate()` retorna `{ met, type, actual }`; o sistema consumidor decide o efeito, feedback e transição de estado.

### StatModifier

`StatModifier` é a única representação de modificadores usada pelo `PlayerData`. Sistemas de funcionalidade criam a instância e informam sua origem; `PlayerData` recalcula os atributos.

## Integrações atuais

`HatsuData` persiste tags normalizadas e suas `gameplay_conditions` opcionais. Na ativação, combina os contextos do jogador e do alvo e recusa o uso quando uma condição não é atendida. `NenSkillTree` cria `StatModifier` diretamente.

## Regras de expansão

Adicione um tipo de condição somente quando ele puder ser reutilizado por mais de um domínio. Consultas de mundo, seleção de alvo, temporizadores e efeitos permanecem no sistema dono; o resultado é passado no contexto. Skill Tree, inimigos, bosses, quests, eventos e HUD devem consumir essas interfaces.

## Validação

Teste normalização/consulta de tags, casos verdadeiro e falso de cada condição, round-trip de serialização do Hatsu, recusa de ativação e aplicação/remoção de modificadores da Skill Tree. Teste save/load quando campos persistentes mudarem.
