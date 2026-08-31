extends Node
class_name SeedManager

@export var fixed_seed: int = 0

var active_seed: int = 0

func initialize_seed() -> int:
	active_seed = fixed_seed if fixed_seed != 0 else int(Time.get_unix_time_from_system())
	seed(active_seed)
	return active_seed
