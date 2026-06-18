extends RigidBody2D;
class_name RigidObject;

#region signals

#endregion

#region fields
# Property integrity node
@onready var objectPropertyIntegrity: ObjectPropertyIntegrity = $ObjectPropertyIntegrity;

# Coefficient of restitution
# Value from 0 to 1 that determines the ratio of conserved collision velocity
@export_range(0., 1.) var c: float = 0.7;

# Friction / roughness coefficient
@export_range(0., 2.) var mu: float = 0.4;

# Linear size normed to units
# Can be set by children / builders
@export var linearSize: float = 2.;

# Moment of inertia, normed to units
var momentOfInertia: float = 1.;
#endregion

#region methods
func _ready() -> void:
	update_moment_of_inertia();

func get_collision_shape2d() -> CollisionShape2D:
	return get_child(0) as CollisionShape2D;

func get_sprite2d() -> Sprite2D:
	return get_child(1) as Sprite2D;

func get_hurtbox_shape2d() -> CollisionShape2D:
	return get_child(3).get_child(0) as CollisionShape2D;

func set_shape(cps: Shape2D) -> void:
	get_collision_shape2d().shape = cps;
	derive_linear_size();
	update_moment_of_inertia();

func set_shape_by_path(path: String) -> void:
	set_shape(load(path));

func set_hurtbox_shape(cps: Shape2D) -> void:
	get_hurtbox_shape2d().shape = cps;

func set_hurtbox_shape_by_path(path: String) -> void:
	set_hurtbox_shape(load(path));

func match_hurtbox_shape() -> void:
	get_hurtbox_shape2d().shape = get_collision_shape2d().shape;

func set_texture(texture: CanvasTexture) -> void:
	get_sprite2d().texture = texture;

func set_texture_by_path(path: String) -> void:
	set_texture(load(path));

func set_texture_shape_coupling(tsc: TextureShapeCoupling) -> void:
	set_texture(tsc.texture);
	set_shape(tsc.shape);

func cross_vector_vector(a: Vector2, b: Vector2) -> float:
	return a.x * b.y - a.y * b.x;

func angular_velocity_to_linear_velocity(rotationSpeedValue: float, point: Vector2) -> Vector2:
	return rotationSpeedValue * point.rotated(PI/2.);

func derive_linear_size() -> void:
	var collisionShape: Shape2D = get_collision_shape2d().shape;
	
	if collisionShape is ConvexPolygonShape2D:
		
		var collisionPolygon: ConvexPolygonShape2D = collisionShape as ConvexPolygonShape2D;
		var collisionPolygonPoints: PackedVector2Array = collisionPolygon.points;
		
		collisionPolygonPoints.sort();
		linearSize = (collisionPolygonPoints[collisionPolygonPoints.size() - 1][0] - collisionPolygonPoints[0][0]) / 16.;

func update_moment_of_inertia() -> void:
	momentOfInertia = mass * linearSize * linearSize;

func get_point_velocity_relative_normed(point: Vector2) -> Vector2:
	return linear_velocity / 8. + angular_velocity_to_linear_velocity(angular_velocity, point);

func get_collision_moment_of_inertia() -> float:
	update_moment_of_inertia();
	return momentOfInertia;

# Applies impulse at point of object, point given in pixels
func apply_impulse_point_relative(impulse: Vector2, point: Vector2):
	apply_impulse(8. * impulse, point);

# Applies impulse at point of object, point given in units
func apply_impulse_point_relative_normed(impulse: Vector2, point: Vector2):
	apply_impulse_point_relative(impulse, 8. * point);

# Applies impulse at global point, point given in pixels
func apply_impulse_point_global(impulse: Vector2, point: Vector2):
	apply_impulse(8. * impulse, point - global_position);

func get_hit_by_attack(attack: Attack) -> void:
	apply_impulse_point_global(attack.impulse, attack.globalPosition);
	objectPropertyIntegrity.get_hit_by_damage(attack.damage);

func _on_hurtbox_attacked(attack: Attack) -> void:
	get_hit_by_attack(attack);

func _on_object_property_integrity_broken() -> void:
	broken();

func broken() -> void:
	queue_free();
#endregion