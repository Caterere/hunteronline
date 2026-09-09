# VERSIONAMENTO DE CONTEÚDO E COMPATIBILIDADE — CONTENT VERSIONING

> **Arquitetura de Versão Tripla, Compatibilidade de Protocolos de Rede e Gerenciamento de Patches**
> **Versão:** 1.0 (Fase L) | **Engine:** Godot 4.6 Stable

---

## 1. SISTEMA DE TRIPLA-VERSÃO (TRIPLE-VERSIONING)

Para evitar incompatibilidades entre o motor binário, a estrutura dos arquivos de salvamento e os pacotes de dados de histórias, o Hunter MMORPG adota três camadas independentes de versão gerenciadas em ContentVersionConfig.gd:

`gdscript
const GAME_VERSION: String =  1.0.0       # Versão do Executável / Código do Motor
const CONTENT_VERSION: String = 1.2.0    # Versão dos Pacotes de Dados e Sagas
const SAVE_VERSION: String = 2.4         # Schema do Arquivo de Salvamento JSON
`

### 1.1 Regras de Incremento:
1. **GAME_VERSION (MAJOR.MINOR.PATCH):**
   * **MAJOR:** Quebra arquitetural fundamental no motor ou renderizador.
   * **MINOR:** Novos sistemas centrais de gameplay (ex: Multiplayer na Fase K, Live Content na Fase L).
   * **PATCH:** Correções de bugs, ajustes de física ou correções visuais sem novos sistemas.

2. **CONTENT_VERSION (MAJOR.MINOR.PATCH):**
   * **MAJOR:** Reestruturação de árvores de habilidades de Nen ou remoção de sagas canônicas.
   * **MINOR:** Adição de novas sagas, novas regiões, novos chefes e pacotes de conteúdo.
   * **PATCH:** Ajustes de balanceamento em stats de monstros, tabelas de loot ou correções textuais de diálogos.

3. **SAVE_VERSION (MAJOR.MINOR):**
   * **MAJOR:** Reformulação completa na organização dos dicionários de save.
   * **MINOR:** Adição de novos subsistemas persistentes (ex: collections, 
pc_memories em 2.4).

---

## 2. COMPATIBILIDADE MULTIPLAYER & MATCHMAKING

Em sessões cooperativas online (Fase K):
* O NetworkManager verifica se o cliente possui uma GAME_VERSION compatível com o Host.
* Diferenças em CONTENT_VERSION (ex: jogador com pacote de expansão instalado jogando com amigo que possui apenas o jogo base) são suportadas através de flags de fallback: o jogador que não possui os assets de uma nova saga simplesmente não pode viajar para aquela região restrita, mas ambos podem jogar juntos em qualquer mapa do jogo base.

---

## 3. O QUE ESTÁ IMPLEMENTADO

* **Centralização em ContentVersionConfig:** Ponto único da verdade para as três versões do projeto.
* **Header de Diagnóstico em Saves:** Cada arquivo de save contém o carimbo de versão para acionar o pipeline de migração quando necessário.
* **Consulta Rápida via API:** ContentVersionConfig.get_version_info() retorna um dicionário com todos os metadados de versão para telemetria e interfaces de UI.

---

## 4. O QUE ESTÁ PLANEJADO

1. **Aviso de Versão Desatualizada no Menu Principal:** Notificação gráfica na tela inicial alertando sobre disponibilidade de novos pacotes de conteúdo.
2. **Rejeição Suave de Pacotes Incompatíveis:** O ContentValidator recusando carregar um .tres de saga que exija um GAME_VERSION superior ao instalado.
3. **Log de Auditoria de Versões em Saves:** Histórico de migrações gravado no save para fins de suporte técnico e depuração.

---

## 5. O QUE É FUTURO

1. **Live Patching Delta:** Atualizações automáticas de dados sem download do executável Godot completo através de arquivos de patch .pck.
2. **Compatibilidade Multi-Plataforma com Checksum:** Verificação de paridade de conteúdo entre versões PC, Mobile e Consoles em partidas co-op cross-play.
