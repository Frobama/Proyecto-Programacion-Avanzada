extends Control

# URL de conexión
var _host = "ws://ucn-game-server.martux.cl:4010/"
@onready var _client: WebSocketClient = $WebSocketClient

# Referencias a los nodos de la UI
@onready var chat_display: TextEdit = $VBoxContainer/MainPanel/ChatDisplay
@onready var player_list: ItemList = $VBoxContainer/MainPanel/VBoxContainer/UserList

@onready var input_message: LineEdit = $VBoxContainer/Commands/InputMessage
@onready var send_button: Button = $VBoxContainer/Commands/SendButton
@onready var start_button: Button = $VBoxContainer/MainPanel/VBoxContainer/StartGameButton

var oponent_id = ""
var svgame_instance: Node = null
var my_id = ""
var players_by_id = {}
var players_in_game = {}

var connected_to_server := false
var current_name := ""

var current_popup: ConfirmationDialog = null
# Señales
# Cuando se cierra la conexión
func _on_web_socket_client_connection_closed():
	var ws = _client.get_socket()
	_sendToChatDisplay("Client just disconnected with code: %s, reason: %s" % [ws.get_close_code(), ws.get_close_reason()])

# Cuando se conecta al servidor
func _on_web_socket_client_connected_to_server():
	var login_event = {
		"event": "login",
		"data": { "gameKey": "695EJ5" }
	}
	_client.send(JSON.stringify(login_event))

# Gestor de mensajes del servidor
func _on_web_socket_client_message_received(message: String):
	var response = JSON.parse_string(message)
	print(response.event)
	match(response.event):
		"connect-match":
			print(response.msg)
		"connected-to-server":
			my_id = response.data.id
			connected_to_server = true
			_sendToChatDisplay("You are connected to the server!")
			$VBoxContainer/ConnectButton.visible = false
			$VBoxContainer/BackButton.visible = true
		"public-message":
			_sendToChatDisplay("(Público) %s: %s" % [response.data.playerName, response.data.playerMsg])
		"private-message":
			_sendToChatDisplay("(Privado) %s: %s" % [response.data.playerName, response.data.playerMsg])
		"send-public-message":
			_sendToChatDisplay("Tú (Publico): %s" % response.data.message)
		"send-private-message":
			_sendToChatDisplay("Tú (Privado al jugador %s): %s" % [players_by_id[response.data.playerId], response.data.message])
		"online-players":
			var names = []
			players_by_id.clear()
			players_in_game.clear()
			for data in response.data:
				var id = data.id
				var name = data.name
				print(name)
				if data.game.name == "Contaminación Mortal":
					players_in_game[id] = name
				players_by_id[id] = name
				names.append(name)
			_updateUserList(names)
		"player-data":
			var names = []
			for user in response.data:
				names.append(user.name)
			_updateUserList(names)
		"login":
			_sendGetUserListEvent()
		"player-name-changed":
			var player_id = response.data.playerId
			var new_name = response.data.playerName
			
			if player_id in players_by_id:
				var old_name = players_by_id[player_id]
				players_by_id[player_id] = new_name
				_sendToChatDisplay("El jugador '%s' ahora se llama '%s'" % [old_name, new_name])
				_updateUserList(players_by_id.values())
				
		"player-connected":
			if response.data.game.name == "Contaminación Mortal":
				players_in_game[response.data.id] = response.data.name
			_addUserToList(response.data.name)
			players_by_id[response.data.id] = response.data.name
		"player-disconnected":
			_deleteUserFromList(response.data.id)
		"match-request-received":
			var from_player = response.data.playerId
			if from_player in players_in_game:
				_show_ready_popup(from_player)
		"match-rejected":
			var from = players_in_game[response.data.playerId]
			_sendToChatDisplay("%s rechazó tu solicitud de partida." % from)
			$VBoxContainer/MainPanel/VBoxContainer/StartGameButton.visible = true
			$VBoxContainer/MainPanel/VBoxContainer/CancelGameButton.visible = false
		"match-accepted":
			var connect_event = {
			"event": "connect-match"
			}
			_client.send(JSON.stringify(connect_event))
		"players-ready":
			print("Jugadores listos, enviando ping...")
			var ping_event = {
				"event": "ping-match"
			}
			_client.send(JSON.stringify(ping_event))		
		"match-start":
			_sendToChatDisplay("Partida iniciada.")
			_start_game()
		"receive-game-data":
			var received_data = response.data
			print(received_data)
			if get_tree().current_scene.has_method("apply_remote_event"):
				get_tree().current_scene.apply_remote_event(received_data)
				
		"send-match-request":
			$VBoxContainer/MainPanel/VBoxContainer/StartGameButton.visible = false
			$VBoxContainer/MainPanel/VBoxContainer/CancelGameButton.visible = true
		"cancel-match-request":
			$VBoxContainer/MainPanel/VBoxContainer/StartGameButton.visible = true
			$VBoxContainer/MainPanel/VBoxContainer/CancelGameButton.visible = false
			_sendToChatDisplay("Se canceló la solicitud de partida.")
			if current_popup:
				current_popup.queue_free()
				current_popup = null
				
		"match-rejected":
			_sendToChatDisplay("%s rechazó tu solicitud de partida." % response.data.playerId)
			if current_popup:
				current_popup.queue_free()
				current_popup = null
		"match-canceled-by-sender":
			_sendToChatDisplay("%s canceló su solicitud de partida." % response.data.playerId)
			if current_popup:
				current_popup.queue_free()
				current_popup = null
		"finish-game":
			if svgame_instance:
				svgame_instance.show_victory_screen()
			_sendToChatDisplay(response.msg)
		"game-ended":
			print(response.msg)
			_sendToChatDisplay(response.msg)
		"close-match":
			print(response.msg)
			
func send_attack(attack_data: Dictionary):
	if oponent_id == "":
		print("No hay oponente asignado.")

	if oponent_id == my_id:
		# Modo local: simula ataque
		if svgame_instance != null:
			print("Simulando ataque local")
			svgame_instance.recibir_ataque(attack_data)
		return
	
	var message = {
		"event": "send-game-data",
		"data": {
			"subEvent": "attack",
			"attack_data": attack_data
		}
	}
	_client.send(JSON.stringify(message))

func _send_death():
	var message = {
		"event": "send-game-data",
		"data": {
			"subEvent": "death"
		}
	}
	_client.send(JSON.stringify(message))

func on_opponent_defeated():
	var event = {
		"event": "finish-game"
	}
	_client.send(JSON.stringify(event))
	svgame_instance.show_victory_screen()
	
func _show_ready_popup(from_player: String):
	var popup = ConfirmationDialog.new()
	popup.dialog_text = "%s quiere comenzar una partida. ¿Aceptar?" % players_by_id[from_player]
	popup.get_ok_button().text = "Aceptar"
	popup.get_cancel_button().text = "Rechazar"
	
	popup.connect("confirmed", func ():
		var accept_event = {
			"event": "accept-match",
			"data": {
				"id": from_player
			}
		}
		_client.send(JSON.stringify(accept_event))
		
		var connect_event = {
			"event": "connect-match"
		}
		_client.send(JSON.stringify(connect_event))
	)
	popup.connect("canceled", func ():
		var reject_event = {
			"event": "reject-match"
		}
		_client.send(JSON.stringify(reject_event))
	)
	current_popup = popup
	add_child(popup)
	popup.popup_centered()

func _send_rematch_request():
	var event = {
		"event": "send-rematch-request",
	}
	print(event)
	var result = _client.send(JSON.stringify(event))
	print(result)

func _send_quit_match():
	var event = {
		"event": "quit-match"
	}
	_client.send(JSON.stringify(event))
	
func _send_surrender():
	var message = {
		"event": "send-game-data",
		"data": {
			"subEvent": "surrender"
		}
	}
	_client.send(JSON.stringify(message))
	
func _start_game():
	var juego = preload("res://svgame.tscn").instantiate()
	juego.multijugador = true
	Global.chat_instance = self
	juego.chat_instance = self
	juego.remaining_time = 300
	juego.mob_limit = 13
	get_tree().root.add_child(juego)
	self.visible = false
	get_tree().current_scene = juego
	
	
# Señales de la UI
# Cuando se envia un mensaje desde el input
func _on_input_submitted(message:String): 
	if input_message.text == "":
		return
		
	_sendMessage(message)
	input_message.text = ""

# Cuando se presiona el botón de "SEND"
func _on_send_pressed():
	if input_message.text == "":
		return

	_sendMessage(input_message.text)
	input_message.text = ""


func _on_send_private_button_pressed() -> void:
	if input_message.text == "" or oponent_id == "":
		return
	
	_sendMessage(input_message.text, oponent_id)
	input_message.text = ""
# Cuando se pulsa el botón de "CONNECT TO SERVER"
func _on_connect_toggled(pressed):
	if not pressed:
		_client.close()
		return
	_sendToChatDisplay("Connecting to host: %s." % [_host])
	var err = _client.connect_to_url(_host)
	if err != OK:
		_sendToChatDisplay("Error connecting to host: %s" % [_host])
		return

# Funciones de la clase
# Agrega un mensaje en la pantalla de chat
func _sendToChatDisplay(msg):
	print(msg)
	chat_display.text += str(msg) + "\n"

# Envía un mensaje a un usuario o al chat grupal y manda la solicitud al servidor
func _sendMessage(message: String, userId: String = ''):
	var action
	var dataToSend
	if (userId != ''):
		action = 'send-private-message'
		dataToSend = {
		"event": action,
		"data": {
			"playerId": oponent_id,
			"message": message
			}
		}
	else:
		action = 'send-public-message'
		dataToSend = {
		"event": action,
		"data": {
			"message": message
			}
		}
	

	_client.send(JSON.stringify(dataToSend))

# Solicita la lista de usuarios activos al servidor
func _sendGetUserListEvent():
	var dataToSend = {
		"event": "online-players"
	}
	_client.send(JSON.stringify(dataToSend))

# Actualiza la lista de usuarios de la interfaz gráfica
func _updateUserList(users: Array):
	player_list.clear()
	for user in users:
		#if user != my_id:
			
		player_list.add_item(user)

# Agrega un jugador al listado
func _addUserToList(user: String):
	player_list.add_item(user)

# Elimina un jugador del listado
func _deleteUserFromList(userId: String):
	var playerListCount = player_list.item_count
	for i in range(0, playerListCount):
		if(player_list.get_item_text(i) == players_by_id[userId]):
			player_list.remove_item(i)
			return


func _on_user_list_item_selected(index: int) -> void:
	var oponent_name = player_list.get_item_text(index)
	oponent_id = get_player_id_by_name(oponent_name)
	start_button.visible = true
	print("Contectado contra:", oponent_id)
	
func get_player_id_by_name(name: String) -> String:
	for id in players_by_id.keys():
		if players_by_id[id] == name:
			return id
	return ""
	
func send_ready_request(oponent_id: String):
	var dataToSend = {
		"event": 'send-match-request',
		"data": {
			"playerId": oponent_id
		}
	}
	_client.send(JSON.stringify(dataToSend))
	

func _on_start_game_button_pressed() -> void:
	if oponent_id != "" and oponent_id in players_in_game and oponent_id != my_id:
		send_ready_request(oponent_id)

func _on_cancel_game_button_pressed() -> void:
	var dataToSend = {
		"event": "cancel-match-request"
	}
	_client.send(JSON.stringify(dataToSend))
	
func start_local_test():
	var juego = preload("res://svgame.tscn").instantiate()
	juego.multijugador = true
	juego.chat_instance = self
	oponent_id = my_id  # Simulamos oponente local

	get_tree().root.add_child(juego)
	self.visible = false
	get_tree().current_scene = juego


func _on_accept_pressed() -> void:
	var name = $LoginPanel/VBoxContainer/PlayerNameInput.text.strip_edges()
	if name == "":
		push_error("Ingresa un nombre válido")
		return
		
	if connected_to_server:
		if name != current_name:
			var change_event = {
				"event": "change-name",
				"data": {
					"name": name
				}
			}
			_client.send(JSON.stringify(change_event))
			current_name = name
		$LoginPanel.visible = false
		$VBoxContainer.visible = true
	else:
		current_name = name
		_host = "ws://ucn-game-server.martux.cl:4010/?gameId=A&playerName=%s" % name
		$LoginPanel.visible = false
		$VBoxContainer.visible = true


func _on_exit_pressed() -> void:
	Global.chat_instance = null
	get_tree().change_scene_to_file("res://menu.tscn")
	  # Destruye esta instancia
	


func _on_back_button_pressed() -> void:
	Global.chat_instance = null
	get_tree().change_scene_to_file("res://menu.tscn")
