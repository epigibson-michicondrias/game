extends Control

func _ready():
	var btn_back = Button.new()
	btn_back.text = "VOLVER AL MENU PRINCIPAL"
	$NavButtons.add_child(btn_back)
	btn_back.pressed.connect(Callable(MenuNavigation, "go_to_main"))
