extends Node2D

@onready var PlayerHand = $Control/PlayerHand
@onready var BotHand = $Control/BotHand
@onready var DeckArea = $Control/DeckArea
@onready var chosenCardLabel = $Control/chosenCardLabel
@onready var botLiarLabel = $Control/botLiarLabel
@onready var playerLiarLabel = $Control/playerLiarLabel
@onready var winLabel = $Control/winLabel
@onready var ButtonSound = $AudioStreamPlayer
@onready var liarAudio = $liarAudio
@onready var dukSound = $dukSound


signal player_selected_card

var whosTurn = ""
var chosencard = ""
var gameOngoing = false

# Game State
var player_hand = []
var bot_hand = []
var deck = []
var middleDeck = []

# Define the Card class
class Card:
	var name: String
	var isHidden: bool
	var cardValue: int
	var type: String

	func _init(_name: String, _value: int, _type: String, _hidden: bool = false):
		name = _name
		cardValue = _value
		type = _type
		isHidden = _hidden

func _ready():
	print("Solo mode started!")
	ButtonSound.play()
	_initialize_game()
	ButtonSound.play()

func _initialize_game():
	gameOngoing = true
	playerLiarLabel.visible = false
	botLiarLabel.visible = false
	winLabel.visible = false
	deck = create_test_deck()
	deck.shuffle()
	set_chosen_card()
	_deal_cards()
	print("Player Hand: ", player_hand)
	print("Bot Hand: ", bot_hand)
	
	

func _on_button_pressed() -> void:
	if !gameOngoing:
		print("Game is over!")
		return
	ButtonSound.play()
	if(whosTurn == "player"):
		
		if middleDeck.size() != 0:
			print("Player pressed LIAR button")
			playerLiarLabel.visible = true
			liarAudio.play()
			await get_tree().create_timer(2).timeout
			update_middle_deck(middleDeck.back(), false)
			if !liar_button_check():
				print("Player wins!")
				winLabel.text = "PLAYER WINS"
				winLabel.visible = true
			else:
				print("Player loses!")
				winLabel.text = "BOT WINS"
				winLabel.visible = true
			gameOngoing = false

func liar_button_check() -> bool:
	if middleDeck.size() == 0:
		return false
	var last_card = middleDeck.back()
	print("Last card in middle deck: ", last_card.name)
	return last_card.name[0] == chosencard[0]

func get_card_texture(card: Card) -> Texture:
	var card_name = card.name
	var texture_path = "res://assets/sprites/cards/%s.png" % card_name
	var texture = load(texture_path)
	return texture

func set_chosen_card():
	var random_card = deck.pick_random()
	chosencard = random_card.name
	print("Chosen Card: " + chosencard[0])
	if chosencard[0] == "A":
		chosenCardLabel.text = "ACE"
	elif chosencard[0] == "K":
		chosenCardLabel.text = "KING"
	elif chosencard[0] == "Q":
		chosenCardLabel.text = "QUEEN"

func create_test_deck() -> Array:
	var testDeck = []
	add_card_to_deck("A1", testDeck, 14, "Ace")
	add_card_to_deck("A2", testDeck, 14, "Ace")
	add_card_to_deck("A3", testDeck, 14, "Ace")
	add_card_to_deck("A4", testDeck, 14, "Ace")
	add_card_to_deck("A5", testDeck, 14, "Ace")
	add_card_to_deck("A6", testDeck, 14, "Ace")
	'add_card_to_deck("A7", testDeck, 14, "Ace")
	add_card_to_deck("A8", testDeck, 14, "Ace")'
	add_card_to_deck("K1", testDeck, 13, "King")
	add_card_to_deck("K2", testDeck, 13, "King")
	add_card_to_deck("K3", testDeck, 13, "King")
	add_card_to_deck("K4", testDeck, 13, "King")
	add_card_to_deck("K5", testDeck, 13, "King")
	add_card_to_deck("K6", testDeck, 13, "King")
	'add_card_to_deck("K7", testDeck, 13, "King")
	add_card_to_deck("K8", testDeck, 13, "King")'
	add_card_to_deck("Q1", testDeck, 12, "Queen")
	add_card_to_deck("Q2", testDeck, 12, "Queen")
	add_card_to_deck("Q3", testDeck, 12, "Queen")
	add_card_to_deck("Q4", testDeck, 12, "Queen")
	add_card_to_deck("Q5", testDeck, 12, "Queen")
	add_card_to_deck("Q6", testDeck, 12, "Queen")
	'add_card_to_deck("Q7", testDeck, 12, "Queen")
	add_card_to_deck("Q8", testDeck, 12, "Queen")'
	return testDeck

func add_card_to_deck(card_name: String, deck_to_add: Array, value: int, card_type: String):
	var card = Card.new(card_name, value, card_type)
	deck_to_add.append(card)

func _deal_cards():
	await get_tree().create_timer(0.5).timeout
	for i in range(5):  # Example: 5 cards each
		var player_card = deck.pop_back() as Card
		var bot_card = deck.pop_back() as Card
		
		player_hand.append(player_card)
		bot_hand.append(bot_card)
		
		# Add card visuals
		dukSound.play()
		_add_card_to_hand(PlayerHand, player_card)
		await get_tree().create_timer(0.2).timeout
		dukSound.play()
		_add_card_to_hand(BotHand, bot_card, true)
		await get_tree().create_timer(0.2).timeout
	whosTurn = "player"

func _add_card_to_hand(hand_node: Node, card: Card, hidden: bool = false):
	var card_texture = get_card_texture(card)
	if card_texture == null:
		print("Error: Failed to load texture for card: ", card.name)
		return
	
	var card_sprite = TextureRect.new()
	card_sprite.texture = card_texture
	
	if hidden:
		card_sprite.texture = preload("res://assets/sprites/cards/Back4.png")
	
	card_sprite.name = card.name
	card_sprite.mouse_filter = Control.MOUSE_FILTER_PASS
	card_sprite.connect("gui_input", Callable(self, "_on_card_clicked").bind(card))
	hand_node.add_child(card_sprite)

func _on_card_clicked(event: InputEvent, card: Card):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT and gameOngoing:
		var is_player_card = false
		for card2 in player_hand:
			if card2.name == card.name:
				is_player_card = true
				break

		if not is_player_card:
			print("Cannot click on bot's card")
			print("Player's hand:", player_hand)
			print("Clicked card:", card.name)
			return

		print("Card clicked: ", card.name)
		_handle_card_selection(card)

func _handle_card_selection(card: Card):
	if whosTurn == "player":
		print("Player selected card: ", card.name)
		ButtonSound.play()
		_move_card_to_middle(card)
		emit_signal("player_selected_card")

func _move_card_to_middle(card: Card):
	print("Moving card to the middle: ", card.name)
	var card_to_remove = null
	var hidden = false
	if whosTurn == "player":
		for card2 in player_hand:
			if card2.name == card.name:
				card_to_remove = card2
				break
		if card_to_remove != null:
			player_hand.erase(card_to_remove)
			_remove_card_from_hand(PlayerHand, card_to_remove)
			hidden = false
	elif whosTurn == "bot":
		for card2 in bot_hand:
			if card2.name == card.name:
				card_to_remove = card2
				break
		if card_to_remove != null:
			bot_hand.erase(card_to_remove)
			_remove_card_from_hand(BotHand, card_to_remove)
			hidden = true

	middleDeck.append(card)
	update_middle_deck(card, hidden)
	next_turn()

func _remove_card_from_hand(hand_node: Node, card: Card):
	for card_sprite in hand_node.get_children():
		if card_sprite.name == card.name:
			hand_node.remove_child(card_sprite)
			card_sprite.queue_free()
			break

func update_middle_deck(card: Card, hidden: bool=false):
	if hidden==false:
		var card_texture = get_card_texture(card)
		var card_sprite = TextureRect.new()
		card_sprite.texture = card_texture
		DeckArea.add_child(card_sprite)
		if card_texture == null:
			print("Error: Failed to load texture for card: ", card.name)
			return
	elif hidden==true:
		var card_texture = preload("res://assets/sprites/cards/Back4.png")
		var card_sprite = TextureRect.new()
		card_sprite.texture = card_texture
		DeckArea.add_child(card_sprite)
	
'	var card_texture = get_card_texture(card)
	if card_texture == null:
		print("Error: Failed to load texture for card: ", card.name)
		return'
	
'	var card_sprite = TextureRect.new()
	card_sprite.texture = card_texture
	DeckArea.add_child(card_sprite)'

func bot_turn():
	if whosTurn == "bot" and gameOngoing:
		await get_tree().create_timer(2.0).timeout
		var rng = randf_range(0,5)
		print(rng)
		if rng > 1:
			var bots_chosen_card = bot_hand.pick_random()
			print(bots_chosen_card.name + " is bot's chosen card")
			ButtonSound.play()
			_move_card_to_middle(bots_chosen_card)
		else:
			print("Bot calls liar")
			botLiarLabel.visible = true
			liarAudio.play()
			await get_tree().create_timer(2).timeout
			if !liar_button_check():
				print("Bot wins!")
				winLabel.text = "BOT WINS"
				winLabel.visible = true
			else:
				print("Bot loses!")
				winLabel.text = "PLAYER WINS"
				winLabel.visible = true
			gameOngoing = false
				
		

func next_turn():
	if whosTurn == "bot":
		whosTurn = "player"
	elif whosTurn == "player":
		whosTurn = "bot"
		bot_turn()
