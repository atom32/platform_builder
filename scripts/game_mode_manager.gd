extends Node

## Game Mode Manager
## Manages switching between Story Mode and Free Sandbox mode
## This is an autoload singleton that tracks the current game mode

## Constants for game modes
const STORY_MODE: int = 1
const FREE_SANDBOX: int = 0

## Signal emitted when game mode changes
signal mode_changed(mode: int)

## Current active game mode
var current_mode: int = FREE_SANDBOX

## Start Story Mode from specified chapter
func start_story_mode(chapter: int = 0):
	current_mode = STORY_MODE
	print("[GameModeManager] Starting Story Mode, Chapter ", chapter)
	mode_changed.emit(current_mode)

## Start Free Sandbox Mode
func start_sandbox_mode():
	current_mode = FREE_SANDBOX
	print("[GameModeManager] Starting Sandbox Mode")
	mode_changed.emit(current_mode)

func _ready():
	print("[GameModeManager] Initialized")
