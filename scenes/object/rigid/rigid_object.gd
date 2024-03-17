extends RigidBody2D;
class_name RigidObject;

#region signals

#endregion

#region fields
# Property integrity node
@onready var objectPropertyIntegrity: ObjectPropertyIntegrity = $ObjectPropertyIntegrity;
# Property resistance node
@onready var objectPropertyResistance: ObjectPropertyResistance = $ObjectPropertyResistance;

# Texture resource
@export var texture: CanvasTexture = null;
# Collision shape resource
@export var shape: ConvexPolygonShape2D = null;
# Sprite2D node
@onready var sprite2D: Sprite2D = $Sprite2D;
# Collision polygon node
@onready var collisionPolygon: CollisionPolygon2D = $CollisionPolygon2D;
#endregion

#region methods
func _ready() -> void:
	apply_resources();

func get_hit_by_attack(attack: Attack):
	return;

func apply_texture() -> void:
	if texture != null:
		sprite2D.texture = texture;

func apply_shape() -> void:
	if shape != null:
		collisionPolygon.polygon = shape.points;

func apply_resources() -> void:
	apply_texture();
	apply_shape();
#endregion
