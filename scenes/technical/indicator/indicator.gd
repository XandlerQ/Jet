extends Sprite2D;
class_name Indicator;

#region signals

#endregion

#region fields
static var indicatorScene: PackedScene = preload("res://scenes/technical/indicator/indicator.tscn");
@export var timeVisible: float = 10;
@onready var SDTimer: Timer = $SDTimer;
#endregion

#region methods
func _ready() -> void:
	visible = false;
	SDTimer.one_shot = true;
	SDTimer.wait_time = timeVisible;

func set_time_visible(t: float) -> void:
	timeVisible = t;
	SDTimer.wait_time = timeVisible;

func indicate() -> void:
	SDTimer.start();
	visible = true;

func _on_sd_timer_timeout() -> void:
	queue_free();

static func create_indicator() -> Indicator:
	var indicator: Indicator = indicatorScene.instantiate();
	return indicator;
#endregion
