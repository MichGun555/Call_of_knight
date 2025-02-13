extends CanvasLayer

onready var Health = $Health
onready var player = get_node("../player")

onready var count_coin = $coins
func _process(delta):
	Health.text = str(player.health)
	count_coin.text = str(player.coin)
	
