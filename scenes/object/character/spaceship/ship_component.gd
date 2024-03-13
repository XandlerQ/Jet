extends Sprite2D;
class_name ShipComponent;

#region signals
signal stats_values_changed();
#endregion

#region fields
# Property integrity node
@onready var propertyIntegrityNode: ObjectPropertyIntegrity = $ObjectPropertyIntegrity;
# Property resistance node
@onready var propertyResistanceNode: ObjectPropertyResistance = $ObjectPropertyResistance;
# Component stats node
@onready var componentStatsNode: ShipComponentStats = $ShipComponentStats;
#endregion

#region methods
func _on_ship_component_stats_stats_values_changed() -> void:
	stats_values_changed.emit();

func set_integrity_resource_path(path: String) -> void:
	propertyIntegrityNode.set_integrity_resource_path(path);

func set_integrity_resource(resource: ResourcePropertyIntegrity) -> void:
	propertyIntegrityNode.set_integrity_resource(resource);

func set_resistance_resource_path(path: String) -> void:
	propertyResistanceNode.set_resistance_resource_path(path);

func set_resistance_resource(resource: ResourcePropertyResistance) -> void:
	propertyResistanceNode.set_resistance_resource(resource);

func set_stats_resource_path(path: String) -> void:
	componentStatsNode.set_stats_resource_path(path);

func set_stats_resource(resource: ResourceShipComponentStats) -> void:
	componentStatsNode.set_stats_resource(resource);
#endregion



