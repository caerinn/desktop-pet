extends Node2D

var speed = 300
var direction = Vector2(1,0)
var screenSize = Vector2()
var windowSize = Vector2(200, 200)

var idleTimer = 0.0
var isIdling = false

var isDragging = false
var dragOffset = Vector2()

@onready var animatedSprite = $AnimatedSprite2D
@onready var area = $Area2D

func _ready():
	screenSize = Vector2(DisplayServer.screen_get_size())
	animatedSprite.play("walk_right")
	area.input_event.connect(_on_area_input)

func _physics_process(delta: float) -> void:
	if isDragging:
		var mousePos = Vector2(DisplayServer.mouse_get_position())
		var newWinPos = mousePos - dragOffset
		DisplayServer.window_set_position(Vector2i(newWinPos))
		return
	
	if isIdling:
		idleTimer -= delta
		if idleTimer <= 0:
			isIdling = false
			speed = 300
			animatedSprite.play("walk_right")
		return
		
	var windowPosition = Vector2(DisplayServer.window_get_position())
	windowPosition += direction * speed * delta
	print(windowPosition)
	windowPosition.x = clamp(windowPosition.x, 0, screenSize.x - windowSize.x)
	windowPosition.y = clamp(windowPosition.y, 0, screenSize.y - windowSize.y)
	DisplayServer.window_set_position(Vector2i(windowPosition))
		
	if windowPosition.x <= 0 or windowPosition.x >= screenSize.x - windowSize.x:
		direction.x *= -1
		animatedSprite.flip_h = !animatedSprite.flip_h
		maybeIdle()
	if windowPosition.y <=0 or windowPosition.y >= screenSize.y - windowSize.y:
		direction.y *= -1
		maybeIdle()

func maybeIdle():
	if randf() < 0.3:
		isIdling = true
		idleTimer = randf_range(1.0, 3.0)
		var r = randi() % 3
		if r == 0:
			animatedSprite.play("idle")
			speed = 0

func _on_area_input(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			isDragging = true
			var mousePos = Vector2(DisplayServer.mouse_get_position())
			var winPos = Vector2(DisplayServer.window_get_position())
			dragOffset = mousePos - winPos
		else:
			isDragging = false
