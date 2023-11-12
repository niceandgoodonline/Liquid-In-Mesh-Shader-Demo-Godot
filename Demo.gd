# @tool
extends Node3D

@export_group("Rotation Example")
@export var RotationExample: Node3D
@export var rotationExampleIsActive     : bool = true
@export var rotationExampleIsRotating   : bool = true
@export var rotationExampleIsTranslating: bool = true
@export_range(0.0, 16.0, 0.1) var rotationExampleRotationSpeed  : float = 1.0
@export_range(0.0, 5.0, 0.1) var rotationExampleTranslatingSpeed: float = 0.5
@export_range(0.0, 2.0, 0.1) var rotationExampleTranslationRange: float = 0.5
var rotationExampleRotationDirection     : Vector3 = Vector3(1.0, 1.0, 1.0)
var rotationExampleSwitchRotationSentinel: float = 25.0
var rotationExampleSwitchRotationTracker : float = 0.0
var rotationExampleTranslationTarget: Vector3

@export_group("Smooth Movement Example")
@export var SmoothExample: Node3D
@export var smoothExampleIsActive     : bool = true
@export var smoothExampleIsRotating   : bool = true
@export var smoothExampleIsTranslating: bool = true
@export_range(0.0, 16.0, 0.1) var smoothExampleRotationSpeed  : float = 1.0
@export_range(0.0, 5.0, 0.1) var smoothExampleTranslatingSpeed: float = 0.5
@export_range(0.0, 2.0, 0.1) var smoothExampleTranslationRange: float = 0.5
var smoothExampleOrigin: Vector3
var smoothExampleRotationDirection     : Vector3 = Vector3(1.0, 1.0, 1.0)
var smoothExampleSwitchRotationSentinel: float = 25.0
var smoothExampleSwitchRotationTracker : float = 0.0
var smoothExampleTranslationTarget: Vector3

@export_group("Intense Movement Example")
@export var IntenseExample: Node3D
@export var intenseExampleIsActive     : bool = true
@export var intenseExampleIsRotating   : bool = true
@export var intenseExampleIsTranslating: bool = true
@export_range(0.0, 16.0, 0.1) var intenseExampleRotationSpeed  : float = 1.0
@export_range(0.0, 5.0, 0.1) var intenseExampleTranslatingSpeed: float = 0.5
@export_range(0.0, 16.0, 0.1) var intenseExampleTranslationRange: float = 0.5
var intenseExampleOrigin: Vector3
var intenseExampleRotationDirection      : Vector3 = Vector3(1.0, 1.0, 1.0)
var intenseExampleSwitchRotationSentinel : float = 25.0
var intenseExampleSwitchRotationTracker  : float = 0.0
var intenseExampleTranslationTarget      : Vector3

func _ready():
	rotationExampleRotationDirection = randomizeRotationSpeeds()
	smoothExampleRotationDirection   = randomizeRotationSpeeds()
	intenseExampleRotationDirection  = randomizeRotationSpeeds()
	print(rotationExampleRotationDirection)

	rotationExampleTranslationTarget = RotationExample.position + Vector3.UP * rotationExampleTranslationRange

	smoothExampleOrigin             = SmoothExample.position
	intenseExampleOrigin            = IntenseExample.position
	smoothExampleTranslationTarget  = randomizeTranslationTarget(smoothExampleOrigin, smoothExampleTranslationRange)
	intenseExampleTranslationTarget = randomizeTranslationTarget(intenseExampleOrigin, intenseExampleTranslationRange)

func randomizeRotationSpeeds() -> Vector3:
	return Vector3(randf_range(0.0, 1.0), randf_range(0.0, 1.0), randf_range(0.0, 1.0))

func randomizeTranslationTarget(origin, targetRange, minRange = 0.0) -> Vector3:
	return origin + Vector3(randf_range(minRange, targetRange), randf_range(minRange, targetRange), randf_range(minRange, targetRange))

func _physics_process(delta):
	if rotationExampleIsActive:
		do_rotation_example(delta)
	if smoothExampleIsActive:
		do_smooth_example(delta)
	if intenseExampleIsActive:
		do_intense_example(delta)

func do_rotation_example(delta):
	if rotationExampleIsRotating:
		rotationExampleSwitchRotationTracker += delta
		if rotationExampleSwitchRotationTracker >= rotationExampleSwitchRotationSentinel:
			rotationExampleRotationDirection = randomizeRotationSpeeds()
			rotationExampleSwitchRotationTracker = 0.0
		RotationExample.rotation += delta * rotationExampleRotationDirection * rotationExampleRotationSpeed
	if rotationExampleIsTranslating:
		RotationExample.position.y = lerp(RotationExample.position.y, rotationExampleTranslationTarget.y, rotationExampleTranslatingSpeed * delta)
		if RotationExample.position.distance_to(rotationExampleTranslationTarget) <= 0.1:
			rotationExampleTranslationTarget = Vector3(rotationExampleTranslationTarget.x, rotationExampleTranslationTarget.y * -1, rotationExampleTranslationTarget.z)

func do_smooth_example(delta):
	if smoothExampleIsRotating:
		smoothExampleSwitchRotationTracker += delta
		if smoothExampleSwitchRotationTracker >= smoothExampleSwitchRotationSentinel:
			smoothExampleRotationDirection = randomizeRotationSpeeds()
			smoothExampleSwitchRotationTracker = 0.0
		SmoothExample.rotation += delta * smoothExampleRotationDirection * smoothExampleRotationSpeed 
	if smoothExampleIsTranslating:
		SmoothExample.position = lerp(SmoothExample.position, smoothExampleTranslationTarget, smoothExampleTranslatingSpeed * delta)
		if SmoothExample.position.distance_to(smoothExampleTranslationTarget) <= 0.1:
			smoothExampleTranslationTarget = randomizeTranslationTarget(smoothExampleOrigin, smoothExampleTranslationRange)


func do_intense_example(delta):
	if intenseExampleIsRotating:
		intenseExampleSwitchRotationTracker += delta
		if intenseExampleSwitchRotationTracker >= intenseExampleSwitchRotationSentinel:
			smoothExampleRotationDirection = randomizeRotationSpeeds()
			intenseExampleSwitchRotationTracker = 0.0
		IntenseExample.rotation += delta * intenseExampleRotationDirection * intenseExampleRotationSpeed 
	if intenseExampleIsTranslating:
		IntenseExample.position = lerp(IntenseExample.position, intenseExampleTranslationTarget, intenseExampleTranslatingSpeed * delta)
		if IntenseExample.position.distance_to(intenseExampleTranslationTarget) <= 0.1:
			intenseExampleTranslationTarget = randomizeTranslationTarget(intenseExampleOrigin, intenseExampleTranslationRange)
