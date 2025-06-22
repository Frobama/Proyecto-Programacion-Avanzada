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
# Señales
# Cuando se cierra la conexión
func _on_web_socket_client_connection_closed():
	var ws = _client.get_socket()
	_sendToChatDisplay("Client just disconnected with code: %s, reason: %s" % [ws.get_close_code(), ws.get_close_reason()])

# Cuando se conecta al servidor
func _on_web_socket_client_connected_to_server():
	_sendGetUserListEvent()

# Gestor de mensajes del servidor
func _on_web_socket_client_message_received(message: String):
	var response = JSON.parse_string(message)
	match(response.event):
		"connected-to-server":
			my_id = response.data.id
			_sendToChatDisplay("You are connected to the server!")
		"public-message":
			_sendToChatDisplay("%s: %s" % [response.data.id, response.data.msg])
		"get-connected-players":
			_updateUserList(response.data)
		"player-connected":
			_addUserToList(response.data.id)
		"player-disconnected":
			_deleteUserFromList(response.data.id)
		"private-message":
			print(response)
			var sender = response.data.id
			var message1 = response.data.msg
			print(message1)
			if typeof(message1) == TYPE_STRING:
				
				if message1 == "ready-to-play":
					print("ready")
					_show_ready_popup(sender)
				elif message1 == "ready-confirmed":
					_start_game_with(sender)
			elif typeof(message1) == TYPE_DICTIONARY and message1.has("type") and message1.type == "attack":
				if svgame_instance != null:
					svgame_instance.recibir_ataque(message1.attack_data)

				

func send_attack(attack_data: Dictionary):
	if oponent_id == "":
		print("No hay oponente asignado.")
		return

	if oponent_id == my_id:
		# Modo local: simula ataque
		if svgame_instance != null:
			print("Simulando ataque local")
			svgame_instance.recibir_ataque(attack_data)
		return
	
	var message = {
		"event": "send-private-message",
		"data": {
			"message": {
				"type": "attack",
				"attack_data": attack_data
			},
			"id": oponent_id
		}
	}
	_client.send(JSON.stringify(message))



func _show_ready_popup(from_player: String):
	var popup = ConfirmationDialog.new()
	popup.dialog_text = "%s quiere comenzar una partida. ¿Aceptar?" % from_player
	popup.get_ok_button().text = "Aceptar"
	popup.get_cancel_button().text = "Rechazar"
	
	popup.connect("confirmed", func ():
		if oponent_id != my_id:
			_send_ready_confirm(from_player)
		_start_game_with(from_player)
	)
	add_child(popup)
	popup.popup_centered()

func _send_ready_confirm(to_player: String):
	var dataToSend = {
		"event": 'send-private-message',
		"data": {
			"id": to_player,
			"message": "ready-confirmed"
		}
	}
	_client.send(JSON.stringify(dataToSend))
	
func _start_game_with(oponent: String):
	oponent_id = oponent
	var juego = preload("res://svgame.tscn").instantiate()
	juego.multijugador = true
	juego.chat_instance = self
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
	if (userId != ''):
		action = 'send-private-message'
	else:
		action = 'send-public-message'
		
	var dataToSend = {
		"event": action,
		"data": {
			"message": message
		}
	}

	_client.send(JSON.stringify(dataToSend))

# Solicita la lista de usuarios activos al servidor
func _sendGetUserListEvent():
	var dataToSend = {
		"event": 'get-connected-players'
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
		if(player_list.get_item_text(i) == userId):
			player_list.remove_item(i)
			return


func _on_user_list_item_selected(index: int) -> void:
	oponent_id = player_list.get_item_text(index)
	start_button.visible = true
	print("Contectado contra:", oponent_id)
	
func send_ready_request(oponent_id: String):
	var dataToSend = {
		"event": 'send-private-message',
		"data": {
			"id": oponent_id,
			"message": "ready-to-play"
		}
	}
	_client.send(JSON.stringify(dataToSend))
	

func _on_start_game_button_pressed() -> void:
	if oponent_id != "":
		send_ready_request(oponent_id)

func start_local_test():
	var juego = preload("res://svgame.tscn").instantiate()
	juego.multijugador = true
	juego.chat_instance = self
	oponent_id = my_id  # Simulamos oponente local

	get_tree().root.add_child(juego)
	self.visible = false
	get_tree().current_scene = juego
