extends Camera2D;
class_name PlayerCamera;

@onready var fPlayer = get_node("../Player");
var fCameraPosition: Vector2;
var fOvershoot: Vector2 = Vector2(0.3, 0.3);

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

func _process(_delta):
	self.fCameraPosition = PlayerCamera.lerp_overshoot_v(self.position, fPlayer.position, 0.2, self.fOvershoot);
	self.position = self.fCameraPosition;
