extends RigidBody2D;
class_name RigidObject;

#region signals

#endregion

#region fields
# Property integrity node
@onready var objectPropertyIntegrity: ObjectPropertyIntegrity = $ObjectPropertyIntegrity;
#endregion

#region methods
func get_collision_shape2d() -> CollisionShape2D:
	return get_child(0) as CollisionShape2D;

func get_sprite2d() -> Sprite2D:
	return get_child(1) as Sprite2D;

func get_hurtbox_shape2d() -> CollisionShape2D:
	return get_child(3).get_child(0) as CollisionShape2D;

func set_shape(cps: Shape2D) -> void:
	get_collision_shape2d().shape = cps;

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

# Applies impulse at point of object, point given in pixels
func apply_impulse_point_relative(impulse: Vector2, point: Vector2):
	apply_impulse(8 * impulse, point);

# Applies impulse at global point, point given in pixels
func apply_impulse_point_global(impulse: Vector2, point: Vector2):
	apply_impulse(8 * impulse, point - global_position);

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
