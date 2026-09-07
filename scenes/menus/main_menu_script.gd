extends Control

func _ready():
	if $NavButtons/BtnPVP:
		$NavButtons/BtnPVP.pressed.connect(Callable(MenuNavigation, "deploy_to_abyss"))
	if $NavButtons/BtnPVE:
		$NavButtons/BtnPVE.pressed.connect(Callable(MenuNavigation, "go_to_chart"))
	if $NavButtons/BtnArsenal:
		$NavButtons/BtnArsenal.pressed.connect(Callable(MenuNavigation, "go_to_arsenal"))
	if $NavButtons/BtnFoundry:
		$NavButtons/BtnFoundry.pressed.connect(Callable(MenuNavigation, "go_to_foundry"))
