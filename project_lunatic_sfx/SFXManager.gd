# ==============================================
# File: SFXManager.gd
# System: Ravdot Custom 4.5 (2D-only Godot build)
# Purpose: Centralized sound effects manager
# ==============================================

extends Node

# ==============================================
# 🔊 PRELOAD YOUR SFX (replace UID with yours)
# ==============================================
var sfx := {
	# UI sounds
	"ui_select": preload("uid://replace_with_uid_ui_select"),
	"ui_accept": preload("uid://replace_with_uid_ui_accept"),
	"ui_cancel": preload("uid://replace_with_uid_ui_cancel"),

	# Gameplay sounds
	"item_picked": preload("uid://replace_with_uid_item_picked"),
	"money_cash": preload("uid://replace_with_uid_money_cash"),
	"customer_leave": preload("uid://replace_with_uid_customer_leave"), # “buwok” sfx

	# Ghost & haunting
	"ghost_haunt": preload("uid://replace_with_uid_ghost_haunt"),

	# Combat / character
	"player_death": preload("uid://replace_with_uid_player_death"),
	"enemy_death": preload("uid://replace_with_uid_enemy_death"),
	"player_shoot": preload("uid://replace_with_uid_player_shoot"),
	"enemy_shoot": preload("uid://replace_with_uid_enemy_shoot"),
	"player_bomb": preload("uid://replace_with_uid_player_bomb"),

	# Crafting / work
	"cloth_make": preload("uid://replace_with_uid_cloth_make")
}

# ==============================================
# 🎚️ PLAYER POOL SETUP
# ==============================================
var players: Array = []
const MAX_PLAYERS := 20

func _ready() -> void:
	for i in range(MAX_PLAYERS):
		var p := AudioStreamPlayer.new()
		add_child(p)
		players.append(p)

# ==============================================
# ▶️ PLAY SFX
# ==============================================
func play(name: String, volume_db: float = 0.0, pitch_scale: float = 1.0) -> void:
	if not sfx.has(name):
		push_warning("⚠️ SFX not found: %s" % name)
		return

	for p in players:
		if not p.playing:
			p.stream = sfx[name]
			p.volume_db = volume_db
			p.pitch_scale = pitch_scale
			p.play()
			return

	# If all players busy, recycle the first one
	var reuse := players[0]
	reuse.stop()
	reuse.stream = sfx[name]
	reuse.volume_db = volume_db
	reuse.pitch_scale = pitch_scale
	reuse.play()

# ==============================================
# ⏹️ STOP ALL
# ==============================================
func stop_all() -> void:
	for p in players:
		p.stop()
