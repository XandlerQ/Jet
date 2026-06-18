extends Node;
class_name TestLevel;

#region signals

#endregion

#region fields

#endregion

#region methods

func _process(_delta):
	if Input.is_action_pressed("Quit"):
		get_tree().quit();
#endregion
