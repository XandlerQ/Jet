extends Node2D;
class_name ShipComponentManager;

#region signals

#endregion

#region fields
# Hull texture shape map
static var hull_texture_shape_map: ResourceTextureShapeMap = load("res://scenes/object/character/ship/hull/repo/texture_shape_map_hull.tres");
# Wing texture shap map
static var wing_texture_shape_map: ResourceTextureShapeMap = load("res://scenes/object/character/ship/wing/repo/texture_shape_map_wing.tres")
#endregion

#region methods
static func set_ship_hull(ship: Ship, id: int):
	ship.set_hull_canvas_texture_path(hull_texture_shape_map.texturePathsArray[id]);
	ship.set_hull_collision_shape_path(hull_texture_shape_map.polygonPathsArray[id]);

static func set_ship_wing(ship: Ship, id: int):
	ship.set_wing_canvas_texture_path(wing_texture_shape_map.texturePathsArray[id]);
	ship.set_wing_collision_shape_path(wing_texture_shape_map.polygonPathsArray[id]);


#endregion

