extends CharacterObject;
class_name Ship;

#region signals

#endregion

#region fields
# Ship stats resource
@export var shipResource: ResourceShip = null;
# Power value
var power: float = 1250;
# Fuel reserve value
var fuel: float = 0;
# Booster power value
var boosterPower: float = 2500;
# Booster cooldown
var boosterCooldown: float = 1;
# Booster thrust
var boosterThrust: float = 0;
# Drag
var drag: float;
# Gravibrake
var gravibrakePower: float = 4;
# Current spaceship thrust
var thrust: float = 0;
# Thrust change speed
var thrustChangeSpeed: float = 5.;
# Max thrust
var forwardThrust: float = 1.0;
# Min thrust
var backwardThrust: float = -0.6;
# Overcharge thrust
var overchargeThrustMultiplier: float = 1.6;
# Target thrust
var targetThrust: float = 0:
	set = set_target_thrust;
# Target thrust states
enum targetThrustStates {
	ZERO,
	FWD,
	BWD,
	OFWD,
	OBWD
}
# Rotation power
var rotationPower: float = 15000;
# Rotation thrust
var rotationThrust: float = 0;
# Max rotation thrust
var maxRotationThrust: float = 1.;
# Rotation thrust change speed
var rotationThrustChangeSpeed: float = 10;
# Target rotation thrust
var targetRotationThrust: float = 0.: 
	set = set_target_rotation_thrust;
# Rotation drag
var rotationDrag: float;
# Boost timer
@onready var boostTimer: Timer = $BoostTimer;
#endregion

#region methods
func _ready() -> void:
	super();
	drag = 3 * linearSize * linearSize / 4;
	rotationDrag = 8;
	# Setup booster timer
	boostTimer.one_shot = true;
	boostTimer.wait_time = boosterCooldown;

func get_collision_virtual_rotational_speed(collisionDistance: float, collisionDirection: Vector2) -> Vector2:
	return rotational_speed_hat_function(collisionDistance) * rotationSpeed * collisionDistance * collisionDirection.rotated(PI/2.) + 2 * collisionDistance * rotationThrust * rotationPower * collisionDirection.rotated(PI/2.) / 15000;

func normalize_target_thrust() -> void:
	var maxThrust: float = forwardThrust * overchargeThrustMultiplier;
	var minThrust: float = backwardThrust * overchargeThrustMultiplier;
	if targetThrust > maxThrust:
		targetThrust = maxThrust;
	if targetThrust < minThrust:
		targetThrust = minThrust;

func set_target_thrust(tgtT: float) -> void:
	targetThrust = tgtT;
	normalize_target_thrust();

func set_target_thrust_state(state: targetThrustStates) -> void:
	match state:
		targetThrustStates.ZERO: targetThrust = 0;
		targetThrustStates.FWD: targetThrust = forwardThrust;
		targetThrustStates.BWD: targetThrust = backwardThrust;
		targetThrustStates.OFWD: targetThrust = forwardThrust * overchargeThrustMultiplier;
		targetThrustStates.OBWD: targetThrust = backwardThrust * overchargeThrustMultiplier;

func set_target_rotation_thrust(tgtRT: float) -> void:
	targetRotationThrust = tgtRT;
	normalize_target_rotation_thrust();

func add_to_target_rotation_thrust(value: float) -> void:
	targetRotationThrust += value;
	normalize_target_rotation_thrust();

func normalize_target_rotation_thrust() -> void:
	if targetRotationThrust > maxRotationThrust:
		targetRotationThrust = maxRotationThrust;
	if targetRotationThrust < -maxRotationThrust:
		targetRotationThrust = -maxRotationThrust;

#region dynamics

func accelerate(delta: float) -> void:
	add_to_speed(delta * ((thrust * power / mass) * Vector2.RIGHT.rotated(rotation) - drag * speed / mass))

func gravibrake(delta: float) -> void:
	var speedModule: float = speed.length();
	if speedModule < 0.00001:
		set_speed(Vector2.ZERO);
	else:
		add_to_speed(-delta * gravibrakePower * speed / mass);

func update_thrust(delta: float) -> void:
	var thrustDelta: float = targetThrust - thrust;
	if abs(thrustDelta) < delta * thrustChangeSpeed:
		thrust = targetThrust;
	else:
		thrust += sign(thrustDelta) * delta * thrustChangeSpeed;

func update_rotation_thrust(delta: float) -> void:
	var rotationThrustDelta: float = targetRotationThrust - rotationThrust;
	if abs(rotationThrustDelta) < delta * rotationThrustChangeSpeed:
		rotationThrust = targetRotationThrust;
	else:
		rotationThrust += sign(rotationThrustDelta) * delta * rotationThrustChangeSpeed;

func update_rotation(delta: float) -> void:
	var rotationSpeedDelta: float = delta * (rotationPower * rotationThrust / momentOfInertia - rotationDrag * rotationSpeed);
	if rotationSpeedDelta * rotationSpeed < 0. and abs(rotationSpeedDelta) > abs(rotationSpeed):
		rotationSpeed = 0;
	else:
		rotationSpeed += rotationSpeedDelta;
	rotation += delta * rotationSpeed;


#func lower_booster_thrust(delta: float) -> void:
	#

func apply_booster(direction: Vector2) -> void:
	#TODO check if timer is running
	apply_central_impulse(direction * boosterPower);
	#TODO start cooldown timer
#endregion

#endregion
