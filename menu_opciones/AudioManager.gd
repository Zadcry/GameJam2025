
extends Node

const CONFIG_PATH := "user://config.cfg"
var master_volume: float = 1.0  # Default volume (0.0 to 1.0)

func _ready():
	_load_config()
	_apply_volume()

# Set the master volume and apply it to the audio bus
func set_master_volume(volume: float) -> void:
	master_volume = clamp(volume, 0.0, 1.0)
	_apply_volume()
	_save_config()

# Get the current master volume
func get_master_volume() -> float:
	return master_volume

# Apply the volume to the Master audio bus
func _apply_volume() -> void:
	var bus_index = AudioServer.get_bus_index("Master")
	if bus_index != -1:
		AudioServer.set_bus_volume_db(bus_index, linear_to_db(master_volume))

# Save volume settings to config file
func _save_config() -> void:
	var config = ConfigFile.new()
	config.set_value("audio", "master_volume", master_volume)
	config.save(CONFIG_PATH)

# Load volume settings from config file
func _load_config() -> void:
	var config = ConfigFile.new()
	var err = config.load(CONFIG_PATH)
	if err == OK:
		master_volume = config.get_value("audio", "master_volume", 1.0)
	else:
		master_volume = 1.0
	_save_config()
