extends Node

signal on_vacuum_update


func vacuum_update(amount):
	on_vacuum_update.emit(amount)
