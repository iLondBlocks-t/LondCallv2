class_name AbilityResource
extends Resource
## Data-only definition: designers tune abilities without touching PlayerController.

@export_category("Identity")
@export var ability_id: StringName
@export var display_name := "Ability"
@export_multiline var description := ""
@export var input_action: StringName
@export var gate_label := ""

@export_category("Feel")
@export var cooldown_seconds := 0.0
@export var resource_cost := 0
@export var active_seconds := 0.15
@export var invulnerable := false
@export var color := Color.WHITE

@export_category("Presentation")
@export var vfx_id := "pulse"
@export var sfx_id := "ability"
