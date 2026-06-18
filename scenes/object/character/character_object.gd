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

# Coefficient of restitution
# Value from 0 to 1 that determines the ratio of conserved collision velocity
var c: float = 0.7;

# Friction / roughness coefficient
var mu: float = 0.4;

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
func cross_vector_vector(a: Vector2, b: Vector2) -> float:
	return a.x * b.y - a.y * b.x;

func angular_velocity_to_linear_velocity(rotationSpeedValue: float, point: Vector2) -> Vector2:
	return rotationSpeedValue * point.rotated(PI/2.);

func get_point_velocity_relative_normed(point: Vector2) -> Vector2:
	return speed + angular_velocity_to_linear_velocity(rotationSpeed, point);

func get_collision_tangent(collisionNormal: Vector2, relativeVelocity: Vector2) -> Vector2:
	var tangentNonNormed: Vector2 = relativeVelocity - relativeVelocity.dot(collisionNormal) * collisionNormal;
	if tangentNonNormed.length() == 0.:
		return Vector2.ZERO;
	return tangentNonNormed.normalized();

func apply_central_impulse(impulse: Vector2):
	add_to_speed(impulse / mass);

# Applies impulse at point of object, point given in pixels
func apply_impulse_point_relative(impulse: Vector2, point: Vector2):
	apply_impulse_point_relative_normed(impulse, point / 8.);

# Applies impulse at point of object, point given in units (pixels / 8)
func apply_impulse_point_relative_normed(impulse: Vector2, point: Vector2):
	apply_central_impulse(impulse);
	rotationSpeed += cross_vector_vector(point, impulse) / momentOfInertia;

# Applies impulse at point of object, point given in pixels with impulse capped with RIC
func apply_impulse_point_relative_rotational_impulse_capped(impulse: Vector2, point: Vector2):
	apply_impulse_point_relative_normed_rotational_impulse_capped(impulse, point / 8.);

# Applies impulse at point of object, point given in units (pixels / 8)
# with rotational impulse capped with RIC
func apply_impulse_point_relative_normed_rotational_impulse_capped(impulse: Vector2, point: Vector2):
	var rotationalImpulse: float = cross_vector_vector(point, impulse);
	if rotationalImpulse == 0.:
		apply_central_impulse(impulse);
		return;
	
	var rotationalImpulseCapped: float = clamp(rotationalImpulse, -RIC, RIC);
	var impulseCapped: Vector2 = impulse * rotationalImpulseCapped / rotationalImpulse;
	
	apply_central_impulse(impulseCapped);
	rotationSpeed += rotationalImpulseCapped / momentOfInertia;

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

func get_collider_mass(collider) -> float:
	if collider is CharacterObject:
		return collider.mass;
	if collider is RigidObject:
		return collider.mass;
	return INF;

func get_collider_moment_of_inertia(collider) -> float:
	if collider is CharacterObject:
		return collider.momentOfInertia;
	if collider is RigidObject:
		return collider.get_collision_moment_of_inertia();
	return INF;

func get_collider_restitution(collider) -> float:
	if collider is CharacterObject:
		return collider.c;
	if collider is RigidObject:
		return collider.c;
	return c;

func get_collider_mu(collider) -> float:
	if collider is CharacterObject:
		return collider.mu;
	if collider is RigidObject:
		return collider.mu;
	return mu;

func get_collider_point_velocity_relative_normed(collider, point: Vector2, collision: KinematicCollision2D) -> Vector2:
	if collider is CharacterObject:
		return collider.get_point_velocity_relative_normed(point);
	if collider is RigidObject:
		return collider.get_point_velocity_relative_normed(point);
	return collision.get_collider_velocity() / 8.;

func apply_impulse_to_collider(collider, impulse: Vector2, pointGlobal: Vector2):
	if collider is CharacterObject:
		collider.apply_impulse_point_global(-impulse, pointGlobal);
		return;
	if collider is RigidObject:
		collider.apply_impulse_point_global(-impulse, pointGlobal);
		return;

func handle_static_collision(collision: KinematicCollision2D):
	# Get collision normal vector
	var collisionNormal: Vector2 = collision.get_normal();
	# Get local collision position
	var collisionPosition: Vector2 = (collision.get_position() - global_position) / 8.;
	
	# Relative velocity at collision point
	var relativeVelocity: Vector2 = get_point_velocity_relative_normed(collisionPosition) - collision.get_collider_velocity() / 8.;
	var relativeVelocityN: float = relativeVelocity.dot(collisionNormal);
	if relativeVelocityN >= 0.:
		return;
	
	# Calculate tangent
	var collisionTangent: Vector2 = get_collision_tangent(collisionNormal, relativeVelocity);
	
	# Calculate impulse
	var collisionPositionCrossNormal: float = cross_vector_vector(collisionPosition, collisionNormal);
	var impulseDenominator: float = (
		1. / mass
		+ collisionPositionCrossNormal * collisionPositionCrossNormal / momentOfInertia
	);
	
	if impulseDenominator == 0.:
		return;
	
	var J: float = -(1. + c) * min(relativeVelocityN, 0.) / impulseDenominator;
	var deltaImpulse: Vector2 = J * (collisionNormal - mu * collisionTangent);
	
	# Apply impulse
	apply_impulse_point_relative_normed_rotational_impulse_capped(deltaImpulse, collisionPosition);

func handle_rigid_collision(collision: KinematicCollision2D):
	# Get collider
	var collider = collision.get_collider();
	# Get collision normal vector
	var collisionNormal: Vector2 = collision.get_normal();
	# Get global collision position
	var collisionPositionGlobal: Vector2 = collision.get_position();
	# Get local collision positions
	var collisionPosition: Vector2 = (collisionPositionGlobal - global_position) / 8.;
	var colliderCollisionPosition: Vector2 = (collisionPositionGlobal - collider.global_position) / 8.;
	
	# Get collider kinetic properties
	var colliderMass: float = get_collider_mass(collider);
	var colliderMomentOfInertia: float = get_collider_moment_of_inertia(collider);
	if colliderMass == INF or colliderMomentOfInertia == INF:
		return;
	
	# Relative velocity at collision point
	var pointVelocity: Vector2 = get_point_velocity_relative_normed(collisionPosition);
	var colliderPointVelocity: Vector2 = get_collider_point_velocity_relative_normed(collider, colliderCollisionPosition, collision);
	var relativeVelocity: Vector2 = pointVelocity - colliderPointVelocity;
	var relativeVelocityN: float = relativeVelocity.dot(collisionNormal);
	if relativeVelocityN >= 0.:
		return;
	
	# Calculate tangent
	var collisionTangent: Vector2 = get_collision_tangent(collisionNormal, relativeVelocity);
	
	# Take average restitution and roughness
	var averageC: float = (c + get_collider_restitution(collider)) / 2.;
	var averageMu: float = (mu + get_collider_mu(collider)) / 2.;
	
	# Calculate impulse
	var collisionPositionCrossNormal: float = cross_vector_vector(collisionPosition, collisionNormal);
	var colliderCollisionPositionCrossNormal: float = cross_vector_vector(colliderCollisionPosition, collisionNormal);
	var impulseDenominator: float = (
		1. / mass
		+ 1. / colliderMass
		+ collisionPositionCrossNormal * collisionPositionCrossNormal / momentOfInertia
		+ colliderCollisionPositionCrossNormal * colliderCollisionPositionCrossNormal / colliderMomentOfInertia
	);
	
	if impulseDenominator == 0.:
		return;
	
	var J: float = -(1. + averageC) * min(relativeVelocityN, 0.) / impulseDenominator;
	var deltaImpulse: Vector2 = J * (collisionNormal - averageMu * collisionTangent);
	
	# Apply impulse to this object
	apply_impulse_point_relative_normed_rotational_impulse_capped(deltaImpulse, collisionPosition);
	
	# Apply impulse to collider
	apply_impulse_to_collider(collider, deltaImpulse, collisionPositionGlobal);

func handle_collision(collision: KinematicCollision2D):
	# Get collider
	var collider = collision.get_collider();
	
	# If collider is static, handle as infinite mass object
	if collider is StaticBody2D or collider is TileMap:
		handle_static_collision(collision);
		return;
	
	# If collider is rigid, handle with two-body impulse equation
	if collider is RigidObject or collider is CharacterObject:
		handle_rigid_collision(collision);
		return;
#endregion

#endregion
