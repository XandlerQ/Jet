extends Resource;
class_name ResourceTextureShapeMap;

#region fields
# Array that holds texture paths for texture polygon couplings
@export var texturePathsArray: PackedStringArray;
# Array that holds polygon paths for texture polygon couplings
@export var polygonPathsArray: PackedStringArray;
# Coupling group element count array
# Used for coupling group size definition and subsequent
# group-specific coupling generation.
# For 4 groups of sizes 2, 5, 2, 1 the array would be
# [0, 2, 7, 9, 10].
# To get group size: array.get(group_id + 1) - array.get(group_id)
# To get group count: array.length() - 1;
# To get coupling count: array.get(array.length() - 1)
@export var couplingGroupSizeArray: PackedInt32Array;
#endregion
