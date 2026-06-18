extends Node2D;
class_name ObjectPropertyIntegrity;

#region signals
signal integrity_value_changed();
signal broken();
#endregion

#region fields
# Integrity values resource
@export var integrityResource: ResourcePropertyIntegrity = null:
	set = set_integrity_resource;
# Durability (max integrity value)
var durability: float = 1;
# Integrity (current integrity value)
var integrity: float = 1;
# Physical resistance (0.0 - 1.0, percentage)
var physicalResistance: float = 0;
# Alpha particle resistance (0.0 - 1.0, percentage)
var alphaResistance: float = 0;
# Beta particle resistance (0.0 - 1.0, percentage)
var betaResistance: float = 0;
# Gamma particle resistance (0.0 - 1.0, percentage)
var gammaResistance: float = 0;
#endregion


#region methods
func _ready() -> void:
	apply_integrity_resource();

func apply_integrity_resource() -> void:
	if integrityResource == null: return;
	var integrityRatio: float;
	if durability == 0:
		integrityRatio = 1.;
	else:
		integrityRatio = integrity / durability;
	durability = integrityResource.durability;
	integrity = integrityRatio * durability;
	physicalResistance = integrityResource.physicalResistance;
	alphaResistance = integrityResource.alphaResistance;
	betaResistance = integrityResource.betaResistance;
	gammaResistance = integrityResource.gammaResistance;

func set_integrity_resource(resource: ResourcePropertyIntegrity) -> void:
	integrityResource = resource;
	apply_integrity_resource();

func set_integrity_resource_path(path: String) -> void:
	set_integrity_resource(load(path));

func add_to_integrity(value: float) -> void:
	integrity += value;
	integrity_value_changed.emit();
	if integrity > durability:
		integrity = durability;
	if integrity <= 0:
		integrity = 0;
		broken.emit();

func get_hit_by_damage(damage: Damage) -> void:
	var physicalDamage: float = (1 - physicalResistance) * damage.physicalDamage;
	var alphaDamage: float = (1 - alphaResistance) * damage.alphaDamage;
	var betaDamage: float = (1 - betaResistance) * damage.betaDamage;
	var gammaDamage: float = (1 - gammaResistance) * damage.gammaDamage;
	
	var totalDamage: float = physicalDamage + alphaDamage + betaDamage + gammaDamage;
	add_to_integrity(-totalDamage);
#endregion
