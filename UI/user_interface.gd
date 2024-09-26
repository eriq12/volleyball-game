extends Control

@onready var label : Label = $Label

func on_update_scores(left_team_score:int, right_team_score:int):
	label.text = "%d - %d" % [left_team_score, right_team_score]
