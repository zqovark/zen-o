extends Node3D

@onready var player: PlayerController = $Player
@onready var world: Node3D = $World
@onready var threshold_system: ZenoThresholdSystem = $Systems/ZenoThresholdSystem
@onready var state_controller: WorldStateController = $Systems/WorldStateController
@onready var transform_director: TransformationDirector = $Systems/TransformationDirector
@onready var operator_system: OperatorSystem = $Systems/OperatorSystem
@onready var objective_manager: ObjectiveManager = $Systems/ObjectiveManager
@onready var seed_manager: SeedManager = $Systems/SeedManager
@onready var spawner: ProceduralSpawner = $Systems/ProceduralSpawner
@onready var debug_overlay: DebugOverlay = $DebugOverlay

@onready var fragment_a: StateInteractable = $World/Interactables/FragmentA
@onready var fragment_b: StateInteractable = $World/Interactables/FragmentB
@onready var anchor: StateInteractable = $World/Interactables/Anchor
@onready var exit_gate: StateInteractable = $World/Interactables/Exit

func _ready() -> void:
	_ensure_input_actions()
	var run_seed := seed_manager.initialize_seed()

	threshold_system.threshold_entered.connect(state_controller.on_threshold_entered)
	threshold_system.threshold_exited.connect(state_controller.on_threshold_exited)
	state_controller.world_state_changed.connect(_on_world_state_changed)
	player.interaction_requested.connect(_on_player_interaction_requested)
	fragment_a.interacted.connect(_on_interactable_interacted)
	fragment_b.interacted.connect(_on_interactable_interacted)
	anchor.interacted.connect(_on_interactable_interacted)
	exit_gate.interacted.connect(_on_interactable_interacted)

	spawner.place_interactable(fragment_a, spawner.fragment_a_slots)
	spawner.place_interactable(fragment_b, spawner.fragment_b_slots)

	_on_world_state_changed(0, state_controller.state_index)
	debug_overlay.update_data(run_seed, state_controller, threshold_system.get_debug_data(player.global_position), operator_system.active_operator, _objective_text())

func _process(_delta: float) -> void:
	threshold_system.update_for_position(player.global_position)
	debug_overlay.update_data(seed_manager.active_seed, state_controller, threshold_system.get_debug_data(player.global_position), operator_system.active_operator, _objective_text())

func _on_world_state_changed(_previous_state: int, current_state: int) -> void:
	transform_director.on_world_state_changed(_previous_state, current_state, state_controller)
	for node in [fragment_a, fragment_b, anchor, exit_gate]:
		node.apply_state(current_state)
	exit_gate.visible = objective_manager.can_exit() and exit_gate.visible

func _on_player_interaction_requested(target: Node) -> void:
	if target is StateInteractable:
		(target as StateInteractable).interact(state_controller.state_index)

func _on_interactable_interacted(interactable: StateInteractable) -> void:
	match interactable.interactable_id:
		&"fragment_a":
			objective_manager.collect_fragment(&"fragment_a")
		&"fragment_b":
			objective_manager.collect_fragment(&"fragment_b")
			state_controller.queue_forward_state_boost(1)
		&"anchor":
			operator_system.activate_anchor()
			objective_manager.activate_anchor()
		&"exit":
			objective_manager.complete_run()

	if objective_manager.can_exit():
		exit_gate.visible = true

func _objective_text() -> String:
	if not objective_manager.has_fragment_b:
		return "Find Fragment B by pushing forward, then check behind you."
	if not objective_manager.has_fragment_a:
		return "Use the modified next state to collect Fragment A."
	if not objective_manager.anchor_activated:
		return "Activate Anchor to stabilize the Exit."
	if not objective_manager.can_exit():
		return "Prepare to exit."
	return "Reach the Exit."

func _ensure_input_actions() -> void:
	_map_action("move_forward", KEY_W)
	_map_action("move_backward", KEY_S)
	_map_action("move_left", KEY_A)
	_map_action("move_right", KEY_D)
	_map_action("interact", KEY_E)
	_map_action("jump", KEY_SPACE)

func _map_action(action: StringName, key: Key) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	if InputMap.action_get_events(action).any(func(event: InputEvent) -> bool: return event is InputEventKey and event.physical_keycode == key):
		return
	var key_event := InputEventKey.new()
	key_event.physical_keycode = key
	InputMap.action_add_event(action, key_event)
