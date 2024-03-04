extends Node2D;
class_name PropertyIntegrity;

#region signals
signal destroyed();
#endregion

#region fields

# Object durabity (max integrity value)
@export var durability: float;
# Current integrity value
var integrity: float;
# Resistance property
var propertyResistance: PropertyResistance;

#endregion

#region methods
func get_hit_by_attack(attack: Attack) -> void:
	var actualPhysicalDamage: float = attack.physical * (1 - propertyResistance.physicalResistance);
	var actualAlphaDamage: float = attack.alpha * (1 - propertyResistance.alphaResistance);
	var actualBetaDamage: float = attack.beta * (1 - propertyResistance.betaResistance);
	var actualLaserDamage: float = attack.laser * (1 - propertyResistance.laserResistance);
	var actualDamage: float = actualPhysicalDamage + actualAlphaDamage + actualBetaDamage + actualLaserDamage;
	durability -= actualDamage;
	if (durability <= 0):
		destroyed.emit();
	return;
#endregion
