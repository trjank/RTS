class_name MultiplayerPlayer extends Player

var peer_id := -1
## Used in lieu of accounts to validate users (do not share!)
var session_id := PackedByteArray()
var is_connected := false

# TODO: Add multiplayer spawner nodes
