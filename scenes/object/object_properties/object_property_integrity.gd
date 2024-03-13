extends Node2D;
class_name ObjectPropertyIntegrity;

#region signals
signal integrity_value_changed();
signal broken();
#endregion

#region fields
# Integrity values resource
@export var integrityResource: ResourcePropertyIntegrity;
# Durability (max integrity value)
@export var durability: float = 0;
# Integrity (current integrity value)
var integrity: float = 0;
# Property resistance node
@onready var propertyResistance: ObjectPropertyResistance = get_node("../ObjectPropertyResistance");
#endregion


#region methods
func _ready() -> void:
	update();

func update() -> void:
	if (integrityResource != null):
		durability = integrityResource.durability;
		integrity = durability;

func set_integrity_resource_path(path: String) -> void:
	set_integrity_resource(load(path));

func set_integrity_resource(resource: ResourcePropertyIntegrity) -> void:
	integrityResource = resource;
	update();

func add_to_integrity(value: float) -> void:
	integrity += value;
	integrity_value_changed.emit();
	if integrity > durability:
		integrity = durability;
	if integrity < 0:
		integrity = 0;
		broken.emit();

func get_hit_by_attack(attack: Attack) -> void:
	var physicalDamage: float = (1 - propertyResistance.physicalResistance) * attack.physicalDamage;
	var alphaDamage: float = (1 - propertyResistance.alphaResistance) * attack.alphaDamage;
	var betaDamage: float = (1 - propertyResistance.betaResistance) * attack.betaDamage;
	var gammaDamage: float = (1 - propertyResistance.gammaResistance) * attack.gammaDamage;
	
	var totalDamage: float = physicalDamage + alphaDamage + betaDamage + gammaDamage;
	add_to_integrity(-totalDamage);
#endregion
