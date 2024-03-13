extends Node2D;
class_name PlayerCameraNode;

#region signals

#endregion

#region fields
# Node position
var dockPosition: Vector2;
# Overshoot vector
@export var overshoot: Vector2 = Vector2(0.3, 0.3);
# Camera zoom
@export var zoom: Vector2 = Vector2(4., 4.);
# Player node
@onready var player: CharacterBody2D = $"../ShipPlayer";
# Camera node
@onready var camera: Camera2D = $PlayerCamera;
#endregion

#region methods
func _ready():
	camera.zoom = zoom;

static func lerp_overshoot(origin: float, target: float, weight: float, overshoot: float) -> float:
	var distance: float = (target - origin) * weight;
	
	if is_equal_approx(distance, 0.0):
		return target;
	
	var distanceSign := signf(distance);
	var lerpValue: float = lerp(origin, target + (overshoot * distanceSign), weight);
	
	if distanceSign == 1.0:
		lerpValue = min(lerpValue, target);
	elif distanceSign == -1.0:
		lerpValue = max(lerpValue, target);
	
	return lerpValue;

static func lerp_overshoot_v(from: Vector2, to: Vector2, weight: float, overshoot: Vector2) -> Vector2:
	var x = lerp_overshoot(from.x, to.x, weight, overshoot.x);
	var y = lerp_overshoot(from.y, to.y, weight, overshoot.y);
	
	return Vector2(x,y);

func _physics_process(_delta):
	dockPosition = PlayerCameraNode.lerp_overshoot_v(global_position, player.global_position, 0.2, overshoot);
	global_position = dockPosition;
#endregion

