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
	"ui_select": preload("uid://pqa1aimdmi71"),
	"ui_accept": preload("uid://dusm1p26bntke"),
	"ui_cancel": preload("uid://wtjh1jd1nwmd"),

	# Gameplay sounds
	"item_picked": preload("uid://bun7blg3wydfv"),
	"money_cash": preload("uid://cban4l5ojy35a"),
	"customer_leave": preload("uid://d3r5gxdjitn5q"), # “buwok” sfx

	# Ghost & haunting
	"ghost_haunt": preload("uid://xl1q50e1xttp"),

	# Combat / character
	"player_death": preload("uid://replace_with_uid_player_death"),
	"enemy_death": preload("uid://replace_with_uid_enemy_death"),
	"player_shoot": preload("uid://replace_with_uid_player_shoot"),
	"enemy_shoot": preload("uid://replace_with_uid_enemy_shoot"),
	"player_bomb": preload("uid://replace_with_uid_player_bomb"),

	# Crafting / work
	"cloth_make": preload("uid://c8p1y3cgo3xe0")
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
