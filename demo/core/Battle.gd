extends Node

enum { STOPPED, STARTING, RUNNING }

var __time := 0.0
var __countdown_time := 0.0
var state := STOPPED

func begin():
	__time = 0.0
	__countdown_time = 0.0
	state = STARTING
	# generate the map here
