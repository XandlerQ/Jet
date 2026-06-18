extends CharacterBody2D;
class_name CharacterObject;

#region signals

#endregion

#region fields
# Rotation speed change cap
# Value that limits rotation speed single change
static var RSCC: float = 16. * PI:
	set = set_RSCC;
# Rotational impulse cap
# Value that limits rotational impulse that could be
# applied to the object
var RIC: float;
# Mass
var mass: float = 15:
	set = set_mass;
# Linear size normed to units
var linearSize: float = 4.;
# Moment of inertia
var momentOfInertia: float = 1.;
# Speed, velocity normed to units
var speed: Vector2 = Vector2.ZERO:
	set = set_speed;
# Rotation speed
var rotationSpeed: float = 0.;
#endregion

#region methods
func _ready() -> void:
	derive_linear_size();

func get_collision_shape2d() -> CollisionShape2D:
	return get_child(0) as CollisionShape2D;

func get_sprite2d() -> Sprite2D:
	return get_child(1) as Sprite2D;

func set_RSCC(value: float) -> void:
	RSCC = value;
	update_RIC();

# RIC is set proportionate to RSCC, moment of inertia and linear size
# to keep similar behaviour for different linear sizes and masses
func update_RIC() -> void:
	RIC = RSCC * momentOfInertia / linearSize;

func set_mass(m: float) -> void:
	mass = m;
	update_moment_of_inertia();

# Set linear size as half of max difference
# between x of collision polygon points
func derive_linear_size() -> void:
	var collisionPolygon: ConvexPolygonShape2D = get_collision_shape2d().shape as ConvexPolygonShape2D;
	var collisionPolygonPoints: PackedVector2Array = collisionPolygon.points;
	collisionPolygonPoints.sort();
	linearSize = (collisionPolygonPoints[collisionPolygonPoints.size() - 1][0] - collisionPolygonPoints[0][0]) / 16.;
	update_moment_of_inertia();

func update_moment_of_inertia() -> void:
	momentOfInertia = mass * linearSize * linearSize;
	update_RIC();

func set_speed(v: Vector2) -> void:
	speed = v;
	update_velocity();

func add_to_speed(v: Vector2) -> void:
	speed += v;
	update_velocity();

func set_texture(texture: CanvasTexture) -> void:
	get_sprite2d().texture = texture;

func set_texture_by_path(path: String) -> void:
	set_texture(load(path));

func set_shape(cps: Shape2D) -> void:
	get_collision_shape2d().shape = cps;
	derive_linear_size();

func set_shape_by_path(path: String) -> void:
	set_shape(load(path));

func update_velocity() -> void:
	velocity = speed * 8;

#region impulse and collision
func apply_central_impulse(impulse: Vector2):
	add_to_speed(impulse / mass);

# Applies impulse at point of object, point given in pixels
func apply_impulse_point_relative(impulse: Vector2, point: Vector2):
	apply_impulse_point_relative_normed(impulse, point / 8.);

# Applies impulse at point of object, point given in units (pixels / 8)
func apply_impulse_point_relative_normed(impulse: Vector2, point: Vector2):
	var lever: float = point.length();
	if lever == 0.:
		apply_central_impulse(impulse);
		return;
	var pointDirection: Vector2 = point / lever;
	
	var centralImpulse: Vector2 = impulse.dot(pointDirection) * pointDirection;
	var rotationalImpulse: float = impulse.dot(pointDirection.rotated(PI/2.));
	
	apply_central_impulse(centralImpulse);
	rotationSpeed += rotationalImpulse * lever / momentOfInertia;

# Applies impulse at point of object, point given in pixels with rotational impulse capped with RIC
func apply_impulse_point_relative_rotational_impulse_capped(impulse: Vector2, point: Vector2):
	apply_impulse_point_relative_normed_rotational_impulse_capped(impulse, point / 8.);

# Applies impulse at point of object, point given in units (pixels / 8)
# with rotational impulse capped with RIC
func apply_impulse_point_relative_normed_rotational_impulse_capped(impulse: Vector2, point: Vector2):
	var lever: float = point.length();
	if lever == 0.:
		apply_central_impulse(impulse);
		return;
	var pointDirection: Vector2 = point / lever;
	
	var centralImpulse: Vector2 = impulse.dot(pointDirection) * pointDirection;
	var rotationalImpulse: float = clamp(impulse.dot(pointDirection.rotated(PI/2.)), -RIC, RIC);
	apply_central_impulse(centralImpulse);
	rotationSpeed += rotationalImpulse * lever / momentOfInertia;

# Applies impulse at local point, point given in pixels
func apply_impulse_point_local(impulse: Vector2, pointLocal: Vector2):
	var pointRelative: Vector2 = pointLocal.rotated(rotation);
	apply_impulse_point_relative(impulse, pointRelative);

# Applies impulse at local point, point given in pixels
# with rotational impulse capped with RIC
func apply_impulse_point_local_rotational_impulse_capped(impulse: Vector2, pointLocal: Vector2):
	var pointRelative: Vector2 = pointLocal.rotated(rotation);
	apply_impulse_point_relative_rotational_impulse_capped(impulse, pointRelative);

# Applies impulse at global point, point given in pixels
func apply_impulse_point_global(impulse: Vector2, pointGlobal: Vector2):
	var pointRelative: Vector2 = pointGlobal - position;
	apply_impulse_point_relative(impulse, pointRelative);

# Applies impulse at global point, point given in pixels
# with rotational impulse capped with RIC
func apply_impulse_point_global_rotational_impulse_capped(impulse: Vector2, pointGlobal: Vector2):
	var pointRelative: Vector2 = pointGlobal - position;
	apply_impulse_point_relative_rotational_impulse_capped(impulse, pointRelative);

# Returns normalizing value for rotational vurtual speed
# calculated during collision
func rotational_speed_hat_function(collisionDistance: float) -> float:
	var argument: float = collisionDistance / linearSize;
	var value: float = 0;
	value = 1.8 * exp(-5. * (argument - 0.75) * (argument - 0.75));
	return value;

# Function that returnes virtual linear speed calculated during collision
# Possibly redefined by children for different behaviour
func get_collision_virtual_linear_speed() -> Vector2:
	return speed;

# Function that returnes virtual rotational speed calculated during collision
# Possibly redefined by children for different behaviour
func get_collision_virtual_rotational_speed(collisionDistance: float, collisionDirection: Vector2) -> Vector2:
	return rotational_speed_hat_function(collisionDistance) * rotationSpeed * collisionDistance * collisionDirection.rotated(PI/2.);

func handle_collision(collision: KinematicCollision2D):
	# Get collider
	var collider = collision.get_collider();
	# Impulse conservation ratio
	# Value from 0 to 1 that determines the ratio of conserved kinetic energy
	var conservationRatio: float = 0.7;
	# Get collision normal vector
	var collisionNormal: Vector2 = collision.get_normal();
	# Get collision tangent vector
	var collisionTangent: Vector2 = collisionNormal.rotated(PI/2.);
	# Get local collision position
	var collisionPosition: Vector2 = (collision.get_position() - global_position) / 8.;
	# Distance to collision point
	var collisionDistance: float = collisionPosition.length();
	# Normed vector to collision point
	var collisionDirection: Vector2 = collisionPosition / collisionDistance;
	
	# Introduce virtual rotational speed
	var virtualRotationalSpeed: Vector2 = get_collision_virtual_rotational_speed(collisionDistance, collisionDirection);
	#var rotationalSpeed: Vector2 = rotational_speed_hat_function(collisionDistance) * (momentOfInertia * rotationSpeed / mass) * collisionDirection.rotated(PI/2.);
	# Introduce virtual velocities
	var virtualSpeed: Vector2 = get_collision_virtual_linear_speed() + virtualRotationalSpeed;
	var virtualSpeedN: float = virtualSpeed.dot(collisionNormal);
	var virtualSpeedT: float = virtualSpeed.dot(collisionTangent);
	
	# Define applied impulse
	var deltaImpulseN: float = 0.;
	var deltaImpulseT: float = 0.;
	var deltaImpulse: Vector2 = Vector2.ZERO;
	
	# If collider is static (StaticBody2D or TileMap)
	if collider is StaticBody2D or collider is TileMap:
		# Handle object collision
		# Calculate applied impulse
		deltaImpulseN = - 2. * mass * virtualSpeedN;
		deltaImpulseT = 0.;
		deltaImpulse = deltaImpulseN * collisionNormal + deltaImpulseT * collisionTangent;
		# Apply conservation ratio
		deltaImpulse *= conservationRatio;
		# Apply impulse
		apply_impulse_point_relative_normed_rotational_impulse_capped(deltaImpulse, collisionPosition);
	# If collider is rigid
	if collider is RigidBody2D or collider is RigidObject:
		# Get collider kinetic properties
		var colliderMass: float = collider.mass;
		var colliderSpeed: Vector2 = collision.get_collider_velocity() / 8;
		var colliderSpeedN: float = colliderSpeed.dot(collisionNormal);
		var colliderSpeedT: float = colliderSpeed.dot(collisionTangent);
		# Handle object collision
		# Calculate applied impulse
		deltaImpulseN = mass * 2. * colliderMass * (colliderSpeedN - virtualSpeedN) / (mass + colliderMass);
		deltaImpulseT = 0.;
		deltaImpulse = deltaImpulseN * collisionNormal + deltaImpulseT * collisionTangent;
		# Apply conservation ratio
		deltaImpulse *= conservationRatio;
		# Apply impulse
		apply_impulse_point_relative_normed_rotational_impulse_capped(deltaImpulse, collisionPosition);
		
		# Handle collider collision
		# Apply impulse in the opposite direction
		print(collision.get_position() - collider.global_position)
		collider.apply_impulse(-8 * deltaImpulse, collision.get_position() - collider.global_position);
#endregion

#endregion
