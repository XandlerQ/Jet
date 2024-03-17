extends Resource;
class_name ResourceShipComponentStats;

#region fields
# Acceleration value contributed to spaceship stats by ship component
@export var acceleration: float;
# Base rotation speed value contributed to spaceship stats by ship component
@export var baseRotationSpeed: float;
# Additional rotation speed value contributed to spaceship stats by ship component
@export var additionalRotationSpeed: float;
# Fuel reserve value contributed to spaceship stats by ship component
@export var fuel: float;
# Booster power value contributed to spaceship stats by ship component
@export var boosterPower: float;
# Booster cooldown value contributed to spaceship stats by ship component
@export var boosterCooldown: float;
# Drag value contributed to spaceship stats by ship component
@export var drag: float;
# Mass value contributed to spaceship stats by ship component
@export var mass: float;
#endregion
