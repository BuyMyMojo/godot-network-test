extends Control

@onready var start_server_button: Button = %StartServerButton
@onready var join_server_button: Button = %JoinServerButton
@onready var send_message_button: Button = %SendMessageButton
@onready var console_log: CodeEdit = %Log
@onready var msg_box: LineEdit = %MSGBox

var peer: ENetMultiplayerPeer

@onready var server_ip_box: LineEdit = %ServerIPBox
@onready var server_port_box: LineEdit = %ServerPortBox
const SERVER_MAX_CLIENTS: int = 16

func _ready() -> void:
	start_server_button.pressed.connect(_start_server)
	join_server_button.pressed.connect(_join_server)
	send_message_button.pressed.connect(_send_msg)
	pass

func _start_server() -> void:
	peer = ENetMultiplayerPeer.new()
	peer.create_server(int(server_port_box.text), SERVER_MAX_CLIENTS)
	multiplayer.multiplayer_peer = peer
	console_log.insert_line_at(0, "New server started on " + server_ip_box.text + ":" + server_port_box.text)
	#log.text = 

func _join_server() -> void:
	peer = ENetMultiplayerPeer.new()
	peer.create_client(server_ip_box.text, int(server_port_box.text))
	multiplayer.multiplayer_peer = peer
	console_log.insert_line_at(0, "Attempting to connect to " + server_ip_box.text + ":" + server_port_box.text + "...")
	await get_tree().create_timer(5).timeout
	if peer.get_connection_status() == 2:
		console_log.insert_line_at(0, "Connected to saerver at " + server_ip_box.text + ":" + server_port_box.text + " with unique id: " + str(peer.get_unique_id()))
	
	print(str(peer.get_connection_status()))

func _send_msg() -> void:
	if !msg_box.text.is_empty():
		message_recieved.rpc(msg_box.text)
	else:
		message_recieved.rpc("Empty Message")
		

@rpc("any_peer", "call_local")
func message_recieved(msg: String) -> void:
	console_log.insert_line_at(0, "New Message: " + msg)
