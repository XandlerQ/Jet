extends Node2D;
class_name ObjectPropertyResistance;

#region signals

#endregion

#region fields
# Resistance values resource
@export var resistanceResource: ResourcePropertyResistance;
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
	update();

func update() -> void:
	if (resistanceResource != null):
		physicalResistance = resistanceResource.physicalResistance;
		alphaResistance = resistanceResource.alphaResistance;
		betaResistance = resistanceResource.betaResistance;
		gammaResistance = resistanceResource.gammaResistance;

func set_resistance_resource_path(path: String) -> void:
	set_resistance_resource(load(path));

func set_resistance_resource(resource: ResourcePropertyResistance) -> void:
	resistanceResource = resource;
	update();
#endregion
