extends Node2D
@onready var PlayerHand = $Control/PlayerHand
@onready var BotHand = $Control/BotHand
@onready var ButtonSound = $AudioStreamPlayer


# Called when the node enters the scene tree for the first time.
# Game State
var player_hand = []
var bot_hand = []
var deck = []

func get_card_texture(card_name: String) -> Texture:
	# Example: card_name should match the filename (e.g., "2_of_hearts.png")
	return load("res://assets/sprites/cards/%s.png" % card_name)


func _ready():
	print("Solo mode started!")
	ButtonSound.play()
	_initialize_game()

func _initialize_game():
	# Placeholder: Initialize the deck and hands
	deck = _create_deck()
	deck.shuffle()
	_deal_cards()
	print("Player Hand: ", player_hand)
	print("Bot Hand: ", bot_hand)

func _create_deck():
	# Create a placeholder deck (e.g., numbers 1-10 for simplicity)
	return ["A.2", "A.4", "A.5", "A.7", "K2", "K4", "K5", "K7", "Q2", "Q4", "Q5", "Q7", "J2", "J4"]

func _deal_cards():
	# Deal cards to the player and bot
	for i in range(5):  # Example: 3 cards each
		var player_card = deck.pop_back()
		var bot_card = deck.pop_back()
		
		player_hand.append(player_card)
		bot_hand.append(bot_card)
		
		# Add card visuals
		_add_card_to_hand(PlayerHand, player_card)
		_add_card_to_hand(BotHand, bot_card, true)

func _add_card_to_hand(hand_node: Node, card_name: String, hidden: bool = false):
	var card_texture = get_card_texture(card_name)
	var card_sprite = TextureRect.new()
	card_sprite.texture = card_texture
	
	if hidden:
		# Use a card back texture for hidden cards (e.g., "card_back.png")
		card_sprite.texture = preload("res://assets/sprites/cards/Back4.png")
	
	# Add the card sprite to the hand
	hand_node.add_child(card_sprite)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
