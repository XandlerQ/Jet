extends Ship;
class_name ShipPlayer;

#region signals

#endregion

#region fields
@onready var playerInputNode: PlayerInput = $PlayerInput;
#endregion

#region methods
func input_target_thrust() -> void:
	if PlayerInput.input_thrust_up() and PlayerInput.input_thrust_down():
		set_target_thrust_state(targetThrustStates.ZERO);
	elif PlayerInput.input_thrust_up():
		if PlayerInput.input_overcharge():
			set_target_thrust_state(targetThrustStates.OFWD);
		else:
			set_target_thrust_state(targetThrustStates.FWD);
	elif PlayerInput.input_thrust_down():
		if PlayerInput.input_overcharge():
			set_target_thrust_state(targetThrustStates.OBWD);
		else:
			set_target_thrust_state(targetThrustStates.BWD);
	else:
		set_target_thrust_state(targetThrustStates.ZERO);

func input_target_rotation_thrust(hrmin: float) -> void:
	set_target_rotation_thrust(hrmin);

func _physics_process(delta) -> void:
	if Input.is_action_just_pressed("Test"):
		apply_impulse_point_local_rotational_impulse_capped(RIC * Vector2(0, 1), Vector2(linearSize * 8, 0));
		#apply_impulse_point_relative_rotational_impulse_capped(8000. * Vector2(0, 1), Vector2(42, 0).rotated(-rotation));
	# Handle movement
	input_target_thrust();
	update_thrust(delta);
	update_rotation_thrust(delta);
	accelerate(delta);
	if PlayerInput.input_booster():
		apply_booster(PlayerInput.input_direction().rotated(rotation + PI / 2.));
	if PlayerInput.input_gravibrake():
		gravibrake(delta);
	if !playerInputNode.mouseInput:
		set_target_rotation_thrust(0.);
		#lower_rotation_thrust(delta);
	update_rotation(delta);
	# Handle collisions
	# Get collision flag
	var collided: bool = move_and_slide();
	# If collision happened
	if (collided):
		# For every collider
		for collId in get_slide_collision_count():
			# Get  collision
			var collision: KinematicCollision2D = get_slide_collision(collId);
			handle_collision(collision);
	# Handle firing
	if PlayerInput.input_fire():
		$Weapon.fire();
#endregion

func _on_player_input_mouse_moved(hrmin) -> void:
	input_target_rotation_thrust(hrmin);
