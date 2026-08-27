# HUNTER X HUNTER MMORPG — AGENTS.md

## 1\. OBJETIVO DO ARQUIVO

Este arquivo contém as regras permanentes para desenvolvimento deste projeto.

O agente deve ler e respeitar este documento antes de modificar qualquer código, cena, sistema ou estrutura do projeto.

O objetivo é desenvolver um MMORPG 2D inspirado em Hunter x Hunter, com foco em:

* combate;
* Nen;
* Hatsu;
* progressão de personagem;
* NPCs;
* quests;
* mundo semiaberto;
* exploração;
* sistemas RPG;
* multiplayer/MMORPG no futuro;
* arquitetura organizada e expansível.

O projeto está sendo desenvolvido em Godot utilizando GDScript.

\---

# 2\. REGRA MAIS IMPORTANTE

## NÃO QUEBRAR O QUE JÁ FUNCIONA.

Antes de modificar qualquer sistema:

1. Ler os arquivos envolvidos.
2. Entender como eles se comunicam.
3. Procurar sistemas existentes que já realizam parte da tarefa.
4. Reutilizar sistemas existentes sempre que possível.
5. Não criar sistemas duplicados.
6. Não substituir uma arquitetura existente sem necessidade.
7. Não apagar funcionalidades existentes.
8. Não modificar arquivos não relacionados sem necessidade.
9. Verificar dependências antes de alterar uma classe.
10. Após implementar, revisar possíveis erros e referências quebradas.

Se existir uma solução já implementada no projeto, ela deve ser utilizada em vez de criar uma segunda solução para o mesmo problema.

\---

# 3\. FILOSOFIA DE DESENVOLVIMENTO

O projeto deve ser desenvolvido de forma incremental.

Não implementar sistemas gigantes quando uma implementação menor e funcional resolve a necessidade atual.

Prioridades:

1. Funcionamento.
2. Arquitetura correta.
3. Compatibilidade com sistemas existentes.
4. Facilidade de expansão.
5. Performance.
6. Organização.
7. Polimento.

Evitar overengineering.

Não criar abstrações complexas sem necessidade real.

Não transformar uma funcionalidade simples em vários sistemas apenas para parecer mais sofisticada.

\---

# 4\. PROCESSO OBRIGATÓRIO ANTES DE CODIFICAR

Para tarefas que envolvam código:

### Etapa 1 — INVESTIGAÇÃO

Antes de editar:

* localizar os arquivos relevantes;
* ler os scripts envolvidos;
* verificar cenas relacionadas;
* verificar sinais;
* verificar grupos;
* verificar autoloads;
* verificar referências entre scripts;
* verificar sistemas que já executam a mesma responsabilidade.

### Etapa 2 — PLANEJAMENTO

Determinar:

* qual sistema deve ser alterado;
* quais arquivos realmente precisam ser modificados;
* quais sistemas dependem dele;
* se a alteração pode quebrar funcionalidades existentes.

### Etapa 3 — IMPLEMENTAÇÃO

Implementar somente o necessário.

### Etapa 4 — REVISÃO

Depois da implementação:

* procurar erros de GDScript;
* procurar referências inexistentes;
* procurar funções chamadas incorretamente;
* verificar tipos;
* verificar sinais;
* verificar nomes de nós;
* verificar caminhos;
* verificar dependências;
* verificar possíveis regressões.

### Etapa 5 — TESTE

Quando possível, executar o projeto ou os testes relevantes.

Se não for possível testar alguma coisa, informar claramente.

Nunca afirmar que algo foi testado quando não foi.

\---

# 5\. GODOT

Engine:

Godot.

Linguagem principal:

GDScript.

Projeto:

MMORPG 2D inspirado em Hunter x Hunter.

A arquitetura deve aproveitar os recursos nativos da Godot quando fizer sentido:

* Node;
* CharacterBody2D;
* Area2D;
* CollisionShape2D;
* signals;
* groups;
* resources;
* scenes;
* autoloads;
* AnimationTree;
* AnimationPlayer;
* UI Controls.

Não criar sistemas paralelos quando a Godot já fornece uma solução apropriada.

\---

# 6\. ARQUITETURA

O projeto deve manter separação de responsabilidades.

Exemplos de responsabilidades:

## Player

Responsável principalmente por:

* movimentação;
* interação;
* controle do personagem;
* execução das ações;
* integração com sistemas de personagem.

## EnemySystem

Responsável por:

* gerenciamento de inimigos;
* dano;
* morte;
* informações relacionadas aos inimigos;
* recompensas relacionadas à morte.

## XPSystem

Responsável por:

* experiência;
* nível;
* XP necessário;
* progressão de nível.

## NenSystem

Responsável por:

* Nen;
* técnicas de Nen;
* níveis das técnicas;
* XP das técnicas;
* estados ativos;
* efeitos das técnicas.

## QuestSystem

Responsável por:

* quests;
* objetivos;
* progresso;
* conclusão;
* recompensas.

## NPC

Responsável por:

* comportamento específico do NPC;
* interação;
* diálogo;
* serviços próprios.

Não colocar toda a lógica do jogo dentro de Player.gd.

\---

# 7\. ESTRUTURA ATUAL DE PERSONAGEM

O personagem possui atributos como:

* vida;
* vida\_max;
* forca;
* defesa;
* velocidade;
* aura;
* aura\_max;
* nivel.

Esses atributos devem ser reutilizados pelos sistemas existentes.

Não criar uma segunda estrutura paralela de atributos sem necessidade.

Se o projeto já possuir uma fonte central de dados do personagem, ela deve ser utilizada.

\---

# 8\. SISTEMA DE XP E NÍVEL

O projeto possui um XPSystem.

Responsabilidades:

* armazenar/gerenciar XP;
* obter XP;
* calcular XP necessário;
* obter nível;
* controlar progressão.

Não chamar funções de instância como se fossem funções estáticas.

Exemplo incorreto:

XPSystem.obter\_level()

Se XPSystem for uma instância, deve ser utilizada a referência correta à instância existente.

Antes de criar outra instância de XPSystem:

* procurar se já existe uma instância;
* verificar se existe autoload;
* verificar referências existentes.

Não criar dois sistemas de XP concorrentes.

\---

# 9\. SISTEMA DE NEN

O sistema de Nen é uma das mecânicas centrais do jogo.

As técnicas consideradas atualmente são:

* TEN
* REN
* ZETSU
* GYO
* SHU
* KO
* EN
* KEN
* RYU

O sistema deve permitir expansão futura.

A estrutura atual das técnicas possui informações como:

* nível;
* XP;
* ativo.

\---

# 10\. REGRAS ATUAIS DAS TÉCNICAS DE NEN

## TEN

Função atual:

Reduzir o dano recebido.

Quanto maior a eficiência/nível do Ten, maior deve ser a capacidade de redução conforme a fórmula definida pelo sistema.

Não inventar uma fórmula nova se já existir uma fórmula implementada.

\---

## ZETSU

Função atual:

Regenerar vida.

O Zetsu deve ser tratado como uma técnica/estado do sistema de Nen.

Não criar um sistema independente de regeneração se a regeneração já estiver sendo controlada pelo NenSystem.

\---

## REN

Função atual:

Aumentar o alcance dos ataques.

O aumento deve utilizar o sistema de atributos/combate existente.

Não criar uma segunda lógica de alcance paralela.

\---

## GYO

Função atual:

Aumentar a esquiva.

O efeito deve ser integrado ao sistema de combate existente.

\---

## SHU

Reservado para implementação futura.

Não implementar funcionalidades novas para Shu sem solicitação explícita.

\---

## KO

Função atual:

Aumentar o dano.

O efeito deve utilizar o sistema de dano existente.

Não criar uma segunda fórmula de dano.

\---

## KEN

Reservado para implementação futura.

Não implementar funcionalidades novas para Ken sem solicitação explícita.

\---

## RYU

Reservado para implementação futura.

Não implementar funcionalidades novas para Ryu sem solicitação explícita.

\---

## EN

Existe no conjunto de técnicas de Nen, mas sua implementação detalhada pode ser definida posteriormente.

Não inventar mecânicas definitivas sem solicitação.

\---

# 11\. COMBATE

O combate é um dos principais diferenciais do projeto.

O sistema deve ser modular para permitir futuramente:

* ataques básicos;
* Nen;
* Hatsu;
* esquiva;
* defesa;
* buffs;
* debuffs;
* condições;
* alcance;
* dano;
* diferentes estilos de combate.

O dano deve considerar os sistemas de atributos e Nen existentes.

Caso exista uma fórmula de dano já implementada, ela deve ser preservada.

Não criar uma nova fórmula simplesmente porque a tarefa exige modificar dano.

Primeiro localizar a fórmula existente.

\---

# 12\. HATSU

Hatsu é uma parte central do jogo.

O sistema deve permitir habilidades personalizadas.

Características planejadas:

* habilidades;
* slots;
* cooldown;
* dano;
* área;
* alcance;
* evolução;
* afinidade;
* efeitos especiais.

O personagem poderá possuir até 4 slots de Hatsu conforme o design atual.

O nível de Hatsu pode:

* reduzir cooldown;
* aumentar dano;
* aumentar área;
* melhorar efeitos.

A afinidade do personagem deve influenciar a eficiência do Hatsu quando esse sistema for implementado.

Não criar habilidades específicas de personagem permanentemente hardcoded dentro de Player.gd.

Hatsu deve ser projetado para expansão.

\---

# 13\. AFINIDADE DE NEN

O jogo possui o conceito de afinidade de Nen.

A afinidade deve influenciar a eficiência de determinadas habilidades.

Não assumir que todos os tipos possuem a mesma eficiência.

Quando o sistema de afinidade ainda não estiver implementado:

* não inventar regras definitivas;
* deixar a arquitetura preparada para expansão;
* evitar valores hardcoded espalhados pelo projeto.

\---

# 14\. BESTA DE NEN

O projeto possui o conceito de Besta de Nen.

A Besta de Nen deve funcionar como uma espécie de companheira ligada ao personagem.

Conceito:

* buffs;
* condições;
* habilidades;
* características próprias;
* evolução;
* dependência do personagem;
* possibilidade de ser muito poderosa;
* forte ligação com o Hatsu/personagem.

A Besta de Nen não precisa seguir exatamente as regras do anime.

Ela é uma mecânica própria do jogo.

Existe também a ideia de obtenção/RNG durante determinadas missões.

Não implementar uma versão definitiva da Besta de Nen sem especificação suficiente.

\---

# 15\. QUESTS

Quests devem ser construídas utilizando os sistemas existentes.

Exemplo:

Quest:

"Mate 10 inimigos."

A quest não deve criar um sistema próprio de morte de inimigos.

Ela deve observar/comunicar-se com o sistema responsável pelos inimigos.

Fluxo desejado:

EnemySystem
→ inimigo morre
→ evento/sinal apropriado
→ QuestSystem recebe informação
→ objetivo é atualizado
→ quest verifica conclusão
→ recompensa é concedida.

Não duplicar a lógica de morte.

\---

# 16\. NPCs

O projeto possui uma estrutura base de NPC.

NPCs podem possuir:

* nome;
* interação;
* diálogo;
* comportamento;
* quests;
* serviços;
* treinamento.

NPCs específicos devem herdar/complementar a estrutura existente quando apropriado.

Exemplo atual:

Wing é um NPC específico.

Não criar lógica global dentro do script específico de Wing.

A lógica genérica deve permanecer no sistema base de NPC/interação.

\---

# 17\. INTERAÇÃO

O projeto utiliza um sistema de interação baseado em Area2D.

O sistema existente possui conceitos como:

* InteractionComponent;
* player\_inside;
* interaction\_text;
* sinal interacted;
* Input de interação.

Antes de criar outro sistema de interação:

* localizar InteractionComponent;
* verificar como NPCs utilizam o componente;
* reutilizar o sistema.

Não criar uma segunda forma de interação para quests/NPCs sem necessidade.

\---

# 18\. DIÁLOGOS

O projeto possui um DialogueBox.

Antes de alterar o sistema de diálogo:

* verificar o script;
* verificar a cena;
* verificar se o script está conectado à cena;
* verificar os nós utilizados.

Não substituir o DialogueBox inteiro para corrigir um problema simples de tamanho ou referência.

\---

# 19\. PLAYER

Player.gd não deve se transformar em um "arquivo Deus".

Evitar colocar nele:

* sistema completo de quests;
* sistema completo de Nen;
* sistema completo de XP;
* sistema completo de inimigos;
* sistema completo de diálogo.

Player deve integrar os sistemas.

Exemplo:

Player → NenSystem

Player → XPSystem

Player → QuestSystem

Player → InteractionComponent

Em vez de colocar todas as responsabilidades dentro de Player.gd.

\---

# 20\. UI

A interface deve ficar separada da lógica de gameplay.

Exemplos:

* HUD;
* StatusMenu;
* barras de vida;
* barra de aura;
* nível;
* XP;
* menus;
* diálogos.

UI deve observar/acessar os sistemas apropriados.

Evitar colocar lógica de gameplay dentro de Label, Panel, VBoxContainer ou outros Controls.

\---

# 21\. HUD E STATUS

O HUD pode apresentar:

* vida;
* aura;
* nível;
* XP;
* informações do personagem.

StatusMenu deve exibir informações do personagem sem se tornar responsável por calculá-las.

O cálculo deve permanecer no sistema apropriado.

\---

# 22\. ANIMAÇÕES

O projeto utiliza animações do personagem.

Pode utilizar:

* AnimationPlayer;
* AnimationTree;
* estados;
* sprites;
* outras ferramentas da Godot.

Não modificar a arquitetura de animação sem verificar como o Player já está configurado.

\---

# 23\. ESTADOS

O projeto possui conceitos de:

* State.gd;
* StateMachine.gd.

Estados devem ser utilizados quando apropriado para comportamentos que realmente possuem estados distintos.

Não criar outra StateMachine se uma já existir.

Antes de criar estados novos:

* localizar a StateMachine atual;
* entender sua interface;
* seguir o padrão existente.

\---

# 24\. NOMENCLATURA

Manter nomes consistentes.

Preferir nomes que expressem claramente a responsabilidade.

Não renomear arquivos/classes existentes sem necessidade.

Se uma classe já é utilizada por várias partes do projeto, não renomeá-la apenas por preferência estética.

\---

# 25\. SINAIS

Antes de criar um novo sinal:

* procurar se já existe um sinal equivalente.

Preferir sinais para comunicação desacoplada entre sistemas quando apropriado.

Não criar dezenas de sinais desnecessários para ações simples.

\---

# 26\. AUTOLOADS / SINGLETONS

Antes de criar uma instância global:

* verificar se o sistema já possui autoload;
* verificar se existe singleton;
* verificar se outra parte do projeto já mantém a referência.

Não criar múltiplas instâncias de sistemas que deveriam ser únicos.

Especialmente:

* XPSystem;
* NenSystem;
* QuestSystem;
* GameManager;
* sistemas globais futuros.

\---

# 27\. DADOS

Quando dados precisarem ser compartilhados entre sistemas:

Preferir uma estrutura central e consistente.

Evitar espalhar informações importantes em:

* variáveis locais;
* constantes duplicadas;
* scripts diferentes;
* valores hardcoded.

Exemplo:

Não armazenar o nível do personagem em três lugares diferentes.

Deve existir uma fonte confiável.

\---

# 28\. HARD CODE

Evitar hardcode quando o valor representa uma regra de gameplay.

Valores de gameplay importantes devem, quando apropriado, estar centralizados.

Exemplos:

* dano;
* cooldown;
* XP;
* multiplicadores;
* alcance;
* defesa;
* redução de dano;
* custos.

Entretanto, não criar configurações excessivamente abstratas para valores simples.

A solução deve ser proporcional à necessidade.

\---

# 29\. PERFORMANCE

O projeto pretende evoluir para MMORPG.

Por isso, sistemas devem ser pensados com escalabilidade em mente.

Evitar:

* loops infinitos;
* processamento desnecessário em `\\\_process`;
* procurar nós repetidamente sem necessidade;
* criar/destroçar objetos excessivamente;
* sinais duplicados;
* cálculos pesados por frame sem necessidade.

Porém:

Não fazer otimização prematura.

Primeiro garantir funcionamento correto.

\---

# 30\. MULTIPLAYER

O projeto tem objetivo futuro de funcionar como MMORPG.

Nem todo sistema precisa ser multiplayer imediatamente.

Entretanto, evitar arquiteturas que tornem impossível separar futuramente:

* lógica do cliente;
* lógica do servidor;
* estado autoritativo;
* dados do personagem;
* combate;
* NPCs;
* quests.

Não implementar networking apenas por antecipação sem solicitação.

\---

# 31\. PROGRESSÃO

O jogo terá progressão de personagem.

Conceitos planejados:

* nível;
* XP;
* atributos;
* aura;
* Nen;
* técnicas de Nen;
* Hatsu;
* potencial;
* treinamento.

Existe a ideia de potencial/IVs do personagem.

A ideia atual é possuir potencial aleatório dentro de uma faixa definida pelo design do jogo.

Não transformar números de balanceamento em regras definitivas se ainda estiverem em discussão.

\---

# 32\. AURA

Aura é um recurso central do personagem.

O personagem possui:

* aura;
* aura\_max.

O jogo possui a ideia de regeneração de aura.

Valores e fórmulas exatas devem permanecer centralizados no sistema responsável.

Não criar diferentes fórmulas de regeneração espalhadas por Player, NenSystem e HUD.

\---

# 33\. REGENERAÇÃO

O design atual considera diferenças entre:

* fora de combate;
* dentro de combate.

Existe uma proposta de:

* regeneração maior fora de combate;
* regeneração menor durante combate.

Esses valores podem ser alterados durante o balanceamento.

Portanto:

Não espalhar os números diretamente pelo código.

\---

# 34\. POTENCIAL

O personagem possui o conceito de potencial.

O potencial pode influenciar o quanto o personagem consegue evoluir.

Existe uma ideia de valores aleatórios de potencial/IV.

O sistema deve ser preparado para que personagens possam possuir potenciais diferentes.

Não remover esse conceito sem solicitação.

\---

# 35\. COMBATE E ATRIBUTOS

Atributos como:

* força;
* defesa;
* velocidade;
* aura;

podem influenciar combate.

O cálculo deve permanecer centralizado.

Evitar:

Player calcula parte do dano
+
Enemy calcula outra parte
+
NenSystem altera diretamente uma terceira parte.

Preferir um fluxo claro.

\---

# 36\. REGRAS PARA ALTERAÇÃO DE CÓDIGO

Quando o usuário solicitar:

"corrija"

Primeiro identificar a causa.

Não simplesmente esconder o erro.

Quando solicitar:

"adicione"

Primeiro procurar onde a funcionalidade deve realmente existir.

Quando solicitar:

"melhore"

Não reescrever todo o sistema automaticamente.

Quando solicitar:

"refatore"

Antes de refatorar, entender dependências e preservar comportamento.

\---

# 37\. NÃO FAZER

Nunca:

* criar sistemas duplicados;
* apagar código funcional sem necessidade;
* renomear tudo;
* reestruturar o projeto inteiro por uma pequena tarefa;
* adicionar dependências externas sem necessidade;
* inventar APIs;
* inventar funções que não existem;
* chamar métodos estáticos que são de instância;
* assumir que uma cena possui um nó sem verificar;
* assumir que um script está conectado a uma cena;
* assumir que um Autoload existe;
* assumir que uma variável existe;
* modificar arquivos aleatórios;
* implementar mecânicas ainda não definidas como se fossem definitivas.

\---

# 38\. QUANDO EXISTIR DÚVIDA

Se uma dúvida puder ser resolvida lendo o código:

LEIA O CÓDIGO.

Não pergunte ao usuário algo que pode ser descoberto analisando o projeto.

Se a dúvida envolver uma decisão de design que não está definida no código ou neste documento:

Não inventar uma regra definitiva.

Explicar a decisão necessária e pedir confirmação quando ela puder alterar significativamente a arquitetura ou gameplay.

\---

# 39\. MODIFICAÇÕES GRANDES

Para mudanças grandes:

Primeiro analisar.

Depois apresentar:

1. O que será alterado.
2. Quais arquivos serão alterados.
3. Como os sistemas irão se comunicar.
4. Possíveis riscos.
5. Como será testado.

Somente depois implementar, quando o usuário estiver trabalhando em modo que permita planejamento/revisão.

\---

# 40\. TESTES

Sempre que possível:

* executar o projeto;
* verificar erros do Godot;
* verificar erros de GDScript;
* verificar referências;
* verificar cenas;
* testar o comportamento afetado.

Não considerar uma alteração concluída apenas porque o código "parece correto".

\---

# 41\. ERROS

Quando encontrar erro:

1. Identificar a origem.
2. Corrigir a causa.
3. Não mascarar o erro.
4. Verificar sistemas dependentes.
5. Executar novamente a validação.

Não adicionar `if` aleatórios apenas para impedir que um erro apareça.

\---

# 42\. CENAS GODOT

Antes de modificar uma `.tscn`:

* verificar os nós;
* verificar scripts;
* verificar caminhos;
* verificar recursos;
* verificar sinais;
* verificar propriedades.

Não substituir uma cena inteira quando uma pequena alteração resolve o problema.

\---

# 43\. RECURSOS E ASSETS

Assets visuais devem permanecer separados da lógica.

Não colocar lógica de gameplay dentro de arquivos de arte.

Manter organização clara para:

* sprites;
* tiles;
* mapas;
* animações;
* UI;
* efeitos;
* sons.

\---

# 44\. PIXEL ART

O projeto utiliza estética 2D/pixel art.

A lógica de gameplay não deve depender diretamente de detalhes visuais.

Um personagem deve continuar funcionando mesmo que:

* sprite seja substituído;
* animação seja substituída;
* aparência seja alterada.

\---

# 45\. MUNDO

O jogo terá um mundo semiaberto.

Elementos planejados:

* cidades;
* NPCs;
* lojas;
* missões;
* inimigos;
* exploração;
* treinamento;
* áreas de história;
* áreas secundárias.

Não implementar sistemas de mundo gigantes sem necessidade para a tarefa atual.

\---

# 46\. HISTÓRIA

O projeto é inspirado no universo de Hunter x Hunter, mas possui liberdade criativa.

O jogo pode:

* adaptar eventos;
* adicionar personagens;
* criar sistemas próprios;
* criar Hatsu próprios;
* criar Bestas de Nen próprias;
* alterar mecânicas.

Não assumir que o jogo precisa reproduzir exatamente todas as regras do anime/mangá.

\---

# 47\. DESIGN DO JOGO

O diferencial principal deve ser:

## COMBATE + NEN + HATSU + PROGRESSÃO

O código deve permitir que esses sistemas cresçam sem exigir reescrita completa da arquitetura.

\---

# 48\. PRIORIDADE DAS REGRAS

Quando houver conflito entre regras:

1. Instruções diretas do usuário nesta tarefa.
2. Regras deste AGENTS.md.
3. Arquitetura existente do projeto.
4. Boas práticas de engenharia.
5. Preferências estéticas.

Sempre preservar a intenção explícita do usuário.

\---

# 49\. REGRA CONTRA "GAMBIARRAS"

Uma solução que apenas faz o erro desaparecer não é considerada uma solução correta.

Exemplos de soluções ruins:

* duplicar variável;
* duplicar sistema;
* colocar lógica aleatória no Player;
* adicionar referências globais sem necessidade;
* usar valores mágicos;
* ignorar erros;
* remover funcionalidades para impedir bugs;
* comentar código quebrado em vez de corrigi-lo.

Preferir soluções estruturais simples.

\---

# 50\. REGRA DE COMPATIBILIDADE

Ao alterar um sistema existente:

Perguntar internamente:

"Quem usa este sistema?"

Depois verificar:

* chamadas;
* sinais;
* herança;
* referências;
* cenas;
* UI;
* outros sistemas.

Uma alteração local não deve quebrar silenciosamente outras partes do projeto.

\---

# 51\. DOCUMENTAÇÃO

Quando uma decisão arquitetural importante for tomada, atualizar a documentação apropriada.

Não transformar AGENTS.md em um changelog.

Este arquivo deve conter REGRAS e CONTEXTO PERMANENTE.

Informações temporárias devem ficar em documentação própria.

\---

# 52\. ESTADO ATUAL CONHECIDO DO PROJETO

Sistemas/conceitos já trabalhados:

* Player;
* NPC;
* Wing;
* InteractionComponent;
* DialogueBox;
* HUD;
* StatusMenu;
* XPSystem;
* EnemySystem;
* NenSystem;
* State;
* StateMachine;
* sistema de atributos;
* combate;
* quests em desenvolvimento;
* técnicas de Nen;
* Hatsu;
* Besta de Nen.

Antes de criar qualquer sistema novo, verificar se algum desses sistemas já possui a responsabilidade desejada.

\---

# 53\. REGRA FINAL

O agente não deve tentar "melhorar" o projeto inteiro em cada tarefa.

Faça exatamente a tarefa solicitada.

Faça-a da maneira mais limpa e compatível possível.

Preserve o que já funciona.

Leia antes de alterar.

Reutilize antes de duplicar.

Teste depois de modificar.

Se algo não estiver definido, não invente como se fosse uma decisão oficial do projeto.

Este projeto está sendo construído incrementalmente.

Cada sistema novo deve respeitar os sistemas anteriores e preparar o projeto para os sistemas futuros.

import pypandoc



text = """# HUNTER ONLINE — DIRETRIZ DE VISÃO, IMERSÃO E ESCALA DO JOGO



> \\\*\\\*Documento para orientar o agente de IA durante todo o desenvolvimento.\\\*\\\*

>

> \\\*\\\*Objetivo central:\\\*\\\* não construir apenas um RPG funcional. Construir um mundo de Hunter x Hunter que pareça vivo, grande, demorado, explorável e cheio de histórias.



\---



\# 1. VISÃO PRINCIPAL



Quero desenvolver um jogo \*\*2D top-down inspirado em Hunter x Hunter\*\*, mas com uma escala e sensação de aventura muito maiores do que um RPG 2D comum.



As principais referências de experiência e estrutura são:



\- \*\*Dragon Ball Xenoverse 1\*\*

\- \*\*Dragon Ball Xenoverse 2\*\*

\- \*\*Hunter x Hunter\*\*

\- \*\*Hyper Light Drifter\*\*

\- \*\*CrossCode\*\*

\- \*\*Zelda 2D\*\*



\### A referência mais importante de escala e sensação de mundo é Dragon Ball Xenoverse 1 e 2.



Não quero copiar Xenoverse.



Quero entender o que faz Xenoverse funcionar como uma experiência de aventura:



\- sensação de mundo;

\- grande quantidade de personagens;

\- cidades e hubs;

\- missões;

\- personagens recorrentes;

\- progressão longa;

\- treinamento;

\- desbloqueios;

\- conteúdo secundário;

\- sensação de que existe algo para fazer;

\- crescimento gradual do personagem;

\- mundo que vai ficando maior conforme o jogador progride.



Quero trazer essa sensação para um jogo 2D de Hunter x Hunter.



E quero que o nosso jogo seja \*\*ainda mais vivo e imersivo\*\* em certos aspectos.



\---



\# 2. O QUE NÃO QUERO



Não quero um jogo que pareça um protótipo.



Não quero:



```text

Mapa pequeno

↓

NPC parado

↓

Quest

↓

3 inimigos

↓

Boss

↓

Recompensa

↓

Próximo mapa



Também não quero:



NPC:

"Olá."



Jogador:

"Olá."



NPC:

"Mate 5 lobos."



Jogador:

"OK."



↓

5 lobos mortos

↓

+XP

↓

próxima quest



Isso é funcional, mas é raso.



O jogador precisa sentir que existe uma razão para aquele lugar, personagem, missão e acontecimento existirem.



3\\. O OBJETIVO EMOCIONAL



Quero que o jogador pense:



"Eu estou dentro desse mundo."



E depois de muitas horas consiga lembrar:



"Foi naquela cidade que conheci aquele Hunter."



"Foi naquela floresta que quase morri."



"Foi aquele NPC que me ensinou uma coisa sobre Nen."



"Foi naquela missão que conheci aquele personagem."



"Foi naquela região que consegui meu primeiro Hatsu."



"Eu voltei para aquele lugar depois de ficar muito mais forte."



Esse é o tipo de experiência que quero construir.



4\\. A FILOSOFIA PRINCIPAL

Não quero fazer um RPG que tenha um mundo.

Quero fazer um mundo que, por acaso, é um RPG.



Essa frase deve orientar o desenvolvimento.



O mundo deve existir mesmo quando o jogador não está olhando.



5\\. O MUNDO DEVE PARECER MAIOR QUE O JOGADOR



O protagonista não deve parecer o centro absoluto do universo desde o primeiro minuto.



Devem existir:



Hunters fortes;

usuários de Nen;

criminosos;

comerciantes;

mestres;

organizações;

viajantes;

mercenários;

pessoas comuns;

vilões;

aventureiros;

monstros;

personagens importantes;

personagens completamente irrelevantes para a história principal.



O jogador está entrando nesse mundo.



Ele ainda precisa conquistar seu espaço.



6\\. INSPIRAÇÃO EM DRAGON BALL XENOVERSE 1 E 2



Quero usar Xenoverse como referência principalmente para:



HUB / CIDADE



Um local que funciona como centro da aventura.



O jogador deve poder:



encontrar personagens;

receber missões;

treinar;

comprar;

conversar;

desbloquear conteúdo;

encontrar outros personagens;

descobrir novas atividades.

MISSÕES



Não quero que todas sejam apenas combate.



Quero:



missões de história;

missões secundárias;

treinamento;

investigação;

exploração;

combate;

escolta;

coleta;

desafios;

bosses;

missões especiais;

missões relacionadas ao Nen.

PROGRESSÃO



O jogador deve começar pequeno e gradualmente desbloquear:



novas áreas;

novos mestres;

novas técnicas;

novas missões;

novos sistemas;

novos inimigos;

novos desafios;

novos Hatsus.

SENSAÇÃO DE CONTEÚDO



Quando o jogador termina uma missão, ele não deve pensar:



"Acabou o jogo."



Ele deve pensar:



"O que será que eu posso fazer agora?"



Esse sentimento é muito importante.



7\\. MAS QUERO MAIS VIDA QUE XENOVERSE



Xenoverse é uma referência de escala e estrutura.



Não quero simplesmente reproduzir a estrutura.



Quero que o mundo tenha mais vida e interação.



Por exemplo, em uma cidade:



NPCs andando;

crianças brincando;

comerciantes trabalhando;

pessoas conversando;

Hunters treinando;

guardas patrulhando;

viajantes chegando;

pessoas entrando em casas;

NPCs indo dormir;

personagens mudando de localização;

eventos acontecendo;

diálogos mudando;

NPCs comentando acontecimentos recentes.



Nem todo NPC precisa entregar uma missão.



Isso é essencial.



Alguns NPCs existem simplesmente para fazer o mundo parecer habitado.



8\\. NPCS DEVEM TER PERSONALIDADE



Não quero NPCs genéricos.



Um NPC importante pode possuir:



Nome

Personalidade

Profissão

História

Objetivos

Medos

Relacionamentos

Rotina

Localização

Segredos

Conhecimentos

Opiniões



Exemplo:



Comerciante



Ele não existe apenas para abrir uma loja.



Ele pode ser um viajante que perdeu sua antiga loja para bandidos.



Ele conhece uma determinada região.



Pode comentar:



"Se você estiver indo para o norte, não siga pela estrada principal."



Isso pode gerar curiosidade.



Outro NPC pode dizer:



"Não escute aquele comerciante. Ele sempre exagera."



Agora temos uma pequena relação entre personagens.



9\\. RELACIONAMENTOS ENTRE NPCS



Quero que NPCs conheçam outros NPCs.



Exemplo:



NPC A

↓

conhece NPC B



NPC B

↓

é irmão de NPC C



NPC C

↓

trabalha para NPC D



O jogador pode descobrir essas relações naturalmente.



Isso permite:



fofocas;

rumores;

conflitos;

amizades;

rivalidades;

famílias;

alianças;

traições;

histórias secundárias.

10\\. PERSONAGENS RECORRENTES



Quero personagens que apareçam várias vezes.



Exemplo:



Primeiro encontro

↓

Conversa

↓

Missão

↓

O jogador ajuda

↓

O personagem desaparece

↓

Encontro em outra cidade

↓

Novo diálogo

↓

Nova missão

↓

Relacionamento evolui



O jogador deve reconhecer essas pessoas.



Quero o sentimento:



"Ah, esse cara de novo!"



Isso cria memória e apego.



11\\. NPCS NÃO DEVEM ESPERAR O JOGADOR



Um mundo vivo precisa de rotinas.



Exemplo:



06:00

NPC acorda



07:00

vai trabalhar



12:00

vai comer



14:00

volta ao trabalho



18:00

fecha a loja



20:00

vai para a taverna



23:00

volta para casa



00:00

dorme



Nem todo NPC precisa de um sistema extremamente complexo.



Mas os personagens importantes devem ter rotinas.



Isso pode gerar acontecimentos espontâneos.



12\\. QUESTS DEVEM SER HISTÓRIAS



Quero evitar quests sem contexto.



Em vez de:



Mate 5 lobos.



Fazer:



Um caçador local desapareceu.



O jogador conversa com:



Criança



"Meu pai sempre volta antes de escurecer..."



Comerciante



"Ele estava procurando alguma coisa na floresta."



Hunter



"Encontrei marcas estranhas perto da região norte."



Então:



Investigação

↓

Floresta

↓

Rastros

↓

Acampamento

↓

Inimigos

↓

Caverna

↓

Hunter desaparecido

↓

Descoberta



Agora a quest é uma história.



13\\. QUESTS DEVEM TER CONSEQUÊNCIAS



Quando o jogador termina uma missão, o mundo pode mudar.



Exemplo:



O jogador ajuda uma cidade.



Depois:



NPCs comentam;

uma loja abre;

um comerciante volta;

uma nova missão aparece;

uma área fica segura;

outro personagem passa a confiar no jogador;

um inimigo aparece procurando vingança.



Não quero que tudo volte ao estado inicial depois da missão.



14\\. HISTÓRIA AO REDOR DO JOGADOR



Quero que eventos aconteçam mesmo sem o protagonista.



Por exemplo:



O jogador está em uma cidade.

↓

ouve rumores.

↓

viaja para outra região.

↓

enquanto está fora, acontece algo.

↓

quando retorna, encontra a cidade diferente.



Isso faz o mundo parecer independente.



O jogador não deve ser sempre o responsável por iniciar tudo.



15\\. O MUNDO DEVE CONTAR HISTÓRIAS SEM DIÁLOGO



Exemplo:



Casa abandonada

↓

porta quebrada

↓

marcas de luta

↓

objeto destruído

↓

carta no chão

↓

sangue



O jogador começa a montar a história sozinho.



Isso é muito importante para a imersão.



16\\. EXPLORAÇÃO DEVE SER UMA MECÂNICA



Não quero mapas que sejam apenas corredores entre quests.



Quero que o jogador tenha vontade de explorar.



Devem existir:



cavernas;

caminhos secretos;

áreas bloqueadas;

atalhos;

ruínas;

casas;

florestas;

montanhas;

dungeons;

regiões perigosas;

NPCs escondidos;

bosses secretos;

itens;

eventos;

áreas de treinamento.



O jogador deve pensar:



"O que será que tem ali?"



17\\. VIAJAR DEVE TER SIGNIFICADO



Não quero teleportar o jogador para todos os lugares o tempo inteiro.



Quero que ele possa caminhar:



Cidade

↓

Estrada

↓

Floresta

↓

Acampamento

↓

Vilarejo

↓

Montanha

↓

Dungeon



O caminho também é conteúdo.



Durante a viagem podem acontecer:



encontros;

inimigos;

NPCs;

eventos;

diálogos;

descobertas;

itens;

atalhos;

segredos;

pequenas histórias.

18\\. ESCALA DO MUNDO



Quero que o jogador sinta que o mundo é grande.



Não quero que uma cidade inteira seja atravessada em 10 segundos.



Quero regiões com identidade:



Cidade inicial

↓

Estrada

↓

Floresta

↓

Vilarejo

↓

Montanhas

↓

Região selvagem

↓

Cidade maior

↓

Dungeon

↓

Nova região



O mundo deve crescer junto com o jogador.



19\\. PROGRESSÃO LONGA



Quero que o personagem demore para ficar realmente forte.



A progressão deve parecer uma jornada:



Fraco

↓

Aprende a lutar

↓

Fica mais forte

↓

Conhece Hunters

↓

Descobre Nen

↓

Treina Nen

↓

Aprende técnicas

↓

Desenvolve Hatsu

↓

Enfrenta usuários de Nen

↓

Viaja para regiões perigosas

↓

Enfrenta elites

↓

Enfrenta monstros

↓

Enfrenta bosses

↓

Torna-se extremamente poderoso



Cada etapa deve ser conquistada.



20\\. ESCALA DE PODER



Quero uma escala grande:



Civil

↓

Lutador

↓

Lutador experiente

↓

Usuário iniciante de Nen

↓

Usuário treinado

↓

Hunter

↓

Usuário avançado

↓

Elite

↓

Monstro

↓

Boss



Mas não quero:



número maior = vitória automática.



Estratégia deve importar.



21\\. COMBATE



O combate deve ser inspirado em:



Hyper Light Drifter;

CrossCode;

Zelda 2D.



Características:



movimentação em 8 direções;

ataques leves;

esquiva manual;

hitboxes reais;

hurtboxes;

knockback;

ataques direcionais;

inimigos com padrões diferentes;

gerenciamento de aura;

Nen;

Hatsus.



O combate deve ser fácil de entender, mas difícil de dominar.



22\\. COMBATES DEVEM TER DURAÇÃO



Não quero que todos os inimigos morram em 1 ou 2 ataques.



Inimigos comuns



Podem morrer rapidamente.



Inimigos fortes



Devem exigir:



posicionamento;

esquiva;

ataques;

leitura de padrões;

Nen;

gerenciamento de recursos.

Bosses



Devem ser confrontos memoráveis.



Podem possuir:



fases;

padrões diferentes;

ataques especiais;

mudança de comportamento;

uso de Nen;

fraquezas;

condições especiais.

23\\. NEN É UM DOS CORAÇÕES DO JOGO



Nen não deve ser apenas mana.



Temos dois sistemas de progressão:



XP normal



Aumenta:



HP;

força;

defesa;

velocidade;

outros atributos.

XP de Nen



Aumenta:



Aura;

domínio do Nen;

técnicas;

potencial de Hatsu.



Os dois sistemas devem ser independentes.



24\\. TÉCNICAS NEN ATUAIS

Ten



Reduz dano recebido.



Zetsu



Permite regeneração de HP.



Ren



Aumenta alcance dos ataques.



Gyo



Aumenta esquiva.



Ko



Aumenta dano.



Shu



Reservado para expansão futura.



Ken



Reservado para expansão futura.



Ryu



Reservado para expansão futura.



25\\. HATSU



Hatsu deve ser um dos maiores sistemas do jogo.



Quero que o jogador pense:



"Esse Hatsu é meu."



Não quero simplesmente 100 skills iguais para todos.



O Hatsu deve considerar:



categoria de Nen;

afinidade;

dano;

custo de aura;

cooldown;

alcance;

área;

condições;

restrições;

risco;

recompensa.



Quero permitir habilidades muito fortes quando o jogador aceitar condições fortes.



26\\. PERSONALIZAÇÃO



O jogador deve sentir que está criando seu próprio Hunter.



Queremos futuramente permitir:



aparência;

roupas;

equipamentos;

estilo de combate;

técnicas;

Nen;

Hatsu;

builds;

escolhas de progressão.



Dois jogadores podem possuir personagens completamente diferentes.



27\\. CIDADES DEVEM SER HUBS VIVOS



Uma cidade importante deve ter:



Praça

├── NPCs

├── comerciantes

├── crianças

├── viajantes

└── eventos



Mercado

├── lojas

├── vendedores

└── rumores



Área residencial

├── casas

├── famílias

└── NPCs



Área Hunter

├── treinamento

├── missões

└── Hunters



Taverna

├── rumores

├── personagens

└── eventos



Área secreta

└── conteúdo opcional



A cidade deve ser um lugar onde o jogador queira ficar.



28\\. SISTEMA DE MISSÕES



Quero vários tipos:



história principal;

secundárias;

matar inimigos;

coleta;

escolta;

investigação;

exploração;

treinamento;

Nen;

bosses;

eventos;

missões especiais.



Mas o mais importante:



as missões devem ter contexto.



29\\. ARCO DE HISTÓRIA



Quero que a história possa ser dividida em grandes arcos.



Exemplo:



ARCO 1

Introdução

↓

Cidade inicial

↓

Primeiras missões



ARCO 2

Hunter Exam

↓

Novos personagens

↓

Novas regiões



ARCO 3

Descoberta do Nen

↓

Treinamento

↓

Primeiras técnicas



ARCO 4

Conflito

↓

Organização inimiga

↓

Boss



ARCO 5

Nova região

↓

Novos Hunters

↓

Novos conflitos



Isso pode crescer muito no futuro.



30\\. O JOGADOR NÃO PRECISA SER O CENTRO DE TUDO



Isso é muito importante.



Quero que existam personagens mais fortes que o jogador.



Quero que existam problemas que o jogador não consegue resolver inicialmente.



Quero que existam acontecimentos que acontecem independentemente dele.



Isso cria escala.



O jogador deve sentir:



"Eu ainda sou pequeno nesse mundo."



E mais tarde:



"Agora eu consigo participar dessas coisas."



31\\. EVENTOS DO MUNDO



Quero eventos que possam acontecer:



ataques;

torneios;

invasões;

desaparecimentos;

mudanças políticas;

chegada de Hunters;

monstros aparecendo;

eventos de NPC;

eventos de Nen;

bosses temporários;

mudanças em cidades.



Alguns eventos podem ser relacionados à história.



Outros podem ser opcionais.



32\\. SISTEMA DE ROTINA E HORÁRIO



Quando possível, NPCs importantes podem ter rotina.



Exemplo:



Manhã

↓

Trabalho



Tarde

↓

Mercado



Noite

↓

Taverna



Madrugada

↓

Casa



Isso pode permitir que certas quests ou diálogos só apareçam em determinados horários.



33\\. SOM E AMBIENTAÇÃO



A imersão não deve depender apenas de gráficos.



Quero considerar:



música por região;

sons ambientes;

passos;

vento;

água;

animais;

cidade;

cavernas;

batalha;

sons de Nen;

mudanças de clima;

iluminação.



Uma floresta deve parecer diferente de uma cidade.



Uma dungeon deve parecer diferente de uma floresta.



34\\. DETALHES PEQUENOS IMPORTAM



Não precisamos criar um sistema gigante para cada coisa.



Pequenos detalhes podem fazer enorme diferença:



NPC carregando caixas;

vendedor organizando produtos;

criança correndo;

guarda conversando;

Hunter treinando;

viajante chegando;

animais andando;

NPC entrando em casa;

pessoas comentando acontecimentos.



Esses detalhes juntos criam vida.



35\\. VERTICAL SLICE



Não quero construir 50 sistemas separados antes de testar o jogo.



Quero criar uma primeira região realmente encorpada.



Exemplo:



CIDADE

│

├── 15–30 NPCs

├── NPCs importantes

├── comerciantes

├── personagens recorrentes

├── história

├── quests

├── side quests

├── treinamento

└── segredos

\&#x20;       ↓

ESTRADA

\&#x20;       ↓

FLORESTA

│

├── inimigos

├── NPC viajante

├── evento

├── acampamento

├── caminho secreto

└── dungeon

\&#x20;       ↓

BOSS

\&#x20;       ↓

RECOMPENSA

\&#x20;       ↓

CONSEQUÊNCIA NA CIDADE



O objetivo é que essa pequena parte já pareça um jogo de verdade.



36\\. NÃO QUERO FAZER TUDO RÁPIDO



Não quero que o agente pense:



"Como faço isso da maneira mais rápida?"



Quero:



"Como faço isso de maneira que pareça parte de um jogo grande?"



Prefiro:



1 sistema profundo



do que:



5 sistemas rasos.



Prefiro:



10 NPCs memoráveis



do que:



100 NPCs genéricos.



Prefiro:



5 quests com história



do que:



50 quests de matar mobs.



37\\. REGRA DE DESIGN



Antes de implementar qualquer coisa, pergunte:



Qual é a função disso no mundo?

Por que o jogador deveria se importar?

Como o jogador descobre isso?

Como NPCs interagem com isso?

Isso gera história?

Isso gera exploração?

Isso gera progressão?

Isso gera consequência?

Isso aumenta a imersão?

Isso conversa com outros sistemas?

38\\. SISTEMAS DEVEM CONVERSAR



A arquitetura deve permitir:



PLAYER

│

├── PlayerData

├── XPSystem

├── NenSystem

├── CombatSystem

└── HatsuSystem

\&#x20;       │

\&#x20;       ↓

\&#x20;    COMBATE

\&#x20;       │

\&#x20;       ↓

\&#x20;    ENEMIES

\&#x20;       │

\&#x20;       ↓

\&#x20;  XP / NEN XP

\&#x20;       │

\&#x20;       ↓

\&#x20;  PROGRESSÃO



E:



WORLD

│

├── NPCSystem

├── QuestSystem

├── EnemySystem

├── ShopSystem

├── DialogueSystem

├── EventSystem

├── DungeonSystem

└── WorldState



Os sistemas devem poder se comunicar sem ficarem completamente dependentes uns dos outros.



39\\. CRESCIMENTO HORIZONTAL



O mundo pode crescer adicionando:



novas cidades;

vilas;

florestas;

montanhas;

dungeons;

regiões;

NPCs;

inimigos;

quests;

bosses;

eventos;

histórias.

40\\. CRESCIMENTO VERTICAL



Também quero aprofundar:



combate;

Nen;

Hatsu;

IA dos inimigos;

NPCs;

relações;

quests;

progressão;

personalização;

mundo;

eventos.



O objetivo não é apenas adicionar conteúdo.



É fazer o conteúdo existente interagir cada vez mais.



41\\. SENSAÇÃO DE JORNADA



O personagem não deve parecer poderoso desde o começo.



Quero:



"Eu ainda não deveria estar aqui."



E depois:



"Agora eu estou preparado."



Esse contraste deve aparecer constantemente.



42\\. O MUNDO DEVE RECOMPENSAR CURIOSIDADE



Se o jogador sair do caminho principal, quero que exista chance de encontrar algo.



Exemplos:



NPC;

item;

quest;

dungeon;

Hatsu;

treinamento;

boss;

história;

segredo;

atalho.



Não quero colocar conteúdo aleatoriamente.



Quero que a exploração tenha significado.



43\\. CONTEÚDO OPCIONAL



Quero bastante conteúdo que não seja obrigatório.



O jogador pode:



fazer quests secundárias;

treinar;

explorar;

descobrir NPCs;

procurar bosses;

investigar histórias;

encontrar áreas secretas.



Isso ajuda o mundo a parecer muito maior.



44\\. IDENTIDADE DE HUNTER X HUNTER



O mundo deve ter a variedade de Hunter x Hunter:



Hunters;

exames;

organizações;

criminosos;

usuários de Nen;

cidades;

viagens;

regiões perigosas;

criaturas;

conflitos;

mistérios;

personagens com objetivos próprios.



Não quero que tudo seja apenas:



"monstro → matar → XP."



45\\. OBJETIVO FINAL DO JOGO



Quero que o jogador:



crie seu personagem;

comece fraco;

explore;

conheça pessoas;

faça missões;

construa relações;

melhore seus atributos;

descubra Nen;

treine;

desenvolva suas técnicas;

crie seu Hatsu;

viaje para novas regiões;

enfrente inimigos mais fortes;

participe de histórias maiores;

encontre personagens recorrentes;

descubra segredos;

fique cada vez mais poderoso;

construa sua própria identidade como Hunter.



A sensação final deve ser:



"Esse é o meu Hunter e essa é a minha jornada."



46\\. REGRA DE OURO



Sempre priorizar:



profundidade > quantidade de sistemas



imersão > velocidade de implementação



mundo vivo > mapas vazios



personagens interessantes > NPCs genéricos



histórias > quests isoladas



exploração > teletransporte constante



progressão > recompensas instantâneas



experiência do jogador > quantidade de código



47\\. DIRETRIZ PARA O AGENTE DE IA



A partir de agora, quando eu pedir para implementar alguma coisa, não pense apenas no código.



Antes de implementar, pense também:



como isso entra no mundo;

como o jogador descobre;

como NPCs interagem;

como isso pode gerar história;

como isso pode gerar exploração;

como isso pode afetar a progressão;

como isso pode ter consequências;

como isso pode aumentar a imersão.



Se eu pedir um NPC, não pense somente no script do NPC.



Pense:



Quem é essa pessoa?



Onde ela mora?



O que ela faz?



Quem ela conhece?



O que ela sabe?



Qual é a rotina dela?



Como ela reage ao jogador?



Ela aparece novamente?



Ela pode participar de uma quest?



Se eu pedir uma quest, não pense somente no objetivo.



Pense:



Por que essa quest existe?



Quem precisa disso?



Qual é a história por trás?



O que o jogador descobre?



O mundo muda depois?



48\\. NÃO ACELERAR O DESENVOLVIMENTO ARTIFICIALMENTE



Não quero que o projeto seja considerado "bom" apenas porque vários sistemas foram implementados.



Quero que cada parte tenha tempo suficiente para ganhar:



detalhes;

identidade;

contexto;

interação;

polimento;

conteúdo.



O objetivo não é terminar rápido.



O objetivo é construir algo que realmente pareça grande.



49\\. REFERÊNCIA FINAL: XENOVERSE + HUNTER X HUNTER



Use Dragon Ball Xenoverse 1 e 2 como referência para:



sensação de escala;

progressão;

hub;

quantidade de conteúdo;

missões;

personagens;

desbloqueios;

treinamento;

sensação de aventura contínua.



Use Hunter x Hunter como referência para:



mundo;

personagens;

Nen;

diversidade;

mistério;

conflitos;

organizações;

viagens;

estratégias;

personagens fortes;

desenvolvimento de habilidades.



Use Hyper Light Drifter / CrossCode / Zelda 2D como referência para:



combate;

movimentação;

exploração;

hitboxes;

esquiva;

sensação de controle.

O resultado desejado:



A escala e sensação de aventura de Xenoverse + a identidade e profundidade de Hunter x Hunter + o combate de um action RPG 2D.



E, acima de tudo:



um mundo ainda mais vivo do que simplesmente uma sequência de missões.



50\\. FRASE DEFINITIVA DO PROJETO

"Não quero fazer um jogo pequeno com elementos de Hunter x Hunter."

"Quero construir um mundo de Hunter x Hunter em que o jogador tenha espaço para crescer."

"Quero que o jogador sinta que existe uma vida acontecendo ao redor dele."

"Quero que ele crie memórias, conheça pessoas, viaje, fique mais forte e sinta que aquela é a história do personagem dele."



O combate é uma parte do jogo.



O Nen é uma parte do jogo.



As quests são uma parte do jogo.



Os NPCs são uma parte do jogo.



O mundo inteiro é a experiência.

"""



# FIM DO AGENTS.MD
