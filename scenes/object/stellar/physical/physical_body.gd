extends RigidBody2D;
class_name PhysicalBody;

#region signals

#endregion

#region fields
@onready var propertyIntegrity: PropertyIntegrity;
@onready var propertyResistance: PropertyResistance;
#endregion

#region methods
func get_hit_by_attack(attack: Attack) -> void:
	propertyIntegrity.get_hit_by_attack(attack);
#endregion
