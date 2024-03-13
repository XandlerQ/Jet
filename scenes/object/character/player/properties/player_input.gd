extends Node2D;
class_name PlayerInput;

#region signals

#endregion

#region fields

#endregion

#region methods
static func input_thrust_up() -> bool:
	return Input.is_action_pressed("Forward");

static func input_thrust_down() -> bool:
	return Input.is_action_pressed("Back");

static func input_thrust_modify_value() -> float:
	return float(PlayerInput.input_thrust_up()) - float(PlayerInput.input_thrust_down());

static func input_direction() -> Vector2:
	return Input.get_vector("Left", "Right", "Forward", "Back");
#endregion

