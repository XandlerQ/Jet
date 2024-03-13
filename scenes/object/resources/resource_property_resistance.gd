extends Resource;
class_name ResourcePropertyResistance;

#region fields
# Physical resistance (0.0 - 1.0, percentage)
@export var physicalResistance: float;
# Alpha particle resistance (0.0 - 1.0, percentage)
@export var alphaResistance: float;
# Beta particle resistance (0.0 - 1.0, percentage)
@export var betaResistance: float;
# Gamma particle resistance (0.0 - 1.0, percentage)
@export var gammaResistance: float;
#endregion
