class_name AsyncTask
extends BTAction


var running: bool = false
var done: bool = false


func _enter() -> void:
	running = false
	done = false


func _tick(_delta: float) -> Status:
	if not running:
		running = true
		_run_async()
		return RUNNING

	if not done:
		return RUNNING

	return SUCCESS


# In this child function, the method _run must be explicitely
# called
func _run_async() -> void:
	push_error("_run_async() must be implemented")


func _run(callable: Callable, ...args) -> void:
	await callable.callv(args)
	done = true
