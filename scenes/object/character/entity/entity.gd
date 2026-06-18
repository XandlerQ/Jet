extends CharacterObject;
class_name Entity;

#region signals

#endregion

#region fields
# Max move speed, normed to units
var moveSpeed: float = 13.;
# Max rush speed, normed to units
var rushSpeed: float = 23.;

# Move acceleration, normed to units
var moveAcceleration: float = 37.;
# Rush acceleration, normed to units
var rushAcceleration: float = 56.;

# Current movement direction
var direction: Vector2 = Vector2.ZERO;
#endregion

#region methods

#endregion
