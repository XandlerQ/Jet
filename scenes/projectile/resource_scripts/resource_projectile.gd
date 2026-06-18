extends Resource;
class_name ResourceProjectile;

#region fields
# Projectile damage
@export var damage: Damage;
# Projectile impulse
# float variable that defines the module of
# impulse applied to objects hit by projectile
@export var impulse: float;
# Projectile lifetime
# SDTimer wait_time is set accordingly to this value
@export var lifetime: float;
#endregion
