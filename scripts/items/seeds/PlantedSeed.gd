extends Node2D

signal seed_rewards

const INITIAL_GROWING_STATE = -1

const GRASS_SEEDS = preload("res://scenes/items/seeds/grass/GrassSeed.tscn")

var state = {
	"tick": 0,
	"growing": INITIAL_GROWING_STATE
}

func _ready():
	$Tick.connect("timeout", self, "_on_tick")
	# Directly play planted animation
	$AnimationPlanted.play("planted")

func _on_tick():
	# TICK DEFAULT TIMEOUT 3
	# Grow seed on tick
	state.tick += 1

func _on_max_growing():
	var rewards = []
	for reward in seed_rewards():
		var current
		match reward:
			"grass":
				current = {"instance": GRASS_SEEDS.instance(), "position": reward_position()}
		rewards.push_back(current)
	
	emit_signal("seed_rewards", rewards)

func reward_position():
	randomize()
	return get_global_position() + Vector2(rand_range(0, 20), 0)

func seed_rewards():
	return []

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
