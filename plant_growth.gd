extends Node2D

var _image = Image.new()
var _texture
var _time = 0
var processNumber = 0
@export var _sprite : Sprite2D
var curves : Array
var _packedByteArray : PackedByteArray
const SIZE = 64

var startPoint = Vector2.ZERO

func _ready():
	_packedByteArray.resize(SIZE * SIZE * 4)
	_packedByteArray.fill(0)
	addCurve(Vector2i(32, 64), Vector2i(16, 48))
	addCurve(Vector2i(32, 64), Vector2i(31, 40))
	addCurve(Vector2i(32, 64), Vector2i(48, 48))

func _process(delta: float) -> void:
	drawCurve(delta)

func addCurve(initialPoint : Vector2i, finalPoint : Vector2i):
	var curve : Array
	initialPoint.y = SIZE - initialPoint.y
	finalPoint.y = SIZE - finalPoint.y
	var divisionAmount = 0
	var t = 0
	while(t <= 1):
		var middlePoint = Vector2((initialPoint.x + finalPoint.x) / 2, finalPoint.y)
		var endpoint = bezierCurve(t, initialPoint, middlePoint, finalPoint)
		curve.push_back(Vector2i(endpoint.x - 1, SIZE - endpoint.y - 1))
		divisionAmount = derivativeBezierCurve(t, initialPoint, middlePoint, finalPoint)
		t += divisionAmount
	curves.push_back(curve)

func bezierCurve(t, initialPoint, middlePoint, finalPoint) -> Vector2i:
	var xComponent = (1 - t) * (1 - t) * initialPoint.x + 2 * (1 - t) * t * middlePoint.x + t * t * finalPoint.x
	var yComponent = (1 - t) * (1 - t) * initialPoint.y + 2 * (1 - t) * t * middlePoint.y + t * t * finalPoint.y
	return Vector2i(round(xComponent), round(yComponent))

func derivativeBezierCurve(t, initialPoint, middlePoint, finalPoint) -> float:
	var xDerivative = 2 * (1 - t) * (middlePoint.x - initialPoint.x) + 2 * t * (finalPoint.x - middlePoint.x)
	var yDerivative = 2 * (1 - t) * (middlePoint.y - initialPoint.y) + 2 * t * (finalPoint.y - middlePoint.y)
	var totalDerivative = max(abs(xDerivative), abs(yDerivative))
	return 1.0 / totalDerivative

func drawCurve(delta: float):
	var atLeastOnce = true
	_time += delta
	if(_time > 0.25 && atLeastOnce):
		atLeastOnce = false
		for x in curves.size():
			if(processNumber < curves[x].size()):
				atLeastOnce = true
				drawCircle(curves[x][processNumber])
		_time = 0
		processNumber += 1
	_image.set_data(SIZE, SIZE, false, Image.FORMAT_RGBA8, _packedByteArray)
	_texture = ImageTexture.create_from_image(_image)
	_sprite.texture = _texture	

func drawCircle(pos : Vector2i):
	var index = (pos.x + pos.y * (SIZE)) * 4
	changeToGreen(index)
	if(pos.y > 0):
		changeToGreen(index - SIZE * 4)
	if(pos.y < SIZE - 1):
		changeToGreen(index + SIZE * 4)

func changeToGreen(index : int):
	_packedByteArray.set(index + 1, 255)
	_packedByteArray.set(index + 3, 255)
