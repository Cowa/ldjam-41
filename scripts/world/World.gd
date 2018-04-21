extends Node


const PLANTED_SEEDS = {
	"grass": preload("res://scenes/items/seeds/grass/PlantedGrass.tscn")
}

const GUITAR = preload("res://scenes/items/Guitar.tscn")

func _ready():
	$Player.connect("seeds_changed", $UI/Belt, "update_seeds")
	$Player.connect("belt_cursor_changed", $UI/Belt, "update_cursor")
	$Player.connect("picked_guitar", $UI/Belt, "toggle_guitar_slot")
	$Player.connect("seed_planted", self, "_seed_planted")
	
	# On first seed, "special" event (ONESHOT => only one tiùe)
	$Player.connect("seed_planted", self, "_on_first_seed_planted", [], CONNECT_ONESHOT)
	
	# Connect pre-existing item
	for item in $Ground/CollectableItems.get_children():
		item.connect("pickup", $Player, "picked_item")
	
	$Tick.connect("timeout", self, "_on_tick")

func _physics_process(delta):
	if Input.is_action_pressed("ui_reload"):
		get_tree().reload_current_scene()

func _seed_planted(seed_type, position):
	var seed_instance = PLANTED_SEEDS[seed_type].instance()
	seed_instance.set_position($Ground.to_local(position))
	$Ground/PlantedSeeds.add_child(seed_instance)
	seed_instance.connect("seed_rewards", self, "_on_seed_rewards")

# World ticking
func _on_tick():
	pass

func _on_seed_rewards(rewards):
	for reward in rewards:
		var instance = reward.instance
		instance.set_global_position(reward.position)
		add_item(instance)

func _on_first_seed_planted(seed_type, position):
	var guitar = GUITAR.instance()
	
	# Make guitar falling from the sky #ameno
	$Tween.interpolate_property(
		guitar, "position",
		$Player.get_position() + Vector2(250, -500), $Player.get_position() + Vector2(250, 0),
		1.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, 1.0
	)
	$Tween.start()
	
	add_item(guitar)

func add_item(item):
	item.connect("pickup", $Player, "picked_item")
	$Ground/CollectableItems.add_child(item)
