extends Area2D;
class_name Projectile;

#region signals

#endregion

#region fields
# Projectile resource
@export var projectileResource: ResourceProjectile = null:
	set = set_projectile_resource;

# Direction of launch
var direction: Vector2 = Vector2.RIGHT;
# Initial speed (velocity of carrier)
var initialSpeed: Vector2;
# Current speed
var speed: Vector2;
# Current swerve speed
var swerveSpeed: float;
# Current swerve amplitude
var swerveAmplitude: float;
# Current rotation speed
var rotationSpeed: float;
# Orient along trajectory flag
var oat: bool = true;

# Tangent to projectile movement
# Updated every physics tick and used for impulse application
# after collision with objects
var tangent: Vector2 = Vector2.RIGHT;

# Queue free timer
@onready var SDTimer: Timer = $SDTimer;
# Lifetime
var lifetime: float = 3;

# Projectile impulse
var impulse: float = 0;
# Projectile damage
var damage: Damage = null;

# Linear size of projectile
# Used for more accurate impulse application
# after collision with objects
@export var linearSize: float = 1;
#endregion

#region methods
func _ready():
	apply_projectile_resource();
	# !!! top_level property set to true in projectile container node !!!

	# Setup SDTimer
	SDTimer.one_shot = true;
	SDTimer.wait_time = lifetime;
	# Start SDTimer
	SDTimer.start();

func set_projectile_resource(prRes: ResourceProjectile) -> void:
	projectileResource = prRes;
	apply_projectile_resource();

func set_projectile_resource_path(path: String) -> void:
	set_projectile_resource(load(path));

func apply_projectile_resource() -> void:
	if projectileResource == null: return;
	damage = projectileResource.damage;
	impulse = projectileResource.impulse;
	lifetime = projectileResource.lifetime;

# Function to run after instantiating but before adding to tree
# Sets parameters and initial position and rotation of projectile
# Running before adding to tree allows to avoid visual bugs right
# after instantiating
func initialize(gPos: Vector2, dir: Vector2, iniS: Vector2) -> void:
	global_position = gPos;
	direction = dir;
	tangent = dir;
	initialSpeed = iniS;
	global_rotation = dir.angle();

#region Kinematic properties functions
# Time dependent functions of kinematic properties of projectile
# Possibly redefined by children for different behaviour
func linear_speed_function(_t: float) -> float:
	var constSpeed = 300;
	return constSpeed;

func speed_function(t: float) -> Vector2:
	var sp: Vector2 = initialSpeed;
	sp += direction * linear_speed_function(t);
	return sp;

func swerve_speed_function(_t: float) -> float:
	var constSwerveSpeed = 0;
	return constSwerveSpeed;

func swerve_amplitude_function(_t: float) -> float:
	var constSwerveAmplitude = 0;
	return constSwerveAmplitude;

func rotation_speed_function(_t: float) -> float:
	var constRotationSpeed = 0;
	return constRotationSpeed;
#endregion

func update_kinematic_properties() -> void:
	var t: float = SDTimer.wait_time - SDTimer.time_left;
	speed = speed_function(t);
	swerveSpeed = swerve_speed_function(t);
	swerveAmplitude = swerve_amplitude_function(t);
	rotationSpeed = rotation_speed_function(t);

# Move projectile
# Returnes movement made
func move(delta: float) -> Vector2:
	var t: float = SDTimer.wait_time - SDTimer.time_left;
	var movement: Vector2 = Vector2(0, 0);
	movement += delta * speed;
	var normal: Vector2 = direction.rotated(PI / 2);
	if (swerveAmplitude != 0):
		movement += delta * swerveAmplitude * normal * swerveSpeed * cos(swerveSpeed * t);
	global_position += movement;
	return movement;

func update_rotation(delta: float) -> void:
	global_rotation += delta * rotationSpeed;

func _physics_process(delta: float) -> void:
	update_kinematic_properties();
	var movement: Vector2 = move(delta);
	tangent = movement.normalized();
	if oat:
		if tangent.length() != 0:
			global_rotation = tangent.angle();
	else:
		update_rotation(delta);

func generate_attack_on_body(body: Node2D) -> Attack:
	var attack: Attack = Attack.new();
	attack.damage = damage;
	var impulseVector: Vector2 = impulse * tangent;
	attack.impulse = impulseVector;
	var distanceVector: Vector2 = body.global_position - global_position;
	var bodyDirection = distanceVector.normalized();
	var attackGlobalPosition: Vector2 = global_position + linearSize * bodyDirection;
	attack.globalPosition = attackGlobalPosition;
	return attack;

func _on_sd_timer_timeout() -> void:
	queue_free();

# TODO define collision handling completely
func _on_area_entered(area: Area2D) -> void:
	print(area);
	if area is Hurtbox:
		var attack: Attack = generate_attack_on_body(area);
		area.get_hit_by_attack(attack);
	queue_free();
#endregion
