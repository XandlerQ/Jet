extends RigidObject;
class_name Asteroid;

#region signals

#endregion

#region fields
# Asteroid scene
static var asteroidScene: PackedScene = preload("res://scenes/object/rigid/asteroid/asteroid.tscn");

# Asteroid names, id enumeration
enum IDS {
	ASTEROID16A,
	ASTEROID16B,
	ASTEROID16C,
	ASTEROID16D,
	ASTEROID32A,
	ASTEROID32B,
	ASTEROID32C,
	ASTEROID32D,
	ASTEROID64A,
	ASTEROID64B,
	ASTEROID64C,
	ASTEROID64D,
	ASTEROID128A,
	ASTEROID128B,
	ASTEROID128C,
	ASTEROID128D,
}

# Asteroid size types
enum SIZE_TYPES {
	SMALL,
	MEDIUM,
	BIG,
	LARGE
}

# Asteroid linear sizes
static var LINEAR_SIZES: PackedFloat32Array = [1., 2., 4., 8.];

# Asteroid weights
static var  MASSES: PackedFloat32Array = [5., 10., 20., 100.];

# Asteroid texture shape map
static var tsma: ResourceTextureShapeMap = preload("res://scenes/object/rigid/asteroid/repo/texture_shape_map_asteroid.tres");

# Asteroid size type
@export_range(0, 3) var size: int = SIZE_TYPES.MEDIUM;

# Burst power
@export var burstPower: float = 8.;
#endregion

#region methods
func _ready() -> void:
	super._ready();
	if get_hurtbox_shape2d().shape == null and get_collision_shape2d().shape != null:
		match_hurtbox_shape();

static func build_asteroid_id(id: int) -> Asteroid:
	var asteroid: Asteroid = asteroidScene.instantiate();
	
	asteroid.set_texture_shape_coupling(tsma.get_coupling(id));
	
	var typeId: int = (id - id % 4) / 4;
	
	asteroid.linearSize = Asteroid.LINEAR_SIZES[typeId];
	asteroid.size = typeId;
	asteroid.mass = Asteroid.MASSES[typeId];
	asteroid.update_moment_of_inertia();
	
	return asteroid;

static func build_asteroid_rand() -> Asteroid:
	return build_asteroid_id(randi_range(0, 15));

static func build_asteroid_by_size_type(st: int) -> Asteroid:
	match st:
		Asteroid.SIZE_TYPES.SMALL:
			return build_asteroid_id(randi_range(0, 3));
		Asteroid.SIZE_TYPES.MEDIUM:
			return build_asteroid_id(randi_range(4, 7));
		Asteroid.SIZE_TYPES.BIG:
			return build_asteroid_id(randi_range(8, 11));
		Asteroid.SIZE_TYPES.LARGE:
			return build_asteroid_id(randi_range(12, 15));
	
	return null;

func broken() -> void:
	if size == SIZE_TYPES.SMALL:
		queue_free();
		return;
	
	var fragmentAmount: int = randi_range(3,4);
	var fanAngleStep: float = 2. * PI / fragmentAmount;
	var fanAngleShift: float = randf_range(0., fanAngleStep);
	
	for fragmentCtr in range(0, fragmentAmount):
		var relativePlacement: Vector2 = linearSize * 4 * Vector2.from_angle(fragmentCtr * fanAngleStep + fanAngleShift);
		var placementDistance: float = relativePlacement.length();
		var tangent: Vector2 = relativePlacement / placementDistance;
		var normal: Vector2 = tangent.rotated(PI / 2);
		var fragment: Asteroid = build_asteroid_by_size_type(size - 1);
		
		fragment.global_position = global_position + relativePlacement;
		fragment.global_rotation = randf_range(-PI, PI);
		
		var fragmentLinearVelocity: Vector2 = linear_velocity + burstPower * tangent + angular_velocity * placementDistance * normal;
		
		fragment.linear_velocity = fragmentLinearVelocity;
		fragment.angular_velocity = randf_range(-PI / 1.5, PI / 1.5);
		
		get_parent().add_child(fragment);
	
	queue_free();

func _on_object_property_integrity_broken() -> void:
	call_deferred("broken");
#endregion