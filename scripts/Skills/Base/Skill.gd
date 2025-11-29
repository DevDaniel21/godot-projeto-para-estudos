extends Resource

class_name Skill

@export_category("Informação")
@export var name: String
@export var description: String
@export var cooldown : int
@export_flags("skill_right_click", "skill_space", "skill_e", "skill_shift") var tecla

func executar(_character):
	pass
