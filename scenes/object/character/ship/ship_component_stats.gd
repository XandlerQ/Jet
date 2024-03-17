extends Node2D;
class_name ShipComponentStats;

#region signals
signal stats_values_changed();
#endregion


#region fields
# Ship component stats resource
@export var shipComponentStatsResource: ResourceShipComponentStats;
# Acceleration value contributed to spaceship stats by ship component
var acceleration: float = 0.0;
# Base rotation speed value contributed to spaceship stats by ship component
var baseRotationSpeed: float = 0.0;
# Additional rotation speed value contributed to spaceship stats by ship component
var additionalRotationSpeed: float = 0.0;
# Fuel reserve value contributed to spaceship stats by ship component
var fuel: float = 0.0;
# Booster power value contributed to spaceship stats by ship component
var boosterPower: float = 0.0;
# Booster cooldown value contributed to spaceship stats by ship component
var boosterCooldown: float = 0.0;
# Drag value contributed to spaceship stats by ship component
var drag: float = 0.0;
# Mass value contributed to spaceship stats by ship component
var mass: float = 0.0;
# Component integrity node
@onready var componentIntegrityNode: ObjectPropertyIntegrity = $"../ObjectPropertyIntegrity";
#endregion


#region methods
func _ready():
	update_no_signal();

func update():
	if shipComponentStatsResource != null:
		var currentIntegrityFractionProportional: float = 0.25 + 0.75 * componentIntegrityNode.integrity / componentIntegrityNode.durability;
		var currentIntegrityFractionReverseProportional: float = 2 - currentIntegrityFractionProportional;
		acceleration = currentIntegrityFractionProportional * shipComponentStatsResource.acceleration;
		baseRotationSpeed = currentIntegrityFractionProportional * shipComponentStatsResource.baseRotationSpeed;
		additionalRotationSpeed = currentIntegrityFractionProportional * shipComponentStatsResource.additionalRotationSpeed;
		fuel = currentIntegrityFractionProportional * shipComponentStatsResource.fuel;
		boosterPower = currentIntegrityFractionProportional * shipComponentStatsResource.boosterPower;
		boosterCooldown = currentIntegrityFractionReverseProportional * shipComponentStatsResource.boosterCooldown;
		drag = currentIntegrityFractionReverseProportional * shipComponentStatsResource.drag;
		mass = shipComponentStatsResource.mass;
		stats_values_changed.emit();

func update_no_signal():
	if shipComponentStatsResource != null:
		var currentIntegrityFractionProportional: float = 0.25 + 0.75 * componentIntegrityNode.integrity / componentIntegrityNode.durability;
		var currentIntegrityFractionReverseProportional: float = 2 - currentIntegrityFractionProportional;
		acceleration = currentIntegrityFractionProportional * shipComponentStatsResource.acceleration;
		baseRotationSpeed = currentIntegrityFractionProportional * shipComponentStatsResource.baseRotationSpeed;
		additionalRotationSpeed = currentIntegrityFractionProportional * shipComponentStatsResource.additionalRotationSpeed;
		fuel = currentIntegrityFractionProportional * shipComponentStatsResource.fuel;
		boosterPower = currentIntegrityFractionProportional * shipComponentStatsResource.boosterPower;
		boosterCooldown = currentIntegrityFractionReverseProportional * shipComponentStatsResource.boosterCooldown;
		drag = currentIntegrityFractionReverseProportional * shipComponentStatsResource.drag;
		mass = shipComponentStatsResource.mass;

func set_stats_resource_path(path: String) -> void:
	set_stats_resource(load(path));

func set_stats_resource(resource: ResourceShipComponentStats) -> void:
	shipComponentStatsResource = resource;
	update();

func _on_object_property_integrity_integrity_value_changed():
	update();
#endregion



