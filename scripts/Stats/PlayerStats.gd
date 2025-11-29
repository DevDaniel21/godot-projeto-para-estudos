extends Resource
class_name PlayerStats

@export_group("Atributos")
@export var nickname : String
@export var title : String
@export var max_health : int
@export var health : int
@export var speed_base : float
@export var speed : float
@export var jump_height : float
@export var acceleration : int = 15
@export var can_run : bool
@export var can_jump : bool
@export var can_double_jump : bool

@export_group("Habilidades")
@export var habilidades : Array[Skill] = []

func scream(sound: String):
	print("O ", nickname, " gritou ", sound)

# @export_group("Habilidades")
# @export var habilidade_1 : int
