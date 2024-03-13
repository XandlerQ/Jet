extends CharacterBody2D;
class_name Ship;

#region signals

#endregion

#region fields
# Acceleration value
var acceleration: float = 0;
# Base rotation speed value
var baseRotationSpeed: float = 0;
# Additional rotation speed value
var additionalRotationSpeed: float = 0;
# Fuel reserve value
var fuel: float = 0;
# Booster power value
var boosterPower: float = 0;
# Booster cooldown
var boosterCooldown: float = 0;
# Drag
var drag: float = 0;
# Hull node
@onready var hull: Hull = $"Hull";
# Wing node
@onready var wing: Wing = $"Wing";
# Current spaceship thrust
var thrust: float = 0;
# Boost timer
@onready var boostTimer: Timer = $BoostTimer;
# Hull collision shape node
@onready var hullCollisionShape: CollisionShape2D = $HullCollisionShape;
# Wing collision shape node
@onready var wingCollisionShape: CollisionShape2D = $WingCollisionShape;
#endregion

#region methods
func _ready():	
	# Setup hull and wing sprites initial rotation
	hull.rotation = PI/2;
	wing.rotation = PI/2;
	# Setup hull and wing collision shapes initial rotation
	hullCollisionShape.rotation = PI/2;
	wingCollisionShape.rotation = PI/2;
	
	recalculate_ship_stats();
	
		# Setup booster timer
	boostTimer.one_shot = true;
	boostTimer.wait_time = boosterCooldown;

func set_hull_collision_shape_path(path: String) -> void:
	set_hull_collision_shape(load(path));

func set_hull_collision_shape(collisionShape: ConvexPolygonShape2D) -> void:
	hullCollisionShape.shape = collisionShape;

func set_wing_collision_shape_path(path: String) -> void:
	set_wing_collision_shape(load(path));

func set_wing_collision_shape(collisionShape: ConvexPolygonShape2D) -> void:
	wingCollisionShape.shape = collisionShape;

func set_hull_integrity_resource_path(path: String) -> void:
	hull.set_integrity_resource_path(path);

func set_hull_integrity_resource(resource: ResourcePropertyIntegrity) -> void:
	hull.set_integrity_resource(resource);

func set_hull_resistance_resource_path(path: String) -> void:
	hull.set_resistance_resource_path(path);

func set_hull_resistance_resource(resource: ResourcePropertyResistance) -> void:
	hull.set_resistance_resource(resource);

func set_hull_stats_resource_path(path: String) -> void:
	hull.set_stats_resource_path(path);

func set_hull_stats_resource(resource: ResourceShipComponentStats) -> void:
	hull.set_stats_resource(resource);

func set_wing_integrity_resource_path(path: String) -> void:
	wing.set_integrity_resource_path(path);

func set_wing_integrity_resource(resource: ResourcePropertyIntegrity) -> void:
	wing.set_integrity_resource(resource);

func set_wing_resistance_resource_path(path: String) -> void:
	wing.set_resistance_resource_path(path);

func set_wing_resistance_resource(resource: ResourcePropertyResistance) -> void:
	wing.set_resistance_resource(resource);

func set_wing_stats_resource_path(path: String) -> void:
	wing.set_stats_resource_path(path);

func set_wing_stats_resource(resource: ResourceShipComponentStats) -> void:
	wing.set_stats_resource(resource);

func recalculate_ship_stats():
	acceleration = hull.componentStatsNode.acceleration + wing.componentStatsNode.acceleration;
	baseRotationSpeed = hull.componentStatsNode.baseRotationSpeed + wing.componentStatsNode.baseRotationSpeed;
	additionalRotationSpeed = hull.componentStatsNode.additionalRotationSpeed + wing.componentStatsNode.additionalRotationSpeed;
	fuel = hull.componentStatsNode.fuel + wing.componentStatsNode.fuel;
	boosterPower = hull.componentStatsNode.boosterPower + wing.componentStatsNode.boosterPower;
	boosterCooldown = hull.componentStatsNode.boosterCooldown + wing.componentStatsNode.boosterCooldown;
	drag = hull.componentStatsNode.drag + wing.componentStatsNode.drag;

func add_to_thrust(value: float) -> void:
	thrust += value;
	normalizeThrust();

func normalizeThrust() -> void:
	if (thrust > 1.0): 
		thrust = 1.0;
		return;
	if (thrust < -0.5):
		thrust = -0.5;
		return;

#region rotation
static func normalize_angle(angle: float) -> float:
	var normalizedAngle = angle;
	while (normalizedAngle > PI): normalizedAngle -= 2 * PI;
	while (normalizedAngle < -PI): normalizedAngle += 2 * PI;
	return normalizedAngle;

static func get_ot_angle(delta: float, origin: float, target: float, baseRotSpeed: float, additionalRotSpeed: float) -> float:
	var angleDifference: float = target - origin;
	var newTarget: float = target; # New target angle
	# If angle difference curve contains -PI to PI jump,
	# define new target angles that are outside normal range
	if (angleDifference > PI): newTarget -= 2 * PI;
	if (angleDifference < -PI): newTarget += 2 * PI;
	
	var distance: float = newTarget - origin; # Angle difference curve length
	if is_equal_approx(distance, 0.0): return target; #If already close to target, return target
	
	var distanceSign := signf(distance); #Angle distance sign
	# Calculate rotation speed = [base rotation speed in the correct direction]
	# + [relative rotation speed] * [distance factor]
	var rotationSpeed: float = distanceSign * baseRotSpeed + additionalRotSpeed * (distance / PI); 
	# Calculate new rotation angle taking delta into account
	var rotationAngle = origin + rotationSpeed * delta;
	
	# Handle possible overshot
	if distanceSign == 1.0: rotationAngle = min(rotationAngle, newTarget);
	elif distanceSign == -1.0: rotationAngle = max(rotationAngle, newTarget);
	
	# Normalize resulting rotation angle (needed due to new target angle possibly being outside normal range)
	var normalizedRotationAngle: float = normalize_angle(rotationAngle);
	
	# Return resulting rotation angle
	return normalizedRotationAngle;

func get_ot_angle_self(delta: float, targetAngle: float):
	return Ship.get_ot_angle(delta, rotation, targetAngle, baseRotationSpeed, additionalRotationSpeed);

func get_angle_to_rotate_to_target_angle(delta: float, targetAngle: float) -> float:
	return get_ot_angle_self(delta, targetAngle);

func rotate_to_target_angle(delta: float, targetAngle: float) -> void:
	rotation = get_ot_angle_self(delta, targetAngle);

func get_angle_to_rotate_to_target(delta: float, target: Vector2):
	var differenceVector: Vector2 = target - global_position;
	var targetAngle = differenceVector.angle();
	return get_ot_angle_self(delta, targetAngle);

func rotate_to_target(delta: float, target: Vector2):
	var differenceVector: Vector2 = target - global_position;
	var targetAngle = differenceVector.angle();
	rotation = get_ot_angle_self(delta, targetAngle);
#endregion

#region velocity

func apply_accelerations(delta: float):
	var velocityModule: float = velocity.length();
	
	velocity += 
#endregion

func _on_hull_stats_values_changed():
	recalculate_ship_stats();

func _on_wing_stats_values_changed():
	recalculate_ship_stats();
#endregion
