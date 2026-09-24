extends Node
## Authoritative, saveable progression state for the Echofang vertical slice.

signal ability_unlocked(id: StringName)
signal health_changed(current: int, maximum: int)
signal motes_changed(amount: int)
signal save_changed

const SAVE_PATH := "user://echofang_save.json"
const MAX_HEALTH := 5
const MAX_UMBRA := 9

var abilities: Dictionary = {
	&"fang_dash": false,
	&"wraith_wings": false,
	&"wall_cling": false,
	&"echo_needle": false,
	&"umbral_pulse": false,
	&"pulse_beam": false,
}
var health: int = MAX_HEALTH
var motes: int = 0
var umbra: int = 0
var last_safe_position := Vector2(180.0, 482.0)
var current_room: int = 2
var recovery_motes: int = 0
var recovery_position := Vector2.ZERO
var expedition_started := false

func _ready() -> void:
	# A fresh run is the default for the playable slice. Continue can call load_game.
	process_mode = Node.PROCESS_MODE_ALWAYS

func reset_run() -> void:
	abilities = {
		&"fang_dash": false,
		&"wraith_wings": false,
		&"wall_cling": false,
		&"echo_needle": false,
		&"umbral_pulse": false,
		&"pulse_beam": false,
	}
	health = MAX_HEALTH
	motes = 0
	umbra = 0
	last_safe_position = Vector2(180.0, 482.0)
	current_room = 2
	recovery_motes = 0
	recovery_position = Vector2.ZERO
	expedition_started = true
	save_changed.emit()

func has_ability(id: StringName) -> bool:
	return bool(abilities.get(id, false))

func unlock_ability(id: StringName) -> void:
	if has_ability(id):
		return
	abilities[id] = true
	ability_unlocked.emit(id)
	save_game()

func damage(amount: int) -> bool:
	if health <= 0:
		return false
	health = maxi(0, health - maxi(1, amount))
	health_changed.emit(health, MAX_HEALTH)
	return health == 0

func heal(amount: int = 1) -> void:
	health = mini(MAX_HEALTH, health + maxi(1, amount))
	health_changed.emit(health, MAX_HEALTH)

func add_motes(amount: int) -> void:
	motes = maxi(0, motes + amount)
	motes_changed.emit(motes)

func add_umbra(amount: int = 1) -> void:
	umbra = mini(MAX_UMBRA, umbra + maxi(1, amount))

func spend_umbra(amount: int) -> bool:
	if umbra < amount:
		return false
	umbra -= amount
	return true

func begin_death(at: Vector2) -> void:
	recovery_motes = motes
	recovery_position = at
	motes = 0
	health = MAX_HEALTH
	last_safe_position = at
	health_changed.emit(health, MAX_HEALTH)
	motes_changed.emit(motes)
	save_game()

func recover_corpse() -> int:
	var recovered := recovery_motes
	motes += recovery_motes
	recovery_motes = 0
	recovery_position = Vector2.ZERO
	motes_changed.emit(motes)
	save_game()
	return recovered

func save_game() -> bool:
	var payload := {
		"version": 1,
		"abilities": abilities,
		"health": health,
		"motes": motes,
		"umbra": umbra,
		"last_safe_position": {"x": last_safe_position.x, "y": last_safe_position.y},
		"current_room": current_room,
		"recovery_motes": recovery_motes,
		"recovery_position": {"x": recovery_position.x, "y": recovery_position.y},
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(payload))
	file.close()
	save_changed.emit()
	return true

func load_game() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		return false
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return false
	var parsed = JSON.parse_string(file.get_as_text())
	file.close()
	if not parsed is Dictionary:
		return false
	var saved: Dictionary = parsed
	var saved_abilities = saved.get("abilities", {})
	if saved_abilities is Dictionary:
		for key in abilities.keys():
			abilities[key] = bool(saved_abilities.get(key, false))
	health = clampi(int(saved.get("health", MAX_HEALTH)), 1, MAX_HEALTH)
	motes = maxi(0, int(saved.get("motes", 0)))
	umbra = clampi(int(saved.get("umbra", 0)), 0, MAX_UMBRA)
	current_room = clampi(int(saved.get("current_room", 2)), 1, 24)
	var saved_pos = saved.get("last_safe_position", {})
	if saved_pos is Dictionary:
		last_safe_position = Vector2(float(saved_pos.get("x", 180.0)), float(saved_pos.get("y", 482.0)))
	var saved_recovery = saved.get("recovery_position", {})
	if saved_recovery is Dictionary:
		recovery_position = Vector2(float(saved_recovery.get("x", 0.0)), float(saved_recovery.get("y", 0.0)))
	recovery_motes = maxi(0, int(saved.get("recovery_motes", 0)))
	expedition_started = true
	health_changed.emit(health, MAX_HEALTH)
	motes_changed.emit(motes)
	return true
