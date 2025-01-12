extends Node2D
@onready var PlayerHand = $Control/PlayerHand
@onready var BotHand = $Control/BotHand
@onready var DeckArea = $Control/DeckArea
@onready var ButtonSound = $AudioStreamPlayer

signal player_selected_card

var whosTurn = "player"
var chosencard = ""

# Called when the node enters the scene tree for the first time.
# Game State
var player_hand = []
var bot_hand = []
var deck = []
var middleDeck = []

func get_card_texture(card_name: String) -> Texture:
	# Example: card_name should match the filename (e.g., "2_of_hearts.png")
	var texture_path = "res://assets/sprites/cards/%s.png" % card_name
	'print("Loading texture: ", texture_path)'
	var texture = load(texture_path)
	'if texture == null:
		print("Error: Texture not found for card: ", card_name)'
	return texture


func _ready():
	print("Solo mode started!")
	ButtonSound.play()
	_initialize_game()
	ButtonSound.play()

func _initialize_game():
	# Placeholder: Initialize the deck and hands
	deck = createTestDeck()
	deck.shuffle()
	chosencard = deck.pick_random().name
	print("Chosen Card: " + chosencard[0])
	_deal_cards()
	print("Player Hand: ", player_hand)
	print("Bot Hand: ", bot_hand)

func _create_deck():
	# Create a placeholder deck (e.g., numbers 1-10 for simplicity)
	return ["A2", "A4", "A5", "A7", "K2", "K4", "K5", "K7", "Q2", "Q4", "Q5", "Q7"]

func createTestDeck():
	var testDeck = []
	addCardToDeck("A2", testDeck, 14, "Ace")
	addCardToDeck("A4", testDeck, 14, "Ace")
	addCardToDeck("A5", testDeck, 14, "Ace")
	addCardToDeck("A7", testDeck, 14, "Ace")
	addCardToDeck("K2", testDeck, 13, "King")
	addCardToDeck("K4", testDeck, 13, "King")
	addCardToDeck("K5", testDeck, 13, "King")
	addCardToDeck("K7", testDeck, 13, "King")
	addCardToDeck("Q2", testDeck, 12, "Queen")
	addCardToDeck("Q4", testDeck, 12, "Queen")
	addCardToDeck("Q5", testDeck, 12, "Queen")
	addCardToDeck("Q7", testDeck, 12, "Queen")
	return testDeck


func addCardToDeck(card_name: String, deckToAdd: Array, value: int, cardType: String):
	deckToAdd.append({
		name = card_name,
		isHidden = false,
		cardValue = value,
		type = cardType
	})


func _deal_cards():
	# Deal cards to the player and bot
	for i in range(5):  # Example: 5 cards each
		var player_card = deck.pop_back()
		var bot_card = deck.pop_back()
		
		player_hand.append(player_card)
		bot_hand.append(bot_card)
		
		# Add card visuals
		_add_card_to_hand(PlayerHand, player_card.name)
		_add_card_to_hand(BotHand, bot_card.name, true)

func _add_card_to_hand(hand_node: Node, card_name: String, hidden: bool = false):
	var card_texture = get_card_texture(card_name)
	if card_texture == null:
		print("Error: Failed to load texture for card: ", card_name)
		return
	
	var card_sprite = TextureRect.new()
	card_sprite.texture = card_texture
	
	if hidden:
		# Use a card back texture for hidden cards (e.g., "card_back.png")
		card_sprite.texture = preload("res://assets/sprites/cards/Back4.png")
	
	# Set the card's name for reference
	card_sprite.name = card_name
	
	# Enable input for the card sprite
	card_sprite.mouse_filter = Control.MOUSE_FILTER_PASS
	
	# Connect input_event signal to detect clicks
	card_sprite.connect("gui_input", Callable(self, "_on_card_clicked").bind(card_name))
	
	# Add the card sprite to the hand
	hand_node.add_child(card_sprite)


# Function to handle card clicks
func _on_card_clicked(event: InputEvent, card_name: String):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		# Check if the clicked card belongs to the player
		var is_player_card = false
		for card in player_hand:
			if card.name == card_name:
				is_player_card = true
				break

		if not is_player_card:
			print("Cannot click on bot's card")
			print("Player's hand:", player_hand)
			print("Clicked card:", card_name)
			return

		# Player clicked on this card
		print("Card clicked: ", card_name)

		# Perform logic for the card click
		_handle_card_selection(card_name)



# Handle card selection
func _handle_card_selection(card_name: String):
	# Example: Player puts this card in the middle
	if whosTurn == "player":
		#whosTurn = "bot"
		print("Player selected card: ", card_name)
		_move_card_to_middle(card_name)
		emit_signal("player_selected_card")

func getCardObject(card_name: String):
	for card in player_hand:
		if card.name == card_name:
			return card
	return null


func _move_card_to_middle(card_name: String):
	print("Moving card to the middle: ", card_name)
	
	# Remove the card from the player's hand
	var card_to_remove = null
	if whosTurn == "player":
		for card in player_hand:
			if card.name == card_name:
				card_to_remove = card
				break
		if card_to_remove != null:
			player_hand.erase(card_to_remove)
			_remove_card_from_hand(PlayerHand, card_name)
	
	elif whosTurn == "bot":
		for card in bot_hand:
			if card.name == card_name:
				card_to_remove = card
				break
		if card_to_remove != null:
			bot_hand.erase(card_to_remove)
			_remove_card_from_hand(BotHand, card_name)

	# Add the card to the middle deck
	middleDeck.append(card_name)
	print("Middle Deck: ", middleDeck)
	updateMiddleDeck(card_name)
	nextTurn()


func _remove_card_from_hand(hand_node: Node, card_name: String):
	for card_sprite in hand_node.get_children():
		if card_sprite.name == card_name:
			hand_node.remove_child(card_sprite)
			card_sprite.queue_free()
			break

func updateMiddleDeck(card_name: String):
	var card_texture = get_card_texture(card_name)
	if card_texture == null:
		print("Error: Failed to load texture for card: ", card_name)
		return
	
	var card_sprite = TextureRect.new()
	card_sprite.texture = card_texture
	DeckArea.add_child(card_sprite)
		
func botTurn():
	if whosTurn == "bot":
		var botsChosenCard = bot_hand.pick_random()
		print(botsChosenCard.name + " is bot's chosen card")
		await get_tree().create_timer(2.0).timeout
		_move_card_to_middle(botsChosenCard.name)

func nextTurn():
	if whosTurn == "bot":
		whosTurn = "player"
	elif whosTurn == "player":
		whosTurn = "bot"
		botTurn()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
	
func gameLoop():
	'print("Game Started")'
	print("Chosen Card: " + chosencard[0])
	while true:
		if whosTurn == "player":
			print("Player's Turn")
			await player_selected_card
		elif whosTurn == "bot":
			print("Bot's Turn")
			botTurn()
		else :
			break

		if len(player_hand) == 0:
			print("Player Wins")
			break
		elif len(bot_hand) == 0:
			print("Bot Wins")
			break
		else:
			pass

	
	
#Everybody gets 5 cards	+
#Game Chooses between King Queens or Aces +
#Player Starts + 
#Player chooses a card, and puts it in the middle +
#Bot can either call liar, or choose a card, and put it in the middle.
#If the bot calls liar, the card is flipped, and if the bot is correct, the player draws a card.
#If the bot is wrong, the bot draws a card.
#If the bot chooses a card, the player can either call liar, or choose a card, and put it in the middle.
#If the player calls liar, the card is flipped, and if the player is correct, the bot draws a card.
#If the player is wrong, the player draws a card.
#This runs until one of the players runs out of cards.
#That player wins
#If the deck runs out of cards, the one with the most cards wins/ or the one with the most of the chosen card wins. or least cards wins, or least of the chosen card wins or, rock paper scissors.
