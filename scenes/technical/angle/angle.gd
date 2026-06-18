extends Node;
class_name Angle;

#region signals

#endregion

#region fields

#endregion

#region methods
static func normalize_angle(angle: float) -> float:
	var normalizedAngle = angle;
	while (normalizedAngle > PI): normalizedAngle -= 2 * PI;
	while (normalizedAngle < -PI): normalizedAngle += 2 * PI;
	return normalizedAngle;

static func get_ot_angle(delta: float, origin: float, target: float, baseRotationSpeed: float, relRotationSpeed: float) -> float:
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
	var rotationSpeed: float = distanceSign * baseRotationSpeed + relRotationSpeed * (distance / PI); 
	# Calculate new rotation angle taking delta into account
	var rotationAngle = origin + rotationSpeed * delta;
	
	# Handle possible overshot
	if distanceSign == 1.0: rotationAngle = min(rotationAngle, newTarget);
	elif distanceSign == -1.0: rotationAngle = max(rotationAngle, newTarget);
	
	# Normalize resulting rotation angle (needed due to new target angle possibly being outside normal range)
	var normalizedRotationAngle: float = normalize_angle(rotationAngle);
	
	# Return resulting rotation angle
	return normalizedRotationAngle;
#endregion
