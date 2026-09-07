extends Node

const MENUS = {
	"MAIN": "res://scenes/menus/main_menu.tscn",
	"CHART": "res://scenes/menus/ocean_chart.tscn",
	"ARSENAL": "res://scenes/menus/arsenal.tscn",
	"FOUNDRY": "res://scenes/menus/foundry.tscn",
	"LOBBY": "res://scenes/menus/crew_lobby.tscn",
	"REWARDS": "res://scenes/menus/mission_rewards.tscn",
	"CODEX": "res://scenes/menus/codex.tscn"
}

var current_scene = null

func _ready():
	var root = get_tree().root
	current_scene = root.get_child(root.get_child_count() - 1)

func goto_scene(path: String):
	# Call deferred to ensure safe scene transition
	call_deferred("_deferred_goto_scene", path)

func _deferred_goto_scene(path: String):
	get_tree().change_scene_to_file(path)

# Helper functions for UI button connections
func go_to_main(): goto_scene(MENUS["MAIN"])
func go_to_chart(): goto_scene(MENUS["CHART"])
func go_to_arsenal(): goto_scene(MENUS["ARSENAL"])
func go_to_foundry(): goto_scene(MENUS["FOUNDRY"])
func go_to_lobby(): goto_scene(MENUS["LOBBY"])
func go_to_rewards(): goto_scene(MENUS["REWARDS"])
func go_to_codex(): goto_scene(MENUS["CODEX"])

# Deploy directly to the main game scene
func deploy_to_abyss():
	goto_scene("res://scenes/main.tscn")
