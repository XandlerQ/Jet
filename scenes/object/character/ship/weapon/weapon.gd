extends Sprite2D;
class_name Weapon;

#region signals

#endregion

#region fields
@export var carrier: CharacterObject;
@onready var barrel: Marker2D = $Barrel;
@onready var projectileContainer = $ProjectileContainer;
@export var recoil: float = 10;
@export var projectileScene: PackedScene;
var positionRelativeToCarrier: Vector2;
#endregion

#region methods
func _ready() -> void:
	positionRelativeToCarrier = position;

func get_initial_projectile_speed() -> Vector2:
	var barrelPositionRelativeToCarrier: Vector2 = positionRelativeToCarrier + barrel.position;
	var barrelDistance = barrelPositionRelativeToCarrier.length();
	var barrelDirectionRelativeToCarrier: Vector2 = barrelPositionRelativeToCarrier / barrelDistance;
	var iniS: Vector2 = carrier.velocity + carrier.rotationSpeed * barrelDistance * barrelDirectionRelativeToCarrier.rotated(PI/2);
	return iniS;

func fire() -> void:
	var projectile: Projectile = projectileScene.instantiate();
	var iniS: Vector2 = get_initial_projectile_speed();
	var dir: Vector2 = Vector2.from_angle(global_rotation)
	projectile.initialize(barrel.global_position, dir, iniS);
	projectileContainer.add_child(projectile);
	carrier.apply_impulse_point_local(-recoil * dir, positionRelativeToCarrier);
#endregion
