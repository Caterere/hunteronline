# GUIA DE CRIAÇÃO DE REGIÕES — REGION CREATION GUIDE

> **Manual de Criação, Identidade Regional e Rotas de Viagem no Hunter MMORPG**
> **Versão:** 1.0 (Fase L) | **Engine:** Godot 4.6 Stable

---

## 1. ESTRUTURA DE UMA REGIÃO (REGION PACKAGE)

Regiões no Hunter MMORPG são encapsuladas no recurso RegionPackage (es://resource/region/RegionPackage.gd). Cada pacote define cenografia, atmosfera, segurança, pontos de interesse e conexões de trânsito.

### 1.1 Exemplo de Construção em GDScript:
`gdscript
var reg := RegionPackage.new(
    & selva_misteriosa,           # region_id
    Selva Misteriosa de Nen,     # region_name
    res://world/maps/selva.tscn, # scene_path
    RegionPackage.DangerLevel.MEDIUM
)
reg.description = Florestas densas com concentração instável de aura selvagem.
reg.ambient_music = res://osts/floresta_ancestral.mp3
reg.ambient_weather = [0, 1, 2] # Limpo, Chuva, Neblina
reg.recommended_level = Vector2i(25, 60)

# Identidade Visual e Atmosférica
reg.regional_identity = {
    lighting_tint: Color(0.85, 0.95, 0.85, 1.0),
    ambient_sfx: selva_vento_folhas,
    unique_mechanic: neblina_bloqueio_visao,
    risk_pacing: moderate
}

# Pontos de Interesse (POIs) e Segredos
reg.points_of_interest = [
    {poi_id: acampamento_base, name: Acampamento Avançado, type: outpost, coords: [100, 250]},
    {poi_id: lago_sagrado, name: Lago da Cura, type: shrine, coords: [420, 800]}
]
reg.secrets = [
    {secret_id: caverna_escondida, name: Entrada Subterrânea, hint: Atrás da cachoeira oeste.}
]

# Conexão de Viagem
reg.add_travel_route(&cidade_yorknew, RegionPackage.TravelType.AIRSHIP, 500, true)

# Registro no TravelSystem
TravelSystem.register_region_package(reg)
`

---

## 2. MODOS DE VIAGEM SUPORTADOS

O TravelSystem suporta os seguintes meios de transporte:
1. FOOT (0) — Trânsito a pé através de portais e saídas de mapa diretas (custo 0).
2. BOAT (1) — Viagem de barco por portos autorizados.
3. AIRSHIP (2) — Dirigíveis para transporte entre grandes cidades e continentes.
4. VEHICLE (3) — Carros e trens terrestres.
5. TRAVEL_MASTER (4) — NPCs guias que teletransportam caçadores credenciados.
6. SPECIAL_TRANSIT (5) — Passagens secretas desbloqueadas por quests ou Hatsu.

---

## 3. O QUE ESTÁ IMPLEMENTADO

* **RegionPackage:** Estrutura completa de metadados, clima, perigo, POIs e iluminação.
* **TravelSystem Autoload:** Armazena pacotes de regiões, consulta rotas disponíveis, valida fundos de Jenny do jogador e controla rotas desbloqueadas com persistência no save.
* **Classificação de Perigo Canônica:** 5 níveis de perigo (SAFE, LOW, MEDIUM, HIGH, CALAMITY).
* **Segredos Ocultos Sem GPS:** Sistema de pistas descritivas para exploração investigativa real.

---

## 4. O QUE ESTÁ PLANEJADO

1. **Travel Cutscenes & Fast Travel Visual:** Animações intermediárias de dirigível e barco cruzando o mapa global durante a tela de transição.
2. **Emboscadas em Trânsito (Travel Encounters):** Chance percentual de ataque de monstros ou bandidos durante rotas perigosas.
3. **Restrições de Clima Dinâmico para Viagens:** Tempestades fechando rotas aéreas e obrigando o uso de rotas terrestres alternativas.

---

## 5. O QUE É FUTURO

1. **Streaming Contínuo de Mapas Adjacentes:** Carregamento em segundo plano de regiões vizinhas para transições sem tela preta.
2. **Rotas Controladas por Facções:** Bairros e portos cobrando taxas variáveis dependendo do status de alinhamento político da guilda do jogador.
