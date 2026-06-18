extends Resource;
class_name ResourceTextureShapeMap;

#region fields
# Array that holds texture paths for texture-shape couplings
@export var texturePathsArray: PackedStringArray;
# Array that holds shape paths for texture-shape couplings
@export var shapePathsArray: PackedStringArray;
#endregion

#region methods
func get_coupling(id: int) -> TextureShapeCoupling:
	if id >= texturePathsArray.size() or id >= shapePathsArray.size(): return null;
	var tsc: TextureShapeCoupling = TextureShapeCoupling.new();
	tsc.shape = load(shapePathsArray[id]);
	tsc.texture = load(texturePathsArray[id]);
	return tsc;
#endregion
