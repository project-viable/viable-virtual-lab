class_name AsyncLock
## A mutex, but for coroutines (this lock only works within one thread).
##
## Given an [AsyncLock] [code]lock[/code], a coroutine can get access to it via
## [code]await lock.lock_async()[/code]. When done using the resource, just call
## [code]lock.unlock()[/code]. Do not await [method unlock].


signal _unlocked()


var _num_accessors: int = 0


func lock_async() -> void:
	# Our "spot in line". When it reaches zero, it is our turn.
	var order := _num_accessors
	_num_accessors += 1

	while order > 0:
		await _unlocked
		order -= 1

func unlock() -> void:
	# Handle the situation where unlock is incorrectly called without locking, I guess.
	_num_accessors = max(0, _num_accessors - 1)
	_unlocked.emit()
