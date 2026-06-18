extends Node2D;
class_name PlayerInput;

#region signals
signal mouseMoved(hrmin: float);
#endregion

#region fields
# Sensitivity
var SENSITIVTY: float = 1/64.;
# Horizontal relative mouse input normalized
var hrmin: float = 0;
# Mouse input flag
var mouseInput: bool = false;

#endregion

#region methods
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED;

func _physics_process(_delta: float) -> void:
	mouseInput = false;

func _unhandled_input(event) -> void:
	if event is InputEventMouseMotion:
		var rmi = event.relative;
		hrmin = clamp(rmi[0] * SENSITIVTY, -1., 1.);
		mouseInput = true;
		mouseMoved.emit(hrmin);

static func input_thrust_up() -> bool:
	return Input.is_action_pressed("Forward");

static func input_thrust_down() -> bool:
	return Input.is_action_pressed("Back");

static func input_overcharge() -> bool:
	return Input.is_action_pressed("Overcharge");

static func input_booster() -> bool:
	return Input.is_action_just_pressed("Booster");

static func input_gravibrake() -> bool:
	return Input.is_action_pressed("Gravibrake");

static func input_direction() -> Vector2:
	return Input.get_vector("Left", "Right", "Forward", "Back");

static func input_fire() -> bool:
	return Input.is_action_just_pressed("Fire");

#endregion
