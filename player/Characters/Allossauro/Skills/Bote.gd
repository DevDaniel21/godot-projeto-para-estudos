extends SkillMovimento
class_name Bote

func executar(character, camera = null):
	print(character is CharacterBody3D)
	print("Nome: ", name)
	print("Descrição: ", description)
	print("Altura: ", velocity_y)
	print("Distância: ", velocity_x)

	# impulso vertical
	character.velocity.y += velocity_y

	# direção para frente da câmera
	var dir = -camera.global_basis.z
	dir.y = 0
	dir = dir.normalized()

	# impulso para frente
	character.velocity += dir * velocity_x
