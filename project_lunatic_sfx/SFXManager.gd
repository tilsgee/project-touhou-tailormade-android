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
	"player_death": preload("uid://kywepy3cov6q"),
	"enemy_death": preload("uid://b0kgjv3ex87nh"),
	"player_shoot": preload("uid://b0t276j08dod8"),
	"enemy_shoot": preload("uid://bmpg6ehqsso00"),
	"player_bomb": preload("uid://dooknh61q6cv"),

	# Crafting / work
	"cloth_make": preload("uid://c8p1y3cgo3xe0")
}
