extends Ship;
class_name ShipPlayer;

#region signals

#endregion

#region fields


#endregion

#region methods
func _physics_process(delta):
	add_to_thrust(delta * 1.5 * PlayerInput.input_thrust_modify_value());
	print(velocity);
	apply_accelerations(delta);
	move_and_slide();
	rotate_to_target(delta, get_global_mouse_position())
#endregion

