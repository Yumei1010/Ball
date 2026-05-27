extends Node

# Placeholder art generator — creates solid-color geometric textures at runtime.
# Blue circle = player, Red triangle = EnemyNormal, Orange diamond = EnemyTracker,
# Green rect = EnemyPatrol, Purple circle = EnemyBounce, White circle/num = bounce counter.

const SIZE := 64

var textures := {}

func _ready() -> void:
	textures["player"] = _make_circle(Color.BLUE, Color.CYAN)
	textures["player_light"] = _make_circle(Color(Color.ROYAL_BLUE, 0.8), Color.CYAN.lightened(0.3))
	textures["enemy_normal"] = _make_triangle(Color.RED, Color.ORANGE_RED)
	textures["enemy_tracker"] = _make_diamond(Color.ORANGE, Color.YELLOW)
	textures["enemy_patrol"] = _make_rect(Color.GREEN, Color.LIME_GREEN)
	textures["enemy_bounce"] = _make_circle(Color.PURPLE, Color.MAGENTA)
	for i: int in range(4):
		textures["bounce_" + str(i)] = _make_number_circle(i)
	textures["icon"] = _make_circle(Color.BLUE, Color.CYAN, 128)

	_apply_to_scene()

func _make_circle(fill: Color, border: Color, p_size := SIZE) -> ImageTexture:
	var img := Image.create(p_size, p_size, false, Image.FORMAT_RGBA8)
	img.fill(Color.TRANSPARENT)
	var cx: float = p_size / 2.0
	var cr: float = p_size / 2.0 - 2
	for y: int in p_size:
		for x: int in p_size:
			var d: float = Vector2(x - cx, y - cx).length()
			if d <= cr:
				img.set_pixel(x, y, fill if d < cr - 2 else border)
	return ImageTexture.create_from_image(img)

func _make_triangle(fill: Color, border: Color) -> ImageTexture:
	var img := Image.create(SIZE, SIZE, false, Image.FORMAT_RGBA8)
	img.fill(Color.TRANSPARENT)
	var cx: float = SIZE / 2.0
	var pts := PackedVector2Array([
		Vector2(cx, 4), Vector2(SIZE - 4, SIZE - 4), Vector2(4, SIZE - 4)
	])
	for y: int in SIZE:
		for x: int in SIZE:
			if Geometry2D.is_point_in_polygon(Vector2(x, y), pts):
				img.set_pixel(x, y, fill)
	for i: int in 3:
		var a: Vector2 = pts[i]
		var b: Vector2 = pts[(i + 1) % 3]
		_draw_line(img, a, b, border)
	return ImageTexture.create_from_image(img)

func _make_diamond(fill: Color, border: Color) -> ImageTexture:
	var img := Image.create(SIZE, SIZE, false, Image.FORMAT_RGBA8)
	img.fill(Color.TRANSPARENT)
	var cx: float = SIZE / 2.0
	var cy: float = SIZE / 2.0
	var pts := PackedVector2Array([
		Vector2(cx, 4), Vector2(SIZE - 4, cy), Vector2(cx, SIZE - 4), Vector2(4, cy)
	])
	for y: int in SIZE:
		for x: int in SIZE:
			if Geometry2D.is_point_in_polygon(Vector2(x, y), pts):
				img.set_pixel(x, y, fill)
	for i: int in 4:
		var a: Vector2 = pts[i]
		var b: Vector2 = pts[(i + 1) % 4]
		_draw_line(img, a, b, border)
	return ImageTexture.create_from_image(img)

func _make_rect(fill: Color, border: Color) -> ImageTexture:
	var img := Image.create(SIZE, SIZE, false, Image.FORMAT_RGBA8)
	img.fill(Color.TRANSPARENT)
	var m: int = 4
	for y: int in m:
		for x: int in m:
			img.set_pixel(x, y, border)
			img.set_pixel(SIZE - 1 - x, y, border)
			img.set_pixel(x, SIZE - 1 - y, border)
			img.set_pixel(SIZE - 1 - x, SIZE - 1 - y, border)
	for y: int in range(m, SIZE - m):
		for x: int in range(m, SIZE - m):
			img.set_pixel(x, y, fill)
	return ImageTexture.create_from_image(img)

func _make_number_circle(num: int) -> ImageTexture:
	var img := Image.create(SIZE, SIZE, false, Image.FORMAT_RGBA8)
	img.fill(Color.TRANSPARENT)
	var cx: float = SIZE / 2.0
	var cr: float = SIZE / 2.0 - 2
	for y: int in SIZE:
		for x: int in SIZE:
			var d: float = Vector2(x - cx, y - cx).length()
			if d <= cr:
				var brightness: float = 1.0 - num * 0.3
				img.set_pixel(x, y, Color(brightness, brightness, brightness))
	return ImageTexture.create_from_image(img)

func _draw_line(img: Image, a: Vector2, b: Vector2, color: Color) -> void:
	var steps: int = int(a.distance_to(b))
	for i: int in steps + 1:
		var t: float = float(i) / max(steps, 1)
		var p: Vector2 = a.lerp(b, t)
		for dx: int in [-1, 0, 1]:
			for dy: int in [-1, 0, 1]:
				var px: int = int(p.x) + dx
				var py: int = int(p.y) + dy
				if px >= 0 and px < SIZE and py >= 0 and py < SIZE:
					img.set_pixel(px, py, color)

func _apply_to_scene() -> void:
	# Walk scene tree and override textures by node name/group
	await get_tree().process_frame
	_apply_recursive(get_tree().root)

func _apply_recursive(node: Node) -> void:
	if node is Sprite2D:
		_override_sprite(node)

	for child: Node in node.get_children():
		_apply_recursive(child)

func _override_sprite(sprite: Sprite2D) -> void:
	var p: Node = sprite.get_parent()
	var tex_key: String = ""
	if p.is_in_group("enemy"):
		var scr: Script = p.get_script()
		if scr:
			var path: String = scr.resource_path
			if "enemy_normal" in path:
				tex_key = "enemy_normal"
			elif "enemy_tracker" in path:
				tex_key = "enemy_tracker"
			elif "enemy_patrol" in path:
				tex_key = "enemy_patrol"
	elif p.is_in_group("bouncing_enemy"):
		tex_key = "enemy_bounce"
	elif p.name == "PlayerBall":
		tex_key = "player" if sprite.name == "Ball" else "player_light"

	if tex_key != "" and textures.has(tex_key):
		sprite.texture = textures[tex_key]
