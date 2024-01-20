extends CharacterBody2D

@onready var main_char = $AnimatedSprite2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var can_move = true;

#Place character stats

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	if can_move :
		if (velocity.x > 1 || velocity.x < -1):
			main_char.animation = "running"
		else:
			main_char.animation = "default"
			
		# Add the gravity.
		if not is_on_floor():
			velocity.y += gravity * delta

		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var direction = Input.get_axis("left", "right")
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, 12)

		move_and_slide()
		
		var isLeft = velocity.x < 0
		main_char.flip_h = isLeft
	else:
		velocity.x = 0
		main_char.animation = "default"
