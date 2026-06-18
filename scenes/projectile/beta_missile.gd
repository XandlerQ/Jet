extends Projectile;
class_name BetaMissile;

#region signals

#endregion

#region fields

#endregion

#region methods

func _ready() -> void:
	super();
	oat = true;
	$AnimationPlayer.play("idle");

#region Kinematic properties functions
# Time dependent functions of kinematic properties of projectile
# Redefined for different behaviour
func linear_speed_function(_t: float) -> float:
	var constSpeed = 1500;
	return constSpeed;

func speed_function(t: float) -> Vector2:
	var sp: Vector2 = initialSpeed;
	sp += direction * linear_speed_function(t);
	return sp;

func swerve_speed_function(_t: float) -> float:
	var constSwerveSpeed = 32 * PI;
	return constSwerveSpeed;

func swerve_amplitude_function(_t: float) -> float:
	var constSwerveAmplitude = 1;
	return constSwerveAmplitude;

func rotation_speed_function(_t: float) -> float:
	var constRotationSpeed = 0;
	return constRotationSpeed;

#endregion

#endregion
