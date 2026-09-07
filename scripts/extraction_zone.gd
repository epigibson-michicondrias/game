extends Area3D

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D):
	if body.name == "Submarine":
		print("Submarine extracted. Returning to rewards menu...")
		# Wait a tiny bit and extract
		get_tree().create_timer(1.0).timeout.connect(func(): MenuNavigation.go_to_rewards())
