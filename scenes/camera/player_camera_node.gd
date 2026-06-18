extends Node2D;
class_name PlayerCameraNode;

#region signals

#endregion

#region fields
# Node position
var dockPosition: Vector2;
# Position overshoot vector
@export var overshoot: Vector2 = Vector2(0.3, 0.3);
# Position lerp weight
@export var lerpWeight: float = 0.2;
# Rotate camera after player flag
@export var rotateAfterPlayer: bool = true;
# Base camera rotation speed
@export var baseRotationSpeed: float = 0.02;
# Relative camera rotation speed
@export var relRotationSpeed: float = PI * PI / 1.5;
# Camera zoom
@export var zoom: Vector2 = Vector2(2., 2.);
# Player node
@onready var player: CharacterBody2D = $"../ShipPlayer";
# Camera node
@onready var camera: Camera2D = $PlayerCamera;
#endregion

#region methods
func _ready():
	camera.zoom = zoom;
	camera.ignore_rotation = false;
	rotation = PI/2;

static func lerp_overshoot(origin: float, target: float, weight: float, ovs: float) -> float:
	var distance: float = (target - origin) * weight;
	
	if is_equal_approx(distance, 0.0):
		return target;
	
	var distanceSign := signf(distance);
	var lerpValue: float = lerp(origin, target + (ovs * distanceSign), weight);
	
	if distanceSign == 1.0:
		lerpValue = min(lerpValue, target);
	elif distanceSign == -1.0:
		lerpValue = max(lerpValue, target);
	
	return lerpValue;

static func lerp_overshoot_v(from: Vector2, to: Vector2, weight: float, ovs: Vector2) -> Vector2:
	var x = lerp_overshoot(from.x, to.x, weight, ovs.x);
	var y = lerp_overshoot(from.y, to.y, weight, ovs.y);
	
	return Vector2(x,y);

func _physics_process(delta):
	dockPosition = PlayerCameraNode.lerp_overshoot_v(global_position, player.global_position, lerpWeight, overshoot);
	global_position = dockPosition;
	if rotateAfterPlayer:
		var otAngle = Angle.get_ot_angle(delta, rotation - PI/2, player.rotation, baseRotationSpeed, relRotationSpeed);
		rotation = otAngle + PI/2;
#endregion
