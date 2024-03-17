extends Ship;
class_name ShipPlayer;

#region signals

#endregion

#region fields


#endregion

#region methods
func _physics_process(delta):
	add_to_thrust(delta * 0.5 * PlayerInput.input_thrust_modify_value());
	print(velocity);
	apply_accelerations(delta);
	
	rotate_to_target(delta, get_global_mouse_position());
	var collided: bool = move_and_slide();
	if (collided):
		for collId in get_slide_collision_count():
			var collision = get_slide_collision(collId);
			var collider = collision.get_collider();
			if collider is RigidBody2D:
				collider.apply_central_impulse(-mass * velocity.length() * collision.get_normal());
#endregion

