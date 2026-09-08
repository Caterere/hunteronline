extends SceneTree

func _init():
	var colors = [
		Color("573a23"), # Hair Base
		Color("402717"), # Hair Shadow
		Color("21110d"), # Hair Deep
		Color("c1ac8f"), # Skin Light
		Color("ac7b5d"), # Skin Shadow
		Color("9a5c42"), # Skin Deep Crease
		Color("a4a8b5"), # Cloth Light
		Color("787e97"), # Cloth Shadow
		Color("2c65b5"), # Accent / Pants Blue
		Color("1d438a"), # Accent / Pants Blue Shadow
		Color("0d205e"), # Accent Dark Crease
		Color("ffffff"), # Weapon Highlight
		Color("dbd2c7"), # Weapon Metal
		Color("000000"), # Black Outline / Eyes
		Color("0c0e19")  # Dark Outline / Body
	]
	var img = Image.create(colors.size(), 1, false, Image.FORMAT_RGBA8)
	for i in range(colors.size()):
		img.set_pixel(i, 0, colors[i])
	img.save_png("res://assets/sprites/characters/master_palette.png")
	print("Master palette saved with %d colors to res://assets/sprites/characters/master_palette.png" % colors.size())
	quit(0)
