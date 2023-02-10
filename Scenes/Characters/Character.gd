extends KinematicBody

var food_types = {}
const PROJECTILE_SPEED = 50
var can_fire = true

func _ready():
	food_types = FileGrabber.get_files("res://Scenes/Ammo/FoodTypes/")
	print(food_types)
	randomize()

func fire():
	var random_food = food_types[randi() % food_types.size()]
	var projectile = load(random_food).instance()
	add_child(projectile)
	projectile.set_as_toplevel(true) # to prevent projectile moving in the same direction as the player. try commenting out for fun
	projectile.global_transform = $Forward.global_transform
	var character_forward = global_transform.basis[2].normalized()
	projectile.linear_velocity = character_forward * PROJECTILE_SPEED

func try_to_fire():
	if can_fire:
		fire()
		can_fire = false
		$TimeBetweenShots.start()

func _on_TimeBetweenShots_timeout():
	can_fire = true
