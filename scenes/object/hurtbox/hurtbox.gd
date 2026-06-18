extends Area2D;
class_name Hurtbox;

#region signals
signal attacked(attack: Attack);
#endregion

#region fields

#endregion

#region methods
func get_hit_by_attack(attack: Attack) -> void:
	print("Signal \"attacked\" emitted with ", attack);
	attacked.emit(attack);
#endregion
