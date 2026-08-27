class_name CombatComicQuotes
extends Resource

# ============================================================
# HUNTER ONLINE - COMBAT COMIC QUOTES (FALAS DE MANGÁ EM COMBATE)
# ============================================================

static func obter_frase_hatsu(nome_hatsu: String) -> String:
	var n = nome_hatsu.to_lower()
	
	if "pedra" in n or "jajanken" in n:
		return "👊 PRIMEIRO VEM A PEDRA... JAJANKEN!!!"
	elif "tesoura" in n:
		return "✌️ TESOURA! LÂMINA DE TRANSMUTAÇÃO!"
	elif "papel" in n:
		return "🖐️ PAPEL! DISPARO DE EMISSÃO!"
	elif "godspeed" in n or "kanmuru" in n:
		return "⚡ KANMURU: VELOCIDADE DO RELÂMPAGO!"
	elif "narukami" in n or "izutsuchi" in n or "elétr" in n:
		return "⚡ IZUTSUCHI! CHOQUE DE ALTA VOLTAGEM!"
	elif "bungee" in n or "goma" in n:
		return "✨ Bungee Gum tem as propriedades de borracha e goma!"
	elif "textura" in n:
		return "🃏 TEXTURA ENGANOSA! Nada é o que parece..."
	elif "guanyin" in n or "bodhisattva" in n or "palma" in n:
		return "🙏 100-TYPE GUANYIN BODHISATTVA!"
	elif "zero" in n:
		return "☀️ ZERO HAND! Toda a aura da minha vida!"
	elif "big bang" in n:
		return "💥 BIG BANG IMPACT! 100% DE PURA DESTRUIÇÃO!"
	elif "rising sun" in n or "pain packer" in n:
		return "☀️ PAIN PACKER: RISING SUN! QUEIMEM ATÉ AS CINZAS!"
	elif "chain jail" in n or "corrente" in n:
		return "⛓️ CHAIN JAIL! O Julgamento da Corrente!"
	elif "judgement" in n:
		return "⛓️ JUDGEMENT CHAIN! Quebre a regra e seu coração para!"
	elif "emperor" in n or "olhos" in n:
		return "🔴 EMPEROR TIME! 100% de Eficiência em todas as categorias!"
	elif "dragon dive" in n or "chuva" in n:
		return "🐉 DRAGON DIVE: CHUVA DE DRAGÕES!"
	elif "dragon head" in n or "presa" in n:
		return "🐉 DRAGON HEAD: PRESAS DO DRAGÃO!"
	elif "potclean" in n or "hakoware" in n or "juros" in n:
		return "📈 HAKOWARE! Seus juros de aura começam a correr!"
	elif "deep purple" in n or "fumaça" in n:
		return "💨 DEEP PURPLE: SOLDADOS DE FUMAÇA!"
	elif "hide and seek" in n or "quarto" in n:
		return "🚪 HIDE AND SEEK: QUARTO QUADRIDIMENSIONAL!"
	elif "júpiter" in n or "cantabile" in n:
		return "🪐 JÚPITER! ESMAGAMENTO ACÚSTICO!"
	elif "terpsichora" in n or "marionete" in n:
		return "🐱 TERPSICHORA: DANÇA DA MARIONETE DE GUERRA!"
	elif "centauro" in n or "fúria" in n:
		return "🔥 METAMORFOSE DO CENTAURO DE FOGO!"
	elif "escala" in n or "espiritual" in n:
		return "🦋 ESCAMAS ESPIRITUAIS: HIPNOSE COLETIVA!"
	elif "zetsu paralelo" in n or "futuro" in n:
		return "👁️ ZETSU PARALELO: O FUTURO DE 10 SEGUNDOS!"
	else:
		return "✨ %s!!!" % nome_hatsu.to_upper()


static func obter_frase_inimigo_spawn(nome_inimigo: String) -> String:
	var n = nome_inimigo.to_lower()
	if "hisoka" in n:
		return "♠️ Que fruto delicioso... Mostre-me mais da sua aura!"
	elif "chrollo" in n:
		return "📖 A morte não me assusta... Ela apenas contempla nosso destino."
	elif "uvogin" in n:
		return "💥 Quer lutar contra mim? Vou partir você ao meio!"
	elif "meruem" in n or "rei" in n:
		return "👑 Você ousa desafiar o Rei de Todas as Formas de Vida?!"
	elif "pitou" in n or "neferpitou" in n:
		return "🐱 Nyaaa! Sinto uma aura tão deliciosa para brincar!"
	elif "netero" in n:
		return "🙏 O coração agradecido supera todos os limites do Nen!"
	elif "illumi" in n or "gittarackur" in n:
		return "📍 Devo controlar seu cérebro com minhas agulhas..."
	elif "feitan" in n:
		return "Você vai se arrepender de respirar perto de mim."
	elif "kastro" in n:
		return "🐯 Você não conseguirá distinguir meu clone da realidade!"
	elif "genthru" in n or "bombardeiro" in n:
		return "💣 LIBEREM! As bombas estão armadas no seu corpo!"
	elif "razor" in n:
		return "🏐 Segure este arremesso se tiver coragem!"
	elif "canary" in n or "mordomo" in n or "gotoh" in n:
		return "Não permitiremos que ultrapassem esta propriedade."
	elif "formiga" in n or "chimera" in n:
		return "Uma nova presa humana para a colônia!"
	else:
		var genericas = [
			"⚔️ Matem o invasor!",
			"Ele é um Caçador de Nen!",
			"Não recuem, cerquem-no!",
			"Sua aura pertence a nós!"
		]
		return genericas[randi() % genericas.size()]


static func obter_frase_inimigo_ataque(nome_inimigo: String) -> String:
	var n = nome_inimigo.to_lower()
	if "hisoka" in n:
		return "♦️ Bungee Gum nunca solta sua presa!"
	elif "chrollo" in n:
		return "⚡ Segredo do Roubo ativado!"
	elif "uvogin" in n:
		return "BIG BANG IMPACT!"
	elif "meruem" in n:
		return "Submeta-se à ordem natural da força!"
	elif "pitou" in n:
		return "Terpsichora vai dançar com você!"
	elif "netero" in n:
		return "99ª Palma de Guanyin!"
	elif "feitan" in n:
		return "PAIN PACKER!"
	else:
		var frases = ["Morra!", "Tome isso!", "Desapareça!", "Ataquem com tudo!"]
		return frases[randi() % frases.size()]


static func obter_frase_inimigo_ferido(nome_inimigo: String) -> String:
	var n = nome_inimigo.to_lower()
	if "hisoka" in n:
		return "♥️ Maravilhoso... Minha excitação só aumenta!"
	elif "meruem" in n:
		return "Impressionante... Um mero humano capaz de me ferir!"
	elif "pitou" in n:
		return "Não posso falhar... Devo proteger o Rei a todo custo!"
	elif "uvogin" in n:
		return "Essa dor só me deixa mais furioso!"
	elif "feitan" in n:
		return "Mais dor... Mais calor para o Sol Nascente!"
	else:
		var frases = [
			"Ghh... Que força absurda!",
			"Essa aura é monstruosa...!",
			"Maldito Hunter!",
			"Isso não vai terminar aqui!"
		]
		return frases[randi() % frases.size()]
