extends RigidBody2D

func _ready() -> void:
	contact_monitor = true
	max_contacts_reported = 5
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("enemy"): return
	if body == self: return
	body.die(Vector2.ZERO)
	die_in_chain_reaction()


func die(_impact_direction: Vector2) -> void:
	queue_free()


func die_in_chain_reaction() -> void:
	queue_free()
